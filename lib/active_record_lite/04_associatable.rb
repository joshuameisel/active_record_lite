require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

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
    @foreign_key ||= "#{name.to_s}_id".to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    options.each do |option, value|
      instance_variable_set("@" + option.to_s, value)
    end
    
    @class_name  ||= name.to_s.singularize.camelcase
    @primary_key ||= :id
    @foreign_key ||= "#{self_class_name.downcase}_id".to_sym
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    instance_variable.set("@" + name.to_s, BelongsToOptions.new(name, options))
    has_many_options = instance_variable.get("@" + name.to_s)
    define_method(name) do
      DBConnection.execute([<<-SQL, 
      SELECT 
        * 
      FROM 
        ?
      WHERE
        ?=?
      SQL
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  include Associatable
end
