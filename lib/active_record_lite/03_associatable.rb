require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    options.each do |option, value|
      instance_variable_set("@" + option.to_s, value)
    end

    @class_name  ||= name.to_s.camelcase
    @primary_key ||= :id
    @foreign_key ||= "#{name}_id".to_sym
  end
end

class HasManyOptions < AssocOptions
  attr_reader :class_name, :primary_key, :foreign_key

  def initialize(name, self_class_name, options = {})
    options.each do |option, value|
      instance_variable_set("@" + option.to_s, value)
    end

    @class_name  ||= name.to_s.singularize.camelcase
    @primary_key ||= :id
    @foreign_key ||= "#{self_class_name.underscore}_id".to_sym
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    foreign_key = options.foreign_key.to_sym
    self.assoc_options[name] = options

    define_method(name) do
      options
      .model_class
      .where(options.primary_key => self.send(foreign_key))
      .first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    primary_key = options.primary_key.to_sym

    define_method(name) do
      options
      .model_class
      .where(options.foreign_key => self.send(primary_key))
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end