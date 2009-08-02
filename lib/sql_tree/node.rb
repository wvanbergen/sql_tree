class SQLTree::Node

  def inspect
    "#{self.class.name}[#{self.to_sql}]"
  end
  
  def quote_var(name)
    "\"#{name}\""
  end
  
  def quote_str(str)
    "'#{str.gsub(/\'/, "''")}'"
  end
  
  def self.[](arg, field = nil)
    if field.nil?
      case arg
        when Symbol; Variable.new(arg.to_s)
        else;        Value.new(arg) 
      end
    else
      Field[arg, field]
    end
  end

end
