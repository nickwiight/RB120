class Cat
  @@number_of_cats = 0

  def initialize
    @@number_of_cats += 1
  end

  def self.total
    @@number_of_cats
  end
end

kitty1 = Cat.new
kitty2 = Cat.new
puts Cat.total
