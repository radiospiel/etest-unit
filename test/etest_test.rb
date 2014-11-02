#!/usr/bin/env ruby
if !defined?(DIRNAME)
  DIRNAME = File.expand_path File.dirname(__FILE__)
end

Dir.chdir(DIRNAME)

if !defined?(ETEST_TEST)
  ETEST_TEST=true
end

require "etest-unit"
require "expectation"

# ---------------------------------------------------------------------

require_relative "./etest_test.inc.rb"

$etest_stats = Hash.new(0)

begin
  String.etest
  Fixnum.etest
  expect! $etest_stats => { :underscore => 1, :camelize => 1, :success => 1 }

  Fixnum.etest
  expect! $etest_stats => { :underscore => 1, :camelize => 1, :success => 2 }

  String.etest :test_camelize, :test_underscore
  expect! $etest_stats => { :underscore => 2, :camelize => 2, :success => 2 }

  begin
    String.etest :test_camelize, :nosuchtest
    expect! false
  rescue EtestUnit::Error
  end

  expect! $etest_stats => { :underscore => 2, :camelize => 2, :success => 2 }
rescue ArgumentError
  STDERR.puts "#{$!}; in #{$!.backtrace.first}"
  exit 1
end

