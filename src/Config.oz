%--------------------------------------%
%               Config.oz              %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%

functor
import
   Gui
export
   Spd
   Delay
   Filename
   SetSpeed
   AutoFight
   Probability
   SetProbability
define
   Spd
   AutoFight
   Probability
   
   proc{SetSpeed L}
      local SetSpeedR in
	 proc{SetSpeedR L R} 
	    if L.1 == true then
	       Spd = R
	    else
	       {SetSpeedR L.2 R+1}
	    end
	 end
	 {SetSpeedR L 0}
      end
   end

   proc{SetProbability L}
            local SetProbabilityR in
	 proc{SetProbabilityR L R} 
	    if L.1 == true then
	       Probability = R*25
	    else
	       {SetProbabilityR L.2 R+1}
	    end
	 end
	 {SetProbabilityR L 0}
      end
   end

   Delay = 100

   Filename = 'Map.txt'
end
