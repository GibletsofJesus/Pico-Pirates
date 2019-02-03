pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--Current cart stats (3/2/18)
-- Token count 5529 / 8192
-- Char count 22,595 / 65,536

currentcellx=2+flr(rnd(20)) currentcelly=2+flr(rnd(20))
camx=-64 camy=-64
fillps={0b0101101001011010.1,
	0b111111111011111.1,
	0b1010010110100101.1,
	0b0101101001011010.1,
	0b0001000100000000.1,
	0b1111111111011111.1
}

printStats=false

state=2--change to 1 to skip intro
--0 splash screen
--1 gameplay
--2 screen transition
--3 combat

function _________built_in_funcitons()
		--remove me
end

function _init()
	--srand(rnd(100))
	srand(1)
	world_init()
	clouds_init()
end

st_t=0--screen transition timer
function _update()
	if state==0 then
		if (btnp(5)) state=2 st_t=0
	elseif state==1 then
		if (not player.draw) boat.update(boat)
		--check if boat is outside cell range
		checkboatpos()
		if (celltype=="island") island.update()
		if (celltype=="whirlpool") wp_update()
		--lighthouse.update()
		if (player.draw) player_update(player)
		map = btn(4)
		wind_arrow.update(wind_arrow,cellwind)
		--4% CPU usage
		for c in all(clouds) do
			c.update(c)
		end
	elseif state==2 then
	elseif state==3 then
		comb_update()
	end
	st_t+=0.016666--1/60
end

function _draw()
	if (state==0) splash_screen()

	--Draw top down view of world
	if state==1 then
		camera(camx,camy)
		cls(12)
		if map then
			draw_map()
			else
			--draw island dark blue backdrop before waves
			if celltype=="island" then
			 	for b in all(island.beach) do
					circfill(b.x,b.y,b.rad+16,1)
				end
			end

			--draw waves from ship
			fillp(fillps[4])
			for w in all(waves) do
				w.draw(w)
			end
			fillp()

			if (celltype=="island") island.draw()
			if (celltype=="whirlpool") wp_draw()

		  boat.draw(boat) 	--60% CPU usage
			for c in all(clouds) do
				c.draw(c)
			end
			hud.draw(hud)
		end
	elseif state==2 then
		if st_t>0 and st_t<.8 then
			st_horizbars_out()
		end
		--2.2
		if (st_t>1) state=1
		--this is very messy, but basically runs the vector smoothing function
		-- 9 times whilst the screen is completely black during the splash
		-- screen being off screen and just before the vertical bars start
		if st_t>.8 and st_t <1.1 then
			cls(0)
			--"Loading"
			print_str('4c6f6164696e67',76,127,12)
			for i=0,(t()*12)%4 do
				pset(120+i*2,126,1)
				pset(120+i*2,125,12)
			end
			smooth_wind_vectors()
		end
	elseif state==3 then
		comb_draw()
	end

	if st_t>.8  and st_t < 2.5 then
		st_vertbars_in()
	end

	if printStats then
		print("mEM USAGE: "..stat(0),camx,camy+17,0)
		print("mEM USAGE: "..stat(0),camx,camy+16,7)
		print("cPU USAGE: "..stat(1),camx,camy+25,0)
		print("cPU USAGE: "..stat(1),camx,camy+24,7)
	end
end

function ___________top_down__HuD()
		--remove me
end

hud={
	update=function(h)
	end,
	draw=function(h)
		minimap_draw()
		draw_morale_bar()
		wind_arrow.draw(wind_arrow,cellwind)
		print("wIND",camx+112,camy+31,txt_shadow)
		print("wIND",camx+112,camy+30,7)
	end
}

function draw_map()
	rectfill(camx,camy,camx+127,camy+127,12)
	for x=1,#cells do
		for y=1,#cells[x] do
			local c = 12
			if (cells[x][y].type=="island") c=15
			if (cells[x][y].type=="whirlpool") c=7
			circfill(-1+camx+x*2,-1+camy+y*2,0,c)
		end
	end
	if (flr(t()*4)%2>0) pset(camx-1+currentcellx*2,camy-1+currentcelly*2,4)
end

function minimap_draw()
	print(currentcellx,camx+102,camy+6,txt_shadow)
	print(currentcelly,camx+116,camy+19,txt_shadow)
	print(currentcellx,camx+102,camy+5,7)
	print(currentcelly,camx+116,camy+18,7)

	rectfill(camx+111,camy,camx+127,camy+16,12)
	rect(camx+111,camy,camx+127,camy+16,7)
	if (celltype=="island") circfill(camx+119,camy+8,island.size/16,15)
	if celltype=="whirlpool" then
		fillp(fillps[1])
		circfill(camx+119,camy+8,4,7)
		fillp()
	end
	--player indicator on minimap
	pset(camx+112+flr(((boat.x+256)/512)*14),camy+1+flr(((boat.y+256)/512)*14),4)
end

function draw_morale_bar()
	--"Morale"
	print_str('4d6f72616c65a',camx+1,camy+11,7)
	local x=camx+42
	local y=camy+1
	local _x=x+57
	local _y=y+10
	--Drawing morale bar
	rectfill(x,y,_x,_y+1,txt_shadow)
	rectfill(x+1,y+1,_x-29,_y-1,8)-- -sin(t()*.1)*29,_y-1,8)
	rect(x,y,_x-29,_y-1,2)-- -sin(t()*.1)*29,_y-1,2)
	rect(x,y,_x,_y,7)
end

function ______________________meta()
		--remove me
end

function splash_screen()
	cls(0)
	--a->z = 97->122
	--a->z = 65->90

	printlogo() -- 42% CPU usage

	print_str('412067616d65206d616465206279',24,72,7) --a game made by
	print_str('43726169672054696e6e6579',26,82,12) --craig tinney
	--print_str('7b4769626c6574736f664a6573757',16,94,12) --@gibletsofjesus

	--twitter handle shimmer 0.06% CPU usage
	--[[for x=17,111 do
		for y=85,94 do
			if pget(x,y)!=0 then
				local start=((t()*45)-y*.5)%192
				if (x>start and x<start+4) pset(x,y,7)
			end
		end
	end]]

	local py=112+sin(t()*.5)*4
	print_str('5072657373',16,py,7) --press
	print_str('58',52,py,8) --red x
	print_str('746f207374617274',64,py,7) --to start
end

--screen transition
function st_horizbars_out()
	--1.2s duration
	--draw black bars
	local a=0
	for y=0,127 do
		if y%2==0 then
			line(127,y,127-(st_t*59),y,0)
		else
			line(0,y,st_t*59,y,0)
 		end
	end
	for y=0,127 do
		local scr=0x6000+(y*64)
		if y%2==0 then
			memcpy(scr,scr+((st_t+.48)*2),64)
		else
			memcpy(scr,scr-(st_t*2),64)
		end
	end
end

function st_vertbars_in()
	for x=0,127 do
		local _x=x+camx
		local _y=camy
		if x%2==0 then
			line(_x,-1+_y,_x,_y+(2.2*120)-st_t*120,0)
		else
			line(_x,128+_y,_x,127-((2.2*120)-st_t*120)+_y,0)
 		end
	end
end

function _______________pirate_crew()
		--remove me
end

morale=0

function ___________top_down_boat()
		--remove me
end

boat={
	x=-160,y=-160,r=0,d=0,
	mx=0,my=0,max=2.5,--momentum x+y
	update=function(b)
		local speed=0.05
		local c=cos(b.r)
		local s=sin(b.r)
		local sc=(s*s)+(c*c)

		if(btn(0)) b.r=b.r%1+.01
		if(btn(1)) b.r=b.r%1-.01

		b.mx+=cellwind.wy*.05
		b.my-=cellwind.wx*.05

		if btn(2) then
			b.mx+=s*speed
			b.my-=c*speed
			sfx(0)
		else
			b.mx*=.99
			b.my*=.99
		end
		b.mx=mid(-b.max,b.mx,b.max)
		b.my=mid(-b.max,b.my,b.max)
		sc=abs(b.mx*b.my)
		b.d+=sc
		if (flr(b.d)>2) newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4) b.d=0

		b.x+=b.mx
		b.y+=b.my
		b.x=flr(b.x*2)/2
		b.y=flr(b.y*2)/2

		camx=flr(boat.x-64)
		camy=flr(boat.y-64)
	end,
	draw=function(b)
		if t()%.25==0 then
			newWave(b.x-sin(b.r)*4,
			b.y+cos(b.r)*4)
		end
		if checklandcol(b.x,b.y,b.r) and not map and not player.draw then
			player.draw=true
			player.x=b.x+sin(b.r)*8
			player.y=b.y-cos(b.r)*8
			b.mx=0 b.my=0
		end
		--This draw method is presonsible for
		-- ~20% CPU usage, which is better than
		-- the unoptimized 60% it was previously
		local s=sin(b.r)
		local c=cos(b.r)
		local _b=s*s+c*c
		local w = sqrt(8^2*2)
		for y=-w,w do
			for x=-w,w do
				local ox=(s*y+c*x)/_b+8
				local oy=(-s*x+c*y)/_b+8
				if ox<16 and oy<16 and ox>0 and oy>0 then
					for i=0,7 do
						local col=sget(ox+(i*16-4),oy+98)
						if (col>0) pset(flr(b.x)+x,flr(b.y-i)+y,col)
					end
				end
			end
		end
	end
}

--check land collision
function checklandcol(x,y,r)
	return pget(x+sin(r)*8,y-cos(r)*8)==15 or
	pget(x-sin(r)*8,y+cos(r)*8)==15 or
	pget(x-sin(r+.75)*8,y+cos(r+.75)*8)==15 or
	pget(x-sin(r+.25)*8,y+cos(r+.25)*8)==15
end

waves={}
function newWave(_x,_y)
	local w={
	x=flr(_x),y=flr(_y-1),r=2,
	draw=function(w)
		circ(w.x,w.y,w.r,7)
		w.r+=0.2
		if (w.r>10) del(waves,w)
	end
	}
	add(waves,w)
end

function _______world_management()
		--remove me
end

function world_init()
	cells={}
	for cx=0,63 do
		local subcell={}
		add(cells,subcell)
		for cy=0,63 do
			--random wind vectors
			local _wx=rnd(0.75)+.25
			if (rnd(1)>.5) _wx*=-1
			local _wy=rnd(0.75)+.25
			if (rnd(1)>.5) _wy*=-1

			local _type=""
			if rnd(1)>island_prob then
				 _type="island"
			elseif rnd(1)>wp_prob then
				 _type="whirlpool"
			else
				_type="sea"
			end

			local cell={
				type=_type,
				treasure={},
				seed=rnd(4096),
				wind={wx=_wx,wy=_wy}
			}

			add(subcell,cell)
		end
	end
	setcell()
end

function cell_shift(x,y)
	boat.x+=x boat.y+=y
	for w in all(waves) do
		w.x+=x w.y+=y
	end
	for c in all(clouds) do
		c.x+=x c.y+=y
	end
	setcell()
end

function checkboatpos()
	if (boat.x < -256) then
		currentcellx-=1
		if (currentcellx<1) currentcellx+=#cells
		cell_shift(512,0)
	elseif (boat.x > 256) then
		currentcellx+=1
		if (currentcellx>#cells) currentcellx=1
		cell_shift(-512,0)
	elseif (boat.y < -256) then
		currentcelly-=1
		if (currentcelly<1) currentcelly+=#cells[currentcellx]
		cell_shift(0,512)
	elseif (boat.y > 256) then
		currentcelly+=1
		if (currentcelly>#cells) currentcelly=1
		cell_shift(0,-512)
	end
end

currentcell={}
cellwind={}
cellseed=0
celltype=""

function setcell()
	wp_ps={}
	fps={}
	currentcell=cells[currentcellx][currentcelly]
	cellwind=currentcell.wind
	cellseed=currentcell.seed
	celltype=currentcell.type
	if celltype=="island" then
		createisland(cellseed)
	elseif celltype=="whirlpool" then
		wp_init()
	end
end

function _________island_generation()
		--remove me
end

island_prob= 0--.925
wp_prob=.99

island={
	update=function()
		for t in all(island.trees) do
			t.update(t)
		end
	end,
	draw=function()
		--white wave crest
		for b in all(island.beach) do
			circ(b.x,b.y,b.rad+((1+sin(t()*.2))*8)+1,7)
			circ(b.x,b.y,b.rad+((1+sin(t()*.2))*8),7)
		end
		--wet sand
		for b in all(island.beach) do
			circfill(b.x,b.y,b.rad+((1+sin(t()*.2))*8),13)
		end
		--beach
		for b in all(island.beach) do
			circfill(b.x,b.y,b.rad,15)
		end
		for b in all(island.beach) do
			circfill(b.x+(b.r0*8),b.y+(b.r0*8),b.rad/15,6)
		end

		if (island.size > 8) circfill(0,0,island.size*.8,6)
		if (island.size > 16) circfill(0,0,island.size*.5,4)

		fillp(fillps[2],-camx,-camy)
		if (island.size > 6) circfill(0,0,island.size*1.35,6)
		fillp(fillps[4],-camx,-camy)
		if (island.size > 16) circfill(0,0,island.size*.35,9)
		fillp()
		--draw trees
		if drawTrees then
			for t in all(island.trees) do
				if(t.c<2) t.draw(t)
			end
		end

		for f in all(fps) do
			f.draw(f) --draw footprints
		end

		if (player.draw) player_draw(player)
		if drawTrees then
			for t in all(island.trees) do
				if(t.c>1)t.draw(t)
			end
		end
	end
}

function createisland(seed)
	srand(seed)
	--radius of this new island
	island.size=rnd(64)+6
	local size=island.size
	--create the various circles required to create this island
 	local totalcircs=max(size/8,5)
	island.beach={}
	island.wetsand={}
	island.waves={}
	for i=0,totalcircs do
		--offset around the overall island circle to place this new circle to be drawn
		local r=i/totalcircs

		add(island.beach,{
			x=cos(r)*size,y=-sin(r)*size,
			rad=(size)*(.7+rnd(.6)),
			r0=rnd(2)-1,r1=rnd(2)-1,r2=rnd(2)-1,r3=rnd(2)-1
		})
	end

	--now for some trees
	island.trees={}
	if size > 24 then
		size*=.5
		for i=0,size/2 do
			local r=i/(size/2)
			sz=rnd(4)+8
			newtree({(rnd(10)-5)+cos(r)*size,(rnd(10)-5)-sin(r)*size},sz)
		end
		for i=0,size/4 do
			local r=i/(size/4)
			sz=rnd(2)+10
			newtree({(rnd(10)-5)+(rnd(1)-.5)*size,(rnd(10)-5)-(rnd(1)-.5)*size},sz)
		end
		--sort trees by z value
		sorttrees(island.trees)
	end
end

drawTrees=true
function toggletrees()
	drawTrees = not drawTrees
end

function toggleStats()
	printStats = not printStats
end

menuitem(1, "trees "..(drawTrees and 'on' or 'off'), toggletrees)
menuitem(2, "print stats "..(printStats and 'on' or 'off'), toggleStats)

function newtree(xy,s)
	local z=rnd(.5)+1
	--trunk
	local trunksections=0
	for i=0,trunksections do
		new_tree_section(xy,(z/trunksections)*i,4,s*.25)
	end
	--shadow
	new_tree_section(xy,0,1,s,fillps[3])
	new_tree_section(xy,0,1,s*1.1,fillps[1])
	--dark green leaves
	new_tree_section(xy,z,3,s*.8)
	new_tree_section(xy,z-.15,3,s*.9,fillps[1])
	new_tree_section(xy,z-.25,3,s,fillps[2])
	--light green leaves (slightly smaller)
	new_tree_section(xy,z+1,11,s/2)
	new_tree_section(xy,z+.5,11,s/1.5,fillps[1])

	--white bitys
	new_tree_section(xy,z+1.5,7,s/5)
	new_tree_section(xy,z+1.25,7,s/4,fillps[1])
end

function new_tree_section(xy,_z,_c,_r,palette)
	local tree={
		x=xy[1],y=xy[2],z=_z*.1,vx=0,vy=0,c=_c,r=_r,
		update=function(t)
			t.vx=(t.x-camx-64)*t.z
			t.vy=(t.y-camy-64)*t.z
		end,
		draw=function(t)
			if (palette) fillp(palette,-camx,-camy)
		  circfill(t.x+t.vx,t.y+t.vy,t.r,t.c)
		  fillp()
		end
	}
	add(island.trees,tree)
end

function sorttrees(a)
	for i=1,#a do
	 local j = i
	 while j > 1 and a[j-1].z > a[j].z do
		a[j],a[j-1] = a[j-1],a[j]
		j=j-1
	 end
	end
end

function _________walk_about_islands()
		--remove me
end

player={
	x=0,y=0,draw=false,speed=1,
	fp_dist=0, dir=0
}

function	player_update(p)
	if abs(p.x-boat.x) < 4 and abs(p.y-boat.y) < 4 then
		p.draw=false
		--push boat away from centre of island
		--island always found at (0,0)
		--vector topush boat away is same as position(normalised)
		magnitude=sqrt((boat.x*boat.x) + (boat.y*boat.y))*.1
	  boat.x+=boat.x/magnitude
		boat.y+=boat.y/magnitude
	 	--boat.x-=sin(boat.r)*16
	 	--boat.y+=cos(boat.r)*16
	end

	if (btn(0)) p.x-=p.speed p.fp_dist+=1
	if (btn(1)) p.x+=p.speed p.fp_dist+=1
	if (btn(2)) p.y-=p.speed p.fp_dist+=1
	if (btn(3)) p.y+=p.speed p.fp_dist+=1

	camx=player.x-64
	camy=player.y-64
end

function	player_draw(p)
	p.speed=1
	local c=pget(p.x,p.y)
	if (c==12) p.speed=.1
	if p.fp_dist>2 then
		if (c==15) new_footprint(p.x,p.y) sfx(1)
		if (c!=15) sfx(2)
		p.fp_dist=0
	end
	circfill(p.x,p.y,1,0)
end

fps={}--footprints
function new_footprint(x,y)
	local fp={
		x,y,
		draw=function(fp)
			pset(x,y,13)
		end
	}
	add(fps,fp)
end


function _________________island_loot()
		--remove me
end


function init_island_chest_view()
	poke(0x5f2c,3)
	chestClouds={}
	for i=0,15 do
		add(chestClouds,{rnd(72),rnd(4),1+rnd(3)})
	end
	for x=0,8,0.5 do
		for y=1,3 do
			add(staticSand,{x*8,y*8+(48-x^1.05),6,15})
		end
	end
	for y=0,7,.75 do
		for x=-3,5 do
			if (y%2==0) x*=-1
			local r=3+rnd(2)
			newGrainOfSand(32+x*2,54+y*.4,r)
			if (y%2==0) x*=-1
		end
	end
end

circTrans_start=0
circTrans_end=0
function circTransition(x,y,t)
	for i=72,t-16,-1 do
		circ(x,y,i,0)
		circ(x,y+1,i,0)
		circ(x,y-1,i,0)
	end
end

sandIndex=1

function update_island_chest_view()
	for i=0,9 do
		if sandIndex<#sand+1 and btnp(4) then
			local grain=sand[index]
			grain.moving=true
			grain.vy-=4	+rnd(2)
			grain.vx=.5+rnd(1)
			grain.r-=1.5
			if (rnd(1)>.5) grain.vx*=-1
			sandIndex+=1
			chestPos-=0.1
		end
	end
	for s in all(sand) do
		s.update(s)
	end
end

chestPos=53
chestCols={
	{8,9,10,2,4,5,1},--red
	{4,13,6,2,5,5,1},--grey
	{3,9,10,1,4,5,0},--green
	{13,4,9,1,2,2,1},--13 = orange
}
chestCol=4

function draw_island_chest_view()
	cls(12)
	pal()
	--draw clouds
	for c in all(chestClouds) do
		c[1]+=c[3]*.05
		circfill((c[1]-3)%72,c[2],c[3],7)
	end

	--draw water
	rectfill(0,28,127,127,1)

	--draw land
	pal(15,7)
	local p=sin(t()*.5)
	for s in all(staticSand) do
		s[3]+=5+p*2.5
		s[1]-=1+p
		circfill(s[1],s[2],s[3],s[4])
		s[3]-=5+p*2.5
		s[1]+=1+p
	end
	pal(15,13)
	for s in all(staticSand) do
		s[3]+=4+p*2.5
		s[1]-=1+p
		circfill(s[1],s[2],s[3],s[4])
		s[3]-=4+p*2.5
		s[1]+=1+p
	end
	pal()
	for s in all(staticSand) do
		circfill(s[1],s[2],s[3],s[4])
	end
	--draw chest
	--draw chest
	for i=1,#chestCols[1] do
		pal(chestCols[1][i],chestCols[chestCol][i])
	end
	if flr(chestPos)==44 then
		sspr(83,48,w,h,32-w/2,chestPos-h/2,w,h)--draw chest contents
		pal()
		?"yOU FOUND SOME\n   TREASURE!",4,16,0
		?"yOU FOUND SOME\n   TREASURE!",4,15,9.5+p
		sspr(48,48,12,5,25,40)
	else
		sspr(64,48,w,h,32-w/2-sin(chestPos/1.5)*.5,chestPos-h/2,w,h)
	end

	--draw sand particles
	for s in all(sand) do
		s.draw(s)
	end

	if flr(chestPos)==44 then
		circTransition(32,32,128+((circTrans_end-t()))*50)
	else
		circTransition(32,32,t()*50)
	end
end

sand={}
staticSand={}
function newGrainOfSand(_x,_y,_r)
	local grain={
		x=_x, y=_y,
		vx=0, vy=0,
		r=_r,moving=false,
		update=function(s)
			if (s.moving) s.r-=0.1 s.vy+=0.5
			--if (s.r<-3) del(sand,s)
			s.x+=s.vx
			s.y+=s.vy
		end,
		draw=function(s)
			circfill(s.x,s.y,s.r,15)
		end
	}
	add(sand,grain)
end

function _____________clouds_n_wind()
		--remove me
end

function clouds_init()
	clouds={}
	local _dx=1
	local _dy=1
	if (rnd(1)>.5) _dx*=-1
	if (rnd(1)>.5) _dy*=-1
	for i=0,50 do
		newCloud(_dx,_dy)
	end
end

function newCloud(_dx,_dy)
	local cloud={
		x=camx+rnd(127),y=camy+rnd(127),
		dx=rnd(3)*_dx,dy=rnd(3)*_dy,
		r=4+rnd(10),
		z=1.5+rnd(.5),vx=0,vy=0,
		update=function(c)
			c.x+=currentcell.wind.wy*.5
			c.y-=currentcell.wind.wx*.5

			if (c.x+c.vx>camx+128) c.x-=128
			if (c.y+c.vy>camy+128) c.y-=128
			if (c.x+c.vx<camx-0) c.x+=128
			if (c.y+c.vy<camy-0) c.y+=128

			c.vx=(c.x-camx-64)*c.z
			c.vy=(c.y-camy-64)*c.z

			c.vx=mid(-128,c.vx,128)
			c.vy=mid(-128,c.vy,128)
		end,
		draw=function(c)
			fillp(fillps[2-flr(c.r/8)])
			circfill(c.x+c.vx,c.y+c.vy,c.r,7)
			fillp()
		end
	}
	add(clouds,cloud)
end

function smooth_wind_vectors()
	for _x=1,#cells do
		for _y=1,#cells[_x] do
			local up=cells[_x][mid(1,_y+1,#cells[_x]-1)].wind
			local down=cells[_x][mid(1,_y+1,#cells[_x]-1)].wind
			local left=cells[mid(1,_x-1,#cells-1)][_y].wind
			local right=cells[mid(1,_x+1,#cells-1)][_y].wind
			local self=cells[_x][_y].wind

			self.wx=(right.wx+left.wx+up.wx+down.wx+self.wx)/5
			self.wy=(right.wy+left.wy+up.wy+down.wy+self.wy)/5
		end
	end
end

wind_arrow={
	sm=20,--smoothing value
  w=5.657,--sqrt(4^2*2)
	c=0,s=0,_b=0,
	update=function(wa,v)
		wa.s=sin(atan2(flr(v.wx*wa.sm)/wa.sm,flr(v.wy*wa.sm)/wa.sm))
		wa.c=cos(atan2(flr(v.wx*wa.sm)/wa.sm,flr(v.wy*wa.sm)/wa.sm))
		wa._b=wa.s*wa.s+wa.c*wa.c
	end,
	draw=function(wa)
	  for y=-wa.w,wa.w do
	    for x=-wa.w,wa.w do
	      local ox=( wa.s*y+wa.c*x)/wa._b+4
	      local oy=(-wa.s*x+wa.c*y)/wa._b+4
	      local col=sget(ox+28,oy+4)
	      if col>0 then
	 				pset(camx+120+x,camy+42+y+1,txt_shadow)
					pset(camx+120+x,camy+42+y,7)
	      end
	    end
	  end
	end
}

function ________________whirlpools()
		--remove me
end

wp_ps={}--whilrpool points

function wp_init()
	local tot=48
	for i=0,tot do
		local _r=(192/tot)*i
		local _o=rnd(2)
		for j=0,4 do
			add(wp_ps,{x=0,y=0,r=_r,o=_o})
		end
	end
end

function wp_update()
	for p in all(wp_ps) do
		local t_=t()+p.o-rnd(.4)
		p.x=64+(sin(t_*(15/p.r))*p.r)+rnd(p.r*.03125)
		p.y=64-(cos(t_*(15/p.r))*p.r)+rnd(p.r*.03125)
	end
end

function wp_draw()
	--circfill(64,64,128,1)
	--fillp(fillps[1])
	local _p;
  for p in all(wp_ps) do
		if (_p and _p.r==p.r and p.r > 8) then
			line(p.x,p.y,_p.x,_p.y,7)
		else
			--circfill(p.x,p.y,p.r*.015625,7)
		end
		_p=p
    --pset(p.x,p.y,7)
  end
	--fillp(0)
end

function _________________fancy_text()
		--remove me
end

txt_shadow=1

function print_s(_x,_y,_l,c)
	--total_layers=4
	--letters_per_layer=7
	--letter size, 7*7

	--Find index of letter to print and which colour layer to look at
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(txt_shadow,layer)
	sspr(7*l,16,7,7,_x,_y-6)
	set_col_layer(c,layer)
	sspr(7*l,16,7,7,_x,_y-7)
	pal()
end

function print_l(_x,_y,_l,c)
	local l=_l%7
	local layer=(_l-l)/7

	set_col_layer(txt_shadow,layer)
	sspr((12*l)+37,23,12,11,_x,_y-9)
	set_col_layer(c,layer)
	sspr((12*l)+37,23,12,11,_x,_y-10)
	pal()
end

function print_xl(_x,_y,_l,c)
	local l=_l%3
	local layer=(_l-l)/3
	for x=0,11 do
		local wiggle=sin(t()*-.33+((_x+x)*.018))*2
		set_col_layer(13,layer)
		sspr((12*l)+x,23,1,21,_x+x,_y+wiggle+1)
		set_col_layer(c,layer)
		sspr((12*l)+x,23,1,21,_x+x,_y+wiggle)
	end
	pal()
end

function print_str(str,x,y,c)
	--decode hex string into ascii values to print (using base 2)
	str=unhex(str,2)

	--x position
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

function print_str_o(str,x,y,c)

	for i=1,#dirs do
		print_str(str,x+dirs[i][1],y+dirs[i][2],c)
	end
end

function print_o(p,str,x,y,c)
	local dirs={{1,0},{1,-1},{1,-1},{-1,0},
		{-1,1},{-1,-1},{0,1},{0,-1}}
	for i=1,#dirs do
		p(str,x+dirs[i][1],y+dirs[i][2],c)
	end
end

function printlogo()
	--Big P
	for x=0,23 do
		pal(1,13)
		local wiggle=sin(t()*-.33+((36+x)*.018))*2
		sspr(x,44,1,27,x+36,5+wiggle)
		pal(1,7)
		sspr(x,44,1,27,x+36,4+wiggle)
	end

	--ico
	local xls={59,69,81}
	for i=1,#xls do
		print_xl(xls[i],5,i-1,7)
	end

	--big P
	for x=0,23 do
		pal(1,13)
		local wiggle=sin(t()*-.33+((14+x)*.018))*2
		sspr(x,44,1,27,x+14,33+wiggle)
		pal(1,7)
		sspr(x,44,1,27,x+14,32+wiggle)
	end

	--pirates
	xls={37,47,60,72,80,92,104}
	local ls={0,3,4,5,7,8,9}
	for i=1,#xls do
		print_xl(xls[i],32,ls[i],7)
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

function unhex(s,n)
	n=n or 2
	local t={}
	for i=1,#s,n do
		add(t,('0x'..sub(s,i,i+n-1))+0)
	end
	return t
end

function ________experimental_tings()
		--remove me
end

function spr_rot(sx,sy,swh,dx,dy,rot)
  local s=sin(rot)
  local c=cos(rot)
  local _b=s*s+c*c
  local size = swh/2
  local w = sqrt(size^2*2)
  for y=-w,w do
    for x=-w,w do
      local ox=(s*y+c*x)/_b+size
      local oy=(-s*x+c*y)/_b+size
      if ox<swh and oy<swh and ox>0 and oy>0 then
        local col=sget(ox+sx,oy+sy)
        if (col>0) pset(dx+x,dy+y,col)
      end
    end
  end
end

--https://www.lexaloffle.com/bbs/?tid=30518
_fillp_original=fillp

--local fill pattern
function fillp(pattern,x,y)
    local add_bits=band(pattern,0x0000.ffff)
    pattern=band(pattern,0xffff)
    y=flr(y)%4
    if(y~=0)then
        local r={0xfff0,0xff00,0xf000}
        local l={0x000f,0x00ff,0x0fff}
        pattern=bxor(lshr(band(pattern,r[y]),y*4),shl(band(pattern,l[y]),(4-y)*4))
    end

    x=flr(x)%4
    if(x~=0)then
        local r={0xeeee,0xcccc,0x8888}
        local l={0x1111,0x3333,0x7777}
        pattern=bxor(lshr(band(pattern,r[x]),x),shl(band(pattern,l[x]),4-x))
    end

    return _fillp_original(bxor(pattern,add_bits))
end

function ____________________combat()
	--#RemoveMe
end

function ___________________helpers()
end

shakeTimer=0
shakeAmount=4
shakeX=0 shakeY=0
function screenShake()
	if shakeTimer > 0 then
		shakeX=rnd(shakeAmount*2)-shakeAmount
		shakeY=rnd(shakeAmount*2)-shakeAmount
		shakeTimer-=0.33
	else
		shakeX=0 shakeY=0
	end
	camera(shakeX,shakeY)
end

function aabbOverlap(a,b)
	return ((a.x+a.w > b.x)
					and (a.x < b.x+b.w))
		and ((a.y+a.h > b.y)
					and (a.y < b.y+b.h))
end

function pal_all(c)
	for i=0,15 do
		pal(i,c)
	end
end

function lerp(a,b,t)
 return b*t+(a*(1-t))
end

__gfx__
0000000000400000000000007000000000000007000000000000000000000000000000000000000000007c0007c0000000000000000000000000000000000000
00000000004000000000000000000000000000000000000000000000000000000000000000000000008cb9a07a8a000000000000000000000000000000000000
0070070000700000000000000000000660000000000000000000000000000000000000000000000007b9a897c9ab000000000000000000000000000000000000
00077000074700000000000000000066660000000000000000000000000000009999999999940000c9ac797a9ac9000000000000000000000000000000000000
000770004444400000000000000006666660000000000000000000000000000955555555559240009b7a9c9ba990000000000000000000000000000000000000
007007007747700000000000000066666666000000aaaaaaaaaaa900000000955555555559224000000000000000000000000000000000000000000000000000
00000000774770000000000000000066660000000a22222222229240000009999999999999224000000000000000000000000000000000000000000000000000
000000004f4f4000000000000000006666000000a2888888888922400000a1111111111114440000000000000000000000000000000000000000000000000000
000000004f4f4000000000000000006666000000a2888aa288892440000a11111111111144000000000000000000000000000000000000000000000000000000
000000004f4f4000000000000000006666000000aaaaa11999994240000aaaaaaaaaaa9424000000000000000000000000000000000000000000000000000000
0000000049f94000000000000000006666000000a222a11922292240000a222a1192229224000000000000000000000000000000000000000000000000000000
0000000044444000000000000000006666000000a288a11928892240000a288a1192889224000000000000000000000000000000000000000000000000000000
0000000044444000000000000000006666000000a288899288892240000a28889928889224000000000000000000000000000000000000000000000000000000
0000000004440000000000000000000000000000a288888888892240000a28888888889224000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000a288888888892400000a28888888889240000000000000000000000000000000000000000000000000000000
0000000000000000000000007000000000000007a999999999994000000a99999999999400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aae5fba057770008eff908ff7daa0bffd9005dddd046617760000000000000000000000000000000000000000000000000000000000000000000000000000000
0e501e088528d804d284008700f00c708500e14ad006320600000000000000000000000000000000000000000000000000000000000000000000000000000000
06b3b60085f580050a04000f6e10007d4000a3d2a007023700000000000000000000000000000000000000000000000000000000000000000000000000000000
070816008d28900582850007807040b04e00a1e8a007002700000000000000000000000000000000000000000000000000000000000000000000000000000000
23edf320df7b8008dfd8007ff9600ffffb023dde2222755200000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000022004400000060000001000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001100000000000000000000000000008800000000000000000000008880000000008880000000000000000000002200000000002220002220000000000
00000811000000000000000000000000000002aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd10000675555572000466515740000000000
000088900000000000000000000000000000002e9550a00009d40aa9d48800049e6090004512a845380000097208d10000623540370000067200700000000000
0008c8880000000000000000000020000044006f8114b100008817e9140800459a2c00000006f906910000017688010000223540230000077200600000000000
000cc88800000000000000000002200000440467993b6000008817fd400804551aa040000006fd68110000013ec5000000203743020000175220600000000000
0044e98002000000023400000022650000040067aa19640000089f69908000451aa0440000067be011000001bb15400000203753020000075221700000000000
0046ffd42220022227777222002677775440007608817000000097609900004592a840000006798710000001fa01060000201761020000075022700000000000
0467ffd72222002453777720027727775510003608853000000097619800000c12ac0100000679871000000db200c20000201760020000065022700000000000
0246fbb022200065510776400577200115100133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb31002225554222000226557200000000000
00467b10020000475102764005772000511002000000000000000000000000000200c40000200000060000020000000000010000000000000000200000000000
00467b10000000475102264405772004111000000000000000000000000000222000088000000000006600000000000000000000000000000000022000000000
00467b10000000677102260005772044551300000000000022222000000000030000000000000000000000000000000000000000000000000000000000000000
00467b10000002655306620005776044555000000000002288888220000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000002655162220005776404555000000000228888282882000000000000000000000000000000000000000000000000000000000000000000000000
00467b10000022655502220001776000555000000002888888828888200000000000000000000000000000000000000000000000000000000000000000000000
00467310000022655102220001336000555000000028888888282888200000000000000000000000000000000000000000000000000000000000000000000000
00467b10000022655102220001372000555000000298888882888888200000000000000000000000000000000000000000000000000000000000000000000000
0046fb901000226751222240117330005550000002a9888888888888200000000000000000000000000000000000000000000000000000000000000000000000
046effbd20002677775327221377775251000000029a988899998888200000000000000000000000000000000000000000000000000000000000000000000000
0046fff20000022675577200046777750000000002898889aaa98888200000000000000000000000000000000000000000000000000000000000000000000000
00004b00000000200410200040002150000000000288888999988882000000000000000000000000000000000000000000000000000000000000000000000000
00011111000010001000000000000000000000000288888888888882000000000000000000000000000000000000000000000000000000000000000000000000
00111111100010111110000002000000000000000288888888888820000000000000000000000000000000000000000000000000000000000000000000000000
01000011110011111111000028800000000000000288888888888282000000000000000000000000000000000000000000000000000000000000000000000000
00000001110110000111100028e00000000000002888888888822882000000000000000000000000000000000000000000000000000000000000000000000000
00000001111010000011110028800000000000028888888882288288200000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000001111028e00000000000288888888828828288200000000000000000000000000000000000000000000000000000000000000000000000
00000011110010000000111028800000000002888228828828828288200000000000000000000000000000000000000000000000000000000000000000000000
00000101110010000000111028e00000000028882888828828828228822800000000000000000000000000000000000000000000000000000000000000000000
00011001110011000001111028800000000028828822288882828822888800000000000000000000000000000000000000000000000000000000000000000000
00111001110010111110111028e00000000028288200288882882888288200000000000000000000000000000000000000000000000000000000000000000000
01111101110010000000111028800000000288288202882888288288822002800000000000000000000000000000000000000000000000000000000000000000
00011111110010000000111028e00000000288828822820288828828888228820000000000000000000000000000000000000000000000000000000000000000
00001111110010000000111028800000000028882828820028882882888888200000000000000000000000000000000000000000000000000000000000000000
00000011110010111110111028e00000000302828828200228828820222222030000000000000000000000000000000000000000000000000000000000000000
00000011110011000001111028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000111028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000111110011110000110028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00011111110011111110100028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111110011111111000028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11000001110010000110000028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001110010000000000028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004000000000000000400000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000040000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000
000040000000000000044400000000000004f4000000000000040400000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000777000000000000007000000000000000000000000000
00004000000000000004440000000000004fff400000000000404040000000000000400000000000000040000000000000004000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000000000000000000000000000000000000000000000000000
00004000000000000004440000000000004fff400000000000400040000000000000000000000000007777700000000000777770000000000000000000000000
00004000000000000004440000000000004fff400000000000404040000000000040404000000000000040000000000000004000000000000000400000000000
00004000000000000004440000000000004fff400000000000490940000000000040004000000000000000000000000000000000000000000000000000000000
00000000000000000004440000000000004444400000000000499940000000000040004000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000444000000000000044400000000000004440000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000001000000000000000000000000000010000000000000000000000000000000101010000000000000000040a09000000000000000000000000000000000001010101000000000000000000000000010000000000000000000000000000000101010100
__sfx__
0003000004610066101f6001d6001d6001c6001c60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000661005650076503460037600236003e6003f6003f6003f6003c600346002b600236001b600126000d6000c6000c6000d60011600166001b600236002d6003360033600316002e60028600236001c600
00010000060100505007050340001f000230003e0003f0003f0003f0003c000340002b000230001b000120000d0000c0000c0000d00011000160001b000230002d0003300033000310002e00028000230001c000
__music__
00 01424344
