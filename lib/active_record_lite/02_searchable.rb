require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_list = []
    params.each do |col, value|
      where_str = "#{col} = "
      where_str += value.is_a?(String) ? "'#{value}'" : "#{value}"
      where_list << where_str
    end

    self.parse_all(
      DBConnection.execute(
        "SELECT * " +
        "FROM #{self.table_name} " +
        "WHERE #{where_list.join(" AND ")}"
      )
    )
  end
end

class SQLObject
  extend Searchable
end
