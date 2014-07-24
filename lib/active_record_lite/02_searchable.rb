require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_strs = []
    params.each do |col, value|
      where_str = "#{col} = "
      where_str += value.is_a?(String) ? "'#{value}'" : value.to_s
      where_strs << where_str
    end

    self.parse_all(
      DBConnection.execute(
        "SELECT * " +
        "FROM #{self.table_name} " +
        "WHERE #{where_strs.join(" AND ")}"
      )
    )
  end
end

class SQLObject
  extend Searchable
end