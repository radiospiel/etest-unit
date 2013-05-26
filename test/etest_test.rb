#!/usr/bin/env ruby
DIRNAME = File.expand_path File.dirname(__FILE__)
Dir.chdir(DIRNAME)

ETEST_TEST=true

require "etest-unit"
require "expectation"

# ---------------------------------------------------------------------

$etest_stats = Hash.new(0)

module String::Etest
  def test_underscore
    $etest_stats[:underscore] += 1

    assert_equal "x", "X".underscore
    assert_equal "xa_la_nder", "XaLaNder".underscore
  end

  def test_camelize
    $etest_stats[:camelize] += 1

    assert_equal "X", "x".camelize
    assert_equal "XaLaNder", "xa_la_nder".camelize
  end

  def test_camelize_lower
    assert_equal "x", "x".camelize(:lower)
    assert_equal "xaLaNder", "xa_la_nder".camelize(:lower)
  end
end

module Fixnum::Etest
  def test_success
    $etest_stats[:success] += 1

    assert true
  end
end

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

