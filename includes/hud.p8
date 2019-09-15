pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--Current cart stats (10/8/18)
-- Token count 473

function minimapPos(boat_obj,c)
	_pset(camx+lerp(111,127,minimapLerpVal(boat_obj.x)),camy+lerp(1,16,minimapLerpVal(boat_obj.y)),c)
end

function minimapLerpVal(value)
	return mid(0,(value+256)/512,1)
end

function draw_morale_bar()
	--"Morale"
	print_str('4d6f72616c65a',camx+1,camy+11,7)
	local x,y=camx+42,camy+1
	local _x,l,_l,_y=x+57,lerp(57,0,morale/100),lerp(57,0,prevMorale/100),y+10

	if playerHpTimer>0 then
		 playerHpTimer=max(0,playerHpTimer-.1)
		 if (playerHpTimer<=1) _l=lerp(l,_l,playerHpTimer)
	else
		prevMorale,_l=morale,l
	end
	--Drawing morale bar
	_rectfill(x,y,_x,_y+1,1)
	_rectfill(x,y,_x-_l,_y,14)
	_rectfill(x+1,y+1,_x-l,_y-1,8)
	_rect(x,y,_x-_l,_y-1,2)
	_rect(x,y,_x,_y,7)
end
