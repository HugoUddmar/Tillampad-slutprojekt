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
$oldpos = nil
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

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def collission_detected?(golfball)
    blockx1 = @x
    blockx2 = @x + @width
    blocky1 = @y
    blocky3 = @y + @height
  
    
    if golfball.x1 >= blockx1 - golfball.width + 1 && golfball.x2 <= blockx2 + golfball.width - 1
      if golfball.y1 >= blocky1 && golfball.y3 <= blocky3
        if golfball.x1 <= blockx2
          #Golfbollen åker vänster i ett block
        
          $type_of_collision = "left"
          $pos = $oldpos
        
          return true
        else
          #Golfbollen åker höger i ett block
        
          $type_of_collision = "right"
          $pos = $oldpos
        
          return true
        end
      elsif golfball.x1 <= blockx2 && golfball.x2 >= blockx2 && golfball.y1 >= blocky1 - golfball.height && golfball.y3 <= blocky3 + golfball.height
        nbr1 = blockx2 - golfball.x1
        if golfball.y3 >= blocky1 && golfball.y1 <= blocky1
          nbr2 = golfball.y3 - blocky1
          if nbr2 > nbr1
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "left"
            $pos = $oldpos
         
            return true
          else
            #Golfbollen faller ner i ett block
        
            $type_of_collision = "down"
            $pos = $oldpos
         
            return true
          end
        else
          nbr2 = blocky3 - golfball.y1
          if nbr2 > nbr1
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "left"
            $pos = $oldpos
        
            return true
          else
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "up"
            $pos = $oldpos
        
            return true
          end
        end
      elsif golfball.x2 >= blockx1 && golfball.x1 <= blockx1 && golfball.y1 >= blocky1 - golfball.height && golfball.y3 <= blocky3 + golfball.height
        nbr1 = golfball.x2 - blockx1
        if golfball.y3 >= blocky1 && golfball.y1 <= blocky1
          nbr2 = golfball.y3 - blocky1
          if nbr2 > nbr1
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "right"
            p $type_of_collision
            $pos = $oldpos
         
            return true
          else
            #Golfbollen faller ner i ett block
        
            $type_of_collision = "down"
            p $type_of_collision
            $pos = $oldpos
         
            return true
          end
        else
          nbr2 = blocky3 - golfball.y1
          if nbr2 > nbr1
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "right"
            p $type_of_collision
            $pos = $oldpos
        
            return true
          else
            #Golfbollen åker vänster i ett block
        
            $type_of_collision = "up"
            p $type_of_collision
            $pos = $oldpos
        
            return true
          end
        end
      elsif golfball.y3 >= blocky1 && golfball.y1 <= blocky3
        #Golfbollen faller på ett block
        
        $type_of_collision = "down"
        $pos = $oldpos
        
        return true
      elsif golfball.y1 <= blocky3 && golfball.y3 >= blocky1
        #Golfbollen åker upp i ett block
       
        $type_of_collision = "up"
        $pos = $oldpos

        return true
      end
    end
    return false
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

      @xspeed += strength * (@xmultiplier/@zmulitplier)/2
      @yspeed += strength * @ymultiplier/@zmulitplier
    end

    if collision && @onetime
      @onetime = false

      if $type_of_collision == "left" || $type_of_collision == "right"
        @xspeed *= -1
      else
        @yspeed *= -1
        @grav *= -1
      end
    end

    if collision 
      @y = $pos[1]
      @x = $pos[0]

      @xspeed *= 0.7
      @yspeed *= 0.7
      @grav *= 0.7

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

    if @xspeed < 0.1 && @xspeed > -0.1
      @xspeed = 0.0
    end

    if @yspeed < 0.1 && @yspeed > -0.1
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

blocks << Block.new(0,WindowHeight-5,WindowWidth,20)
blocks << Block.new(0,150,WindowWidth-50,20)
blocks << Block.new(50,300,WindowWidth-50,20)
blocks << Block.new(WindowWidth-5,0,20,WindowHeight)
blocks << Block.new(300, 400, 20, 100)
blocks << Block.new(0,0,20,WindowHeight)
blocks << Block.new(0,0,WindowWidth,20)

update do
  clear
  background.draw()
  #p "x:#{player.x }"
  #p "y: #{player.y}"

  i = 0
  collision = false
  while i < blocks.length
    blocks[i].draw
    if blocks[i].collisionDetection(player.golfball) && !collision
      collision = true
    end
    i += 1
  end

  #p $type_of_collision

  if !collision
    $oldpos = [player.x,player.y]
  end

  player.move(shot,power,powerMeter.x,powerMeter.y,collision)
  powerMeter.move(player.x,player.y,player.width,player.height)

  player.draw()
  powerMeter.draw(power)

  if shot 
    shot = false
    power = 1
  end
end

#run

show