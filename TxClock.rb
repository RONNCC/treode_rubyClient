class TxClock
    attr_accessor :time
    def initialize(time)
        if not time.is_a?(Integer)
            # we use integer because it max be a FixNum or a BigNum
            raise TypeError, 'Needs the time to be an integer!'
        end
        @time = time
    end
end