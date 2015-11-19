%--------------------------------------%
%               Trainer.oz             %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%


functor
import
   Browser
   Utils
   Pokemoz
export
   NewTrainer
   CollisionPrevented
define

   % Trainer Constructor
   fun {NewTrainer X Y P}
      {Utils.newPortObject
	    fun {$ Msg State}
	       case Msg
	       of moveLeft then myState(x:State.x-1 y:State.y pokemoz:State.pokemoz dead:State.dead)
	       [] moveRight then myState(x:State.x+1 y:State.y pokemoz:State.pokemoz dead:State.dead)
	       [] moveUp then myState(x:State.x y:State.y-1 pokemoz:State.pokemoz dead:State.dead)
	       [] moveDown then myState(x:State.x y:State.y+1 pokemoz:State.pokemoz dead:State.dead)
	       [] die then myState(x:State.x y:State.y+1 pokemoz:State.pokemoz dead:true)
	       [] getState(?X) then  X= myState(x:State.x y:State.y pokemoz:State.pokemoz dead:State.dead)
		  myState(x:State.x y:State.y pokemoz:State.pokemoz dead:State.dead)
	       end
	    end
	     myState(x:X y:Y pokemoz:P dead:false)}
   end

   fun{CollisionPrevented TtoMove TtoAnalyse X Y}
      local
	 StateT1 StateT2
      in
	 {Send TtoMove getState(StateT1)}
	 {Send TtoAnalyse getState(StateT2)}

	 if X == 0 then %Move in the y direction
	    if StateT1.y+Y == StateT2.y then
	       if StateT1.x == StateT2.x then
		  {Pokemoz.trainerFight TtoMove TtoAnalyse}
		  false
	       else
		  true
	       end
	    else
	       true
	    end
	    
	 elseif Y == 0 then %Move in the x direction
	    if StateT1.x+X == StateT2.x then
	       if StateT1.y == StateT2.y then
		  {Pokemoz.trainerFight TtoMove TtoAnalyse}
		  false
	       else
		  true
	       end
	    else
	       true
	    end
	 end
      end
   end

end
