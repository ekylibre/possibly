# Represents a non-empty value
class Some < Maybe
  def initialize(value, inst_method = nil, parent_stack = [])
    @value = value
    @inst_method = inst_method || ["Some.new", []]
    @parent_stack = parent_stack
  end

  def get
    @value
  end

  def or_else(*)
    @value
  end

  def or_raise(*)
    @value
  end

  def or_nil
    @value
  end

  def is_some?
    true
  end

  def is_none?
    false
  end

  def ==(other)
    super && get == other.get
  end

  alias_method :eql?, :==

  def ===(other)
    other && other.class == self.class && @value === other.get
  end

  def method_missing(method_sym, *args, &block)
    Maybe(@value.send(method_sym, *args, &block))
  end

  def respond_to_missing?(name, include_all)
    @value.respond_to?(name, include_all) || super
  end

  def to_s
    "Some(#{@value})"
  end

  def map &block
    Maybe(block.call @value)
  end

  def to_a
    [@value]
  end
end