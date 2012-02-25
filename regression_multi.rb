  
# http://rosettacode.org/wiki/Multiple_regression#Ruby  
# http://al3xandr3.github.com/2011/03/18/ml-ex51.html

# Modify class Matrix, to be able to set elements
require 'matrix'
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

module Regression

  class Multi
    attr_accessor :parameters
    def initialize y, x, l=0      
      # output
      y = Matrix.columns([y])
      # data
      x = Matrix.columns(x)

      # regularization
      d = Matrix.I(x.column_size)
      d[0,0] = 0

      @parameters = (x.t * x + (l * d)).inverse * x.t * y
    end
  end
end

#Add to Array 
class Array
  def regression_multi(x=nil, l=0)
    Regression::Multi.new(self, x, l).parameters.to_a
  end
end

if __FILE__ == $0
  require "test/unit"

  class MultiLinearRegressionTest < Test::Unit::TestCase 
    def test_1var
      x = [[2, 1, 3, 4, 5]]
      y = [1, 2, 3, 4, 5]
      assert_equal([[0.9818181818181818]], 
                   y.regression_multi(x))
    end  

    def test_2var
      x = [[2, 1, 3, 4, 5], 
           [1, 2, 5, 2, 3.0]]
      y = [1, 2, 3, 4, 5]
      assert_equal([[0.8585690515806985], 
                    [0.16139767054908483]], 
                   y.regression_multi(x))
    end

    def test_multi
      m = []
      # for each example
      [-0.99768,-0.69574,-0.40373,-0.10236,0.22024,0.47742,0.82229].each do |x|
        # apply full formula
        m << [1, x, x*x, x*x*x, x*x*x*x, x*x*x*x*x]
      end
      x = m.transpose # column=example, row=variable
      y = [2.0885, 1.1646, 0.3287, 0.46013, 0.44808, 0.10013, -0.32952]
      assert_equal([[0.4725287728743337],
                    [0.6813528948566963],
                    [-1.3801284186123346],
                    [-5.977687467469287],
                    [2.4417326847932648],
                    [4.737114334830853]],
                   y.regression_multi(x))
    end

    def test_multi_lambda
      m = []
      # for each example
      [-0.99768,-0.69574,-0.40373,-0.10236,0.22024,0.47742,0.82229].each do |x|
        # apply full formula
        m << [1, x, x*x, x*x*x, x*x*x*x, x*x*x*x*x]
      end
      x = m.transpose # column=example, row=variable
      y = [2.0885, 1.1646, 0.3287, 0.46013, 0.44808, 0.10013, -0.32952]
      assert_equal([[0.3975952991754666],
                    [-0.4206663713768963],
                    [0.12959211198019321],
                    [-0.39747389939143307],
                    [0.17525552670873984],
                    [-0.3393877173623372]], 
                   y.regression_multi(x, 1))
    end  

  end
end
