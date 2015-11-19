%--------------------------------------%
%                Utils.oz              %
%             Remi Chauvenne           %
%               Jerry Wei              %
%            LINGI 1131 2015           %
%--------------------------------------%

functor
export
   GetHeight
   GetWidth
   CreateRecord
   NewPortObject
define

   fun{GetHeight List}
      local GetHeight2
	 fun{GetHeight2 List R}
	    case List of nil then R
	    [] H|T then
	       if H == "r".1 then
		  {GetHeight2 T R+1}
	       else {GetHeight2 T R}
	       end
	    end
	 end
      in
	 {GetHeight2 List 0}
      end
   end

   fun{GetWidth List}
      local GetWidth2
	 fun{GetWidth2 List R}
	    case List of H|T then
	       if H==48 then
		  {GetWidth2 T R+1}
	       elseif H==49 then
		  {GetWidth2 T R+1}
	       elseif H ==")".1 then
		  R
	       else
		  {GetWidth2 T R}
	       end
	    end
	 end	 
      in
	 case List of nil then nil
	 []H|T then
	    if H=="(".1 then
	       {GetWidth2 T 0}
	    else {GetWidth T}
	    end
	 end
      end
   end
   
   proc{CreateRecord Record List I}
      local CreateTuple Tup J
	 proc{CreateTuple ListT Tupl J}
	    case ListT of nil then skip
	    [] H|T then
	       if H==48 then
		  Tupl.J = 0
		  {CreateTuple T Tupl J+1}
	       elseif H==49 then
		  Tupl.J = 1
		  {CreateTuple T Tupl J+1}
	    elseif H==")".1 then
		  skip
	    elseif H==" ".1 then
		  {CreateTuple T Tupl J}
	       end
	    end
	 end 
   in
	 case List of nil then skip
	 [] H|T then
	    if H == "r".1 then
	       {MakeTuple r 7 Tup} %to change
	       {CreateTuple T.2 Tup 1}
	       Record.I = Tup
	       {CreateRecord Record T I+1}
	    else
	    {CreateRecord Record T I}
	    end
	 end
      end
   end

   % Function for creating a NewPortObject
   fun {NewPortObject Func Init}
      proc {Loop S State}
	 case S of Msg|S2 then
	    {Loop S2 {Func Msg State}}
	 end
      end
      P S
   in
      P={NewPort S}
      thread {Loop S Init} end % Port object is sequential internally
      P
   end
end
