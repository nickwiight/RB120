class Pet
  attr_reader :type, :name
  
  def initialize(type, name)
    @type = type
    @name = name
  end
end

class Owner
  attr_accessor :pets
  attr_reader :name
  
  def initialize(name)
    @name = name
    @pets = 0
  end

  def number_of_pets
    @pets
  end
end

class Shelter
  def initialize
    @adoption_records = Hash.new { |h, k| h[k] = [] }
  end

  def adopt(owner, pet)
    @adoption_records[owner] << pet
    owner.pets += 1
  end

  def print_adoptions
    @adoption_records.each do |owner, pets|
      puts "#{owner.name} has adopted the following pets:"
      pets.each { |pet| puts "a #{pet.type} named #{pet.name}"}
      puts
    end
  end
end

butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new
shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."
