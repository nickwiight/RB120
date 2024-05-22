class Pet
  def speak
    'unimplemented'
  end

  def swim
    'swimming!'
  end

  def run
    'running!'
  end

  def jump
    'jumping!'
  end

  def fetch
    'fetching!'
  end
end

class Dog < Pet
  def speak
    'bark!'
  end
end

class Bulldog < Dog
  def swim
    "can't swim!"
  end
end

class Cat < Pet
  def speak
    'meow!'
  end

  def swim
    "can't swim!"
  end

  def fetch
    "can't fetch!"
  end
end

teddy = Dog.new
puts teddy.speak
puts teddy.swim

karl = Bulldog.new
puts karl.speak
puts karl.swim
p Bulldog.ancestors
