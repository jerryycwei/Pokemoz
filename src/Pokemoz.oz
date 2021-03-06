%--------------------------------------%
%               Pokemoz.oz             %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%

functor
import
   OS
   Browser
   QTk at 'x-oz://system/wp/QTk.ozf'

   Gui
   Utils
   Config
   POKEMOZ_GAME
export
   GrassFight
   NewPokemoz
   TrainerFight
   DetermineNewPokemoz
define

   % Pokemon Constructor
   fun {NewPokemoz Name Type}
      {Utils.newPortObject
	    fun {$ Msg State}
	       case Msg
	       of maxHealth then myState(name:State.name hp:State.maxHp xp:State.xp maxHp:State.maxHp lvl:State.lvl type: State.type color:State.color)
	       [] levelUp then myState(name:State.name hp: State.maxHp+2 xp:State.xp maxHp: State.maxHp+2 lvl: State.lvl+1 type: State.type color:State.color)
	       [] increaseLevel(X) then myState(name:State.name hp:State.maxHp+(2*X) xp:State.xp maxHp:State.maxHp+(2*X) lvl: State.lvl+X type: State.type color:State.color)
	       [] receiveAttack(X) then myState(name:State.name hp: State.hp-X xp:State.xp maxHp: State.maxHp lvl: State.lvl type: State.type color:State.color) 
	       [] winXP(X) then myState(name:State.name hp:State.hp xp:State.xp+X maxHp:State.maxHp lvl: State.lvl type: State.type color:State.color)
	       [] resetXP(X) then myState(name:State.name hp: State.hp xp:State.xp-X maxHp: State.maxHp lvl: State.lvl type: State.type color:State.color)
	       [] getState(?X) then  X=myState(name:State.name hp:State.hp xp:State.xp maxHp:State.maxHp lvl:State.lvl type:State.type color:State.color)
		  myState(name:State.name hp:State.hp xp:State.xp maxHp:State.maxHp lvl:State.lvl type:State.type color:State.color)
	       end
	    end
	    
	    if Type==grass then
	       myState(name:Name hp:20 xp:0 maxHp:20 lvl:5 type:Type color:green)
	    elseif Type==water then
	       myState(name:Name hp:20 xp:0 maxHp:20 lvl:5 type:Type color:blue)
	    elseif Type==fire then
	       myState(name:Name hp:20 xp:0 maxHp:20 lvl:5 type:Type color:red)
	    end
      }
   end

  % Create a new random pokemoz %
   fun{DetermineNewPokemoz}
      local
	 TypeProb = {OS.rand} mod 3 + 1
	 Pokemoz
      in
	 if TypeProb==1 then
	    Pokemoz={NewPokemoz "Bulbasoz" grass}
	 elseif TypeProb==2 then
	    Pokemoz={NewPokemoz "Oztirtle" water}
	 elseif TypeProb==3 then
	    Pokemoz={NewPokemoz "Charmandoz" fire}
	 end

	 Pokemoz
	 
      end
   end

   proc{GrassFight P}
      local
	 Prob = {OS.rand} mod 100 + 1
      in
	 if Prob < Config.probability then
	    local
	       TrainerState Fighter FighterState
	    in

	       Fighter = {DetermineNewPokemoz}
	       
	       if Config.autoFight then
		  {AutoFight P Fighter}
	       else
		  {FightInterface P Fighter}
	       end
	    end
	 end
      end
   end

   proc{AutoFight P1 P2}
      local
	 State1 State1bis State2 State2bis StateXP EndDesc EndScreen
      in	 
	 {Send P1 getState(State1)}
	 {Send P2 getState(State2)}

	 if State2.hp < 1 then
	    {Win nil {CalculateXP State1.lvl State2.lvl} State2.name}
	    {Send P1 winXP({CalculateXP State1.lvl State2.lvl})}
	    local NewState in
	       {Send P1 getState(NewState)}
	       {CheckEvolution P1 NewState.xp NewState.lvl}
	    end
	 end

	 %attack P2
	 if State2.hp > 0 then
	    {Attack P2 State1.type State2.type  State1.lvl State2.lvl}
	 end
    
         %attack P1
	 if State1.hp > 0 then
	    {Attack P1 State1.type State2.type  State1.lvl State2.lvl}
	 end

	 {Send P1 getState(State1bis)}
	 {Send P2 getState(State2bis)}
	 
	 if State1bis.hp < 1 then
	    {GameOver nil}
	    
	 elseif State2bis.hp < 1 then
	    {Win nil {CalculateXP State1.lvl State2.lvl} State2bis.name}
	    {Send P1 winXP({CalculateXP State1.lvl State2.lvl})}
	    local NewState in
	       {Send P1 getState(NewState)}
	       {CheckEvolution P1 NewState.xp NewState.lvl}
	    end
	    
	 else
	    {AutoFight P1 P2}
	 end
      end
   end

   proc{TrainerFight T1 T2}
      local
	 State1 State2 PokeState1 PokeState2 P1 P2
      in
	 {Send T2 die}
	 {Send T1 getState(State1)}
	 {Send T2 getState(State2)}

	 P1 = State1.pokemoz
	 {Send P1 getState(PokeState1)}
	 P2 = State2.pokemoz
	 {Send P2 getState(PokeState2)}

	 {FightInterface P1 P2}
      end
   end

   proc{FightInterface P1 P2}
      local
	 PokeState1 PokeState2 Window Desc AttackProc HP1 XP1 LVL1 HP2 XP2 LVL2
      in
	 {Send P1 getState(PokeState1)}
	 {Send P2 getState(PokeState2)}

	 Desc=lr(label(init:PokeState1.name background:PokeState1.color) newline
		 label(init:"HP:") label(init:{Int.toString PokeState1.hp} handle:HP1) label(init:"LVL:") label(init:{Int.toString PokeState1.lvl} handle:LVL1)
		 label(init:"XP:") label(init:{Int.toString PokeState1.xp} handle:XP1) newline
		 label(init:"VS") newline
		 label(init:PokeState2.name background:PokeState2.color) newline
		 label(init:"HP:") label(init:{Int.toString PokeState2.hp} handle:HP2) label(init:"LVL:") label(init:{Int.toString PokeState2.lvl} handle:LVL2)
		 label(init:"XP:") label(init:{Int.toString PokeState2.xp} handle:XP2) newline
		 button(text:"Fight" action:proc{$}
					       {Attack P2 PokeState1.type PokeState2.type PokeState1.lvl PokeState2.lvl}
					       {Attack P1 PokeState2.type PokeState1.type PokeState2.lvl PokeState1.lvl}
					       local State1 State2 in
						  {Send P1 getState(State1)}
						  {Send P2 getState(State2)}
						  {HP1  set({Int.toString State1.hp})}
						  if State1.hp < 1 then
						     {GameOver Window}
						  end
						  {XP1  set({Int.toString State1.xp})}
						  {LVL1 set({Int.toString State1.lvl})}
						  {HP2  set({Int.toString State2.hp})}
						  {XP2  set({Int.toString State2.xp})}
						  if State2.hp < 1 then
						     {Win Window {CalculateXP State1.lvl State2.lvl} State2.name}
						     {Send P1 winXP({CalculateXP State1.lvl State2.lvl})}
						     local StateUpdate in
							{Send P1 getState(StateUpdate)}
							{CheckEvolution P1 StateUpdate.xp StateUpdate.lvl}
							{Window close}
						     end
						  end
						  {LVL2 set({Int.toString State2.lvl})}
					       end
					    end
		       ) button(text:"Run Away" action:toplevel#close)
		)
	 Window = {QTk.build Desc}
	 
	 {Window show}
      end
   end

   proc{Win FightWindow XP Name}
      local WinDesc WinScreen in
	 WinDesc = lr(label(init:"You win ")
		      label(init:{Int.toString XP})
		      label(init:" XP against ")
		      label(init:Name) newline
		      button(text:"Resume"
			     action:toplevel#close)
		     )
	 WinScreen = {QTk.build WinDesc}
	 {WinScreen show}
	 if FightWindow == nil then
	    skip
	 else {FightWindow close}
	 end
      end
   end

   proc{GameOver FightWindow}
      local EndDesc EndScreen in
	 EndDesc = td(button(text:"You lose!"
				action:toplevel#close))
	 EndScreen = {QTk.build EndDesc}
	 {EndScreen show}
	 {Gui.window close}
	 if FightWindow == nil then
	    skip
	 else {FightWindow close}
	 end
      end
   end
   
   % Returns the probability of attack 
   fun {AttackProb LA LD}
      local
	 Prob = {OS.rand} mod 100 + 1
      in
	 if ((6+LA-LD)*9) > Prob then
	    true
	 else
	    false
	 end
      end	
   end

   proc {Attack P2 TypeP1 TypeP2 L1 L2}
      local
	 AttackMatrix = map(grass:grass(grass:2 fire:1 water:3) fire:fire(grass:3 fire:2 water:1) water:water(grass:1 fire:3 water:2))
      in
	 if{AttackProb L1 L2} then
	    {Send P2 receiveAttack((AttackMatrix.(TypeP1)).(TypeP2))}
	 end
      end
   end
   
   fun{CalculateXP LA LD}
      (LA+2*LD) div 2
   end

   proc{CheckEvolution P XP Level}
      local
	 EvolutionMatrix = map(5:5 6:12 7:20 8:30 9:50)
      in
	 if XP >= EvolutionMatrix.Level then
	    {Send P levelUp}
	    {Send P resetXP(EvolutionMatrix.Level)}
	 end 
      end
   end

end