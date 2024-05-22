class Person
  attr_accessor :first_name, :last_name

  def initialize(full_name)
    parse_full_name(full_name)
  end

  def name
    "#{first_name} #{last_name}".strip
  end

  def name=(full_name)
    parse_full_name(full_name)
  end

  def parse_full_name(full_name)
    first_name, last_name = full_name.split
    self.first_name = first_name
    self.last_name = last_name ? last_name : ''
  end

  def same_name?(other_person)
    name == other_person.name
  end

  def to_s
    name
  end
end

bob = Person.new("Robert Smith")
rob = Person.new("Robert Smith")
p bob.same_name?(rob)
puts "The person's name is #{bob}"
