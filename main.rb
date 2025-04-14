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

collision = false

$howmanyshots = 0
$type_of_collision = nil
$pos = nil
$oldpos = nil
$menu = true
$level = 0
$ballingoal = false
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

class Menu
  def initialize()
  end

  def draw()
    #level1

    Rectangle.new(
      x:100, y:200, width:100,height:50,color:'white',z:0
    )

    Text.new(
      'Level1',
      x: 120, y: 212,
      style: 'bold',
      size: 20,
      color: 'blue',
      z: 10
    )

    #level2

    Rectangle.new(
      x:300, y:200, width:100,height:50,color:'white',z:0
    )

    Text.new(
      'Level2',
      x: 320, y: 212,
      style: 'bold',
      size: 20,
      color: 'blue',
      z: 10
    )

    #level3

    Rectangle.new(
      x:500, y:200, width:100,height:50,color:'white',z:0
    )

    Text.new(
      'Level3',
      x: 520, y: 212,
      style: 'bold',
      size: 20,
      color: 'blue',
      z: 10
    )

    #quit

    Rectangle.new(
      x:300, y:300, width:100,height:50,color:'white',z:0
    )

    Text.new(
      'Quit game',
      x: 300, y: 312,
      style: 'bold',
      size: 20,
      color: 'blue',
      z: 10
    )
  end
end

class Block
  def initialize(x,y,width,height)
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
  
    
    if golfball.x1 >= blockx1 - golfball.width && golfball.x2 <= blockx2 + golfball.width
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
            #Golfbollen åker upp i ett block
        
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
            #Golfbollen åker höger i ett block
        
            $type_of_collision = "right"
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
            #Golfbollen åker höger i ett block
        
            $type_of_collision = "right"
            $pos = $oldpos
        
            return true
          else
            #Golfbollen åker upp i ett block
        
            $type_of_collision = "up"
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

class Howmanyshots
  def draw()
    Text.new(
      "#{$howmanyshots}",
      x: 0, y: 0,
      style: 'bold',
      size: 20,
      color: 'blue',
      z: 10
    )
  end
end

class Player
  attr_reader :x
  attr_reader :y
  attr_reader :xspeed
  attr_reader :yspeed
  attr_reader :grav
  attr_reader :width
  attr_reader :height
  attr_reader :golfball
  def initialize(startx,starty)
    @x = startx
    @y = starty
    @grav = 0.01
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

    if collision
      @y = $pos[1]
      @x = $pos[0]

      if @onetime
        @onetime = false

        if $type_of_collision == "left" || $type_of_collision == "right"
          @xspeed *= -1
        else
          @yspeed *= -1
          @grav *= -1
        end
      end

      @xspeed *= 0.5
      @yspeed *= 0.5
      @grav *= 0.5

      if @grav > -0.2 && @grav < 0
        @grav = 0
      end
    else
      @onetime = true

      if @grav < 7
        @grav += 0.051
      end
    end

    if @xspeed < 0.1 && @xspeed > -0.1
      @xspeed = 0.0
    end

    if @yspeed < 0.1 && @yspeed > -0.1
      @yspeed = 0.0
    end

    @xspeed *= 0.99
    @yspeed *= 0.99

    @x += @xspeed
    @y += @yspeed + @grav
  end
end

class Goal
  def initialize(x,y)
    @x = x
    @y = y
  end

  def draw()
    @block = Rectangle.new(
    x:@x, y:@y, width:30,height:30,color:'yellow',z:5
    )

    Text.new(
      "Goal",
      x: @x, y: @y+8,
      style: 'bold',
      size: 12,
      color: 'blue',
      z: 10
    )
  end

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def collission_detected?(golfball)
    blockx1 = @x
    blockx2 = @x + 30
    blocky1 = @y
    blocky3 = @y + 30
  
    
    if golfball.x1 >= blockx1 - golfball.width && golfball.x2 <= blockx2 + golfball.width
      if golfball.y3 >= blocky1 && golfball.y1 <= blocky3
        #Golfbollen faller på ett block
        
        $type_of_collision = "down"
        $pos = $oldpos
        $ballingoal = true
        return true
      end
    end
    return false
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
    if $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      if power == 20
        add *= -1
      elsif power == 0
        add *= -1
      end
      power += add
    end
  when 'escape'
    $menu = true
    $ballingoal = false
    $howmanyshots = 0
  end
end

on :mouse_down do |event|
  case event.button
  when :left
    if event.x > 100 && event.x < 200 && event.y > 200 && event.y < 250 && $menu
      $menu = false

      $player = Player.new(100,100)
      $blocks = []
      $blocks << Block.new(0,WindowHeight-5,WindowWidth,20)
      $blocks << Block.new(0,150,WindowWidth-50,20)
      $blocks << Block.new(50,300,WindowWidth-50,20)
      $blocks << Block.new(WindowWidth-5,0,20,WindowHeight)
      $blocks << Block.new(300, 400, 20, 100)
      $blocks << Block.new(0,0,20,WindowHeight)
      $blocks << Block.new(0,0,WindowWidth,20)
      $blocks << Goal.new(300,300)
    elsif event.x > 300 && event.x < 400 && event.y > 200 && event.y < 250 && $menu
      $menu = false

      $player = Player.new(100,100)
      $blocks = []
      $blocks << Block.new(0,WindowHeight-5,WindowWidth,20)
      $blocks << Block.new(0,150,WindowWidth-50,20)
      $blocks << Block.new(50,300,WindowWidth-50,20)
      $blocks << Block.new(WindowWidth-5,0,20,WindowHeight)
      $blocks << Block.new(300, 400, 20, 100)
      $blocks << Block.new(0,0,20,WindowHeight)
      $blocks << Block.new(0,0,WindowWidth,20)
      $blocks << Goal.new(300,100)
    elsif event.x > 500 && event.x < 600 && event.y > 200 && event.y < 250 && $menu
      $menu = false

      $player = Player.new(100,100)
      $blocks = []
      $blocks << Block.new(0,WindowHeight-5,WindowWidth,20)
      $blocks << Block.new(0,150,WindowWidth-50,20)
      $blocks << Block.new(50,300,WindowWidth-50,20)
      $blocks << Block.new(WindowWidth-5,0,20,WindowHeight)
      $blocks << Block.new(300, 400, 20, 100)
      $blocks << Block.new(0,0,20,WindowHeight)
      $blocks << Block.new(0,0,WindowWidth,20)
      $blocks << Goal.new(500,150)
    elsif event.x > 300 && event.x < 400 && event.y > 300 && event.y < 350 && $menu
      close
    end
  end
end

on :key_up do |event|
  case event.key
  when 'space'
    if $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      shot = true
      $howmanyshots += 1
    end
  end
end

#update
menu = Menu.new
howmanyshots = Howmanyshots.new
powerMeter = PowerMeter.new
background = Background.new

update do
  clear

  background.draw()

  if $ballingoal
    Text.new(
      "Yay! you did it, it took #{$howmanyshots} shots, press esc to go back to menu",
      x: 5, y: 400,
      style: 'bold',
      size: 20,
      color: 'white',
      z: 10
    )
  elsif $menu
    menu.draw
  else
    i = 0
    collision = false
    while i < $blocks.length
      $blocks[i].draw
      if $blocks[i].collisionDetection($player.golfball) && !collision
        collision = true
      end
      i += 1
    end

    if !collision
      $oldpos = [$player.x,$player.y]
    end

    if $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      collision = true
    end

    $player.move(shot,power,powerMeter.x,powerMeter.y,collision)
    powerMeter.move($player.x,$player.y,$player.width,$player.height,period)

    $player.draw()
    powerMeter.draw(power)

    howmanyshots.draw()

    if shot 
      shot = false
      power = 1
    end
  end
end

#run

show