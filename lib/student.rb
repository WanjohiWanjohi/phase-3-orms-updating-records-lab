require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name , grade ,id= nil)
    @name = name
    @grade = grade
    @id = id
  end
  
  def self.create_table 
    sql= <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name VARCHAR(255),
      grade INTEGER
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students
    SQL
    DB[:conn].execute(sql)
  end
  
  def save 
    sql = <<-SQL
    INSERT INTO students (name, grade)
    VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.grade)
  self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end
  def update
    sql = <<-SQL 
    UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def self.create(name, grade)
    stud = Student.new(name, grade)
    stud.save
  end

  def self.new_from_db(row)
    stud = Student.new(row[1], row[2])
    stud.id = row[0]
    return stud

  end
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students WHERE name = ?
    SQL
    DB[:conn].execute(sql, name).map do|song|
    self.new_from_db(song)
    end.first
    end
end
