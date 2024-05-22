module Towable
  def can_tow?(pounds)
    pounds < 2000
  end
end

class Vehicle
  @@vehicle_count = 0
  attr_accessor :color, :model, :speed
  attr_reader :year

  def initialize(year, color, model)
    @year = year
    self.color = color
    self.model = model
    self.speed = 0
    @@vehicle_count += 1
  end

  def to_s
    "This #{year} #{model} is #{color}."
  end

  def speed_up(amount)
    self.speed += amount
  end

  def brake(amount)
    self.speed -= amount
  end

  def shut_off
    puts 'Shutting off car'
  end

  def spray_paint(color)
    self.color = color
  end
 
  def self.mpg(miles, galons)
    "Getting #{miles / galons} mpg."
  end

  def self.print_vehicle_count
    puts "There are #{@@vehicle_count} vehicles."
  end

  def age
    "Your #{model} is #{calculate_age} years old."
  end

  private

  def calculate_age
    Time.now.year - year
  end
end

class MyCar < Vehicle
  NUMBER_OF_DOORS = 4
end

class MyTruck < Vehicle
  include Towable
end
car = MyCar.new(2004, 'yellow', 'Corolla')
truck = MyTruck.new(2018, 'red', 'F150')
puts car
puts car.age
puts truck.age
# puts MyCar.ancestors
# puts Vehicle.ancestors
# puts MyTruck.ancestors
