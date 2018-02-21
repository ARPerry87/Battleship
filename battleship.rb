class Grid
  attr_reader :size

  def initialize(size = 10)
    @size = size
    @ship_spots = []
    @squares = Array.new(size) do |y|
      Array.new(size) { |x| Square.new(self, x, y) }
    end
  end

  def [](x, y)
    return nil unless (0...size).cover?(x)
    return nil unless (0...size).cover?(y)
    @squares[y][x]
  end

  def free_squares
    free_areas(@squares) + free_areas(@squares.transpose)
  end

  def place_ship(size)
    span = free_squares.select { |span| span.count >= size }.sample
    raise "Too many ships, boss" unless span
    offset = rand(0..span.count - size)
    @ship_spots << span.slice(offset, size)
    @ship_spots.last.each{ |c| c.ship = size }
  end

  def coordinates
    @ship_spots.map do |squares|
      squares.map{ |s| [s.x, s.y] }
    end
  end

  def to_s
    @squares.map do |row|
      row.map(&:to_s).join(" ")
    end.join("\n")
  end

  private

  def free_areas(grid)
    grid.flat_map do |row|
      row.chunk(&:free?).select(&:first).map(&:last)
    end
  end
end

# A grid square
class Square
  attr_reader :x, :y
  attr_accessor :ship

  def initialize(grid, x, y)
    @grid = grid
    @x = x
    @y = y
    @ship = nil
  end

  # Is there a ship on this square?
  def blank?
    ship.nil?
  end

  def free?
    blank? && neighbors.all?(&:blank?)
  end

  def neighbors
    @neighbors ||= [-1, 0, 1].repeated_permutation(2).map do |nx, ny|
      @grid[x + nx, y + ny] unless dx.zero? && dy.zero?
    end.compact
  end

  def to_s
    blank? ? "·" : ship.to_s
  end
end

grid = Grid.new 

t =  2
d =  3
s =  3
b =  4
c =  5

ships = [t, d, s, b, c]
ships.each{ |size| grid.place_ship(size)}


puts grid
