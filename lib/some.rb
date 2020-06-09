# Represents a non-empty value
class Some < Maybe
  def initialize(value, inst_method = nil, parent_stack = [])
    @value = value
    @inst_method = inst_method || ["Some.new", []]
    @parent_stack = parent_stack
  end

  def get(*)
    @value
  end

  alias_method :or_else, :get
  alias_method :or_raise, :get

  def catch(*)
    self
  end

  alias_method :recover, :catch

  def is_some?
    true
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

  def to_s
    "Some(#{@value})"
  end

  def fmap(&block)
    Maybe(block.call @value)
  end

  def cata(some:, none:)
    some.call(@value)
  end

  private

    def respond_to_missing?(name, include_all)
      @value.respond_to?(name, include_all) || super
    end


end