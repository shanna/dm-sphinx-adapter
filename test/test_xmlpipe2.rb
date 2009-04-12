require File.join(File.dirname(__FILE__), 'helper')
require 'dm-sphinx-adapter/xmlpipe2'

class TestResource < Test::Unit::TestCase
  context 'DM::A::Sphinx::Resource module' do
    begin
      require 'nokogiri'
    rescue LoadError
      warn '  * WARNING: Nokogiri not found, skipping xmlpipe2 tests.'
      return nil
    end

    setup do
      load File.join(File.dirname(__FILE__), 'files', 'model.rb')
    end

    should 'respond to #xmlpipe2' do
      assert_respond_to Item, :xmlpipe2
    end

    context '#xmlpipe2' do
      setup do
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
        @xml = $stdout.rewind && $stdout.read
        @doc = Nokogiri::XML.parse(@xml) rescue nil
        @ns  = {'s' => 'sphinx'}
        $stdout = STDOUT
      end

      should 'stream xml to stdout' do
        assert_not_nil @xml
        assert_not_nil @doc
      end

      context 'schema' do
        should 'have id field' do
          assert_not_nil @doc.xpath(%q{//s:field[@name='id']}, @ns).first
        end

        should 'have t_string field' do
          assert_not_nil @doc.xpath(%q{//s:field[@name='t_string']}, @ns).first
        end

        should 'have text attribute' do
          assert_not_nil @doc.xpath(%q{//s:attr[@name='t_text' and @type='str2ordinal']}, @ns).first
        end

        should 'have decimal attribute' do
          assert_not_nil @doc.xpath(%q{//s:attr[@name='t_decimal' and @type='float']}, @ns).first
        end

        should 'have float attribute' do
          assert_not_nil @doc.xpath(%q{//s:attr[@name='t_float' and @type='float']}, @ns).first
        end

        should 'have int attribute' do
          assert_not_nil @doc.xpath(%q{//s:attr[@name='t_integer' and @type='int']}, @ns).first
        end

        should 'have timestamp attribute' do
          assert_not_nil @doc.xpath(%q{//s:attr[@name='t_datetime' and @type='timestamp']}, @ns).first
        end
      end
    end
  end
end

