require 'rep_test_helper'

# Include Inherit Module And Decorator Test
class SchemaTest < MiniTest::Spec
  module Genre
    include Representable218
    property :genre
  end

  module LinkFeature
    def self.included(base)
      base.extend(Link)
    end

    module Link
      def link
      end
    end
  end


  module Module
    include Representable218::Hash
    feature LinkFeature

    property :title
    property :label do # extend: LabelModule
      property :name
      link # feature

      property :location do
        property :city
        link # feature.
      end
    end

    property :album, :extend => lambda { raise "don't manifest me!" } # this is not an inline decorator, don't manifest it.


    include Genre # Schema::Included::included is called!
  end


  class WithLocationStreetRepresenter < Representable218::Decorator
    include Representable218::Hash
    feature LinkFeature

    property :title
    property :label do # extend: LabelModule
      property :name
      link # feature

      property :location do
        property :city
        link # feature.
      end
    end
  end

  describe "3-level deep with features" do
    let (:label) { OpenStruct.new(:name => "Epitaph", :location => OpenStruct.new(:city => "Sanfran", :name => "DON'T SHOW ME!")) }

    # Module does correctly include features in inlines.
    it { band.extend(Module).to_hash.must_equal({"label"=>{"name"=>"Epitaph", "location"=>{"city"=>"Sanfran"}}, "genre"=>"Punkrock"}) }

    # Decorator does correctly include features in inlines.
    it { Decorator.new(band).to_hash.must_equal({"label"=>{"name"=>"Epitaph", "location"=>{"city"=>"Sanfran"}}, "genre"=>"Punkrock"}) }
  end



  class Decorator < Representable218::Decorator
    feature Representable218::Hash

    include Module
  end

  # puts Decorator.representable_attrs[:definitions].inspect

  let (:label) { OpenStruct.new(:name => "Fat Wreck", :city => "San Francisco", :employees => [OpenStruct.new(:name => "Mike")], :location => OpenStruct.new(:city => "Sanfran")) }
  let (:band) { OpenStruct.new(:genre => "Punkrock", :label => label) }


  # it { FlatlinersDecorator.new( OpenStruct.new(label: OpenStruct.new) ).
  #   to_hash.must_equal({}) }
  it do
    Decorator.new(band).to_hash.must_equal({"genre"=>"Punkrock", "label"=>{"name"=>"Fat Wreck", "location"=>{"city"=>"Sanfran"}}})
  end


  class InheritDecorator < Representable218::Decorator
    include Representable218::Hash

    include Module

    property :label, inherit: true do # decorator.rb:27:in `initialize': superclass must be a Class (Module given)
      property :city

      property :location, :inherit => true do
        property :city
      end
    end
  end

  it do
    InheritDecorator.new(band).to_hash.must_equal({"genre"=>"Punkrock", "label"=>{"name"=>"Fat Wreck", "city"=>"San Francisco", "location"=>{"city"=>"Sanfran"}}})
  end



  class InheritFromDecorator < InheritDecorator

    property :label, inherit: true do
      collection :employees do
        property :name
      end
    end
  end

  it do
    InheritFromDecorator.new(band).to_hash.must_equal({"genre"=>"Punkrock", "label"=>{"name"=>"Fat Wreck", "city"=>"San Francisco", "employees"=>[{"name"=>"Mike"}], "location"=>{"city"=>"Sanfran"}}})
  end
end


class ApplyTest < MiniTest::Spec
  class AlbumDecorator < Representable218::Decorator
    property :title

    property :hit do
      property :title
    end

    collection :songs do
      property :title
    end

    property :band do # yepp, people do crazy stuff like that.
      property :label do
        property :name
      end
    end
  end

  # #apply
  it do
    properties = []

    AlbumDecorator.apply do |dfn|
      properties << dfn.name
      dfn.merge! :cool => true
    end.must_equal AlbumDecorator

    properties.must_equal ["title", "hit", "title", "songs", "title", "band", "label", "name"]
    # writeable
    AlbumDecorator.representable_attrs.get(:band).representer_module.representable_attrs.get(:label).representer_module.representable_attrs.get(:name)[:cool].must_equal true
  end
end