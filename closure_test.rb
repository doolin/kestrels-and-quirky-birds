#!/usr/bin/env ruby

x = 5

def m
  p = Proc.new
  x = 10
  p.call(x)
end

m { |x| puts x }


def lambda_check
  x = -> { return }
  x.()
  puts 'returned from lambda'
  y = Proc.new { return }
  y.()
  puts 'returned from proc'
end

lambda_check
