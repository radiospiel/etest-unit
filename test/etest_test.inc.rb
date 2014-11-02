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
