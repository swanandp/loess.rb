# Loess

Simple Loess / Lowess interpolator built in Ruby, based on Apache's [`LoessInterpolator`][1].

## Installation

Add this line to your application's Gemfile:

    gem 'loess'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install loess

## Usage

```Ruby

regression = Loess::Calculator.calculate(data)
regression = Loess::Calculator.new(data).calculate

# Change your settings

calculator = Loess::Calculator.new(data)
calculator.bandwidth = 0.2
calculator.robustness_factor = 10 # Go crazy
calculator.calculate

# Pass in settings through initialize
calculator = Loess::Calculator.new(data, bandwidth: 0.2, accuracy: 1e-10)
calculator.calculate


```

## Contributing

1. Fork it ( https://github.com/swanandp/loess.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[1]: http://commons.apache.org/proper/commons-math/jacoco/org.apache.commons.math3.analysis.interpolation/LoessInterpolator.java.html