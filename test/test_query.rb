require File.join(File.dirname(__FILE__), 'helper')

class TestQuery < Test::Unit::TestCase
  context 'DM::A::Sphinx::Query conditions' do
    setup do
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
      @adapter  = repository(:search)
      @resource = Item
    end

    should 'treat nil operator as extended field match' do
      assert_equal '@t_string "foo"', query_string(:t_string => 'foo')
    end

    should 'treat .eql operator as extended field match' do
      assert_equal '@t_string "foo"', query_string(:t_string.eql => 'foo')
    end

    should 'treat .like operator as extended field match' do
      assert_equal '@t_string "foo"', query_string(:t_string.like => 'foo')
    end

    should 'treat Array as extended field AND match' do
      assert_equal '@t_string "foo bar"', query_string(:t_string => %w{foo bar})
    end

    should 'treat .not opeartor as extended field NOT match' do
      assert_equal '@t_string -"foo"', query_string(:t_string.not => 'foo')
    end

    should 'treat Array .not operator as extended field NOT match' do
      assert_equal '@t_string -"foo bar"', query_string(:t_string.not => %w{foo bar})
    end

    should 'treat .in operator as extended OR match' do
      assert_equal '@t_string ("foo" | "bar")', query_string(:t_string.in => %w{foo bar})
    end

    should 'treat multiple .eql operators as AND search' do
      # When is DM going to switch conditions to an array? :(
      assert(/(?:@t_string "b" )?@t_string "a"(?: @t_string "b")?/.match(
        query_string(:t_string.eql => 'a', :t_string.eql => 'b')
      ))
    end

    should 'leave raw conditions as they are' do
      assert_equal '"foo bar"~10', query_string(:conditions => ['"foo bar"~10'])
    end
  end

  protected
    def query(conditions = {})
      DataMapper::Adapters::Sphinx::Query.new(
        DataMapper::Query.new(@adapter, @resource, conditions)
      )
    end

    def query_string(conditions = {})
      query(conditions).to_s
    end
end
