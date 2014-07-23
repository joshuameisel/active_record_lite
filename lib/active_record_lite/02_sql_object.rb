require_relative 'db_connection'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |attributes| self.new(attributes) }
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
    return @columns if @columns

    @columns = DBConnection.execute2("SELECT * FROM " + self.table_name)
      .first
      .map(&:to_sym)
    @columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method(col.to_s + "=") do |val|
        attributes[col] = val
      end
    end

    @columns
  end

  def self.all
    self.parse_all(
      DBConnection.execute("SELECT * FROM " + self.table_name)
    )
  end

  def self.find(id)
    self.parse_all(
      DBConnection.execute(
        "SELECT * FROM " + self.table_name + " WHERE id = " + id.to_s
      )
    ).first
  end

  def attributes
    @attributes ||= {}
  end

  def update
    set_string = ""
    attributes.each do |col, val|
      value_str = val.is_a?(String) ? "'#{val}'" : val.to_s
      set_string.concat("#{col.to_s}=#{value_str},")
    end
    set_string.chop!

    DBConnection.execute(
      "UPDATE #{self.class.table_name} " +
      "SET #{set_string} " +
      "WHERE id=#{self.id}"
    )
  end

  def insert
    attributes[:id] = self.class.all.last.id + 1
    column_strs, value_strs = [], []

    self.class.columns.each do |col|
      next if col == :id

      column_strs << col.to_s

      value = attributes[col]
      value_strs << (value.is_a?(String) ? "'#{value}'" : value.to_s)
    end

    column_string = "(#{column_strs.join(',')})"
    value_string = "(#{value_strs.join(',')})"

    DBConnection.execute(
      "INSERT INTO #{self.class.table_name} #{column_string} " +
      "VALUES #{value_string}"
    )
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      attributes[attr_name.to_sym] = val
    end
  end

  def save
    self.id ? self.update : self.insert
  end

  def attribute_values
    return self.class.columns.map { |col| attributes[col] }
  end
end