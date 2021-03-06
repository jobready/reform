require 'multi_json'
require 'representable218/hash'
require 'representable218/json/collection'

module Representable218
  # Brings #to_json and #from_json to your object.
  module JSON
    extend Hash::ClassMethods
    include Hash

    def self.included(base)
      base.class_eval do
        include Representable218 # either in Hero or HeroRepresentation.
        extend ClassMethods # DISCUSS: do that only for classes?
        register_feature Representable218::JSON
      end
    end


    module ClassMethods
      def collection_representer_class
        JSON::Collection
      end
    end


    # Parses the body as JSON and delegates to #from_hash.
    def from_json(data, *args)
      data = MultiJson.load(data)
      from_hash(data, *args)
    end

    # Returns a JSON string representing this object.
    def to_json(*args)
      MultiJson.dump to_hash(*args)
    end
  end
end
