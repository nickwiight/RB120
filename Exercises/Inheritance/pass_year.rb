class Vehicle
  attr_reader :year

  def initialize(year)
    @year = year
  end
end

class Truck < Vehicle
  attr_reader :bed_size

  def initialize(year, bed_size)
    super(year)
    @bed_size = bed_size
  end
end

class Car < Vehicle
end

truck1 = Truck.new(1994, 'Short')
puts truck1.year
puts truck1.bed_size

car1 = Car.new(2006)
puts car1.year
