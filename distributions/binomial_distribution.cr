require "distributions/probability_distribution"
# This class provides an object for encapsulating binomial distributions
# Ported to Ruby from PHPMath class by Bryan Donovan
# Author:: Mark Hale
# Author:: Paul Meagher
# Author:: Bryan Donovan (http://www.bryandonovan.com)
module Crystalstats
  class BinomialDistribution < Crystalstats::ProbabilityDistribution 
    include Crystalstats::NumericalConstants
    include Crystalstats::SpecialMath
    include Crystalstats::ExtraMath
    include Crystalstats::MakeDiscrete

    getter p : Float64 | Int32, n : Float64 | Int32
    setter p : Float64 | Int32, n : Float64 | Int32

    # Constructs a binomial distribution
    def initialize (trials, prob)
      if trials <= 0
        raise ArgumentError.new("Error: trials must be greater than 0")
      end
      @n = trials.to_i
      if prob < 0.0 || prob > 1.0
        raise ArgumentError.new("prob must be between 0 and 1")
      end
      @p = prob.to_f
    end

    #returns the number of trials
    def get_trials_parameter
      @n
    end

    #returns the probability
    def get_probability_parameter
      @p
    end

    #returns the mean
    def get_mean
      @n * @p
    end

    #returns the variance
    def get_variance
      @n * @p * (1.0 - @p)
    end

    # Private methods below

    # Probability density function of a binomial distribution (equivalent
    # to R dbinom function).
    # _x should be an integer
    # returns the probability that a stochastic variable x has the value _x,
    # i.e. P(x = _x)
    private def get_pdf(x)
      check_range(x, 0, @n)
      binomial(@n, x) * @p**x * (1-@p)**(@n-x)
    end

    # Private shared function for getting cumulant for particular x
    # param _x should be integer-valued
    # returns the probability that a stochastic variable x is less than _x
    # i.e P(x < _x)
    private def get_cdf(_x)
      check_range(_x, 0.0, @n)
      sum = 0.0
      (0.._x).each do |i| 
        sum = sum + pdf(i).as(Float64)
      end
      sum
    end

    # Inverse of the cumulative binomial distribution function     
    # returns the value X for which P(x < _x).
    private def get_icdf(prob)
      check_range(prob)
      sum = 0.0
      k = 0
      until prob <= sum 
        sum += get_pdf(k)
        k += 1
      end 
      k - 1
    end

    # Private binomial RNG function    
    # Variation of Luc Devroye's "Second Waiting Time Method" 
    # on page 522 of his text "Non-Uniform Random Variate Generation."
    # There are faster methods based on acceptance/rejection techniques, 
    # but they are substantially more complex to implement.
    private def get_rng
      p = (@p <= 0.5) ? @p : (1.0 - @p)        
      log_q = Math.log(1.0 - p)
      sum = 0.0
      k = 0.0
      loop do
        sum += Math.log(rand) / (@n - k)
        if (sum < log_q)
          return (p != @p) ? [(@n - k)] : [k]          
        end
        k += 1
      end
    end
  
  end
end
