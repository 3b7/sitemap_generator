require 'spec_helper'
require 'sitemap_generator/interpreter'

describe SitemapGenerator::Interpreter do
  let(:link_set)    { SitemapGenerator::LinkSet.new }
  let(:interpreter) { SitemapGenerator::Interpreter.new(:link_set => link_set) }

  # The interpreter doesn't have the URL helpers included for some reason, so it
  # fails when adding links.  That messes up later specs unless we reset the sitemap object.
  after :all do
    SitemapGenerator::Sitemap.reset!
  end

  it "should find the config file if Rails.root doesn't end in a slash" do
    SitemapGenerator::Utilities.with_warnings(nil) do
      Rails = stub(:root => SitemapGenerator.app.root.to_s.sub(/\/$/, ''))
    end
    expect { SitemapGenerator::Interpreter.run }.not_to raise_error
  end

  it "should set the verbose option" do
    SitemapGenerator::Interpreter.any_instance.expects(:instance_eval)
    interpreter = SitemapGenerator::Interpreter.run(:verbose => true)
    expect(interpreter.instance_variable_get(:@linkset).verbose).to be true
  end

  describe "link_set" do
    it "should default to the default LinkSet" do
      expect(SitemapGenerator::Interpreter.new.sitemap).to be(SitemapGenerator::Sitemap)
    end

    it "should allow setting the LinkSet as an option" do
      expect(interpreter.sitemap).to be(link_set)
    end
  end

  describe "public interface" do
    describe "add" do
      it "should add a link to the sitemap" do
        link_set.expects(:add).with('test', :option => 'value')
        interpreter.add('test', :option => 'value')
      end
    end

    describe "group" do
      it "should start a new group" do
        link_set.expects(:group).with('test', :option => 'value')
        interpreter.group('test', :option => 'value')
      end
    end

    describe "sitemap" do
      it "should return the LinkSet" do
        expect(interpreter.sitemap).to be(link_set)
      end
    end

    describe "add_to_index" do
      it "should add a link to the sitemap index" do
        link_set.expects(:add_to_index).with('test', :option => 'value')
        interpreter.add_to_index('test', :option => 'value')
      end
    end
  end

  describe "eval" do
    it "should yield the LinkSet to the block" do
      interpreter.eval(:yield_sitemap => true) do |sitemap|
        expect(sitemap).to be(link_set)
      end
    end

    it "should not yield the LinkSet to the block" do
      # Assign self to a local variable so it is captured by the block
      this = self
      interpreter.eval(:yield_sitemap => false) do
        this.expect(self).to this.be(this.interpreter)
      end
    end

    it "should not yield the LinkSet to the block by default" do
      # Assign self to a local variable so it is captured by the block
      this = self
      interpreter.eval do
        this.expect(self).to this.be(this.interpreter)
      end
    end
  end
end
