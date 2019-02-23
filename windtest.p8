pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function rrnd(min,max)
	return rnd(max-min)+min
end
srand(1)
currentcellx,currentcelly=flr(rrnd(2,30)),flr(rrnd(2,30))

smoothy=0
	cells={}
	for cx=0,31 do
		local subcell={}
		add(cells,subcell)
		for cy=0,31 do
			--random wind vectors
			local wx=rrnd(.25,1)
			if (rnd"1">.5) wx*=0xffff
			local wy=rrnd(0.25,1)
			if (rnd"1">.5) wy*=0xffff

			local _type=""
			if rnd"1">0 then
				 _type="island"
			elseif rnd"1">.7 then
				 _type="monster"
			elseif rnd"1">.99 then
				 _type="whirlpool"
			else
				_type="sea"
			end

			local cell={
				type=_type,
				treasure=1,
				seed=rnd(4096),
				windx=wx,
				windy=wy,
				visited=false
			}

			add(subcell,cell)
		end
	end
for _x=1,#cells do
	for _y=1,#cells[_x] do
		local up=cells[_x][max(1,_y-1)]
		local down=cells[_x][min(_y+1,#cells[_x]-1)]
		local left=cells[max(1,_x-1)][_y]
		local right=cells[min(_x+1,#cells-1)][_y]
		local self=cells[_x][_y]
		smoothy+=1
		self.windx=(right.windx+left.windx+up.windx+down.windx+self.windx)/5
		self.windy=(right.windy+left.windy+up.windy+down.windy+self.windy)/5
	end
end
?cells[1][1].windx
?cells[1][1].windy
