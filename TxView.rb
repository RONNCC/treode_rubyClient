
## Not used
class TxView
  attr_accessor :data
  def initialize(op_list = [])
    @data = op_list
  end
  def add_operation(table, key, operation, value)
    @data << [table, key, operation, value]
  end
end
