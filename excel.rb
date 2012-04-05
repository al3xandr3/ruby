
module Excel
  require 'win32ole'
  extend self

  # Excel.export "book1.xlsl"
  def export to_open, to_save, sheet
    xl = WIN32OLE.new("Excel.Application")
    wb = xl.Workbooks.Open(to_open)
    wb.RefreshAll()
    wb.saved = true
    wb.Save()
    case
    when to_save.contains?("html")
      wb.SaveAs(to_save, 44)
    when to_save.contains?("pdf")
      wb.SaveAs(to_save, 57)
    end 
    xl.Quit
  end
end

if __FILE__ == $0
  if ARGV[0] == "export"
    Excel.export ARGV[1], ARGV[2]
  end
end

# How to:
# Create mew excel 
# import text file into raw sheet
# configure data connection to update without asking file
# +update on startup, for example
# build calculated new sheet, ready to export

# http://rubyonwindows.blogspot.com/