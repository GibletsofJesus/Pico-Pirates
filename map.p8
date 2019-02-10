pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
cls(1)
for x=2,7,0.25 do
	for y=1,7,0.25 do
		circfill(-(y^1.2)+x*16,y*16,4+rnd(2),15)
	end
end

for i=0,20+rnd(8) do
	circfill(16+rnd(96),8+rnd(112),rnd(2),1)
end

for x=0,127 do
	for y=0,127 do
		if pget(x,y)==15 then
			if pget(x,y-1)==1 or pget(x-1,y)==1 then
				pset(x,y,13)
				for i=0,1+rnd(2) do
 				pset(x+rnd(1),y+rnd(1),13)
 			end
			elseif pget(x+1,y+1)==1 or pget(x+1,y)==1 then
				pset(x,y,13)
				for i=0,1+rnd(2) do
 				--``pset(x-rnd(1),y-rnd(1),13)
				end
			end
		end
	end
end
