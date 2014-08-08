# -*- encoding : utf-8 -*-
require 'rjb'
Rjb::add_jar(File.join(File.expand_path('../../', __FILE__), 'vendor', 'apache', 'commons-math3-3.3.jar').to_s)

module Loess
  class Interpolator
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
      self.accuracy          = Float(options[:accuracy] || DEFAULT_ACCURACY)
      self.bandwidth         = Float(options[:bandwidth] || DEFAULT_BANDWIDTH)
      self.robustness_factor = Integer(options[:robustness_factor] || DEFAULT_ROBUSTNESS_FACTOR)
      @klass                 = Rjb::import('org.apache.commons.math3.analysis.interpolation.LoessInterpolator')
      @interpolator          = @klass.new(bandwidth, robustness_factor, accuracy)
    end

    # Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    def interpolate(data = nil)
      @xval, @yval = split_up(data) if data
      @interpolator.smooth(@xval, @yval)
    end

    # Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    def spline_interpolator(data = nil)
      @xval, @yval = split_up(data) if data
      @interpolator.interpolator(@xval, smooth(@xval, @yval))
    end

    # Accepts array of [x, y] pairs
    # e.g. [ [1, 2], [3, 4], [5, 6], [0, 42] ]
    def self.interpolate(data, options = {})
      new(data, options).interpolate
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
