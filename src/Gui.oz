%--------------------------------------%
%                 Gui.oz               %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%

functor
import
   OS
   Open at 'x-oz://system/Open.ozf'
   QTk at 'x-oz://system/wp/QTk.ozf'

   Utils
   Config
   Trainer
   Pokemoz
export
   T1 T2
   Window
   MoveUp
   MoveDown
   MoveLeft
   Autofight
   MoveRight
   MoveRandomly
define
   Canvas
   Module
   CharsList
   Height
   Width
   FirstScreen
   Autofight
   C1 C2 C3
   P1 P2 P3 P4 P5
   S0 S1 S2 S3 S4
   S5 S6 S7 S8 S9 S10
   P

   ImageSize = 32

   % Images loading %
   Grass={QTk.newImage photo(file:"img/herbe.gif" format:"gif")}
   Road={QTk.newImage photo(file:"img/route.gif" format:"gif")}
   Player={QTk.newImage photo(file:"img/trainer.gif" format:"gif")}
   Girl={QTk.newImage photo(file:"img/fighter.gif" format:"gif")}

   % Map file loading %
   File = {New Open.file init(name:Config.filename flags:[read])}
   {File read(list:CharsList size:all)}
   {File close}

   % Functions %
   
   % Map Building %
   proc{PlaceSprite X Y Img}
      case Img of 0 then
	 {Canvas create(image X Y image:Road)}
      [] 1 then
	 {Canvas create(image X Y image:Grass)}
      else
	 {Canvas create(image X Y image:Road)} 
      end
   end
   
   proc{BuildMap Map Height Width}
      local
	 proc{Build L C}
	    if L<Height then
	       if C<Width then
		  {PlaceSprite C*ImageSize+(ImageSize div 2) L*ImageSize+(ImageSize div 2) Map.(L+1).(C+1)}
		  {Build L C+1}
	       else
		  {Build L+1 0}
	       end
	    else
	       skip
	    end
	 end
      in
      {Build 0 0}
      end
   end

   proc{MoveUp}
      {Delay ((10-Config.spd)*Config.delay)}
      if {Trainer.collisionPrevented T1 T2 0 ~1} then
	 local L LAfter in
	    {Avatar getCoords(L)}
	    if {FloatToInt L.2.1} > ImageSize div 2 then
	       {Avatar move(0 ~ImageSize)}
	       {Send T1 moveUp}
	       {Avatar getCoords(LAfter)}
	       {CheckCoords LAfter}
	    else
	       skip
	    end 
	 end
      else
	 skip
      end
   end
   
   % Move functions %
   proc{MoveDown}
      {Delay ((10-Config.spd)*Config.delay)}
      if {Trainer.collisionPrevented T1 T2 0 1} then
	 local L LAfter in
	    {Avatar getCoords(L)}
	    if {FloatToInt L.2.1} < (Width*ImageSize)-(ImageSize div 2) then
	       {Avatar move(0 ImageSize)}
	       {Send T1 moveDown}
	       {Avatar getCoords(LAfter)}
	       {CheckCoords LAfter}
	    else
	       skip
	    end
	 end
      else
	 skip
      end
   end
   
   proc{MoveLeft}
      {Delay ((10-Config.spd)*Config.delay)}
      local L LAfter R in
	 if R = {Trainer.collisionPrevented T1 T2 ~1 0} then
	    {Avatar getCoords(L)}
	    if {FloatToInt L.1} > ImageSize div 2 then
	       {Avatar move(~ImageSize 0)}
	       {Send T1 moveLeft}
	       {Avatar getCoords(LAfter)}
	       {CheckCoords LAfter}
	    else
	       skip
	    end 
	 else
	   skip
	 end
      end
   end

   proc{MoveRight}
      {Delay ((10-Config.spd)*Config.delay)}
      if {Trainer.collisionPrevented T1 T2 1 0} then
	 local L LAfter in
	    {Avatar getCoords(L)}
	    if {FloatToInt L.1} < (Height*ImageSize)-(ImageSize div 2) then
	       {Avatar move(ImageSize 0)}
	       {Send T1 moveRight}
	       {Avatar getCoords(LAfter)}
	       {CheckCoords LAfter}
	    else
	       skip
	    end 
	 end
      else
	 skip
      end
   end
   
   proc{MoveRandomly Avatar}
      {Delay ((10-Config.spd)*Config.delay)}
      local X L State in
	 {Send Avatar getState(State)}
	 if State.dead then skip
	 else
	    {Fighter getCoords(L)}
	    X = {OS.rand} mod 4 + 1
	    if (X==1) then
	       if {Trainer.collisionPrevented T2 T1 1 0} then
		  if {FloatToInt L.1} < (Width*ImageSize)-(ImageSize div 2) then
		     {Fighter move(ImageSize 0)}
		     {Send Avatar moveRight}
		  end
	       end
	    elseif (X==2) then
	       if {Trainer.collisionPrevented T2 T1 0 1} then
		  if {FloatToInt L.2.1} < (Height*ImageSize)-(ImageSize div 2) then
		     {Fighter move(0 ImageSize)}
		     {Send Avatar moveDown}
		  end
	       end
	    elseif (X==3) then
	       if {Trainer.collisionPrevented T2 T1 ~1 0} then
		  if {FloatToInt L.1} > ImageSize div 2 then
		     {Fighter move(~ImageSize 0)}
		     {Send Avatar moveLeft}
		  end
	       end
	    elseif (X==4) then
	       if {Trainer.collisionPrevented T2 T1 0 ~1} then
		  if {FloatToInt L.2.1} > ImageSize div 2 then
		     {Fighter move(0 ~ImageSize)}
		     {Send Avatar moveUp}
		  end
	       end
	    end
	    {MoveRandomly Avatar}
	 end
      end
   end

   % If trainer is at top right : end of the game %
   % If trainer is in the grass : probability of a fight %
   proc{CheckCoords L}
      local EndDesc EndScreen X Y
      in
	 if {FloatToInt L.1} == (Width*ImageSize)-(ImageSize div 2) then
	    if {FloatToInt L.2.1} == ImageSize div 2 then
	       EndDesc = td(button(text:"You win!"
				     action:toplevel#close))
	       EndScreen = {QTk.build EndDesc}
	       {EndScreen show}
	       {Window close}
	    end
	 end
	 X = ({FloatToInt L.1} + (ImageSize div 2)) div ImageSize
	 Y = ({FloatToInt L.2.1} + (ImageSize div 2)) div ImageSize

	 if Map.Y.X == 1 then %Trainer in the Grass
	    {Pokemoz.grassFight P}
	 end
      end
   end
  
   % FIRST SCREEN %
   % OPTIONS %
   Choice=lr(grid(checkbutton(text:"Autofight"
			 init:false
			 return:Config.autoFight) newline
	     label(init:"Speed of your trainer : ") newline
	     radiobutton(text:"0"
			 init:true
			 return:S0
			 group:speed)
	     radiobutton(text:"1"
			 return:S1
			 group:speed)
	     radiobutton(text:"2"
			 return:S2
			 group:speed)
	     radiobutton(text:"3"
			 return:S3
			 group:speed)
	     radiobutton(text:"4"
			 return:S4
			 group:speed)
	     radiobutton(text:"5"
			 return:S5
			 group:speed)
	     radiobutton(text:"6"
			 return:S6
			 group:speed)
	     radiobutton(text:"7"
			 return:S7
			 group:speed)
	     radiobutton(text:"8"
			 return:S8
			 group:speed)
	     radiobutton(text:"9"
			 return:S9
			 group:speed)
	     radiobutton(text:"10"
			 return:S10
			 group:speed) newline
	     label(init:"Probability of attack in tall grass :"
		   glue:we) newline
	     radiobutton(text:"0%"
			 init:true
			 return:P1
			 group:prob)
	     radiobutton(text:"25%"
			 return:P2
			 group:prob)
	     radiobutton(text:"50%"
			 return:P3
			 group:prob)
	     radiobutton(text:"75%"
			 return:P4
			 group:prob)
	     radiobutton(text:"100%"
			 return:P5
			 group:prob) newline
	     label(init:"Choice of your Pokemoz!"
		  glue:we) newline
	     radiobutton(text:"Bulbasoz"
			 init:true
			 return:C1
			 background:green
			 group:pokemoz) 
	     radiobutton(text:"Oztirtle"
			 return:C2
			 background:blue
			 group:pokemoz)
	     radiobutton(text:"Charmandoz"
			 return:C3
			 background:red
			 group:pokemoz) newline
	     button(text:"OK"
		    action:toplevel#close)
	     ))
   
   FirstScreen={QTk.build Choice}
   {FirstScreen show}
   {Wait Config.autoFight}
   {Wait C3}
   {Wait P4}
   {Wait S10}

   {Config.setSpeed [S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10]}
   {Config.setProbability [P1 P2 P3 P4 P5]}

   if C1 then
      P={Pokemoz.newPokemoz "Bulbasoz" grass}
   elseif C2 then
      P={Pokemoz.newPokemoz "Oztirtle" water}
   else
      P={Pokemoz.newPokemoz "Charmandoz" fire}
   end

   % BUILDING OF THE MAP %
   Height = {Utils.getHeight CharsList}
   Width = {Utils.getWidth CharsList}

   % Map file -> Record %
   Map = {MakeTuple map Height}
   {Utils.createRecord Map CharsList 1}
   
   % SECOND SCREEN %
   Desc=td(canvas(width:Width*ImageSize
		  height:Height*ImageSize
		  handle:Canvas))
   
   Window={QTk.build Desc}
   {BuildMap Map Height Width}

   Avatar = {Canvas newTag($)}
   Fighter = {Canvas newTag($)}

   % Trainers %
   {Canvas create(image Height*ImageSize-(ImageSize div 2) Width*ImageSize-(ImageSize div 2) image:Player tags:Avatar)}
   T1 = {Trainer.newTrainer Width-1 Height-1 P}
   {Canvas create(image (ImageSize div 2) (ImageSize div 2) image:Girl tags:Fighter)}
   T2 = {Trainer.newTrainer 0 0 {Pokemoz.determineNewPokemoz}}
   
end