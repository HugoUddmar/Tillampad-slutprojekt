

#Svåra problem: Kollision, att veta vilken typ av kollision som sker, och hantera det på rätt sätt

#initialize

require 'ruby2d'

set width: 1920
set height: 1080
set fullscreen: true

period = 3.1

shot = false
power = 1
add = 1

collision = false

$howmanyshots = 0
$portal = false
$type_of_collision = nil
$pos = nil
$oldpos = nil
$menu = true
$level = 0
$ballingoal = false
$endText = ""
$onetime = true

$highscoreLevel1 = ""
$highscoreLevel2 = ""
$highscoreLevel3 = ""
#classes

highscore = File.read("score.text")
i = 0
level = 1
while i < highscore.length
  if highscore[i] == "\n"
    level += 1
    i += 1
  end

  if level == 1
    $highscoreLevel1 += highscore[i]
  elsif level == 2
    $highscoreLevel2 += highscore[i]
  elsif level == 3
    $highscoreLevel3 += highscore[i]
  end
  i += 1
end

class Background
  def draw
    
  end
end

class Menu
  def initialize()
  end

  def draw()
    #level1

    $level1 = Rectangle.new(
      x:(Window.width/4)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:0
    )

    Text.new(
      "Level1, Highscore:#{$highscoreLevel1}",
      x:(Window.width/4)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 10
    )

    #level2

    $level2 = Rectangle.new(
      x:(Window.width/2)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:0
    )

    Text.new(
      "Level2, Highscore:#{$highscoreLevel2}",
      x:(Window.width/2)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 10
    )

    #level3

    $level3 = Rectangle.new(
      x:(3*Window.width/4)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:0
    )

    Text.new(
      "Level3, Highscore:#{$highscoreLevel3}",
      x:(3*Window.width/4)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 10
    )

    #quit

    $quit = Rectangle.new(
      x:(Window.width/2)-100, y:(Window.height/2)+100, width:200,height:100,color:'white',z:0
    )

    Text.new(
      'Quit game',
      x:(Window.width/2)-90, y:(Window.height/2)+130,
      style: 'bold',
      size: 30,
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
    Rectangle.new(
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
      size: 40,
      color: 'white',
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
    z: 10
    )
  end

  def move(bool,strength,meterx,metery,collision)
    if $portal && $onetime
      $onetime = false
      @x = 1550
      @y = Window.height-50
      $oldpos = [1550,Window.height-50]
    end

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
    Rectangle.new(
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

class Portal
  def initialize(x,y)
    @x = x
    @y = y
  end

  def draw()
    Rectangle.new(
    x:@x, y:@y, width:30,height:30,color:'purple',z:5
    )

    Rectangle.new(
      x: 1550,y:Window.height-50, width:30, height:30, color:'purple', z:5
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
      if golfball.y1 >= blocky1 - golfball.width && golfball.y2 <= blocky3 + golfball.width
        $portal = true
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
      color: [1-color/40.0, 1-color/40.0, 1-color/40.0, 1],
      z:1
    )
  end

  def move(playerx,playery,playerwidth,playerheight,period)
    @x = playerx + (playerwidth - @width)/2 + (Math.sin(period) * 30).to_i
    @y = playery + (playerheight - @height)/2 + (Math.cos(period) * 30).to_i
  end
end

class MovingBlock
  attr_reader :x
  def initialize(x,y,width,height,color)
    @x = x
    @y = y
    @width = width
    @height = height
    @color = color
  end

  def draw()
    Rectangle.new(
    x:@x, y:@y, width:@width,height:@height,color:@color,z:5
    )

    @x -= rand(1..4)
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
      if golfball.y1 >= blocky1 - golfball.width && golfball.y2 <= blocky3 + golfball.width
        $ballingoal = true
      end
    end

    return false
  end
end

#listeners

on :key_held do |event|
  case event.key
  when 'left'
    period += Math::PI/90
  when 'right'
    period -= Math::PI/90
  when 'space'
    if $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      if power == 40
        add *= -1
      elsif power == 0
        add *= -1
      end
      power += add
    end
  end
end

on :mouse_down do |event|
  case event.button
  when :left
    if $menu && $level1.contains?(event.x,event.y)
      $menu = false
      $level = 1

      $player = nil
      $player = Player.new(120,100)
      $blocks = []
      $blocks << Block.new(0,0,Window.width,20)
      $blocks << Block.new(0,0,20,Window.height)
      $blocks << Block.new(0,Window.height-20,Window.width,20)
      $blocks << Block.new(Window.width-20,0,20,Window.height)

      $blocks << Block.new(20,350,Window.width-350,100)
      $blocks << Block.new(220,200,350,150)
      $blocks << Block.new(570,250,350,100)
      $blocks << Block.new(920,300,350,50)
      $blocks << Block.new(Window.width-330,150, 50, 450)
      $blocks << Block.new(Window.width-330,600,150,50)
      $blocks << Block.new(Window.width-230,150, 50, 450)

      $blocks << Block.new(1350,750, 200, 400)
      $blocks << Block.new(1150,520, 200, 300)
      $blocks << Block.new(700,400, 70, 580)
      $blocks << Block.new(770,930, 400, 50)
      $blocks << Block.new(20,800, 80, 50)
      $blocks << Block.new(170,600, 90, 70)

      $blocks << Goal.new(200,600)
    elsif $menu && $level2.contains?(event.x,event.y)
      $menu = false
      $level = 2

      $player = nil
      $player = Player.new(Window.width/2, Window.height-70)
      $blocks = []
      $blocks << Block.new(0,0,Window.width,20)
      $blocks << Block.new(0,0,20,Window.height)
      $blocks << Block.new(0,Window.height-20,Window.width,20)
      $blocks << Block.new(Window.width-20,0,20,Window.height)

      $blocks << Block.new(Window.width*0.4,150,40, Window.height-170)
      $blocks << Block.new(Window.width*0.6,20,40, Window.height-40)
      $blocks << Block.new(Window.width*0.4 + 40,750,170, 50)
      $blocks << Block.new(Window.width*0.4 + 200,500,185, 50)
      $blocks << Block.new(Window.width*0.4 + 40,250,170, 50)

      $blocks << Block.new(100,240,615, 50)
      $blocks << Block.new(700, 500,70, 70)
      $blocks << Block.new(20, 500,200, 70)
      $blocks << Portal.new(100, 470)
      $blocks << Block.new(1400,600, 350,50)
      $blocks << Block.new(1600,130, 100,50)

      $blocks << Goal.new(Window.width-300,130)
    elsif $menu && $level3.contains?(event.x,event.y)
      $menu = false
      $level = 3

      $player = nil
      $player = Player.new(100,100)
      $blocks = []
      $blocks << Block.new(0,0,Window.width,20)
      $blocks << Block.new(0,0,20,Window.height)
      $blocks << Block.new(0,Window.height-20,Window.width,20)
      $blocks << Block.new(Window.width-20,0,20,Window.height)

      $blocks << Goal.new(Window.width-50,Window.height-20)
    elsif $menu && $quit.contains?(event.x,event.y)
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
  when 'escape'
    if $menu 
      close
    end
    $menu = true
    $ballingoal = false
    $howmanyshots = 0
  end
end

#update
menu = Menu.new
howmanyshots = Howmanyshots.new
powerMeter = PowerMeter.new
background = Background.new

onetime = true
frames = rand(10..100)
a = 5
adds = 1
update do
  clear

  background.draw()
  
  if $ballingoal
    if onetime
      onetime = false
      if $level == 1 
        if $howmanyshots < $highscoreLevel1.to_i
          $highscoreLevel1 = $howmanyshots.to_s
          $endText = "Yay! you completed level 1, and achieved a highscore of #{$howmanyshots}! press esc to go back to menu"
  
          $highscore = File.readlines("score.text")
          $highscore[0] = ""
          i = 0 
          while i < $howmanyshots.to_s.length
            $highscore[0][i] = $howmanyshots.to_s[i]
            i += 1
          end
  
          $highscore[$highscore.length] = "\n"
  
          nyfil = File.open("score.text","w")
          nyfil.puts $highscore
          nyfil.close
  
        else
          $endText = "Yay! you completed level 1, it took #{$howmanyshots} shots, press esc to go back to menu"
        end
      elsif $level == 2
        if $howmanyshots < $highscoreLevel2.to_i
          $highscoreLevel2 = $howmanyshots.to_s
          $endText = "Yay! you completed level 2, and achieved a highscore of #{$howmanyshots}! press esc to go back to menu"
  
          $highscore = File.readlines("score.text")
          $highscore[1] = ""
          i = 0 
          while i < $howmanyshots.to_s.length
            $highscore[1][i] = $howmanyshots.to_s[i]
            i += 1
          end
  
          $highscore[$highscore.length] = "\n"
  
          nyfil = File.open("score.text","w")
          nyfil.puts $highscore
          nyfil.close
  
        else
          $endText = "Yay! you completed level 2, it took #{$howmanyshots} shots, press esc to go back to menu"
        end
      else
        if $howmanyshots < $highscoreLevel3.to_i
          $highscoreLevel3 = $howmanyshots.to_s
          $endText = "Yay! you completed level 3, and achieved a highscore of #{$howmanyshots}! press esc to go back to menu"
  
          $highscore = File.readlines("score.text")
          $highscore[2] = ""
          i = 0 
          while i < $howmanyshots.to_s.length
            $highscore[2][i] = $howmanyshots.to_s[i]
            i += 1
          end
  
          $highscore[$highscore.length] = "\n"
  
          nyfil = File.open("score.text","w")
          nyfil.puts $highscore
          nyfil.close
        else
          $endText = "Yay! you completed level 3, and achieved a highscore of #{$howmanyshots}! press esc to go back to menu"
        end
      end
    end

    Text.new(
      $endText,
      x: 150, y: Window.height/2,
      style: 'bold',
      size: 40,
      color: 'white',
      z: 10
    )
  elsif $menu
    menu.draw
    onetime = true
  else
    if $level == 3
      if frames > 0
        frames -= 1
      else
        frames = rand(40..200)
        $blocks[a] = MovingBlock.new(2000,rand(200..1060),rand(10..200),rand(50..400),[rand(0..1.0),rand(0..1.0),rand(0..1.0),rand(0.5..1.0)])
        if a == 25
          adds *= -1
        elsif a == 4
          a += 1
          adds *= -1
        end
        a += adds
      end
    end

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