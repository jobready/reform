module Disposable009
  class Twin
    class Decorator < Representable218::Decorator
      include Representable218::Hash
      include AllowSymbols

      # DISCUSS: same in reform, is that a bug in represntable?
      def self.clone # called in inheritable_attr :representer_class.
        Class.new(self) # By subclassing, representable_attrs.clone is called.
      end

      def self.build_config
        Config.new(Definition)
      end

      def twin_names
        representable_attrs.
          find_all { |attr| attr[:twin] }.
          collect { |attr| attr.name.to_sym }
      end
    end

    class Definition < Representable218::Definition
      def dynamic_options
        super + [:twin]
      end
    end
  end
end