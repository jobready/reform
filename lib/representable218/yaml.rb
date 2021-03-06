require 'representable218/hash'
require 'representable218/yaml/binding'

module Representable218
  module YAML
    include Hash

    def self.included(base)
      base.class_eval do
        include Representable218
        #self.representation_wrap = true # let representable compute it.
        register_feature Representable218::YAML
      end
    end


    def from_yaml(doc, options={})
      hash = Psych.load(doc)
      from_hash(hash, options, Binding)
    end

    # Returns a Nokogiri::XML object representing this object.
    def to_ast(options={})
      #root_tag = options[:wrap] || representation_wrap

      Psych::Nodes::Mapping.new.tap do |map|
        create_representation_with(map, options, Binding)
      end
    end

    def to_yaml(*args)
      stream = Psych::Nodes::Stream.new
      stream.children << doc = Psych::Nodes::Document.new

      doc.children << to_ast(*args)
      stream.to_yaml
    end
  end
end
