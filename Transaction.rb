require_relative('./TxClock')
require_relative(./StaleException)
class Transaction
  def initialize(cache, read_timestamp=TxClock.new((Time.now.to_f * 1000000).to_i), max_age =nil, no_cache=false)
    raise TypeError, 'Cache must be instance of Cache class' unless Cache.is_a?(Cache)
    raise TypeError, 'Read_Timestamp must be instance of TxClock' unless read_timestamp.is_a?(TxClock)
    raise TypeError, 'Max_age must be an instance of Integer' unless (max_age.nil? or max_age.is_a?(Integer))
    raise TypeError, 'No_cache must be a boolean ' unless [TrueClass, FalseClass].include?(no_cache.class)

    @max_age = max_age
    @no_cache = no_cache
    @read_timestamp = read_timestamp
    @cache = cache

    @min_rt = TxClock.MaxValue
    @max_vt = Tx.MinValue
    @view = Hash.new()

  end

  def read(table, key, max_age=nil, no_cache = false)
    max_age = [max_age, @max_age].compact.min
    no_cache = no_cache or @no_cache
    cache_result = @cache.read(@read_timestamp, table, key, max_age, no_cache)
    raise StaleException(read_timestamp, nil) unless not cache_result.nil?
    @view[[table,key]] = ["hold", nil]
    @min_rt = [@min_rt, cache_result.cached_time].min
    @max_vt = [@max_vt, cache_result.value_time].max
    raise StaleException(@min_rt, @max_vt) unless (@max_vt <= @min_rt)
    return cache_result.value
  end
  def write(table, key, value)
    cache_result = nil
    begin
      cache_result = read(table, key)
    rescue
    end
    @view[[table,key]] = [cache_result.nil? "create" : "update", value]
  end
  def delete(table, key)
    @view[[table,key]] = ["delete", nil]
  end
  def commit
    @cache.batch_write(@min_rt, @view)
  end

  private

  def _updateTimes(cached_time, value_time)
    @min_rt = [@min_rt, cached_time].min
    @max_vt = [@max_vt, value_time].max
    raise StaleException(@min_rt, @max_vt) unless (@max_vt <= @min_rt)
  end

end
