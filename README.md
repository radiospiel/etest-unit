# etest-unit

## Installation

    gem install etest-unit

## Intro

    ~/projects/ruby/scratch > irb
    irb>     class X
    irb>       def self.foo; "baz"; end
    irb>     end
    irb>     module X::Etest
    irb>       def test_abc
    irb>         assert_equal X.foo, "bar"
    irb>       end
    irb>     end
    irb*     require "etest-unit"
    => true
    irb>     X.etest
    Warning: Cannot reload module X
    Loaded suite X::Etest
    Started
    F
    ===============================================================================
    Failure:
    test_abc()
    (irb):7:in `test_abc'
    <"baz"> expected but was
    <"bar">

    [ ... ]
    57.30 tests/s, 57.30 assertions/s
    => 1 tests, 1 assertions, 1 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications


    irb>     # fix the typo
    irb*     class X
    irb>       def self.foo; "bar"; end
    irb>     end
    => nil
    irb>     # run test again
    irb*     X.etest
    Warning: Cannot reload module X
    Loaded suite X::Etest
    Started
    .

    Finished in 0.00111 seconds.

    1 tests, 1 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
    100% passed

    irb> 

## License

The etest-unit gem is distributed under the terms of the Modified BSD License, see LICENSE.BSD for details.
