pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (30/4/18)
-- Token count 614

function init_island_chest_view()
	camera(0,0)
	camx,camy=0,0
	poke(0x5f2c,3)
	sand,staticSand,chestClouds,circTrans_start,circTrans_end,sandIndex,chestPos,chestCol={},{},{},t(),0,1,53,(currentcell.treasure*2)-1
	for i=0,15 do
		add(chestClouds,{x=rnd(72),y=rnd(4),r=rrnd(1,4)})
	end
	for _x=0,8,0.5 do
		for _y=1,3 do
			add(staticSand,{x=_x*8,y=_y*8+(48-_x^1.05),r=6})
		end
	end
	srand(3)
	for y=0,8,.75 do
		for x=-3,5 do
			if (y%2==0) x*=0xffff
			local grain={
				x=32+x*2,y=54+y*.4,
				vx=0,vy=0,r=rrnd(2,5)
			}
			add(sand,grain)
			if (y%2==0) x*=0xffff
		end
	end
end

function circTransition(x,y,t)
	for i=72,t-16,-1 do
		for _a in all(stringToArray"0,1,0xffff,★") do
			circ(x,y+_a,i,0)
		end
	end
end

function update_island_chest_view()
	if flr(chestPos)>44 and btnp(4) then
		sfx(7-rnd"2")
		for i=0,9 do
			if sandIndex<#sand+1 then
				circTrans_end=t()+2
				local grain=sand[sandIndex]
				grain.vy-=4+rnd(2)
				grain.vx=.5+rnd(1)
				grain.r-=1.5
				if (rnd"1">.5) grain.vx*=0xffff
				sandIndex+=1
				chestPos-=0.1
				if (flr(chestPos)==44) sfx"7"
			end
		end
	end
	for s in all(sand) do
		if (s.vx!=0) s.r-=0.1 s.vy+=0.5
		s.x+=s.vx
		s.y+=s.vy
	end
end

chestCols={
	stringToArray"8,9,10,2,4,5,1,★",--red
	stringToArray"13,4,9,1,2,2,1,★",--orange
	stringToArray"3,9,10,1,4,5,0,★",--green
	stringToArray"4,13,6,2,5,5,1,★"--grey
}

function draw_island_chest_view()
	cls(12)
	pal()
	--draw clouds
	for c in all(chestClouds) do
		c.x+=c.r*.05
		_circfill((c.x-3)%72,c.y,c.r,7)
	end

	--draw water
	_rectfill(0,28,127,127,1)

	--draw land
	local _pals={7,13,15}
	local p=sin(t()*.5)
	local w=4+p*2.5
	local r={w+1,w,0}
	local x={1+p,1+p,0}

	for i=1,3 do
		pal(15,_pals[i])
		for s in all(staticSand) do
			_circfill(s.x+x[i],s.y,s.r+r[i],15)
		end
	end

	--draw chest
	for i=1,7 do
		pal(chestCols[1][i],chestCols[chestCol][i])
	end
	if flr(chestPos)==44 then
		sspr(32,34,18,13,23,chestPos-6,18,13)--draw open chest
		pal()

		--Most common
		--	Empty
		--less common
		--	Small treasure
		--Rare
		--	Big treasre
		--Very Rare
		--	A big cannon
		?"yOU FOUND SOME\n	 TREASURE!",4,16,0
		?"yOU FOUND SOME\n	 TREASURE!",4,15,9.5+p
		_sspr(50,34,12,5,24,39)--draw chest contents
	else
		--draw closed chest
		_sspr(32,47,15,11,23-sin(chestPos/1.5)*.5,chestPos-4)
	end

	--draw sand particles
	for s in all(sand) do
		circfill(s.x,s.y,s.r,15)
	end

	if flr(chestPos)==44 then
		circTransition(32,32,128+((circTrans_end-t()))*50)
		if circTrans_end-t()<-2.5 then
			--exit treasure chest state
			cls(0)
			poke(0x5f2c,0)
			nextState,state,st_t,boat_message=1,2,1,""
			currentcell.treasure=0
		end
	else
		circTransition(32,32,(t()-circTrans_start)*50)
	end
end
