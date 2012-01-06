
# http://sqlite-ruby.rubyforge.org/sqlite3/faq.html
require 'sqlite3'

class Table
  attr_accessor :name
  
  def self.with_db(&block)
    db = SQLite3::Database.new("./table.db")
    yield db if block_given?
    db.close  
  end

  def self.query q, new_table_name=nil
    if new_table_name
      val = []
      Table.with_db {|db| val = db.execute2(q) }
      Table.new val.shift, val, new_table_name
    else 
      Table.with_db {|db| return db.execute(q) }
    end
  end  
  
  # new
  def initialize header, data, name
    @table = name

    # sql to create new table
    sql = "create table #{@table} ("
    header.each_with_index do |h, i|

      # iterates each row, looking for a non empty value
      val = ""
      data.each do |row| 
        if row[i] != nil and row[i] != ""
          val = row[i]
          break
        end
      end
      
      if val.class == Fixnum or val.class == Float
        sql << "#{h} NUMERIC,"
      else 
        sql << "#{h} TEXT,"
      end
    end
    sql << ");"

    Table.with_db do |db|
      db.execute( "drop table if exists #{@table};" ) # remove if exists
      db.execute(sql.gsub(",);", ");"))               # create new table  
      data.each do |row|                              # insert data
        db.execute( "insert into #{@table} values ( '#{row.join("','")}' );" )        
      end
    end
  end

  # column  
  def method_missing(m, *args, &block) 
    Table.with_db do |db|
      return db.execute( "select #{m} from #{@table}" ).flatten
    end
  end

  # add  
  def add col, data
    Table.with_db do |db|
      if data[0].class == Fixnum or data[0].class == Float
        db.execute( "alter table #{@table} add #{col} NUMERIC;" )
      else
        db.execute( "alter table #{@table} add #{col} TEXT;" )
      end
      
      # add specified value to each row
      data.each_with_index do |val, i|
        db.execute( "update #{@table} set #{col} = '#{val}' where ROWID = #{i+1};" )
      end
    end
  end
  
  # How to clean old ones ?
  # list all existing
  def list
    Table.with_db do |db|
      return @db
        .execute("select name from sqlite_master where type='table' ORDER BY name;")
        .flatten    
    end
  end
end

if __FILE__ == $0

  require "test/unit"
  class TestTable < Test::Unit::TestCase
    
    def setup
      require 'fileutils'
      File.delete "./table.db" if File.exists? "./table.db"
    end    
    
    def test_insert
      Table.new ["id", "v1", "v2"], [[1, 23, "a"], [2, 34, "b"]], "test"
      assert_equal [[23.0, "a"], [34.0, "b"]], Table.query("select v1,v2 from test")
    end
    
    def test_method_missing
      tbl = Table.new ["id", "col1", "col2"], [[1, 23, "a"], [2, 34, "b"]], "test"
      assert_equal [23.0, 34.0], tbl.col1
    end
    
    def test_add
      tbl = Table.new ["id", "col1"], [[1, 23], [2, 34]], "test"
      tbl.add("col2", tbl.col1.map{|v|v+1} ) # v1+=1 as v2
      assert_equal [24.0, 35.0], tbl.col2
      tbl.add("col3", ["random", "stuff"])
      assert_equal ["random", "stuff"], tbl.col3
    end
   
    def test_join
      Table.new ["id", "v1", "v2"], [[1, 23, "a"], [2, 34, "b"]], "tbl1"
      Table.new ["id", "v3", "v4"], [[1, 24, "c"], [2, 36, "d"]], "tbl2"
      sql = "select tbl1.id,v1,v4 from tbl1 join tbl2 on tbl1.id = tbl2.id"
      assert_equal [[1, 23, "c"], [2, 34, "d"]], Table.query(sql)
    end
    
    def test_alias
      Table.new ["g", "v"], [["a",11], ["a",9], ["b",2], ["b",2]], "tbl"
      tbl2 = Table.query("select g, sum(v) as value from tbl group by g", "tbl2")
      assert_equal ["a", "b"], tbl2.g
      assert_equal [20.0, 4.0], tbl2.value
    end
    
    def test_join_with_new_table
      Table.new ["id", "v1", "v2"], [[1, 11, "a"], [2, 12, "b"]], "tbl1"
      Table.new ["id", "v3", "v4"], [[1, 21, "c"], [2, 22, "d"]], "tbl2"
      sql = "select tbl1.id,v1,v4 from tbl1 join tbl2 on tbl1.id = tbl2.id"
      Table.query(sql, "tbl3")
      assert_equal [[1, 11, "c"], [2, 12, "d"]], Table.query("select * from tbl3")
    end
    
    def test_ad_hoc
      Table.new ["id", "v1", "v2"], [[1, 23, "a"], [2, 34, "b"]], "test"
      val = nil
      Table.with_db {|db| val = db.execute("select v1 from test limit 1") }
      assert_equal [23.0], val.flatten
    end
    
    def test_date
      Table.new ["ts", "v"], [[Date.today, 23], [Date.today+10, 34]], "test"
      sql = "select v from test where ts < '#{Date.today+2}'"
      assert_equal [23.0], Table.query(sql).flatten
    end
    
    def test_time
      Table.new ["ts", "v"], [[Time.now, 10], [Time.now+10, 20]], "test"
      sql = "select v from test where ts < '#{Time.now+2}'"
      assert_equal [10.0], Table.query(sql).flatten
    end
    
  end
end