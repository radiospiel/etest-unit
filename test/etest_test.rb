#!/usr/bin/env ruby
DIRNAME = File.expand_path File.dirname(__FILE__)
Dir.chdir(DIRNAME)

ETEST_TEST=true

require "etest-unit"

# ---------------------------------------------------------------------

module String::Etest
  def test_camelize
    assert_equal "x", "X".underscore
    assert_equal "xa_la_nder", "XaLaNder".underscore
  end

  def test_underscore
    assert_equal "X", "x".camelize
    assert_equal "XaLaNder", "xa_la_nder".camelize
  end
end

module Fixnum::Etest
  def test_success
    $etests_did_run = true
    assert true
  end
end

String.etest

$etests_did_run = false
Fixnum.etest
exit(0) if $etests_did_run

STDERR.puts "Etests didn't run"
exit(1)
