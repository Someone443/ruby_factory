# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory

  def self.new(name, *params, &block)
    validate(params)

    if name.is_a? String
      struct_with_name(name, params, &block)
    else
      params.unshift(name)
      struct_without_name(params, &block)
    end
  end

  def self.validate(params)
    params.shift if params[0].is_a? String
    raise ArgumentError if params.any? { |param| !(param.is_a? Symbol) }
  end

  def self.struct_with_name(name, params, &block)
    struct = eval <<CODE
      #{name.capitalize} = Class.new do |klass|

        attr_accessor #{params.to_s.gsub('[', '').gsub(']', '')}

        def initialize(*options, &block)
          raise ArgumentError if options.size != #{params.to_s}.size
          h = Hash[#{params}.zip options]
          h.each { |p, opt| self.send(p.to_s + '=', opt) }
        end

        klass.class_eval &block if block_given?

        define_method :[] do |selector|
          selector = #{params}[selector] if selector.is_a? Integer
          self.send(selector)
        end

        define_method :[]= do |selector, value|
          selector = #{params}[selector] if selector.is_a? Integer
          self.send(selector.to_s + '=', value)
        end

        define_method :each do |&block|
          #{params}.map { |param| self.send(param) }.each &block
        end

        define_method :each_pair do |&block|
          values = #{params}.map { |param| self.send(param) }
          Hash[#{params}.zip values].each &block
        end

        define_method :dig do |*indexes|
          values = #{params}.map { |param| self.send(param) }
          Hash[#{params}.zip values].dig(*indexes)
        end

        define_method :size do
          #{params}.size
        end

        define_method :members do
          #{params}
        end

        define_method :select do |&block|
          values = #{params}.map { |param| self.send(param) }
          values.select &block
        end

        define_method :to_a do
          #{params}.map { |param| self.send(param) }
        end

        define_method :values_at do |*indexes|
          #{params}.map { |param| self.send(param) }.values_at(*indexes)
        end

        define_method :eql? do |other|
          values = #{params}.map { |param| self.send(param) }
          self_members_values = Hash[#{params}.zip values]
          other_values = #{params}.map { |param| other.send(param) }
          other_members_values = Hash[#{params}.zip other_values]
          (self.class == other.class) &&
          (self_members_values == other_members_values) ? true : false
        end

        alias :length :size
        alias :== :eql?
      end
CODE
    struct
  end

  def self.struct_without_name(params, &block)
     struct = eval <<CODE
      #{self.constants[0]} = Class.new do |klass|

        attr_accessor #{params.to_s.gsub('[', '').gsub(']', '')}

        def initialize(*options, &block)
          raise ArgumentError if options.size != #{params.to_s}.size
          h = Hash[#{params}.zip options]
          h.each { |p, opt| self.send(p.to_s + '=', opt) }
        end

        klass.class_eval &block if block_given?

        define_method :[] do |selector|
          selector = #{params}[selector] if selector.is_a? Integer
          self.send(selector)
        end

        define_method :[]= do |selector, value|
          selector = #{params}[selector] if selector.is_a? Integer
          self.send(selector.to_s + '=', value)
        end

        define_method :each do |&block|
          #{params}.map { |param| self.send(param) }.each &block
        end

        define_method :each_pair do |&block|
          values = #{params}.map { |param| self.send(param) }
          Hash[#{params}.zip values].each &block
        end

        define_method :dig do |*indexes|
          values = #{params}.map { |param| self.send(param) }
          Hash[#{params}.zip values].dig(*indexes)
        end

        define_method :size do
          #{params}.size
        end

        define_method :members do
          #{params}
        end

        define_method :select do |&block|
          values = #{params}.map { |param| self.send(param) }
          values.select &block
        end

        define_method :to_a do
          #{params}.map { |param| self.send(param) }
        end

        define_method :values_at do |*indexes|
          #{params}.map { |param| self.send(param) }.values_at(*indexes)
        end

        define_method :eql? do |other|
          values = #{params}.map { |param| self.send(param) }
          self_members_values = Hash[#{params}.zip values]
          other_values = #{params}.map { |param| other.send(param) }
          other_members_values = Hash[#{params}.zip other_values]
          (self.class == other.class) &&
          (self_members_values == other_members_values) ? true : false
        end

        alias :length :size
        alias :== :eql?
      end
CODE
    struct
  end
end
