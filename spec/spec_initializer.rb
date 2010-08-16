class Rails
  class Railtie
  end
  def self.version
    '3.0.0.RC'
  end

  def self.root
    File.dirname(__FILE__)
  end
end


def write_inheritable_attribute(key, value)
  @attributes ||= {}
  @attributes[key] = value
end

def read_inheritable_attribute(key)
  (@attributes||{})[key]
end

def initializer(*args)
end
