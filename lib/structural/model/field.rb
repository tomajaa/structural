module Structural
  module Model
    class Field
      def initialize(model, name, options)
        @model = model
        @name = name
        @options = options
      end

      def define
        Definer.method_memoize(model, name) { |data| value_of(data) }
        Definer.method(model, "#{name}?") { |obj| presence_of(obj.data) }
        hook_define
      end

      def hook_define
      end

      def value_of(data)
        value = data.fetch(key, &default_value)
        cast(value)
      end

      def presence_of(data)
        data.has_key?(key) && !data.fetch(key).nil?
      end

      def cast(value)
        TypeCasts.cast(options.fetch(:type, false), value)
      end

      def key
        options.fetch(:key, name).to_s
      end

      def default_value
        proc do
          if default?
            default
          else 
            raise MissingAttributeError, key
          end
        end
      end

      def default?
        options.has_key?(:default)
      end

      def default
        options.fetch(:default)
      end

      attr_reader :model, :name, :options
    end
  end
end
