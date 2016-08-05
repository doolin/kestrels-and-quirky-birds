#!/usr/bin/env ruby

class Array
  def carve!
    # dup.tap { delete_if(&Proc.new) } - self
    dup.tap { delete_if &Proc.new } - self
  end
end


carve = <<EOS
class Array
  def carve!
    dup.tap { delete_if &Proc.new } - self
  end
end
EOS

puts RubyVM::InstructionSequence.compile(carve).disasm if false

class Array
  def carve!
    puts block_given?
    # tap appears necessary here, justify its necessity and explain
    # how it works.
    # dup.tap { delete_if &Proc.new } - self
    dup.tap { self.delete_if &Proc.new } - self
  end

  def carve2!
    other = dup
    delete_if &Proc.new
    # dd = other.delete_if &Proc.new
    # dd = other.tap { delete_if &Proc.new }
    # puts dd
    # puts self
    other - self
  end

  def carve3!
    (dup.delete_if &Proc.new) - self
  end

  def d_reject!
    delete_if &Proc.new
  end
end

puts "carve"
a = [1, 2, 3, 4, 5]
b = a.carve! { |e| e < 3 }
print "a: ", a, "\n"
print "b: ", b, "\n"

puts "carve2"
c = [1, 2, 3, 4, 5]
d = c.carve2! { |e| e < 3 }
print "c: ", c, "\n"
print "d: ", d, "\n"

puts "carve3"
e = [1, 2, 3, 4, 5]
f = c.carve3! { |element| element < 3 }
print "e: ", e, "\n"
print "f: ", f, "\n"

puts "reject example"
puts [6,7,8].d_reject! { |e| e > 7 }

class Array
  def newmap
    map &Proc.new
  end
end

puts "newmap example"
nm = [1, 2].newmap { |element| element + 1 }
puts nm

# What I need to do here is create my own method which yields, and see how
# &Proc works with that. Using `map` and `delete_if` doesn't give me enough
# insight into how &Proc works.

def block_binder(&block)
  puts block.binding.inspect
  yield
end

puts "block.binding example"
block_binder { puts "foo" }
