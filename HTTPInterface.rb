require 'net/http'

class HTTPInterface
  #parser and maker

  def initialize(url, port)
    @url = url
    @port = port
  end


  def parseHTTP(HTTP_Obj)
    status_codes = ["200", "304", "305", "404", "412"] # 304 and 305 seem to both be Not Modified Status Codes
    raise TypeError, 'Return Body must have a valid status Code', unless status_codes.include?(HTTP_Obj.code)
    raise TypeError, 'Return Body must have a Date' unless HTTP_Obj.has_key?('Date')
    raise TypeError, 'Return Body must have a Last-Modified' unless HTTP_Obj.has_key?('Last-Modified')
    raise TypeError, 'Return Body must have a Value-TxClock' unless HTTP_Obj.has_key?('Value-TxClock')
    parsed_object = return_body.to_hash
    #convert fields to the correct datatypes
    if parsed_object.has_key?('Read-TxClock')
      parsed_object['Read-TxClock'] = parsed_object['Read-TxClock'].to_i
    end
    parsed_object['Value-TxClock'] = parsed_object['Value-TxClock'].to_i
    parsed_object.code = parsed_object.code.to_i
    return parsed_object
  end

  def GET_Request(path, params)
    #returns the request object on success, nil on failure
    uri = URI(@url)
    url.query = URI.encode_www_form(params)
    raise TypeError, "Params must contain a Read-TxClock field" unless params.has_key?('Read-TxClock')
    res = Net::HTTP.get_response(uri, path, port)
    return parseHTTP(res) if res.is_a?(Net::HTTPSuccess)
  end


  def PUT_Request(path,params, json_body)
    uri = URI(@url)
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
