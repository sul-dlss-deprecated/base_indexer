require 'test_helper'

class BaseIndexerTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, BaseIndexer
  end
end
