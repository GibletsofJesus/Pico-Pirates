pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (30/4/18)
-- Token count 332

function print_s(_x,_y,_l,c)
	--total_layers=4
	--letters_per_layer=7
	--letter size, 7*7

	--Find index of letter to print and which colour layer to look at
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	_sspr(7*l,16,7,7,_x,_y-6)
	set_col_layer(c,layer)
	_sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(1,layer)
	_sspr(12*l,23,12,11,_x,_y-9)
	set_col_layer(c,layer)
	_sspr(12*l,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	local layer=(_l-l)/3
	for x=49,61 do
		local wiggle=sin(t()*-.33+((_x+x)*.018))*2
		set_col_layer(13,layer)
		_sspr((12*l)+x,0,1,22,_x+x,_y+wiggle+1)
		set_col_layer(c,layer)
		_sspr((12*l)+x,0,1,22,_x+x,_y+wiggle)
	end
	pal()
end

function print_str(_str,x,y,c)
	local str={}
	for i=1,#_str,2 do
		add(str,('0x'..sub(_str,i,i+1))+0)
	end
	local p=x

	-- for each letter
	for s=0,#str-1 do
		--if ascii value > 96, lower case letter
		if str[s+1]>96 then
			print_s(p,y,str[s+1]-97,c)
			--move cursor for x position over by slightly smaller amount
			-- since lower case letters are smaller than upper case (duh)
			p+=6
		else
			print_l(p,y,str[s+1]-65,c)
			p+=9
			if (str[s+1]<65)p-=6
		end
	end
end

function set_col_layer(c,b)
	b=2^b
	for i=0,15 do
		if (band(shl(i),b)>0) then
			pal(i,c)
		else
			palt(i,true)
		end
	end
end
