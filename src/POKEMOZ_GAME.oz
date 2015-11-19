%--------------------------------------%
%            POKEMOZ_GAME.oz           %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%


functor
import
   Gui
export
   FighterThread
define

   {Gui.window bind(event:"<Up>" action:Gui.moveUp)}
   {Gui.window bind(event:"<Left>" action:Gui.moveLeft)}
   {Gui.window bind(event:"<Down>" action:Gui.moveDown)}
   {Gui.window bind(event:"<Right>" action:Gui.moveRight)}
   
   {Gui.window show}

   FighterThread

   thread
      {Thread.this FighterThread}
      {Gui.moveRandomly Gui.t2}
   end

end