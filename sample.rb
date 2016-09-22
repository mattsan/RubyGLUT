require './gl'
require './glut'

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other)
    Point.new(@x + other.x, @y + other.y)
  end

  def to_s
    "(#{x}, #{y})"
  end
end

class Boundary
  attr_reader :lefttop, :rightbottom

  def initialize(lefttop, rightbottom)
    @lefttop, @rightbottom = lefttop, rightbottom
  end

  def rearranges
    @rightbottom.x, @lefttop.x =  @lefttop.x, @rightbottom.x if @rightbottom.x < @lefttop.x
    @rightbottom.y, @lefttop.y =  @lefttop.y, @rightbottom.y if @rightbottom.y < @lefttop.y
  end

  def +(other)
    Boundary.new(lefttop + other.lefttop, rightbottom + other.rightbottom)
  end

  def leftbottom
    Point.new(rightbottom.x, rightbottom.y)
  end

  def righttop
    Point.new(rightbottom.x, lefttop.y)
  end

  def left
    lefttop.x
  end

  def right
    rightbottom.x
  end

  def top
    lefttop.y
  end

  def bottom
    rightbottom.y
  end

  def includes?(point)
    lefttop.x <= point.x && point.x <= rightbottom.x &&
    lefttop.y <= point.y && point.y <= rightbottom.y
  end

  def overlaps_with(other)
    includes?(other.lefttop)    || includes?(other.righttop)    ||
    includes?(other.leftbottom) || includes?(other.rightbottom) ||
    other.includes?(lefttop)    || other.includes?(righttop)    ||
    other.includes?(leftbottom) || other.includes?(rightbottom)
  end

  def to_s
    "#{@lefttop}-#{@rightbottom}"
  end
end

class RGBColor
  attr_reader :rgb

  def initialize(r = 0, g = 0, b = 0)
    @rgb = [r.to_f, g.to_f, b.to_f]
  end

  def to_s
    format('(%f, %f, %f)', *rgb)
  end
end

class Text
  SCALE = 0.1
  COLOR = RGBColor.new(1, 0, 0).freeze

  def initialize(position)
    @position = position
    @text = ''
  end

  def set(text)
    @text = text
  end

  def get
    @text
  end

  def draw
    GL.color3dv(COLOR.rgb)
    GL.push_matrix
    GL.translatef(@position.x, @position.y, 0)
    GL.scalef(SCALE, -SCALE, 0)
    @text.chars.each {|c| GLUT.stroke_character(GLUT::STROKE_ROMAN, c) }
    GL.pop_matrix
  end
end

class ShapeObject
  attr_reader :game, :position

  def initialize(game, position)
    @game = game
    @position = position
  end

  def visible?
    game.screen.includes?(position)
  end

  def draw_with_color(color)
    GL.color3dv(color.rgb)
    GL.primitive(GL::POLYGON) do
      points.each do |point|
        GL.vertex2i(position.x + point.x, position.y + point.y)
      end
    end
  end

  def move(delta)
    @position += delta
  end
end

class Bullet < ShapeObject
  def initialize(game, position, delta, color)
    super(game, position)
    @delta = delta
    @color = color
    @visible = true
  end

  def points
    @points ||= [
      Point.new(-3,  -5),
      Point.new( 0, -10),
      Point.new( 3,  -5),
      Point.new( 0,   0)
    ].freeze
  end

  def boundary
    Boundary.new(position + Point.new(-3, -10), position + Point.new(3, 0))
  end

  def visible=(visible)
    @visible = visible
  end

  def visible?
    @visible && super
  end

  def move
    if visible?
      super(Point.new(0, @delta))
    end
  end

  def draw
    draw_with_color(@color) if visible?
  end
end

class Alien < ShapeObject
  BULLET_SPEED = 10
  COLOR = RGBColor.new(1, 0.5, 0).freeze

  def initialize(game)
    super(game, Point.new(20, 20))
    @speed = Point.new(5, 10)
  end

  def points
    @points ||= [
      Point.new( -5, -5),
      Point.new(  5, -5),
      Point.new( 10,  0),
      Point.new(  5,  5),
      Point.new(  2,  2),
      Point.new( -2,  2),
      Point.new( -5,  5),
      Point.new(-10,  0)
    ]
  end

  def boundary
    Boundary.new(@position + Point.new(-10, -5), @position + Point.new(10, 5))
  end

  def fire
    Bullet.new(game, position, BULLET_SPEED, COLOR)
  end

  def turn
    @speed = Point.new(-@speed.x, @speed.y)
  end

  def move
    super(Point.new(@speed.x, 0))
    screen = game.screen

    if (@position.x < screen.left) || (screen.right < @position.x)
      turn
      super(Point.new(0, @speed.y))
    end
  end

  def draw
    draw_with_color(COLOR)
  end
end

class Aliens
  def initialize(game)
    @game = game
    @aliens = []
    @bullets = []
  end

  def add_alien
    @aliens.push Alien.new(@game)
  end

  def hit_by?(object)
    return false unless object&.visible?

    alien = @aliens.find {|alien| object.boundary.overlaps_with(alien.boundary) }

    return false unless alien

    @aliens.delete(alien)

    true
  end

  def hits(object)
    @bullets.find {|bullet| object.boundary.overlaps_with(bullet.boundary) }
  end

  def clear_bullets
    @bullets = []
  end

  def draw
    @aliens.each(&:draw)
    @bullets.each(&:draw)
  end

  def move
    @aliens.each(&:move)
    @bullets.each(&:move)

    @bullets.delete_if {|bullet| !bullet.visible? }

    @aliens.each do |alien|
      @bullets.push alien.fire if rand(20) == 1
    end
  end
end

class Ship < ShapeObject
  DELTA = 10
  COLOR = RGBColor.new(0, 0, 1).freeze
  BULLET_SPEED = -10

  def initialize(game, position)
    super(game, position)
  end

  def points
    @points ||= [
      Point.new(-10,   0),
      Point.new(  0, -10),
      Point.new( 10,   0),
      Point.new( 10,  10),
      Point.new(-10,  10)
    ]
  end

  def boundary
    Boundary.new(@position + Point.new(-10, 0), @position + Point.new(10, 10))
  end

  def move_left
    move(Point.new(-DELTA, 0))
  end

  def move_right
    move(Point.new(DELTA, 0))
  end

  def move_up
    move(Point.new(0, -DELTA))
  end

  def move_down
    move(Point.new(0, DELTA))
  end

  def fire
    Bullet.new(game, position, BULLET_SPEED, COLOR)
  end

  def draw
    draw_with_color(COLOR)
  end
end

class Game
  SPACE  = ' '.ord
  Q      = 'q'.ord
  CTRL_C = 3
  POINT_PER_ALIEN = 10

  attr_reader :width, :height, :interval

  def initialize
    @width = 320
    @height = 240
    @interval = 100
    @my_ship = Ship.new(self, Point.new(@width / 2, @height / 2))
    @my_bullet = Bullet.new(self, Point.new(0, 0), Ship::BULLET_SPEED, Ship::COLOR)
    @aliens = Aliens.new(self)
    @text = Text.new(Point.new(10, 12))
    @score = 0
    @left  = 3
    @my_bullet.visible = false
  end

  def draw
    GL.clear(GL::COLOR_BUFFER_BIT)
    @my_ship.draw
    @my_bullet.draw
    @aliens.draw
    @text.draw
    GLUT.swap_buffers
  end

  def display
    draw
  end

  def reshape(width, height)
    GL.viewport(0, 0, width, height)
    @width = width
    @height = height
    GL.load_identity
    GL.ortho(-0.5, width - 0.5, height - 0.5, -0.5, -1.0, 1.0)
  end

  def keyboard(key, x, y)
    case key
    when SPACE
      @my_bullet = @my_ship.fire unless @my_bullet.visible?
    when CTRL_C
      exit
    when Q
      GC.enable
      GC.start
    else
      puts key
    end
  end

  def special(key, x, y)
    case key
    when GLUT::KEY_LEFT  then @my_ship.move_left
    when GLUT::KEY_RIGHT then @my_ship.move_right
    when GLUT::KEY_UP    then @my_ship.move_up
    when GLUT::KEY_DOWN  then @my_ship.move_down
    end
  end

  def timer(value)
    @my_bullet.move
    @aliens.move

    @aliens.add_alien if rand(20) == 1

    if @aliens.hit_by?(@my_bullet)
      @score += POINT_PER_ALIEN
      @my_bullet.visible = false
    end

    my_ship_hit = @aliens.hits(@my_ship)

    @text.set(format('SCORE : %06d / LEFT : %d', @score, @left))

    clear_color = my_ship_hit ? RGBColor.new(1.0, 0.8, 0.8) : RGBColor.new(1, 1, 1)
    GL.clear_color(*clear_color.rgb, 1.0)

    draw

    if my_ship_hit
      return false if @left == 0

      @left -= 1
      @aliens.clear_bullets
    end

    true
  end

  def screen
    Boundary.new(Point.new(0, 0), Point.new(@width, @height))
  end
end

GC.disable

game = Game.new

GLUT.init_window_position(100, 100)
GLUT.init_window_size(game.width, game.height)
GLUT.init(ARGV)
GLUT.init_display_mode(GLUT::RGBA + GLUT::DOUBLE)
GLUT.create_window('sample.rb')
GL.clear_color(1.0, 1.0, 1.0, 1.0)

GLUT.main_loop(game)
