class TxClock
  include Comparable

  attr_accessor :time
  @@MinValue = 0
  @@MaxValue = 2**64 - 1 # artificial limit - it's unbounded
  def initialize(time)
    if not time.is_a?(Integer)
      # we use integer because it max be a FixNum or a BigNum
      raise TypeError, 'Needs the time to be an integer!'
    end
    @time = time
  end

  def to_str
    return time
  end

  def <=>(otherTxClock)
    time <=> otherTxClock.time
  end
end
