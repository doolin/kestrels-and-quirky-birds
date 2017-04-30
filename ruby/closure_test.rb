#!/usr/bin/env ruby
# frozen_string_literal: true

x = 5

def m
  p = Proc.new
  x = 10
  p.call(x)
end

m { |x| puts x }

def lambda_check
  x = -> { return }
  x.call
  puts 'returned from lambda'
  y = proc { return }
  y.call
  puts 'returned from proc'
end

lambda_check
