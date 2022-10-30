#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec'

class Array
  def carve!
    # dup.tap { delete_if(&Proc.new) } - self
    dup.tap { delete_if(&Proc.new) } - self
  end
end

carve = <<~EOS
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
    dup.tap { delete_if(&Proc.new) } - self
  end

  def carve2!
    other = dup
    delete_if(&Proc.new)
    # dd = other.delete_if &Proc.new
    # dd = other.tap { delete_if &Proc.new }
    # puts dd
    # puts self
    other - self
  end

  def carve3!
    dup.delete_if(&Proc.new) - self
  end

  def d_reject!
    delete_if(&Proc.new)
  end

  def call_test_for_spec
    test_for_spec
  end

  # private
  def test_for_spec
    'called'
  end
end

# Interesting note on testing private methods:
# http://mixandgo.com/blog/3-ways-of-testing-private-methods-in-rails
#
# From the comments:
#
# For the love of $DEITY, don't test your ruddy private methods in Ruby!
#
# Private methods are implementation details, subject to change seemingly
# on a whim as the needs of the public methods which they support change.
#
# Test public behaviour, not implementation. This isn't PHP, despite
# some folks' best (and disturbingly competent) efforts.
#
# Here's a handy summary of some good rules to follow, and you really
# should watch this
#
# from RailsConf 2013.
#
# https://www.youtube.com/watch?v=URSWYvyc42M
#
#
# see more
# 1  • Reply•Share ›
# Avatar
# lifecoderua  Jeff Dickey • 9 months ago
# So do you voting against unit testing? It is not great to get an epic
# fail one day just because two private methods both produced wrong
# results, but their combination in public method works well for some cases.
#  • Reply•Share ›
#  Avatar
#  Jeff Dickey  lifecoderua • 9 months ago
#
#  I'm not arguing against unit testing at all; neither is the video I linked to.
#  What I am arguing against is explicit testing of methods that aren't part of
#  your public interface. Test those using unit tests, and use feature/integration
#  tests to verify that your various classes work together as expected. But private
#  methods, for as long as such have existed in any language, have declared "this
#  is how things work now. We make no promises that the next commit won't add,
#  change, or remove private methods seemingly on a whim. Public methods, by contrast,
#  are (hopefully) more methodically thought out."
#
#  You shouldn't have any private methods that aren't exercised, directly or indirectly,
#  by public methods. If you do, that's called dead code; it ought to be ripped out.
#  If you say "hey, hang on; I use those", then they shouldn't be private methods, should they?
#
#  This is also a useful place to stick in a reminder about the SRP; it applies
#  to classes and larger assemblies, not simply to methods.

RSpec.describe Array do
  it 'captures call to private method with expectation' do
    array = [3]
    expect(array).to receive(:test_for_spec).and_return('called')
    expect(array.call_test_for_spec).to eq 'called'
  end
end

puts 'carve'
a = [1, 2, 3, 4, 5]
b = a.carve! { |e| e < 3 }
print 'a: ', a, "\n"
print 'b: ', b, "\n"

puts 'carve2'
c = [1, 2, 3, 4, 5]
d = c.carve2! { |e| e < 3 }
print 'c: ', c, "\n"
print 'd: ', d, "\n"

puts 'carve3'
e = [1, 2, 3, 4, 5]
f = c.carve3! { |element| element < 3 }
print 'e: ', e, "\n"
print 'f: ', f, "\n"

puts 'reject example'
puts [6, 7, 8].d_reject! { |e| e > 7 }

class Array
  def newmap
    map(&Proc.new)
  end
end

puts 'newmap example'
nm = [1, 2].newmap { |element| element + 1 }
puts nm

# What I need to do here is create my own method which yields, and see how
# &Proc works with that. Using `map` and `delete_if` doesn't give me enough
# insight into how &Proc works.

def block_binder(&block)
  puts block.binding.inspect
  yield
end

puts 'block.binding example'
block_binder { puts 'foo' }
