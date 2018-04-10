require 'pg'


class VRecord


	def initialize (params={})
	    params.each do |key, value|
	      self.send("#{key}=", value) if value
    	end
  	end

  	def self.connect_db 
   		@connect = PG.connect :dbname => 'test_vr', :user => 'admin', :password => '' 
  	end

	def self.tb_name
    	tb_name = self.to_s.downcase
  	end  

  	def self.select_all
	    inquiry = "SELECT * FROM #{tb_name}"
	    arr = self::Relation.new
	    connect_db.exec(inquiry) do |result|
	      result.each { |e|
	        arr << self.new(e)
	      }
	    end
	    @connect.close
	    arr
 	end

    def self.limit(param)
	    inquiry = "SELECT * FROM #{tb_name} LIMIT #{param};" 
	    arr = self::Relation.new
	    connect_db.exec(inquiry) do |result|
	      result.each { |e|
	        arr << self.new(e)
	      }
	    end
	    @connect.close
	    arr
    end

    def self.find_entry(id)
	    inquiry = "SELECT * FROM #{tb_name} WHERE ID = #{id} LIMIT 1"
	    arr = []
	    connect_db.exec(inquiry) do |result|
	      arr = result.map { |e|
	        arr << self.new(e)
	      }
	    end
	    @connect.close
	    arr.first
    end

    def self.add_entry(params) #Добавить запись
	    values = []
	    columns = []
	    params.each{|key, value| columns.push(key.to_s); values.push("'#{value.to_s}'")}
	    columns = columns.join(", ") 
	    values = values.join(", ")
	    inquiry = "INSERT INTO #{tb_name} (#{columns}) values (#{values}) returning *" 
	    record = connect_db.exec(inquiry)
	    @connect.close
	    self.new(record.first) #Здесь выводим запись
    end

    def self.delete_entry(id) #Удалить запись по id
	    connect_db.exec("DELETE FROM #{tb_name} WHERE ID = #{id}")
	    @connect.close
	end

    def self.update_entry(column_name, new_value, id)# Изменить запись по id
    	inquiry = "UPDATE #{tb_name} SET #{column_name} = #{new_value} WHERE ID = #{id}"
	    connect_db.exec(inquiry)
	    @connect.close
    end

    def self.where(params) #Точный поиск по нескольким значениям
	    updates = []
	    params.each{|key, val| updates.push("#{key} = '#{val}'")} 
	    inquiry = "SELECT * FROM #{tb_name} WHERE #{updates.join(" AND ")}"
	    arr = self::Relation.new
	    connect_db.exec(inquiry) do |result|
	      result.each { |e|
	        arr << self.new(e)
	      }
	    end
	    @connect.close
	    arr
    end

    def self.order(column_name, trend = "ASC")
	    inquiry = "SELECT * FROM #{tb_name} ORDER BY #{column_name} #{trend};"
	    arr = self::Relation.new
	    connect_db.exec(inquiry) do |result|
	      result.each { |e|
	        arr << self.new(e)
	      }
	    end
	    @connect.close
	    arr
    end

    def self.column_add(new_column_name, datatype = 'Text')
	    connect_db.exec("ALTER TABLE #{tb_name} ADD COLUMN IF NOT EXISTS #{new_column_name} #{datatype};")
	    @connect.close
    end

    def self.column_drop(column_name)
	    connect_db.exec("ALTER TABLE #{tb_name} DROP COLUMN IF EXISTS #{column_name};")
	    @connect.close
    end

    def table_rename(tb_name_new)
	    connect_db.exec("ALTER TABLE IF EXISTS #{tb_name} RENAME TO #{tb_name_new};")
	    @connect.close
    end

    def column_rename(column_old_name, column_new_name)
	    connect_db.exec("ALTER TABLE IF EXISTS ONLY #{tb_name} * RENAME COLUMN #{column_name} TO #{column_new_name}")    
	    @connect.close
    end

  

    class Relation < Array #Массив создан так, чтоб вы#бнуться
    end






end