
# http://derrick.pallas.us/ruby-stats/

class Numeric
  def square ; self * self ; end

  def relative_change y
    (y.to_f - self)/self * 100.0
  end

  def absolute_change y
    (y.to_f / self)
  end
end


module Enumerable

  def histogram
    self.sort.inject({}) { |h, x| h[x] += 1; h}
  end
  
  def absolute_change
    idx = self.first
    self.collect { |v|
      (v.to_f/idx)*100
    }
  end

  def relative_change
    idx = self.first
    self.collect { |v|
      ((v.to_f-idx)/idx)*100
    }
  end

  def sum
    return self.inject(0){|acc,i| acc + i}
  end
 
  def mean
    return self.sum/self.length.to_f
  end

  def median
    case self.size % 2
      when 0 then self.sort[self.size/2-1,2].mean
      when 1 then self.sort[self.size/2].to_f
    end if self.size > 0
  end

  def mode
    map = self.histogram
    max = map.values.max
    map.keys.select{|x|map[x]==max}
  end

  def squares ; self.inject(0){|a,x|x.square+a} ; end

  # variance of sample
  def variance
    avg=self.mean
    sum=self.inject(0){|acc,i| acc + (i-avg)**2 }
    return(1/(self.length.to_f-1)*sum)
  end

  # standard deviation
  def sd
    return Math.sqrt(self.variance)
  end

  # assume full population
  def variance_population
    # for example of a dice
    avg=self.mean
    sum=self.inject(0){|acc,i| acc + (i-avg)**2 }
    return(1/self.length.to_f*sum)
  end

  # assume full population
  def sd_population
    # for example of a dice
    return Math.sqrt(self.variance_population)
  end

  def permute ; self.dup.permute! ; end

  def permute!
    (1...self.size).each do |i| ; j=rand(i+1)
      self[i],self[j] = self[j],self[i] if i!=j
    end;self
  end
  
  def sample n=1 
    (0...n).collect{ self[rand(self.size)] } ; 
  end

end

if __FILE__ == $0
  require "test/unit"
  class TestAlenum < Test::Unit::TestCase 
    def test_relative_change
      assert_equal [100.0,200.0,50.0,400.0,500.0,600.0,700.0,800.0,900.0], 
                   [1,2,0.5,4,5,6,7,8,9].absolute_change
      
      assert_equal [100.0,186.95652173913044,21.73913043478261], 
                   [2.3,4.3,0.5].absolute_change
    end

    def test_sum
      assert_equal 42.5, [1,2,0.5,4,5,6,7,8,9].sum
      assert_equal    6, [1,2,3].sum
    end

    def test_mean
      assert_equal 4.722222222222222, [1,2,0.5,4,5,6,7,8,9].mean
      assert_equal 3.5,               [1,2,3,4,5,6].mean
    end

    def test_variance
      assert_equal 9.444444444444445, [1,2,0.5,4,5,6,7,8,9].variance
      assert_equal 3.5,               [1,2,3,4,5,6].variance
    end
    
    def test_sd
      assert_equal 3.073181485764296,  [1,2,0.5,4,5,6,7,8,9].sd
      assert_equal 1.8708286933869707, [1,2,3,4,5,6].sd
    end

    def test_variance_real
      assert_equal 8.395061728395062,  [1,2,0.5,4,5,6,7,8,9].variance_population
      assert_equal 2.9166666666666665, [1,2,3,4,5,6].variance_population
    end
    def test_sd_real
      assert_equal 2.8974232912011773, [1,2,0.5,4,5,6,7,8,9].sd_population
      assert_equal 1.707825127659933,  [1,2,3,4,5,6].sd_population
    end

    def test_frequency
      assert_equal({1=>1, 2=>3, 3=>1, 4=>1}, [1,2,2,3,2,4].frequency)
    end

  end
end

## Based on example 18-6 from Resampling: The New Statistcs, given the weights of pigs in groups given different feed, what is the likelyhood that the differences in each group's mean weight is due to chance?
#  #!/usr/bin/ruby
#  require 'stats'
#  A=%w{34 29 26 32 35 38 31 34 30 29 32 31}.collect{|x|x.to_i}
#  B=%w{26 24 28 29 30 29 32 26 31 29 32 28}.collect{|x|x.to_i}
#  C=%w{30 30 32 31 29 27 25 30 31 32 34 33}.collect{|x|x.to_i}
#  D=%w{32 25 31 26 32 27 28 29 29 28 23 25}.collect{|x|x.to_i}
#
#  U = A + B + C + D
#  e = [ A.mean, B.mean, C.mean, D.mean ].variance
#  n = 4000
#  t = \
#  (0...n).inject(0) do |a,x|
#    ([ U.permute![0...A.size].mean,
#       U.permute![0...B.size].mean,
#       U.permute![0...C.size].mean,
#       U.permute![0...D.size].mean,
#    ].variance>=e) ? a+1 : a
#  end
#  puts t.to_f / n

