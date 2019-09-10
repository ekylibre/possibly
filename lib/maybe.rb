class Maybe
  def ==(other)
    other.class == self.class
  end

  alias_method :eql?, :==

  def inspect
    to_s
  end

  def is_some?
    false
  end

  def is_none?
    false
  end

  def or_nil
    or_else nil
  end

  protected

    def print_error(msg)
      message =
        if msg
          msg + "\n\n"
        else
          "\n"
        end

      message + print_stack + "\n"
    end

    def print_stack
      longest_method = stack.drop(1).map { |inv| inv.first }.map(&:length).max || 0
      stack.map { |(method, value)|
        method ||= ""
        "#{method.ljust(longest_method)} => #{value}"
      }.join("\n")
    end

    def stack
      @parent_stack + [self_stack]
    end

    def self_stack
      [inst_method, self.inspect]
    end

    def inst_method
      "#{print_method(@inst_method)}"
    end

    def print_method(invocation)
      method, args, block = invocation

      print_method =
        if method == :[]
          args.to_s
        else
          method.to_s
        end

      print_args =
        if method == :[]
          nil
        elsif args.empty?
          nil
        else
          "(#{args.join(', ')})"
        end

      [print_method, print_args].compact.join("")
    end

end
