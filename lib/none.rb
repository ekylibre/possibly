# Represents an empty value
class None < Maybe

  class ValueExpectedException < Exception; end

  def initialize(inst_method = nil, parent_stack = [])
    @inst_method = inst_method || ["None.new", []]
    @parent_stack = parent_stack
  end

  def get
    msg ||= "`get` called to None. A value was expected."
    raise ValueExpectedException.new(print_error(msg))
  end

  def or_else(els = nil)
    block_given? ? yield : els
  end

  def catch(&block)
    block.call
    self
  end

  def recover(els = nil)
    Maybe(block_given? ? yield : els)
  end

  def or_raise(msg_or_exception = "`or_raise` called to None. A value was expected.", msg = nil, print_stack: true)
    exception_object =
      if msg_or_exception.respond_to? :exception
        if msg
          msg_or_exception.exception(msg)
        else
          msg_or_exception.exception
        end
      else
        ValueExpectedException.new(msg_or_exception)
      end

    exception_and_stack =
      if print_stack
        exception_object.exception(print_error(exception_object.message))
      else
        exception_object
      end

    raise exception_and_stack
  end

  def method_missing(method_sym, *args, &block)
    None([method_sym, args, block], self.stack)
  end

  def respond_to_missing?(_name, _all)
    true
  end

  def to_s
    "None"
  end

  def fmap
    None()
  end

  def is_none?
    true
  end

  def cata(some:, none:)
    none.call
  end

  private

    def extract_opts(args)
      *initial, last = *args

      if last.is_a?(::Hash)
        [last, initial]
      else
        [{}, args]
      end
    end
end
