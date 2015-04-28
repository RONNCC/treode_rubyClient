
## Not used
class TxView
  attr_accessor :data
  def initialize(op_list = [])
    @data = op_list
  end
  def add_operation(table, key, operation, value)
    raise TypeError, 'Operation is not a valid operation' unless ['create','hold','update','delete'].include?(operation)
    @data << [table, key, operation, value]
  end
  
end
