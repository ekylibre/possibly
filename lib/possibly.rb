require_relative 'maybe'
require_relative 'some'
require_relative 'none'

def Maybe(value, parent_stack = [], inst_method = nil)
  inst_method ||= ["Maybe", []]
  if value.nil? || (value.respond_to?(:length) && value.length == 0)
    None(inst_method, parent_stack)
  else
    Some(value, inst_method, parent_stack)
  end
end

def Some(value, inst_method = nil, parent_stack = [])
  inst_method ||= ["Some", []]
  return None.new inst_method, parent_stack if value.nil?
  Some.new(value, inst_method, parent_stack)
end

def None(inst_method = nil, parent_stack = [])
  inst_method ||= ["None", []]
  None.new(inst_method, parent_stack)
end
# rubocop:enable MethodName
