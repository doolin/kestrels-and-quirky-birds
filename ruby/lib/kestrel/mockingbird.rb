#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rspec/autorun'

def mockingbird(x)
  x.call(x)
end
# But really, this is the M combinator Mx = xx
alias M mockingbird

RSpec.describe 'self' do
  xit 'blows up the stack with SystemStackError when without a halting condition' do
    y = ->(y) { mockingbird y }
    expect { mockingbird(y) }.to raise_error SystemStackError
  end

  it 'raises NoMethodError when not called with a function' do
    y = 1
    expect { mockingbird(y) }.to raise_error NoMethodError
  end

  it 'sings like a mockingbird' do
    x = ->(_x) { 'sing like a mockingbird' }
    expect(mockingbird(x)).to eq 'sing like a mockingbird'
  end

  it 'satisfies the M combinator definition Mx = xx' do
    x = ->(_x) { 'I am the Mighty M Combinator' }
    expect(M(x)).to eq x[x]
  end
end
