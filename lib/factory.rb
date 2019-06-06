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
    validate(name, params)

    if name.is_a? String
      const_set(name.capitalize, struct_class(params, &block))
    else
      params.unshift(name)
      struct_class(params, &block)
    end
  end

  def self.struct_class(params, &block)
    Class.new do |klass|
      attr_accessor(*params)

      def initialize(*options, &block)
        raise ArgumentError if options.size != members.size

        Hash[members.zip options].each do |member, opt|
          public_send(member.to_s + '=', opt)
        end
      end

      define_method :[] do |selector|
        selector = members[selector] if selector.is_a? Integer
        public_send(selector)
      end

      define_method :[]= do |selector, value|
        selector = members[selector] if selector.is_a? Integer
        public_send(selector.to_s + '=', value)
      end

      define_method :each do |&blk|
        values.each(&blk)
      end

      define_method :each_pair do |&blk|
        struct_hash.each(&blk)
      end

      define_method :dig do |*indexes|
        struct_hash.dig(*indexes)
      end

      define_method :size do
        members.size
      end

      define_method :members do
        params
      end

      define_method :select do |&blk|
        values.select(&blk)
      end

      define_method :to_a do
        values
      end

      define_method :values_at do |*indexes|
        values.values_at(*indexes)
      end

      define_method :eql? do |other|
        (self.class == other.class) && (struct_hash == struct_hash(other))
      end

      alias :length :size
      alias :== :eql?

      klass.class_eval(&block) if block_given?

      private

      define_method :values do |other = nil|
        if other
          members.map { |member| other.public_send(member) }
        else
          members.map { |member| public_send(member) }
        end
      end

      define_method :struct_hash do |other = nil|
        other ? Hash[members.zip values(other)] : Hash[members.zip values]
      end
    end
  end

  def self.validate(name, params)
    raise ArgumentError unless (name.is_a? String) || (name.is_a? Symbol)
    raise ArgumentError unless params.all? { |param| param.is_a? Symbol }
  end
end
