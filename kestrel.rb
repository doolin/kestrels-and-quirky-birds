#!/usr/bin/env ruby


# From https://github.com/raganwald-deprecated/homoiconic/blob/master/2008-10-29/kestrel.markdown#readme
# Kxy = x
# for *any* x,
# kestrel.call(:foo).call(x)
#   => :foo
# The key to understanding this is that x is arbitrary. This could have as easily
# been written
# kestrel.call(x).call(y)
#   => x # for *any* y.



# kestrel = -> (y) { y.call }

def inside value , &block
  value.instance_eval(&block)
  value
end

v = inside [1, 2, 3, 3] do
  # This modifies
  uniq!
end

puts v

x = -> { puts 42 }
y = -> { puts 13 }

kestrel = -> (x) { x }

puts kestrel.call(:foo)
