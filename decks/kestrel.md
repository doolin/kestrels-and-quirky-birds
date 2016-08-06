# Ruby's `tap` as a kestrel

---
title: Carving Ruby arrays
date: 2015-10-24 06:38 PDT
tags: ruby, deep-dive, array, carve
---

I ran across an interesting method in a colleague's commit
recently, which monkey patched Ruby's `Array` class. To me, it nearly
epitomizes Ruby's elegance by packing a number of powerful
techniques into a single short line of code, without being unreadably
complicated. No line noise here. While I'm not sold one way or the other
on monkey patching, I was intrigued enough by the following `carve!`
method to dig a bit deeper.

*Note: this replicates functionality provided by `Enumerable.partition`,
so there's probably no reason to use this in production.* On the other
hand, as noted by Benjamin Tan in [The Ruby Closures
Book](https://leanpub.com/therubyclosuresbook/read), implementing a [cheap
counterfeit](https://practicingruby.com/articles/domain-specific-apis)
is usually enlightening.


Here's the snippet under consideration:

~~~ruby
class Array
  def carve!
    dup.tap { delete_if &Proc.new } - self
  end
end
~~~

It does exactly what the name `carve!` implies, separating one Array
into two Arrays based on the condition passed in as a block.

How it works:

* `dup` makes a copy of the values in the array and returns those values
in a new array. That's pretty straightforward.
* `tap` [yields self to the block then returns
itself](http://ruby-doc.org/core-2.2.3/Object.html#method-i-tap). This
is the first key part of the technique.
* `delete_if` takes a block, and deletes every element matching the
condition given by the block. Note that the [deletion occurs on every
match](http://ruby-doc.org/core-2.2.3/Array.html#method-i-delete_if),
not after the iteration is complete. Note that `delete_if` *operates on
the original array*, not on the duplicated array.
* `&Proc.new` is an odd construction, even for Ruby, which can appear to
  have a number of odd constructions. We'll examine this in more detail
  shortly. This is the third key part.

Then the original array (`self`) is subtracted from the duplicated and
modified array.  That looks simple enough.

The slightly mind-bending aspect of `carve!` is how it processes the
block passed in as the condition. It was not at all obvious to me, so
let's take a deeper look at that.

## dup and tap

The `dup.tap` calls warrant a closer look. Especially `tap` which to me is one
of those super simple constructions which I don't use very often, hence
haven't developed an intuitive feel for it. Using `tap` saves two lines of
code for the same functionality:

~~~ruby
def carve2!
  other = dup
  delete_if &Proc.new
  other - self
end
~~~

A case could be made for `carve2` being easier to understand. A (strong) case
could also be made for mastering Ruby, `tap` and all. I choose mastery.

### More about #tap

Ruby 1.9 introduced the `tap` method, which passes `self` to a block and
returns `self` after processing the block. Normally, the result of the
block would be returned. In combinatory logic, this behavior is defined
by a function called *kestrel*, or $$K$$ Combinator:

$$
kxy = x.
$$

The theoretical importance of $$K$$ cannot be overstated. Combined with
the $$S$$ combinator, the $$SK$$ calculus is equivalent to an untyped lambda
calculus, i.e., is Turing complete.

But that takes us too far afield for today.

The important thing when using `tap` is understanding that the block has
no implicit return, it is only used as a generator of side effects.

## delete_if and passing procs

Let's take a closer look at `delete_if`. This is one of those
Ruby methods which "just works" usually without having to think much about it.
For our investigation, we need to get drill a bit deeper. We'll start
with some REPL code:

~~~ruby
$ irb
2.2.3 :001 > [1, 2].delete_if { |e| e < 2 }
 => [2] # as expected

2.2.3 :002 > deleter = ->(e) { e < 2 } # set us up the lambda
 => #<Proc:0x007f8f0981bcb8@(irb):3 (lambda)>

2.2.3 :003 > [1, 2].delete_if(deleter) # we have to try...
ArgumentError: wrong number of arguments (1 for 0) # as expected...
        from (irb):4:in 'delete_if'
        from (irb):4
        from /Users/doolin/.rvm/rubies/ruby-2.2.3/bin/irb:15:in '<main>'

2.2.3 :004 > [1, 2].delete_if(&deleter)
 => [2] # success

2.2.3 :005 >
~~~

As can be seen, `delete_if` doesn't take any arguments, unless it takes a single
argument prefixed with an ampersand `&`. In which case, that argument is received
as Proc object.


## &Proc.new

In Ruby, `Proc` is an object created from a block.

When the last argument of a method is prefixed with an ampersand `&`,
that argument will receive the block as a Proc object.
From ruby-doc, [Proc.new](http://ruby-doc.org/core-2.2.3/Proc.html#method-c-new):

<blockquote>
Creates a new <code>Proc</code> object, bound to the current context.
<code>Proc::new</code> may be called without a block only within a method with an
attached block, in which case that block is converted to the <code>Proc</code> object.
</blockquote>

What I need to do here is create my own method which yields, and see how
`&Proc` works with that. Using `map` and `delete_if` doesn't give me enough
insight into how `&Proc` *really* works. The `dup.tap` gets in the way.
How about a custom map method:

~~~ruby
class Array
  def newmap
    map &Proc.new
  end
end

nm = [1, 2].newmap { |element| element + 1 }
puts nm # 2, 3
~~~

And that's the long and short of `carve!`.

## Carving arrays

Without making any judgement call on monkey patching, `carve!` feels like an
elegant addition to Ruby's `Array` class. The implementation given here is not
likely performant due to `delete_if`'s behavior of deleting by each item. On the
other hand, implementing something more computationally efficient becomes very
difficult very quickly, as the deletion criteria can be arbitrary.

The coolest thing about `carve!` for me as a Ruby programmer is running across
code which stretches my comprehension of the language, something which is
increasingly rare as my Ruby ability grows.
