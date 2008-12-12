require File.join(File.dirname(__FILE__), '..', 'helper')

class TestResource < Test::Unit::TestCase
  def test_true
    assert true
  end

  def setup
    super
    index
  end
end
