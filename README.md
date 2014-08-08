# Loess

Simple Loess / Lowess interpolator built in Ruby, using Apache's [`LoessInterpolator`][1] through Rjb

## Installation

Add this line to your application's Gemfile:

    gem 'loess'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install loess

## Depencies

This gem depends on Rjb, which in turn depends on Java. [Rjb documentation][3] has more info.

## Usage

```Ruby

data = 1000.times.map { |i| [i, rand(10_000)] }

regression = Loess::Interpolator.interpolate(data)
regression = Loess::Interpolator.new(data).interpolate

# Change your settings

interpolator = Loess::Interpolator.new(data)
interpolator.bandwidth = 0.2
interpolator.robustness_factor = 10 # Go crazy
interpolator.interpolate

# Pass in settings through initialize
interpolator = Loess::Interpolator.new(data, bandwidth: 0.2, accuracy: 1e-10)
interpolator.interpolate

# Get a Spline Interpolator object
# Returns an instance of PolynomialSplineFunction, smoothed with the given data
# More documentation at [Apache Commons Maths][2]
interpolator.spline_interpolator

```

## Contributing

At this moment, there is little to contribute, but still:  

1. Fork it ( https://github.com/swanandp/loess.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[1]: http://commons.apache.org/proper/commons-math/jacoco/org.apache.commons.math3.analysis.interpolation/LoessInterpolator.java.html
[2]: http://commons.apache.org/proper/commons-math/jacoco/org.apache.commons.math3.analysis.polynomials/PolynomialSplineFunction.java.html
[3]: https://github.com/arton/rjb
