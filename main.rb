#Kollision
#Kaströrelse

#initialize

require 'ruby2d'

WindowWidth = 700
WindowHeight = 670

set width: WindowWidth
set height: WindowHeight

period = 3.1
shot = false
power = 1
add = 0.5
time = 0
blocks = []
hello = false

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
  def initialize(x,y,width,height)
    @collision = false
    @x = x
    @y = y
    
    @width = width
    @height = height
  end
  def draw
    @block = Rectangle.new(
    x:@x, y:@y, width:@width,height:@height,color:'red',z:5
    )
  end

  def collisionDetection(blocks,golfball)
    if golfball && collission_detected?(blocks,golfball)
      @collision = true
    else
      @collision = false
    end

  end

  def collission_detected?(blocks,golfball)
    blocks.any? do |other_block|
      other_block.includehej(other_block.block,golfball)
    end
  end

  def returnCollision()
    return @collision
  end

  def includehej(other_square,golfball)
    golfball.contains?(other_square.x1,other_square.y1) ||
    golfball.contains?(other_square.x2,other_square.y2) ||
    golfball.contains?(other_square.x3,other_square.y3) ||
    golfball.contains?(other_square.x4,other_square.y4) 
  end
end

class Player
  def initialize()
    @x = 100
    @y = 100
    @speed = 0
    @grav = 0
    @width = 20
    @height = 20
    @xmultiplier = 1
    @ymultiplier = 1
    @middlepoint = 1
    @zmulitplier = 1
    @onetime = true
  end

  def draw
    @golfball = Square.new(
    x: @x, y: @y,
    size:@width,
    color: 'teal',
    z: 1
    )
  end

  def gravity()
  end

  def move(bool,strength,meterx,metery,collision)
    @middlepoint = [@x + @width/2, @y + @height/2]
    if bool
      @speed = strength
      
      @xmultiplier = meterx + 5 - @middlepoint[0]
      @ymultiplier = metery + 5 - @middlepoint[1]
      @zmulitplier = Math.sqrt(@ymultiplier ** 2 + @xmultiplier ** 2)
    end

    if collision && @onetime
      @grav *= -1
      @speed *= -0.7
    end

    p @grav

    if collision 
      @grav *= 0.75
      @speed *= 0.7

      @onetime = false

      if @grav > -0.2 && @grav < 0
        @grav = 0
      end

      @x += @speed * (@xmultiplier/@zmulitplier)/2
      @y += @speed * @ymultiplier/@zmulitplier + @grav
    else
      @onetime = true
    
      @x += @speed * (@xmultiplier/@zmulitplier)/2
      @y += @speed * @ymultiplier/@zmulitplier + @grav

      if @grav < 7
        @grav += 0.05
      end
    end

    if @speed < 0.03 && @speed > -0.03
      @speed = 0.0
    end

    @speed *= 0.985;
  end

  def getEverything()
    return [@x,@y,@width,@height,@golfball]
  end
end

class PowerMeter
  def initialize
    @x = 100
    @y = 100
    @width = 10
    @height = 10
  end

  def returnPos()
    return [@x,@y]
  end

  def draw(color)
    Rectangle.new(
      x:@x,y:@y,
      width:@width, height: @height,
      color: [1-color/20.0, 1-color/20.0, 1-color/20.0, 1],
      z:1
    )
  end

  def move(playerx,playery,playerwidth,playerheight,period)
    @x = playerx + (playerwidth - @width)/2 + (Math.sin(period) * 30).to_i
    @y = playery + (playerheight - @height)/2 + (Math.cos(period) * 30).to_i
  end
end

#listeners

on :key_held do |event|
  case event.key
  when 'left'
    period += 0.1
  when 'right'
    period -= 0.1
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

blocks << Block.new(100,300,20,10)

update do
  clear
  blocks.each do |block|
    block.draw
    block.collisionDetection(blocks,player.getEverything()[4])
    if block.returnCollision()
      hello = true
    else
      hello = false
    end
  end
  background.draw
  powerMeter.draw(power)
  player.draw
  player.move(shot,power,powerMeter.returnPos()[0],powerMeter.returnPos()[1],hello)
  powerMeter.move(player.getEverything()[0],player.getEverything()[1],player.getEverything()[2],player.getEverything()[3],period)
  player.gravity
  if shot 
    shot = false
    power = 1
  end
end

#run

show