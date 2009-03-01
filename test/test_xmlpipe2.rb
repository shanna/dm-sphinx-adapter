require File.join(File.dirname(__FILE__), 'helper')
require 'dm-sphinx-adapter/xmlpipe2'

class TestResource < Test::Unit::TestCase
  context 'DM::A::Sphinx::Resource module' do
    setup do
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
    end

    should 'respond to #xmlpipe2' do
      assert_respond_to Item, :xmlpipe2
    end

    context '#xmlpipe2' do
      should 'stream to stdout' do
        $stdout = StringIO.new
        Item.create(
          :id         => 1,
          :t_string   => 'one',
          :t_text     => "text one!",
          :t_decimal  => BigDecimal.new('0.01'),
          :t_float    => 0.0001,
          :t_integer  => 1,
          :t_datetime => Time.at(1235914716)
        )
        Item.xmlpipe2(:default, :search)
        xml = $stdout.rewind && $stdout.read
        $stdout = STDOUT

        # TODO: Nokogiri or something and test some xpaths instead of a big eq match.
        assert_equal(
          File.open(File.join(File.dirname(__FILE__), 'files', 'test_xmlpipe2.xml')).read.chomp,
          xml
        )
      end
    end
  end
end

