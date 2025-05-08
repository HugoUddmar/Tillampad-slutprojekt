# Fil: main.rb
# Författare: Hugo Uddmar
# Datum 2025-04-28
# Beskrivning: Ett minigolfspel 

#initiera

require 'ruby2d'

set width: 1920
set height: 1080
set fullscreen: true

#Variabel för vilken position pilen har
period = Math::PI

#Variabler för slaget och kraftmätaren
shot = false
power = 1
add = 1

#Bool om det skett en kollision eller inte 
collision = false

#Hur många slag man gjort/hur många sekunder som passerat på nivå 3
$score = 0

#Bool för portalen
$portal = false

#Variabler för kollision
#Vilken typ av kollision och en position som uppdateras när det inte sker en kollision 
#som man teleporterar tillbaka till när det sker en kollision och som används i kollision funktionen
$type_of_collision = nil
$oldpos = nil

#Variabler för menyn
$menu = true
$level = 0
$finish = false
$endText = ""

#Variabler för update loopen
onetime = true
frames = rand(10..100)
index = 5

#Bool om man kan hoppa eller inte i nivå 3
onetime2 = true

#Klasser

#Player

#Spelaren alltså golfbollen. Den ser ut som en boll men fungerar som en kvadrat.
#Den blir påverkad av gravitation och slag och kolliderar med block.
class Player
  attr_reader :x
  attr_reader :y
  attr_accessor :xspeed
  attr_accessor :yspeed
  attr_accessor :grav
  attr_reader :width
  attr_reader :height
  attr_reader :golfball
  def initialize(startx,starty)
    @x = startx
    @y = starty
    @grav = 0.01
    @width = 30
    @height = 30
    @xmultiplier = 1
    @ymultiplier = 1
    @middlepoint = 1
    @zmulitplier = 1
    @onetime = true
    @xspeed = 0
    @yspeed = 0
    @rotation = 0
  end

  def draw()
    @golfball = Rectangle.new( #Det som används för kollisionen
    x: @x, y: @y,
    width: @width,
    height: @height,
    color: [0,0,0,0],
    z: 2,
    )

    @rotation += @xspeed  #Rotationen är inte realistisk men det här funkar väl

    Sprite.new( #Det som man ser av spelaren
      "golfball2.png",
      width:@width,
      height:@height,
      x:@x,
      y:@y,
      z:3,
      rotate: @rotation,
    )
  end

  #Beskrivning: Spelarrörelsen. Hantering av kollision, slag, gravitation, hastighet, position
  #
  #Parametrar:
  #bool - bool, om ett slag skett
  #strength - int, styrkan på slaget
  #powermeterx - int, pilens x-koordinat
  #powermetery - int, pilens y-koordinat
  #powermeterwidth - int, bredden på pilen
  #powermeterheight - int, höjden på pilen. Alla pil parametrar används för uträkningen vid slag
  #collision - bool, om en kollision skett
  #return: inget
  def move(bool,strength,powermeterx,powermetery,collision,powermeterwidth,powermeterheight)
    if $portal #Teleportera i nivå 2
      @x = 1550
      @y = Window.height-30
      $oldpos = [1550,Window.height-30]
    end

    if collision 
      @x = $oldpos[0]   #Först teleportera tillbaka där kollision inte hände
      @y = $oldpos[1]   

      if @onetime #En gång vid kollision multipliceras hastigheterna med -1 beroende på vilken typ av kollision
        @onetime = false

        if $type_of_collision == "leftright"
          @xspeed *= -1
          @xspeed *= 0.5
        else
          @yspeed *= -1
          @grav *= -1
        end
      end
      
      #Ändrar xspeed mindre än yspeed eftersom det är en boll och då måste man sätta collision innan den hanterar ett slag
      #För annars kommer den justera hastigheterna olika mycket och så får man fel riktning på slaget.
      @xspeed *= 0.97
      @yspeed *= 0.5
      @grav *= 0.5

      if @grav > -0.2 && @grav < 0     #så att det inte blir oändligt många decimaler
        @grav = 0
      end
    else
      @onetime = true

      if @grav < 7          #När det är kollision stängs gravitationen av, annars funkar det som vanligt
        @grav += 0.075
      end

      @xspeed *= 0.99
      @yspeed *= 0.99  #I luften minskar hastigheten också lite
    end

    if @xspeed < 0.15 && @xspeed > -0.15 #så att det inte blir oändligt många decimaler
      @xspeed = 0.0
    end

    if @yspeed < 0.1 && @yspeed > -0.1 #så att det inte blir oändligt många decimaler
      @yspeed = 0.0
    end

    @middlepoint = [@x + @width/2, @y + @height/2] #mittpunkten av spelaren

    if bool
      #Först räknas skillnaden i x och y-led ut mellan mittpunkterna på pilen och spelaren.
      #Sen räknar man ut hur lång hypotenusan/avståndet mellan pilen och spelaren är och
      #delar skillnaden i x och y-led med avståndet så att man får lika mycket kraft i alla riktningar.
      #Annars hade man fått större starthastighet i 45 grader än 0 grader.
      @xmultiplier = powermeterx + powermeterwidth/2 - @middlepoint[0]
      @ymultiplier = powermetery + powermeterheight/2 - @middlepoint[1]
      @zmulitplier = Math.sqrt(@ymultiplier ** 2 + @xmultiplier ** 2)

      
      #Det multipliceras med styrkan och adderas till hastigheterna
      @xspeed += strength * @xmultiplier/@zmulitplier
      @yspeed += strength * @ymultiplier/@zmulitplier
    end

    @x += @xspeed #Till slut adderas spelarens position med hastigheterna
    @y += @yspeed + @grav
  end
end

#Alla block klasser

#Block som man kan ändra färg på. De är rektanglar och fungerar som hinder med spelaren.
class Block
  def initialize(x,y,width,height,color)
    @x = x
    @y = y
    @width = width
    @height = height
    @color = color
  end

  def draw()
    Rectangle.new(
    x:@x, y:@y, width:@width,height:@height,color:@color,z:1
    )
  end

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  #Kollision för rektanglar. Detektion och vilken typ av kollision.
  #Jag tänkte göra det för en cirkel och rektangel men jag har spenderat så mycket tid på funktionen och jag är väldigt nöjd med den.
  #Parametrar: golfball - Rectangle: Position och storlek som båda är i int som används i villkoren i funktionen
  #Return: true/false 
  def collission_detected?(golfball)
    #Först initieras variablerna för koordinaterna på kanterna på rektanglarna.
    #x1 = vänstra kanten, x2 = högra kanten, y1 = toppkanten, y2/y3 = bottenkanten. 
    #Anledningen till att det är y2/y3 är för att det utgår från koordinaterna av hörnen x1-4 och y1-4 men man behöver bara 4 koordinater per rektangel
    #och jag tycker det är tydligare med x1-2 och y1-2 så blocket har y1 och y2 medan golfbollen har y1 och y3

    #Först kollar den om man är tillräckligt nära blocket med en marginal på 40 pixlar så det blir effektivt.
    #Sen kollar den om spelaren är inuti blocket på x-koordinaten.
    #Sen innan den kollar up och ner kollision kollar den om man är i en sidokollision fast hela spelaren är i sidan av ett block.
    #Sen kollar den på hörnkollisionerna. Jag har först delat upp det i varje hörn för sig. Först kollar jag på oldpos där i vissa fall det bara finns en kollision som kan ha skett.
    #Sen när det finns två olika kollisioner som kan ha skett räknar jag ut en tid genom sträcka / hastighet för x och y-ledet och justerar så det bara blir positivt och tar den tiden som är minst.
    #Sist kollar den upp och ner kollision

    blockx1 = @x
    blockx2 = @x + @width
    blocky1 = @y
    blocky2 = @y + @height

    if golfball.y3 < blocky1 - 40 || golfball.y1 > blocky2 + 40 || golfball.x2 < blockx1 - 40 || golfball.x1 > blockx2 + 40
      return false
    end
    
    if golfball.x2 > blockx1 && golfball.x1 < blockx2
      if golfball.y1 >= blocky1 && golfball.y3 <= blocky2
        #Vanlig vänster-högerkollision
        $type_of_collision = "leftright"
        return true
      elsif golfball.y3 >= blocky1 && golfball.y3 <= blocky2
        #Hörnkollisionerna
        if golfball.x2 > blockx2
          #Upp åt höger
          #Man kan tänka $oldpos[0] som x1 på spelarens gamla position och $oldpos[1] som y1
          #Första villkoret är när inte hela spelaren vid oldpos är över kanten på hörnet
          #Då kan det bara ske en nerup-kollision. 
          #Elsif-villkoret är när inte hela spelaren vid oldpos är över höjden av kanten på hörnet
          #Då kan det bara ske en vänsterhöger-kollision
          #Sen när det finns flera möjliga kollisioner gör jag så tiden alltid blir positiv och tar den minsta tiden och repeterar för varje hörn.

          if $oldpos[0] <= blockx2  #Villkoren överlappar varandra lite men innan den gör det i spelet kommer det alltid ske en kollision
            $type_of_collision = "downup"
            return true
          elsif $oldpos[1] + golfball.height >= blocky1
            $type_of_collision = "leftright"
            return true
          end
          
          tidx = (-1 * ($oldpos[0] - blockx2)) / $player.xspeed
          tidy = (blocky1 - $oldpos[1]) / ($player.yspeed + $player.grav)

          if tidx < tidy
            $type_of_collision = "leftright"
            return true
          else
            $type_of_collision = "downup"
            return true
          end
        elsif golfball.x1 < blockx1
          #Upp åt vänster

          if $oldpos[0] + golfball.width >= blockx1
            $type_of_collision = "downup"
            return true
          elsif $oldpos[1] + golfball.height >= blocky1
            $type_of_collision = "leftright"
            return true
          end
         
          tidx = (blockx1-$oldpos[0]) / $player.xspeed
          tidy = (blocky1-$oldpos[1]) / ($player.yspeed + $player.grav)

          if tidx < tidy
            $type_of_collision = "leftright"
            return true
          else
            $type_of_collision = "downup"
            return true
          end
        else
          #Vanlig upp-nerkollision
          $type_of_collision = "downup"
          return true
        end
      elsif golfball.y1 <= blocky2 && golfball.y3 >= blocky2
        if golfball.x2 > blockx2
          #Ner åt höger
          if $oldpos[0] <= blockx2
            $type_of_collision = "downup"
            return true
          elsif $oldpos[1] <= blocky2
            $type_of_collision = "leftright"
            return true
          end

          tidx = (blockx2 - $oldpos[0]) / $player.xspeed
          tidy = (blocky2 - $oldpos[1]) / ($player.yspeed + $player.grav)
          if tidx < tidy
            $type_of_collision = "leftright"
            return true
          else
            $type_of_collision = "downup"
            return true
          end
        elsif golfball.x1 < blockx1
          #Ner åt vänster
          if $oldpos[0] + golfball.width >= blockx1
            $type_of_collision = "downup"
            return true
          elsif $oldpos[1] <= blocky2
            $type_of_collision = "leftright"
            return true
          end

          tidx = (blockx1 - $oldpos[0]) / $player.xspeed
          tidy = (blocky2 - $oldpos[1]) / ($player.yspeed + $player.grav)

          if tidx < tidy
            $type_of_collision = "leftright"
            return true
          else
            $type_of_collision = "downup"
            return true
          end
        else
          #Vanlig upp-nerkollision
          $type_of_collision = "downup"
          return true
        end
      end
    end
    return false
  end
end

#Målet som är en gul rektangel med en blå text 'Goal' på. Om man kolliderar med den har kört klart nivån.
class Goal
  def initialize(x,y)
    @x = x
    @y = y
  end

  def draw()
    Rectangle.new(
    x:@x, y:@y, width:30,height:30,color:'yellow',z:2
    )

    Text.new(
      "Goal",
      x: @x, y: @y+8,
      style: 'bold',
      size: 12,
      color: 'blue',
      z: 3
    )
  end

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def collission_detected?(golfball)
    blockx1 = @x
    blockx2 = @x + 30
    blocky1 = @y
    blocky2 = @y + 30
  
    #För kollision detektion. Samma i portal och movingblock klassen.
    if golfball.x2 > blockx1 && golfball.x1 < blockx2 
      if golfball.y3 >= blocky1 && golfball.y1 <= blocky2
        $finish = true
      end
    end
    return false
  end
end

#Portalerna som man kan teleportera mellan i nivå 2 om man kolliderar.
class Portal
  def initialize(x,y)
    @x = x
    @y = y
  end

  def draw()
    Rectangle.new(
    x:@x, y:@y, width:30,height:30,color:'purple',z:2
    )

    Rectangle.new(
      x: 1550,y:Window.height-30, width:30, height:30, color:'purple', z:2
    )
  end

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def collission_detected?(golfball)
    blockx1 = @x
    blockx2 = @x + 30
    blocky1 = @y
    blocky2 = @y + 30
  
    
    if golfball.x2 > blockx1 && golfball.x1 < blockx2
      if golfball.y3 >= blocky1 && golfball.y1 <= blocky2
        $portal = true
      end
    else
      $portal = false
    end

    return false
  end
end

#Blocket i level 3 som åker från höger till vänster med en slumpmässig färg. Hastigheten och storleken ändras slumpmässigt.
class MovingBlock
  def initialize(x,y,width,height,color)
    @x = x
    @y = y
    @width = width
    @height = height
    @color = color
    @xadd = 0
    @yadd = 0
  end

  def draw()
    #Slumpmässigt ändrar hastigheter och storlek
    #x-hastigheten kan bara bli större och större
    @xadd += rand(-0.6..0.0)
    @yadd += rand(-0.2..0.2)
    @x += @xadd
    @y += @yadd
    if rand(0..1) == 0
      @width += rand(0.0..2.0)
    else
      @height += rand(0.0..2.0)
    end
    Rectangle.new(
    x:@x, y:@y, width:@width,height:@height,color:@color,z:1
    )
  end

  def collisionDetection(golfball)
    return golfball && collission_detected?(golfball) #Måste skriva && golfball för att kolla om den är initierad
  end

  def collission_detected?(golfball)
    blockx1 = @x
    blockx2 = @x + @width
    blocky1 = @y
    blocky2 = @y + @height
  
    if golfball.x2 > blockx1 && golfball.x1 < blockx2 
      if golfball.y3 >= blocky1 && golfball.y1 <= blocky2
        $finish = true
      end
    end
    return false
  end
end

#Meny och UI klasser

#Menyn, hantering av highscore och när man är klar med en nivå.
class Menu
  def initialize()
    #alfabetet för kryptering
    @crypt = "abcdefghijklmnopqrstuvwxyzåäö"  

    #Innan spelet börjar dekrypterar programmet highscoren i textfilen och sparar det för menyn.

    @highscoreLevel1 = ""
    @highscoreLevel2 = ""
    @highscoreLevel3 = ""

    highscore = File.readlines("score.text")
    i = 0
    level = 1
    while i < highscore.length
      row = highscore[i][0..highscore[i].length-2]
      if level == 1
        @highscoreLevel1 = decryption(row)
      elsif level == 2
        @highscoreLevel2 = decryption(row)
      elsif level == 3
        @highscoreLevel3 = decryption(row)
      end
      i += 1
      level += 1
    end
  end

  # Beskrivning: En funktion som tar ett värde och skapar en sträng av värdet med bokstäver. 
  # Alla Bokstävernas position i alfabetet summerat blir värdet * 31. 
  # Strängen skapas slumpmässigt men om man dekrypterar det får man det man stoppade in.
  #
  # Parameter: value - int, värdet som man vill kryptera, större än noll
  # Return: string - string, strängen som är krypterad
  # 
  # Testfall: encryption(2) => "uöjb"
  #           encryption(2) => "jjjjjjb"
  #
  def encryption(value)
    string = ""
    value *= 31
    while value > 29
      x = rand(1..29)
      value -= x

      string += @crypt[x-1]
    end

    string += @crypt[value-1]
    return string
  end

  # Beskrivning: En funktion som tar bokstäverna i en sträng returnar värdet på 
  # summeringen av ordningen på bokstäverna i alfabetet / 31. Om dekrypteringen inte går jämt ut alltså
  # När någon har försökt fuska skapas ett fel och programmet slutar.
  #
  # Parameter: string - string, bokstäverna som man vill dekryptera
  # Return: value - int, dekrypterade värdet
  # 
  # Testfall: decryption("uöjb") => 2
  #           decryption("jjjjjjb") => 2
  #
  def decryption(string)
    i = 0
    value = 0
    while i < string.length
      y = 0
      while string[i] != @crypt[y]
        y += 1
      end
      value += y + 1
      i += 1
    end
    value /= 31.0
    if value.to_i != value
      raise "Nope"
    end
    return value.to_i
  end

  #Beskrivning: funktionen när det är gameover, ändrar sluttexten, ändrar highscoren i textfilen och i programmet om man gjort det och spelar upp ljud.
  #Parametrar:none
  #Return:none
  def die()
    #Det finns tre olika levlar och 4 olika utfall: 1. Man får inte highscore och klarar inte av nivån 
    #2. Man får highscore men klarar inte av nivån 3. Man klarar av nivån men får inte highscore 4. Man gör båda
    if $level == 1 
      if $score < 20
        if $score < @highscoreLevel1.to_i
          @highscoreLevel1 = $score.to_s
          $endText = "Yay! you completed level 1, and achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[0] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        
        else
          $endText = "Yay! you completed level 1, it took #{$score} shots, press esc to go back to menu"
        end
        sound = Sound.new('geometrydash.mp3')
        sound.play
        sleep 3
      else
        if $score < @highscoreLevel1.to_i
          @highscoreLevel1 = $score.to_s
          $endText = "Nice try! to complete the level your score must be under 20, but you achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[0] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        else
          $endText = "Nice try! but to complete the level your score must be under 20, press esc to back to menu"
          sound = Sound.new('wilhelm.mp3')
          sound.play
          sleep 2
        end
      end
    elsif $level == 2
      if $score < 20
        if $score < @highscoreLevel2.to_i
          @highscoreLevel2 = $score.to_s
          $endText = "Yay! you completed level 2, and achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[1] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        else
          $endText = "Yay! you completed level 2, it took #{$score} shots, press esc to go back to menu"
        end
        sound = Sound.new('geometrydash.mp3')
        sound.play
        sleep 3
      else
        if $score < @highscoreLevel2.to_i
          @highscoreLevel2 = $score.to_s
          $endText = "Nice try! to complete the level your score must be under 20, but you achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[1] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        else
          $endText = "Nice try! but to complete the level your score must be under 20, press esc to go back to menu"
          sound = Sound.new('wilhelm.mp3')
          sound.play
          sleep 2
        end
      end
    else
      if $score > 30
        if $score > @highscoreLevel3.to_i
          @highscoreLevel3 = $score.to_s
          $endText = "Yay! you completed level 3, and achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[2] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        else
          $endText = "Yay! you completed level 3 with a score of #{$score}, press esc to go back to menu"
        end
        sound = Sound.new('geometrydash.mp3')
        sound.play
        sleep 3
      else
        if $score > @highscoreLevel3.to_i
          @highscoreLevel3 = $score.to_s
          $endText = "Nice try! to complete the level your score must be over 30, but you achieved a highscore of #{$score}! press esc to go back to menu"
        
          highscore = File.readlines("score.text")
          highscore[2] = encryption($score) + "\n"
        
          nyfil = File.open("score.text","w")
          nyfil.puts highscore
          nyfil.close
        else
          $endText = "Nice try! but to complete the level your score must be above 30, press esc to go back to menu"
          sound = Sound.new('wilhelm.mp3')
          sound.play
          sleep 2
        end
      end
    end
  end

  #Ritar ut alla knappar och texter för menyn
  def draw()
    #level1

    $level1 = Rectangle.new(
      x:(Window.width/4)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:1
    )

    Text.new(
      "Level1, Highscore:#{@highscoreLevel1}",
      x:(Window.width/4)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 1
    )

    #level2

    $level2 = Rectangle.new(
      x:(Window.width/2)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:1
    )

    Text.new(
      "Level2, Highscore:#{@highscoreLevel2}",
      x:(Window.width/2)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 1
    )

    #level3

    $level3 = Rectangle.new(
      x:(3*Window.width/4)-150, y:(Window.height/2)-50, width:330,height:100,color:'white',z:1
    )

    Text.new(
      "Level3, Highscore:#{@highscoreLevel3}",
      x:(3*Window.width/4)-145, y:(Window.height/2)-25,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 1
    )

    #quit

    $quit = Rectangle.new(
      x:(Window.width/2)-100, y:(Window.height/2)+100, width:200,height:100,color:'white',z:1
    )

    Text.new(
      'Quit game',
      x:(Window.width/2)-90, y:(Window.height/2)+130,
      style: 'bold',
      size: 30,
      color: 'blue',
      z: 1
    )
  end
end

#Backgrunden som är en färg.
class Background
  def initialize(color)
    @color = color
  end

  def draw
    Rectangle.new(x:0,y:0,width:Window.width,height:Window.height,color:@color,z:0)
  end
end

#Visaren längst uppe åt vänster som visar hur många slag man gjort eller sekunder som gått sen man startade spelet i nivå 3.
class Howmanyshots
  def draw()
    def initialize()
      @oldsec = Time.now.strftime("%S").to_i 
    end

    #På nivå 3 räknar den ut sekundrarna efter man startat nivån
    #Den adderar en poäng varje gång sekundvisaren ändras alltså sekundrarna efter start genom att jämföra en gammal sekundvisare med den i nuläget.
    #Ibland kan man starta precis innan en sekundvisaren ändras vilket innebär att man börjar ungefär vid 1 sekund
    #men det är så lite skillnad så det gör inget.
    if $level == 3
      second = Time.now.strftime("%S").to_i

      if second != @oldsec
        $score += 1
      end

      @oldsec = second
    end
    Text.new(
      "#{$score}",
      x: 0, y: 0,
      size: 40,
      color: 'white',
      z: 2
    )
  end
end

#Kraftmätaren och pilen. Följer efter spelarens position.
class PowerMeter
  attr_reader :x
  attr_reader :y
  attr_reader :width
  attr_reader :height
  def initialize
    @x = 100
    @y = 100
    @width = 20
    @height = 20
  end

  #Beskrivning: Funktionen ritar pilen och kraftmätaren
  #Rotationen på pilen utgår från variabeln period som är radian. 
  #Jag behöver bara överföra det till grader och sen justera det till startvärdet och sen ta det åt andra hållet med minus.
  #På kraftmätaren blir röda värdet på färgen mer och mer och gröna mindre och mindre och den är grön i början
  #Längden justeras med color och för att den ska växa uppåt ändras y positionen
  #
  #Parametrar:
  #color - int, styrkan av slaget just nu
  #period - float, en radian som beskriver vilken rotation pilen ska ha
  #playerx - int, spelarens x-värde 
  #playery - int, spelarens y-koordinate. Kraftmätarens position beror på spelaren
  def draw(color,period,playerx,playery)
    Sprite.new(
      "pil.png",
      width:@width, height: @height,
      x:@x,y:@y,z:4,
      rotate:((-period/Math::PI)*180) + 180,
    )

    Rectangle.new(
      width:5,
      height:5+color,
      x:playerx - 13,
      y:playery + 25 - color,
      z:3,
      color: [color/40.0,1-color/40.0,0,1]
    )
  end

  #Beskrivning: Funktionen räknar ut positionen på pilen

  #Parametrar: playerx - int, spelarens x-värde
  #playery - int, spelarens y-värde
  #playerwidth - int, spelarens bredd
  #playerheight - int, spelarens höjd
  #period - float, en radian som beskriver var i en cirkel runt spelaren man är i
  #
  #return: inget
  def move(playerx,playery,playerwidth,playerheight,period)
    @x = playerx + (playerwidth - @width)/2 + (Math.sin(period) * 40).to_i
    @y = playery + (playerheight - @height)/2 + (Math.cos(period) * 40).to_i
  end
end

#lyssnare

on :key_held do |event|
  case event.key 
  #Ändra position på power meter med två grader
  when 'left' 
    period += Math::PI/90
  when 'right'
    period -= Math::PI/90
  when 'space'
  #Ändra styrkan innan varje slag, i level 3 kan man ändra styrkan efter att ha nuddat marken, i de andra nivåerna måste man stå stilla
    if $level == 3
      if onetime2
        if power == 40
          add *= -1
        elsif power == 0
          add *= -1
        end
        power += add
      end
    elsif $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
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
  #Om man klickar på knapparna i menyerna
  when :left
    #Här lägger jag till alla objekt för en nivå, för blocken kan man ändra position, storlek och färg.
    #Måste ha globalt räckvidd på player och blocks variablerna eftersom jag inte kan skapa de i updaten eftersom de kommer att glömmas bort varje frame.
    if $menu && $level1.contains?(event.x,event.y)
      $menu = false
      $level = 1
      
      $player = nil
      $player = Player.new(85,310)
      $blocks = []
      $blocks << Block.new(0,-20,Window.width,20,[0,0,0,0])
      $blocks << Block.new(-20,0,20,Window.height,[0,0,0,0])
      $blocks << Block.new(0,Window.height,Window.width,20,[0,0,0,0])
      $blocks << Block.new(Window.width,0,20,Window.height,[0,0,0,0])

      $blocks << Block.new(75,250,50,50,"white")

      $blocks << Block.new(0,350,Window.width-320,100,"white")
      $blocks << Block.new(220,200,350,150,"white")
      $blocks << Block.new(570,250,350,100,"white")
      $blocks << Block.new(920,300,350,50,"white")
      $blocks << Block.new(Window.width-330,150, 30, 450,"white")
      $blocks << Block.new(Window.width-330,600,150,50,"white")
      $blocks << Block.new(Window.width-210,150, 30, 450,"white")

      $blocks << Block.new(1350,750, 200, 400,"brown")
      $blocks << Block.new(1150,520, 200, 300,"green")
      $blocks << Block.new(700,400, 70, 580,"blue")
      $blocks << Block.new(770,930, 400, 50,"blue")
      $blocks << Block.new(0,800, 100, 50,"white")
      $blocks << Block.new(170,600, 90, 70,"white")

      $blocks << Goal.new(200,600)
    elsif $menu && $level2.contains?(event.x,event.y)
      $menu = false
      $level = 2

      $player = nil
      $player = Player.new(Window.width/2, Window.height-70)
      $blocks = []
      $blocks << Block.new(0,-20,Window.width,20,[0,0,0,0])
      $blocks << Block.new(-20,0,20,Window.height,[0,0,0,0])
      $blocks << Block.new(0,Window.height,Window.width,20,[0,0,0,0])
      $blocks << Block.new(Window.width,0,20,Window.height,[0,0,0,0])

      $blocks << Block.new(Window.width*0.4,150,40, Window.height-150,"fuchsia")
      $blocks << Block.new(Window.width*0.6,0,40, Window.height,"fuchsia")
      $blocks << Block.new(Window.width*0.4 + 40,750,170, 50,"fuchsia")
      $blocks << Block.new(Window.width*0.4 + 200,500,185, 50,"fuchsia")
      $blocks << Block.new(Window.width*0.4 + 40,250,170, 50,"fuchsia")

      $blocks << Block.new(100,240,615, 50,"white")
      $blocks << Block.new(700, 500,70, 70,"white")
      $blocks << Block.new(0, 500,220, 70,"white")
      $blocks << Block.new(1400,600, 350,50,"white")
      $blocks << Block.new(1600,130, 100,50,"white")

      $blocks << Portal.new(100, 470,)
      $blocks << Goal.new(Window.width-300,130)
    elsif $menu && $level3.contains?(event.x,event.y)
      $menu = false
      $level = 3
      index = 7
      onetime2 = false

      $player = nil
      $player = Player.new(100,1000)
      $blocks = []
      $blocks << Block.new(0,0,Window.width,20,"gray")
      $blocks << Block.new(0,0,20,Window.height,"gray")
      $blocks << Block.new(0,Window.height-20,Window.width,20,"gray")
      $blocks << Block.new(Window.width-20,0,20,Window.height,"gray")
      $blocks << Block.new(Window.width/2 - 150,Window.height/2 - 50,300,100,"gray")
      $blocks << Block.new(200,Window.height/2 - 50,300,100,"gray")
      $blocks << Block.new(3 * Window.width/4 - 50,Window.height/2 - 50,300,100,"gray")
    elsif $menu && $quit.contains?(event.x,event.y)
      close
    end
  end
end

on :key_up do |event|
  case event.key
  #Om man släpper space knappen blir en boolean true som säger att ett slag ska ske om de andra villkoren gäller, skillnad mellan nivå 3 och andra nivåer
  when 'space'
    if $level == 3
      if onetime2
        onetime2 = false
        shot = true
      end
    elsif $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      shot = true
      $score += 1
    end
  #Här stängs antingen spelet ner om man är i menyn eller går man till menyn genom att meny boolen blir sann och progressen resetas
  when 'escape'
    if $menu 
      close
    end
    $menu = true
    $finish = false
    $score = 0
  end
end

#update

#Här skapar jag variabler som är instanser av klasser som gäller för hela programmet alltså behöver bara göra det en gång
menu = Menu.new
howmanyshots = Howmanyshots.new
powerMeter = PowerMeter.new
background = Background.new("#87cefa")

update do
  clear

  #Rita bakgrunden
  background.draw()
  
  #Om man är i mål eller om man måste starta om
  if $finish
    if onetime
      onetime = false
      menu.die()
      $player.xspeed = 0
      $player.yspeed = 0
      $player.grav = 0
    end

    Text.new(
      $endText,
      x: 25, y: Window.height/2,
      style: 'bold',
      size: 33,
      color: 'white',
      z: 10
    )
  elsif $menu
    menu.draw
    onetime = true
  else
    #Det som sker i nivåerna
    #Här läggs blocken som rör sig i slumpmässiga intervall till.
    #Den börjar på indexet efter de vanliga blocken och efter ett tag resetar den till startpunkten
    #Då försvinner de tidigare blocket som var på de indexen. Antalet block kommer då vara konstant efter ett tag
    if $level == 3
      if frames > 0
        frames -= 1
      else
        frames = rand(1..75)
        $blocks[index] = nil
        $blocks[index] = MovingBlock.new(2000,rand(0..1080),rand(50..200),rand(50..400),[rand(0..1.0),rand(0..1.0),rand(0..1.0),rand(0.5..1.0)])
        if index == 20
          index = 6
        end
        index += 1
      end
    end

    #I det under hanteras kollisionen. Den går igenom kollisionen i alla block och ritar upp alla block, uppdaterar oldpos och ser om man står stilla
    i = 0
    collision = false
    if $level == 3   #Kan göra en while loop och ha if $level == 3 inuti den men det här är mer effektivt
      while i < $blocks.length
        $blocks[i].draw
        if $blocks[i].collisionDetection($player.golfball) #Kan inte ha med && !collision för då kan den missa blocken som slutar spelet i nivå 3.
          collision = true
          onetime2 = true
        end
        i += 1
      end
    else
      while i < $blocks.length
        $blocks[i].draw
        if $blocks[i].collisionDetection($player.golfball) && !collision #!collision för att den inte behöver fortsätta när en kollision redan skett
          collision = true
        end
        i += 1
      end
    end

    if !collision
      $oldpos = [$player.x,$player.y]
    end

    if $player.xspeed == 0 && $player.yspeed == 0 && $player.grav == 0
      collision = true
    end

    #--------------

    #Här ritas det andra upp och rörelse funktionerna körs igenom

    $player.move(shot,power,powerMeter.x,powerMeter.y,collision,powerMeter.width,powerMeter.height)
    powerMeter.move($player.x,$player.y,$player.width,$player.height,period)

    $player.draw()
    powerMeter.draw(power,period,$player.x,$player.y)

    howmanyshots.draw()

    if shot 
      shot = false
      power = 1
    end
  end
end

#run

show