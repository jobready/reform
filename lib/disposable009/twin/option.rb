module Disposable009::Twin::Option
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def option(name, options={})
      # default: nil will always set an option in the, even when not in the incoming options.
      property(name, options.merge(:readable => false, :default => nil))
    end
  end
end