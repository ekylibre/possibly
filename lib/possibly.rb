require_relative 'maybe'
require_relative 'some'
require_relative 'none'

# rubocop:disable MethodName
def Maybe(value, parent_stack = [], inst_method = nil)
  inst_method ||= ["Maybe", []]
  if value.nil? || (value.is_a?(None))
    None(inst_method, parent_stack)
  else
    value = value.get if value.is_a? Some
    Some.new(value, inst_method, parent_stack)
  end
end

def Some(value, inst_method = nil, parent_stack = [])
  inst_method ||= ["Some", []]

  Maybe(value, inst_method, parent_stack)
end

def None(inst_method = nil, parent_stack = [])
  inst_method ||= ["None", []]
  None.new(inst_method, parent_stack)
end
# rubocop:enable MethodName
