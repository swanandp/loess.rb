# -*- encoding : utf-8 -*-

# A Ruby Port of Apache's LoessInterpolator
# http://commons.apache.org/proper/commons-math/jacoco/org.apache.commons.math3.analysis.interpolation/LoessInterpolator.java.html
#
module Loess
  class Calculator
    attr_accessor :data, :bandwidth, :robustness_factor, :accuracy
    # Sane Defaults as per Apache
    DEFAULT_ACCURACY          = 1e-12
    DEFAULT_BANDWIDTH         = 0.3 # A sensible value is usually 0.25 to 0.5
    DEFAULT_ROBUSTNESS_FACTOR = 2 # number of iterations to refine over 1 or 2 is usually good enough

    # data: Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    # For options, refer to defaults above
    def initialize(data = [], options = {})
      @xval, @yval           = split_up(data)
      self.accuracy          = options[:accuracy] || DEFAULT_ACCURACY
      self.bandwidth         = options[:bandwidth] || DEFAULT_BANDWIDTH
      self.robustness_factor = options[:robustness_factor] || DEFAULT_ROBUSTNESS_FACTOR
    end

    # Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    def calculate(data = nil)
      @xval, @yval = split_up(data) if data
      smooth(@xval, @yval)
    end

    def smooth(xval, yval, weights = [])
      xlength = xval.length
      return unless xlength > 0 && xlength == yval.length
      return yval if xlength == 1 || xlength == 2
      bandwidth_in_points = (bandwidth * xlength).to_i
      fail "bandwidth is way too small" if bandwidth_in_points < 2
      weights = weights.present? ? weights : [1.0] * xlength

      result             = []
      residuals          = []
      robustness_weights = [1] * xlength

      robustness_factor.times do |factor|
        xval.each_with_index do |x, i|
          bandwidth_interval = [0, bandwidth_in_points - 1]
          update_bandwidth_interval(xval, weights, i, bandwidth_interval) if i > 0
          ileft, iright = bandwidth_interval
          edge          = if xval[i] - xval[ileft] > xval[iright] - xval[i]
                            ileft
                          else
                            iright
                          end

          sum_weights   = 0
          sum_x         = 0
          sum_x_squared = 0
          sum_y         = 0
          sum_xy        = 0
          denom         = (1.0 / (xval[edge] - x)).abs

          xval[ileft..iright].each_with_index do |xk, k|
            next unless xk
            yk            = yval[k]
            dist          = (k < i) ? x - xk : xk - x
            w             = tricube(dist * denom) * robustness_weights[k] * weights[k]
            xkw           = xk * w

            # Intentionally avoiding multiple reduce calls here
            # On large data-sets, this severly impacts performance
            sum_weights   += w
            sum_x         += xkw
            sum_x_squared += xk * xkw
            sum_y         += yk * w
            sum_xy        += yk * xkw
          end

          mean_x         = sum_x / sum_weights
          mean_y         = sum_y / sum_weights
          mean_xy        = sum_xy / sum_weights
          mean_x_squared = sum_x_squared / sum_weights

          beta = if Math.sqrt((mean_x_squared - mean_x * mean_x).abs) < accuracy
                   0
                 else
                   (mean_xy - mean_x * mean_y) / (mean_x_squared - mean_x * mean_x)
                 end

          alpha        = mean_y - beta * mean_x
          result[i]    = beta * x + alpha
          residuals[i] = (yval[i] - result[i]).abs
        end

        break if factor == robustness_factor - 1

        sorted_residuals = residuals.sort
        median_residual  = sorted_residuals[xlength / 2]

        break if median_residual.abs < accuracy

        xlength.times do |i|
          arg = residuals[i] / (6 * median_residual)
          if arg >= 1
            robustness_weights[i] = 0
          else
            robustness_weights[i] = (1 - arg * arg) ** 2
          end
        end
      end
      result
    end

    # http://en.wikipedia.org/wiki/Local_regression#Weight_function
    def tricube(x)
      (1 - x.abs ** 3) ** 3
    end

    def update_bandwidth_interval(xval, weights, i, bandwith_interval)
      left, right = bandwith_interval
      next_right  = next_non_zero(weights, right)
      if next_right < xval.length &&
          xval[next_right] - xval[i] < xval[i] - xval[left]
        next_left            = next_non_zero(weights, left)
        bandwith_interval[0] = next_left
        bandwith_interval[1] = next_right
      end
    end

    def next_non_zero(collection, index)
      collection.each_with_index.detect { |el, i|
        i > index && !el.zero?
      }[1]
    end

    # Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    def self.calculate(data)
      new(data).calculate
    end

    private
    # Given this: [ [1, 2], [3, 4], [5, 6], ['a', 'b'] ]
    # Return this: [ [1, 3, 5, 'a'], [2, 4, 6, 'b'] ]
    def split_up(data)
      data.reduce([[], []]) { |memo, (x, y)|
        memo[0] << x
        memo[1] << y
        memo
      }
    end
  end
end
