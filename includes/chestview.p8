pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (10/8/18)
-- Token count 592

function init_island_chest_view()
	camera(0,0)
	poke(0x5f2c,3)
	music"1"
	camx,camy,sand,staticSand,chestClouds,circTrans_start,circTrans_end,sandIndex,chestPos,chestCol,chestCols=0,0,{},{},{},t(),0,1,53,(currentcell.treasure*2)-1,{		stringToArray"8,9,10,2,4,5,1,★",--red
  stringToArray"13,4,9,1,2,2,1,★",--orange
		stringToArray"3,9,10,1,4,5,0,★",--green
		stringToArray"4,13,6,2,5,5,1,★"--grey
	}
	if (chestCol==2 and compass_chunks > 2) chestCol=3

	if (chestCol==1) extra_canons+=1
	if (chestCol==2) compass_chunks+=1
	if (chestCol==3) morale=min(morale+20,100)

	for i=0,15 do
		add(chestClouds,{x=rnd"72",y=rnd"4",r=rrnd(1,4)})
	end
	for _x=4,62 do
		for _y=56,64,4 do
			add(staticSand,{x=_x,y=_y-_x*.15})
		end
	end
	srand"3"
	for y=0,3,.5 do
		for x=0,9,.5 do
			add(sand,{x=25+x,y=53+y,vx=0,vy=0,r=rrnd(2,5)})
		end
	end
end

function circTransition(x,y,t)
	for i=72,t-16,-1 do
		for j=-1,1 do
			circ(x,y+j,i,0)
		end
	end
end

function update_island_chest_view()
	if flr(chestPos)>44 and btnp(5) then
		sfx(56-rnd"2")
		for i=0,11 do
			if sandIndex<#sand+1 then
				circTrans_end,grain=t()+2,sand[sandIndex]
				grain.vy-=rrnd(4,6)
				grain.vx=rrnd(.5,1.5)
				grain.r-=1.5
				if (halfprob()) grain.vx*=0xffff
				sandIndex+=1
				chestPos-=0.1
				if (flr(chestPos)==44 and chestCol>1) sfx"57" score+=(chestCol-1)*35
			end
		end
	end
end

function draw_island_chest_view()
	cls"12"
	--draw clouds
	for c in all(chestClouds) do
		c.x+=c.r*.05
		_circfill((c.x-3)%72,c.y,c.r,7)
	end

	--draw water
	_rectfill(0,28,127,127,1)

	--draw land
	local w=4+sin(t()*.5)*2.5

	for i=1,3 do
		pal(15,({7,13,15})[i])
		for s in all(staticSand) do
			_circfill(s.x,s.y,9+({w+1,w,0})[i],15)
		end
	end

	--draw chest
	for i=1,7 do
		pal(chestCols[1][i],chestCols[chestCol][i])
	end

	if flr(chestPos)==44 then
		sspr(32,34,18,13,23,chestPos-6,18,13)--draw open chest
		pal()
		firstChest=false
		print_u(({"   yOU FOUND\nANOTHER CANNON!","yOU FOUND A BIT\n OF A COMPASS!","yOU FOUND SOME\n	 TREASURE!","   bAH! iT'S\n    empty!"})[chestCol],4,15,10,0)
		--draw chest contents
		if (chestCol==1) pal(11,0)_sspr(57,42,14,16,26,29)
		if (chestCol==2) _sspr(72,40,13,14,23,29) --compass
	  if (chestCol==3)	_sspr(50,34,12,5,24,39) --treasure
	else
		--draw closed chest
		_sspr(32,47,15,11,23-sin(chestPos/1.5)*.5,chestPos-4)
		pal()
		--draw sand particles
		for s in all(sand) do
			if (s.vx!=0) s.r-=0.1 s.vy+=0.5
			s.x+=s.vx
			s.y+=s.vy
			circfill(s.x,s.y,s.r,15)
		end
		if(t()%.5>.25 and firstChest)print_u("dIG! ❎",18,16,10)
	end


	if flr(chestPos)==44 then
		circTransition(32,32,128+(circTrans_end-t())*50)
		if circTrans_end-t()<-2.5 then
			--exit treasure chest state
			cls"0"
			poke(0x5f2c,0)music"63" --stop playing music
			nextState,state,st_t,boat_message,currentcell.treasure=1,2,1,"",0
		end
	else
		circTransition(32,32,(t()-circTrans_start)*50)
	end
end
