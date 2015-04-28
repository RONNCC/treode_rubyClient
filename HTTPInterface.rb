require 'net/http'

class HTTPInterface
  #parser and maker

  def initialize(server, port)
    @server = server
    @port = port
  end


  # parse the codes from the return values
  # and do some validation and type conversion
  def parseHTTP(http_obj)
    status_codes = ["200", "304", "305", "404", "412"] # 304 and 305 seem to both be Not Modified Status Codes
    raise TypeError, 'Return Body must have a valid status Code' unless status_codes.include?(http_obj.code)
    raise TypeError, 'Return Body must have a Date' unless http_obj.has_key?('Date')
    raise TypeError, 'Return Body must have a Last-Modified' unless http_obj.has_key?('Last-Modified')
    raise TypeError, 'Return Body must have a Value-TxClock' unless http_obj.has_key?('Value-TxClock')
    parsed_object = return_body.to_hash
    #convert fields to the correct datatypes
    if parsed_object.has_key?('Read-TxClock')
      parsed_object['Read-TxClock'] = parsed_object['Read-TxClock'].to_i
    end
    parsed_object['Value-TxClock'] = parsed_object['Value-TxClock'].to_i
    parsed_object.code = parsed_object.code.to_i
    [parsed_object['Read-TxClock'], parsed_object['Value-TxClock'], parsed_object.body]
  end


  def read(read_time,table,key, max_age=nil, no_cache=false)
    GET_Request(read_time, table,key ,max_age, no_cache)
  end
  
  def write(condition_time, tx_view)
    PUT_Request(condition_time, tx_view)
  end


  def GET_Request(read_time, table, key, max_age = nil, no_cache = false, unmodified_since = nil, transaction_id = nil, condition_txclock=nil)
    params = Hash.new
    params['Cache-Control:'] =  "max-age:#{max_age if max_age}, #{'no-cache' if no_cache}"
    params['Content-Type'] =  'text/json'
    
    if not unmodified_since.nil?
      params['If-Unmodified-Since']= unmodified_since.strftime("%a, %e %B %Y %H:%M:%S  %Z")
    end

    if not transaction_id.nil?
      params['Transaction:'] = "id=#{transaction_id}"
    end

    if not condition_txclock.nil?
      params['Condition-TxClock'] = condition_txclock.to_str
    end
    #returns the request object on success, nil on failure
    uri = URI(@server+table+"/"+key)
    url.query = URI.encode_www_form(params)
    raise TypeError, "Params must contain a Read-TxClock field" unless params.has_key?('Read-TxClock')
    res = Net::HTTP.get_response(uri, path, port)
    return parseHTTP(res) if res.is_a?(Net::HTTPSuccess) else raise IOError, "Could not connect to network when submitting GET request"
  end


  def PUT_Request(path, json_body, max_age = nil, no_cache = false, unmodified_since = nil, transaction_id = nil, condition_txclock=nil)
    params = Hash.new
    params['Cache-Control:'] =  "max-age:#{max_age if max_age}, #{'no-cache' if no_cache}"
    params['Content-Type'] =  'text/json'
    if not unmodified_since.nil?
      params['If-Unmodified-Since']= unmodified_since.strftime("%a, %e %B %Y %H:%M:%S  %Z")
    end

    if not transaction_id.nil?
      params['Transaction:'] = "id=#{transaction_id}"
    end

    if not condition_txclock.nil?
      params['Condition-TxClock'] = condition_txclock.to_str
    end
    
    uri = URI(@server+table+"/"+key)
    url.query = URI.encode_www_form(params)
    req = Net::HTTP::Put.new(uri)
    req.body = json_body
    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
    
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      return parseHTTP(res)
    else
      raise IOError, "Could not connect to network when submitting PUT request"
    end
  
  end


end
