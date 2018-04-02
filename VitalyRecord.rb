require 'pg' # вызов postgre

class Vr
  def initialize (params)
    params.each do |key, value|
      self.send("#{key}=", value) if value
    end
  end

  def self.connect_db #  Запускает коннект . Происходит PG::Connection.open или PG::Connection.new
    @connect = PG.connect :dbname => 'test_vr', :user => 'admin', :password => '' 
  end

  def connect_db #  Запускает коннект . Происходит PG::Connection.open или PG::Connection.new
    self.class.connect_db
  end

  def self.select_all
    inquiry = "SELECT * FROM #{tb_name};"
    arr = self::Relation.new()
    p arr 
    connect_db.exec(inquiry) do |result|
      arr = result.map { |e|
        self.new(e)
      }
    end
    @connect.close
    arr
  end

  def self.limit(param)
    inquiry = "SELECT * FROM #{tb_name} LIMIT #{param};" 
    arr = []
    connect_db.exec(inquiry) do |result|
      arr = result.map { |e|
        self.new(e)
      }
    end
    @connect.close
    arr
  end

  def self.add_entry(params) #Добавить запись
    values = Array.new
    columns = Array.new
    params.each{|key, value| columns.push(key.to_s); values.push("'#{value.to_s}'")}
    columns = columns.join(", ") #Значения передаются через запятую (", ")
    values = values.join(", ")
    inquiry = "INSERT INTO #{tb_name} (#{columns}) values (#{values}) returning *" #Вводятсяс столбцы через запятую и значения через запятую
    record = connect_db.exec(inquiry)
    @connect.close
    self.new(record[0])
  end

  def delete_entry #Удалить запись
    connect_db.exec("DELETE FROM #{tb_name} WHERE id=#{self.id}") # Тупа где-то вписывается id
    connect_db.close
    self
  end

  def update_entry(params)# Изменить запись
    updates = Array.new
    params.each {|key, val| updates.push("#{key} = '#{val}'")} # В массиве будут пары (ключ = 'значение')
    updates = updates.join(", ")# И эти пары будут через запятую
    inquiry = "UPDATE #{tb_name} SET #{updates} WHERE id=#{self.id} "
    connect_db.exec(inquiry)
    connect_db.close
    self
  end


  def column_add(new_column_name, datatype)
    connect_db.exec("ALTER TABLE #{tb_name} ADD [ COLUMN ] [ IF NOT EXISTS ] #{new_column_name} #{datatype};")
    @connect.close
  end

  def column_drop(column_name)
    connect_db.exec("ALTER TABLE #{tb_name} DROP [ COLUMN ] [ IF EXISTS ] #{column_name};")
    @connect.close
  end

  def table_rename(tb_name_new)
    connect_db.exec("ALTER TABLE [ IF EXISTS ] #{tb_name} RENAME TO #{tb_name_new};")
    @connect.close
  end

  def column_rename(column_name, column_new_name)
    connect_db.exec("ALTER TABLE [ IF EXISTS ] [ ONLY ] #{tb_name} [ * ] RENAME [ COLUMN ] #{column_name} TO #{column_new_name}")    
    @connect.close
  end

  # def alias_columns(params) 
  #   columns
  #   inquiry = ("SELECT колонка1 AS колонка1нов " + "#{any_colomn}" + "FROM #{tb_name};")
  #   connect_db.exec(inquiry) do |result|# Запускае коннект.с пеередачей данных командной строке (того, что в скобках)
  #     result.each { |e|
  #       p e #Короче таблица выводится
  #     }
  #   end
  #   @connect.close
  # end
  def self.find_entry(id)
    inquiry = "SELECT * FROM #{tb_name} WHERE ID = #{id} LIMIT 1"
    arr = []
    connect_db.exec(inquiry) do |result|
      arr = result.map { |e|
        self.new(e)
      }
    end
    @connect.close
    arr.first
  end

  def self.tb_name #Если применить метод к самой таблице, то выведется "строка"
    tb_name = self.to_s.downcase + "s"
  end

  def self.where(params)
    updates = []
    params.each{|key, val| updates.push("#{key} = '#{val}'")} 
    inquiry = "SELECT * FROM #{tb_name} WHERE #{updates.join(" AND ")}"
    arr = []
    connect_db.exec(inquiry) do |result|
      arr = result.map { |e|
        self.new(e)
      }
    end
    @connect.close
    arr
  end

  def self.order(column_name, trend = "ASC")
    inquiry = "SELECT * FROM #{tb_name} ORDER BY #{column_name} #{trend};"
    arr = []
    connect_db.exec(inquiry) do |result|
      arr = result.map { |e|
        self.new(e)
      }
    end
    @connect.close
    arr
  end

  def tb_name 
    self.class.tb_name
  end

  class Relation

  end
end









