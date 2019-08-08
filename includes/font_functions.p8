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

  if (c!=1) print_s(_x,_y+1,_l,1)
	set_col_layer(c,(_l-l)/7)
	_sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7

	if (c!=1) print_l(_x,_y+1,_l,1)
	set_col_layer(c,(_l-l)/7)
	_sspr(12*l,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	if (c!=13) print_xl(_x,_y+1,_l,13)
	for x=49,61 do
		set_col_layer(c,(_l-l)/3)
		_sspr(12*l+x,0,1,22,_x+x,_y+sin(t()*-.33+((_x+x)*.018))*2)
	end
	pal()
end

function print_str(_str,x,y,c)
	local str,p={},x
	for i=1,#_str,2 do
		add(str,('0x'..sub(_str,i,i+1))+0)
	end
  add(str,0x20)
  --char  hex   dec
  --A     41     65
  --Z     5a     90
	--a     61     97
	--z     7a    122

	-- for each letter
	for s=0,#str-2 do
		--if ascii value > 96, lower case letter
		local v=str[s+1]
		if v>96 then
			print_s(p,y,v-97,c)
			--move cursor for x position over by slightly smaller amount
			-- since lower case letters are smaller than upper case (duh)
			p+=6
		else
			print_l(p,y,v-65,c)
			if v<65 then
				p+=5 --this must be spacing character
			else
				p+=9
				if (str[s+2]<96)p-=1 --another upper case char
			end
		end
	end
end

function set_col_layer(c,b)
	for i=0,15 do
		if band(shl(i),2^b)>0 then
			pal(i,c)
		else
			palt(i,true)
		end
	end
end
