require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    # ...
  end
end

class SQLObject < MassObject 
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end
  
  def self.columns
    DBConnection.execute2("SELECT * FROM " + self.table_name)
      .first
      .map(&:to_sym)
  end
  
  if self.superclass == SQLObject
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end
    
      define_method(col.to_s + "=") do |val|
        attributes[col] = val
      end
    end
  end
  
  def self.all
    # ...
  end

  def self.find(id)
    # ...
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.includes?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'" 
      end
      @attributes[attr_name.to_sym = val]
    end
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end
