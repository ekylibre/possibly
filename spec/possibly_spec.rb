require 'possibly'

describe "possibly" do

  describe "values and non-values" do
    it "None" do
      expect(Maybe(nil).is_none?).to eql(true)
      expect(Maybe(nil).fmap { raise "Should not be executed" }.is_none?).to eql(true)
    end

    it "Some" do
      expect(Maybe(0).is_some?).to eql(true)
      expect(Maybe(false).is_some?).to eql(true)
      expect(Maybe([1]).is_some?).to eql(true)
      expect(Maybe(" ").is_some?).to eql(true)
      expect(Maybe([]).is_some?).to eql(true)
      expect(Maybe("").is_some?).to eql(true)
      expect(Maybe(" ").fmap { "value" }.is_some?).to eql(true)
      expect(Maybe(" ").fmap { "value" }.get).to eql("value")
      expect(Maybe([1]).map! { |i| i + 1 }.get).to eql([2])
    end
  end

  describe "is_a" do
    it "Some" do
      expect(Some(1).is_a?(Some)).to eql(true)
      expect(Some(1).is_a?(None)).to eql(false)
      expect(None().is_a?(Some)).to eql(false)
      expect(None().is_a?(None)).to eql(true)
      expect(Some(1).is_a?(Maybe)).to eql(true)
      expect(None().is_a?(Maybe)).to eql(true)
    end
  end

  describe "equality" do
    it "#eql?" do
      expect(Maybe(nil).eql? Maybe(nil)).to be true
      expect(Maybe(nil).eql? Maybe(5)).to be false
      expect(Maybe(5).eql? Maybe(5)).to be true
      expect(Maybe(3).eql? Maybe(5)).to be false
    end
  end

  describe "case equality" do
    it "#===" do
      expect(Some(1) === Some(1)).to be true
      expect(Maybe(1) === Some(2)).to be false
      expect(Some(1) === None).to be false
      expect(None === Some(1)).to be false
      expect(None === None()).to be true
      expect(Some((1..3)) === Some(2)).to be true
      expect(Some(Integer) === Some(2)).to be true
      expect(Maybe === Some(2)).to be true
      expect(Maybe === None()).to be true
      expect(Some === Some(6)).to be true
    end
  end

  describe "case expression" do
    def test_case_when(case_value, match_value, non_match_value)
      value = case case_value
                when non_match_value
                  false
                when match_value
                  true
                else
                  false
              end

      expect(value).to be true
    end

    it "matches Some" do
      test_case_when(Maybe(1), Some, None)
    end

    it "matches None" do
      test_case_when(Maybe(nil), None, Some)
    end

    it "matches to integer value" do
      test_case_when(Maybe(1), Some(1), Some(2))
    end

    it "matches to range" do
      test_case_when(Maybe(1), Some((0..2)), Some((2..3)))
    end

    it "matches to lambda" do
      even = ->(a) { a % 2 == 0 }
      odd = ->(a) { a % 2 == 1 }
      test_case_when(Maybe(2), Some(even), Some(odd))
    end
  end

  describe "get and or_else" do
    it "get" do
      message = [
        "`get` called to None. A value was expected.",
        "",
        "None => None",
        ""
      ].join("\n")

      expect { None().get }.to raise_error(None::ValueExpectedException, message)
      expect(Some(1).get).to eql(1)
    end

    it "or_else" do
      expect(None().or_else(true)).to eql(true)
      expect(None().or_else { false }).to eql(false)
      expect(Some(1).or_else(2)).to eql(1)
      expect(Some(1).or_else { 2 }).to eql(1)
    end
  end

  describe 'recover' do
    it 'does does not execute block on Some and returns self' do
      called = false
      some = Maybe(42)

      expect(some.recover { called = true; 43 }).to be some
      expect(some.recover(56)).to be some
      expect(called).to be false
    end

    it "returns value or call block on None" do
      called = false
      none = None()
      expect(none.recover { called = true; 42 }).to eql(Some(42))
      expect(called).to be true
      expect(none.recover(42)).to eql(Some(42))
    end

    it "flattens returned maybe values" do
      none = None()

      expect(none.recover(nil)).to eql(None())
      expect(none.recover(None())).to eql(None())
      expect(none.recover { None() }).to eql(None())

      expect(none.recover(Maybe(42))).to eql(Some(42))
      expect(none.recover { Maybe(42) }).to eql(Some(42))
    end
  end

  describe 'catch' do
    it "returns self" do
      maybe = Maybe(42)
      none = Maybe(nil)
      expect(maybe.catch { 42 }).to be maybe
      expect(none.catch { 42 }).to be none
    end

    it 'does not execute block on Some' do
      called = false
      Maybe(42).catch { called = true }

      expect(called).to be false
    end

    it 'executes the block on None' do
      called = false
      None().catch { called = true }

      expect(called).to be true
    end
  end

  describe "or_raise" do
    it "gets" do
      expect(Maybe(1).or_raise).to eq(1)
    end

    it "raises with 'stack'" do
      data = {
        hash: {
          number: {
            name: nil,
            value: 1
          }
        }
      }

      # TODO: re-enable this
      # message = [
      #   "`or_raise` called to None. A value was expected.",
      #   "",
      #   "Maybe       => Some({:hash=>{:number=>{:name=>nil, :value=>1}}})",
      #   "[:hash]     => Some({:number=>{:name=>nil, :value=>1}})",
      #   "map         => None",
      #   "select      => None",
      #   "[:name]     => None",
      #   "slice(1, 4) => None",
      #   ""
      # ].join("\n")

      expect {
        Maybe(data)[:hash].fmap { |h|
          h[:numbers]
        }.select {
          |number| number[:value].odd?
        }[:name].slice(1, 4).or_raise()

      }.to raise_error(None::ValueExpectedException) #, message)
    end

    it "raises with stack and message" do

      message = [
        "must be Some",
        "",
        "Maybe => None",
        ""
      ].join("\n")

      expect { Maybe(nil).or_raise("must be Some") }.to raise_error(None::ValueExpectedException, message)
    end

    it "has the same interface as Kernel raise method" do
      with_stack = ->(msg) {
        [msg, "", "Maybe => None", ""].join("\n")
      }

      msg = "message and stack"
      expect { Maybe(nil).or_raise(msg) }
        .to raise_error(None::ValueExpectedException, with_stack.call(msg))

      msg = "message without stack"
      expect { Maybe(nil).or_raise(msg, print_stack: false) }
        .to raise_error(None::ValueExpectedException, msg)

      msg = "argument error object and stack"
      expect { Maybe(nil).or_raise(ArgumentError.new(msg)) }
        .to raise_error(ArgumentError, with_stack.call(msg))

      msg = "argument error object without stack"
      expect { Maybe(nil).or_raise(ArgumentError.new(msg), print_stack: false) }
        .to raise_error(ArgumentError, msg)

      msg = "argument error class, message and stack "
      expect { Maybe(nil).or_raise(ArgumentError, msg) }
        .to raise_error(ArgumentError, with_stack.call(msg))

      msg = "argument error class, message without stack "
      expect { Maybe(nil).or_raise(ArgumentError, msg, print_stack: false) }
        .to raise_error(ArgumentError, msg)
    end
  end

  describe "or_nil" do
    it "gets the value" do
      expect(Maybe(1).or_nil).to eq(1)
      expect(None().or_nil).to eq(nil)
    end
  end

  describe "forward" do
    it "forwards methods" do
      expect(Some("maybe").upcase.get).to eql("MAYBE")
      expect(Some([1, 2, 3]).fmap { |arr| arr.map { |v| v * v } }.get).to eql([1, 4, 9])
    end
  end
end
