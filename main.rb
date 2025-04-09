#Kollision
#Kaströrelse

#initialize

require 'ruby2d'

WindowWidth = 700
WindowHeight = 670

set width: WindowWidth
set height: WindowHeight

$period = 3.1
shot = false
power = 1
add = 0.5
time = 0
blocks = []
collision = false
$type_of_collision = nil
$pos = nil
#classes

class Background
  def draw
    Image.new(
    'astronomy.jpg',
    x: 0, y: 0,
    width: WindowWidth, height: WindowHeight,
    z: -1
    )
  end
end

class Block
  attr_accessor :block
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  def initialize(x,y,width,height)
    @collision = false
    @x = x
    @y = y
    @width = width
    @height = height
  end

  def draw()
    @block = Rectangle.new(
    x:@x, y:@y, width:@width,height:@height,color:'red',z:0
    )
  end

  def collisionDetection(blocks,golfball)
    return golfball && collission_detected?(blocks,golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def abs(value)
    value1 = 0
    value1 = value
    if value1 < 0
      value1 *= -1
    end
    return value1
  end

  def collission_detected?(blocks,golfball)
    i = 0
    while i < blocks.length

      blockx1 = blocks[i].x
      blockx2 = blocks[i].x + block.width
      blocky1 = blocks[i].y
      blocky3 = blocks[i].y + block.height
      
    
      if golfball.x1 >= blockx1 - golfball.width + 1 && golfball.x2 <= blockx2 + golfball.width - 1 
        if golfball.y3 >= blocky1 && golfball.y3 <= blocky1 + 4
          #puts "Golfboll faller på ett block"
          
          $type_of_collision = "down"
          #p $type_of_collision
          $pos = [0,blocky1 - golfball.height ]
          
          return true
        elsif golfball.y1 <= blocky3 && golfball.y1 >= blocky1 - 4
          #puts "Golfboll åker upp i ett block"
         
          $type_of_collision = "up"
          #p $type_of_collision
          $pos = [0,blocky3 + 1]
        
          
          return true
        end
      elsif golfball.y1 >= blocky1 - golfball.height + 1 && golfball.y3 <= blocky3 + golfball.height - 1
        if golfball.x1 <= blockx2 + 2 && golfball.x1 >= blockx2 - 4
          #puts "Golfboll åker vänster i ett block"
          
          $type_of_collision = "left"
          #p $type_of_collision
          $pos = [blockx2 + 3,0]
          
          
          return true
        elsif golfball.x2 >= blockx1 - 2 && golfball.x2 <= blockx1 + 4
          #puts "Golfboll åker höger i ett block"
         
          $type_of_collision = "right"
          #p $type_of_collision
          $pos = [(blockx1 - 3) - golfball.width,0]

          return true
        end
      end
      i += 1
    end
  end
end

class Player
  attr_accessor :x
  attr_accessor :y
  attr_accessor :width
  attr_accessor :height
  attr_accessor :golfball
  def initialize()
    @x = 100
    @y = 100
    @grav = 0
    @width = 20
    @height = 20
    @xmultiplier = 1
    @ymultiplier = 1
    @middlepoint = 1
    @zmulitplier = 1
    @onetime = true
    @xspeed = 0
    @yspeed = 0
  end

  def draw
    @golfball = Square.new(
    x: @x, y: @y,
    size:@width,
    color: 'teal',
    z: 1
    )
  end

  def move(bool,strength,meterx,metery,collision)
    @middlepoint = [@x + @width/2, @y + @height/2]

    if bool
      @xmultiplier = meterx + 5 - @middlepoint[0]
      @ymultiplier = metery + 5 - @middlepoint[1]
      @zmulitplier = Math.sqrt(@ymultiplier ** 2 + @xmultiplier ** 2)

      @xspeed = strength * (@xmultiplier/@zmulitplier)/2
      @yspeed = strength * @ymultiplier/@zmulitplier
    end

    if collision && @onetime
      if $type_of_collision == "left" || $type_of_collision == "right"
        @xspeed *= -1
      else
        @yspeed *= -1
        @grav *= -1
      end
    end

    if collision 
      if $pos[0] == 0
        @y = $pos[1]
      elsif $pos[1] == 0
        @x = $pos[0]
      end

      @xspeed *= 0.7
      @yspeed *= 0.7
      @grav *= 0.7

      @onetime = false

      if @grav > -0.2 && @grav < 0
        @grav = 0
      end
    else
      @onetime = true

      if @grav < 7
        @grav += 0.05
      end
    end

    @x += @xspeed
    @y += @yspeed + @grav

    if @xspeed < 0.03 && @xspeed > -0.03
      @xspeed = 0.0
    end

    if @yspeed < 0.03 && @yspeed > -0.03
      @yspeed = 0.0
    end

    @xspeed *= 0.99;
    @yspeed *= 0.99
  end
end

class PowerMeter
  attr_accessor :x
  attr_accessor :y
  def initialize
    @x = 100
    @y = 100
    @width = 10
    @height = 10
  end

  def draw(color)
    Rectangle.new(
      x:@x,y:@y,
      width:@width, height: @height,
      color: [1-color/20.0, 1-color/20.0, 1-color/20.0, 1],
      z:1
    )
  end

  def move(playerx,playery,playerwidth,playerheight)
    @x = playerx + (playerwidth - @width)/2 + (Math.sin($period) * 30).to_i
    @y = playery + (playerheight - @height)/2 + (Math.cos($period) * 30).to_i
  end
end

#listeners

on :key_held do |event|
  case event.key
  when 'left'
    $period += 0.1
  when 'right'
    $period -= 0.1
  when 'space'
    if power == 20
      add *= -1
    elsif power == 0
      add *= -1
    end
    power += add
  end
end

on :key_up do |event|
  case event.key
  when 'space'
    shot = true
  end
end

#update

player = Player.new
powerMeter = PowerMeter.new
background = Background.new

blocks << Block.new(0,WindowHeight-5,WindowWidth,10)
blocks << Block.new(0,150,WindowWidth-50,10)
blocks << Block.new(50,300,WindowWidth-50,10)
blocks << Block.new(WindowWidth-5,0,10,WindowHeight)
blocks << Block.new(300, 400, 20, 100)
blocks << Block.new(0,0,10,WindowHeight)
blocks << Block.new(0,0,WindowWidth,10)

update do
  clear

  background.draw

  player.draw
  player.move(shot,power,powerMeter.x,powerMeter.y,collision)

  powerMeter.draw(power)
  powerMeter.move(player.x,player.y,player.width,player.height)

  if shot 
    shot = false
    power = 1
  end

  collision = false

  blocks.each do |block|
    block.draw
    if block.collisionDetection(blocks,player.golfball)
      collision = true
    end
  end
end

#run

show