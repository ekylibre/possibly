# Possibly - Maybe monad for Ruby

Maybe monad implementation for Ruby

```ruby
puts Maybe(User.find_by_id("123")).username.downcase.or_else { "N/A" }

=> # puts downcased username if user "123" can be found, otherwise puts "N/A"
```

## Installation

```ruby
gem install possibly
```

## Getting started

```
require 'possibly'

first_name = Maybe(deep_hash)[:account][:profile][:first_name].or_else { "No first name available" }
```

## Documentation

Maybe monad is a programming pattern that allows to treat nil values that same way as non-nil values. This is done by wrapping the value, which may or may not be `nil` to, a wrapper class.

The implementation includes three different classes: `Maybe`, `Some` and `None`. `Some` represents a value, `None` represents a non-value and `Maybe` is a constructor, which results either `Some`, or `None`.

```ruby
Maybe("I'm a value")    => #<Some:0x007ff7a85621e0 @value="I'm a value">
Maybe(nil)              => #<None:0x007ff7a852bd20>
```

Both `Some` and `None` implement four trivial methods: `is_some?`, `is_none?`, `get` and `or_else`

```ruby
Maybe("I'm a value").is_some?               => true
Maybe("I'm a value").is_none?               => false
Maybe(nil).is_some?                         => false
Maybe(nil).is_none?                         => true
Maybe("I'm a value").get                    => "I'm a value"
Maybe("I'm a value").or_else { "No value" } => "I'm a value"
Maybe(nil).get                              => RuntimeError: No such element
Maybe(nil).or_else { "No value" }           => "No value"
```

In addition, `Some` and `None` implement `Enumerable`, so all methods available for `Enumerable` are available for `Some` and `None`:

```ruby
Maybe("Print me!").each { |v| puts v }      => it puts "Print me!"
Maybe(nil).each { |v| puts v }              => puts nothing
Maybe(4).map { |v| Math.sqrt(v) }           => #<Some:0x007ff7ac8697b8 @value=2.0>
Maybe(nil).map { |v| Math.sqrt(v) }         => #<None:0x007ff7ac809b10>
Maybe(2).inject(3) { |a, b| a + b }         => 5
None().inject(3) { |a, b| a + b }           => 3
```

All the other methods you call on `Some` are forwarded to the `value`.

```ruby
Maybe("I'm a value").upcase                 => #<Some:0x007ffe198e6128 @value="I'M A VALUE">
Maybe(nil).upcase                           => None
```

### Case expression

Maybe implements threequals method `#===`, so it can be used in case expressions:

```ruby
value = Maybe([nil, 1, 2, 3, 4, 5, 6].sample)

case value
when Some
  puts "Got Some: #{value.get}"
when None
  puts "Got None"
end
```

If the type of Maybe is Some, you can also match the value:

```ruby
value = Maybe([nil, 0, 1, 2, 3, 4, 5, 6].sample)

case value
when Some(0)
  puts "Got zero"
when Some((1..3))
  puts "Got a low number: #{value.get}"
when Some((4..6))
  puts "Got a high number: #{value.get}"
when None
  puts "Got nothing"
end
```

For more complicated matching you can use Procs and lambdas. Proc class aliases #=== to the #call method. In practice this means that you can use Procs and lambdas in case expressions. It works also nicely with Maybe:

```ruby
even? = ->(a) { a % 2 == 0 }
odd? = ->(a) { a % 2 != 0 }

value = Maybe([nil, 1, 2, 3, 4, 5, 6].sample)

case value
when Some(even?)
  puts "Got even value: #{value.get}"
when Some(odd?)
  puts "Got odd value: #{value.get}"
when None
  puts "Got None"
end
```

### case_of

Maybe implements the threequals method in a way which allows it to be used in case expressions pretty neatly: You can match both the type (`None` or `Some`) and the value of `Some`. It almost feels like pattern matching in functional language. However, there's one big shortcoming. Ruby doesn't allow binding the value of `Some` to a variable, so you must use the `get` method to do that. The following does not work in Ruby:

```ruby
case apples
when Some(1)
  puts "one apple"
when Some(x)
  puts "#{x} apples"
when None
  puts "Unknown number of apples"
end
```

Instead, you have to use `get`, which is cubersome:

```ruby
case apples
when Some(1)
  puts "one apple"
when Some
  x = apples.get
  puts "#{x} apples"
when None
  puts "Unknown number of apples"
end
```

To workaround this limitation, Maybe implements a method `case_of`, which internally uses case expression:

```ruby
apples.case_of(Some(1)) { |_| puts "1 apple" }
apples.case_of(Some(Integer)) { |x| puts "#{x} apples" }
apples.case_of(None) { |_| puts "Unknown number of apples" }
```

```haml
- apples.case_of(Some(1)) do
  = "1 apple"

- apples.case_of(Some(Integer)) do |x|
  = puts "#{x} apples"

- apples.case_of(None) do
  = "Unknown number of apples"
```

## Examples

Instead of using if-clauses to define whether a value is a `nil`, you can wrap the value with `Maybe()` and threat it the same way whether or not it is a `nil`

Without Maybe():

```ruby
user = User.find_by_id(user_id)
number_of_friends = if user && user.friends
  user.friends.count
else
  0
end
```

With Maybe():

```ruby
number_of_friends = Maybe(User.find_by_id(user_id)).friends.count.or_else { 0 }
```

Same in HAML view, without Maybe():

```haml
- if @user && @user.friends
  = @user.friends.count
- else
  0
```

```haml
= Maybe(@user).friends.count.or_else { 0 }
```

## Tests

`rspec spec/spec.rb`

## License

[MIT](LICENSE)

## Author

[Mikko Koski](https://github.com/rap1ds) / [@rap1ds](http://twitter.com/rap1ds)

## Sponsored by

[Sharetribe](https://github.com/sharetribe) / [@sharetribe](http://twitter.com/sharetribe) / [www.sharetribe.com](https://www.sharetribe.com)