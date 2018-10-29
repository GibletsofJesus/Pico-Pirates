pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--Current cart stats (29/10/18)
-- Token count 4860 / 8192
-- Char count 20285 / 65,536

--4870 token start

currentcellx=2+flr(rnd(20)) currentcelly=2+flr(rnd(20))
camx=-64 camy=-64
fillps={0b0101101001011010.1,
	0b111111111011111.1,
	0b1010010110100101.1,
	0b0101101001011010.1,
	0b0001000100000000.1,
	0b1111111111011111.1}
--fillps={0b0000000000000000}

state=2--change to 1 to skip intro
--0 splash screen
--1 gameplay
--2 screen transition
--3 combat

function _________built_in_funcitons()
		--remove me
end

treedith=false

function toggletreedithering()
	treedith = not treedith
end
menuitem(1, "tree dith "..(treedith and 'true' or 'false'), toggletreedithering())

function _init()
	cells={}
	srand(rnd(100))
	for cx=0,63 do
		local subcell={}
		add(cells,subcell)
		for cy=0,63 do
			--random wind vectors
			local _wx=rnd(0.75)+.25
			if (rnd(1)>.5) _wx*=-1
			local _wy=rnd(0.75)+.25
			if (rnd(1)>.5) _wy*=-1
			add(subcell,{item={},seed=rnd(4096),wind={wx=_wx,wy=_wy}})
		end
	end

	setcell()
	lighthouse.init()
	clouds_init()
end

st_t=0--screen transition timer

function _update()
	menuitem(1, "tree dith "..(treedith and 'true' or 'false'), toggletreedithering)

	if state==0 then
		if (btnp(5)) state=2
	end

	if state==1 then
		if (not player.draw)boat_update(boat)
		--check if boat is outside cell range
		checkboatpos()
		if (currentcell.seed<island_prob) island.update()
		if (currentcell.seed<wp_prob) wp_update()
		lighthouse.update()
		if (player.draw) player_update(player)
		map = btn(4)
		clouds_update()
	end

	if state==2 then
		st_t+=0.016666--1/60
	end
end

function _draw()
	if (state==0) splash_screen()

	if state==1 then
		camera(camx,camy)
		cls(12)

		--draw island dark blue backdrop before waves
		if currentcell.seed<island_prob then
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
		if (currentcell.seed<island_prob) island.draw()
		if (currentcell.seed<wp_prob) wp_draw()

	  boat_draw(boat)
		clouds_draw()
		minimap()
		lighthouse.draw()
		draw_morale()
		--draw map of world over entire screen
		if map then
			rectfill(camx,camy,camx+127,camy+127,12)
			for x=1,#cells do
				for y=1,#cells[x] do
					if (cells[x][y].seed<island_prob) circfill(camx+x*2,camy+y*2,0,15)
					if (cells[x][y].seed<wp_prob) circfill(camx+x*2,camy+y*2,0,7)
				end
			end
			if (flr(t()*4)%2>0) pset(camx+currentcellx*2,camy+currentcelly*2,4)
		end
		if (btn(5)) camera(0,0) printlogo()
	end

	if state==2 then
		if st_t>0 and st_t<.8 then
			st_horizbars_out()
		elseif st_t>0 then
			cls(12)
			sspr(13,2,7,12,61,58)
			st_vertbars_in()
		end
		if (st_t>2.2) state=1
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
	end
	print("mem usage: "..stat(0),camx,camy+17,0)
	print("mem usage: "..stat(0),camx,camy+16,7)
	print("cpu usage: "..stat(1),camx,camy+25,0)
	print("cpu usage: "..stat(1),camx,camy+24,7)
end

function ______________________meta()
		--remove me
end

island_prob=.15*4096
wp_prob=25

function splash_screen()
	cls(0)
	--a->z = 97->122
	--a->z = 65->90

	printlogo() -- 42% CPU usage

	--print_str('412067616d65206d616465206279',24,73,1)
	print_str('412067616d65206d616465206279',24,72,7) --a game made by
	--print_str('43726169672054696e6e6579',26,83,1)
	print_str('43726169672054696e6e6579',26,82,7) --craig tinney
	--print_str('7b4769626c6574736f664a65737573',16,95,1)
	print_str('7b4769626c6574736f664a65737573',16,94,12) --@gibletsofjesus

	--twitter handle shimmer 0.06% CPU usage
	for x=17,111 do
		for y=85,94 do
			if pget(x,y)!=0 then
				local start=((t()*45)-y*.5)%192
				if (x>start and x<start+4) pset(x,y,7)
			end
		end
	end

	local py=112+sin(t()*.5)*4
	--print_str('5072657373',16,py+1,1)
	print_str('5072657373',16,py,7) --press
	--print_str('58',52,py+1,2)
	print_str('58',52,py,8) --red x
	--print_str('746f207374617274',64,py+1,1)
	print_str('746f207374617274',64,py,7) --to start
	print(stat(1))
end

--screen transition
function st_horizbars_out()
	--1.2 second duration
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
		if x%2==0 then
			line(x,-1,x,(2.2*120)-st_t*120,0)
		else
			line(x,128,x,127-((2.2*120)-st_t*120),0)
 	end
	end
end

function ___________pirate_crew()
		--remove me
end

morale=0

function draw_morale()
	--"Morale"
	--print_str_o('4d6f72616c65a',camx+1,camy+12,1)
	--print_str_o('4d6f72616c65a',camx+1,camy+11,0)
	print_str('4d6f72616c65a',camx+1,camy+11,7)
	local x=camx+42
	local y=camy+1
	local _x=x+57
	local _y=y+10
	--Drawing morale bar
	rectfill(x,y,_x,_y+1,txt_shadow)
	rectfill(x+1,y+1,_x-29-sin(t()*.1)*29,_y-1,8)
	rect(x,y,_x-29-sin(t()*.1)*29,_y-1,2)
	rect(x,y,_x,_y,7)
end

function ___________top_down_boat()
		--remove me
end



boat={
	x=-192,y=-192,r=0,d=0,
	mx=0,my=0,max=2.5--momentum x+y
}
function boat_update(b)
	local speed=0.05
	local c=cos(b.r)
	local s=sin(b.r)
	local sc=(s*s)+(c*c)

	if(btn(0)) b.r=b.r%1+.01
	if(btn(1)) b.r=b.r%1-.01

	b.mx+=currentcell.wind.wy*.05
	b.my-=currentcell.wind.wx*.05

	if btn(2) then
		b.mx+=s*speed
		b.my-=c*speed
	else
		b.mx*=.99
		b.my*=.99
	end
	b.mx=mid(-b.max,b.mx,b.max)
	b.my=mid(-b.max,b.my,b.max)
	sc=abs(b.mx*b.my)
	b.d+=sc
	if (flr(b.d)>2) newwave(b.x-sin(b.r)*4,b.y+cos(b.r)*4) b.d=0

	b.x+=b.mx
	b.y+=b.my
	b.x=flr(b.x*2)/2
	b.y=flr(b.y*2)/2

	camx=flr(boat.x-64)
	camy=flr(boat.y-64)
end

--check land collision
function checklandcol(x,y,r)
	return pget(x+sin(r)*8,y-cos(r)*8)==15 or
	pget(x-sin(r)*8,y+cos(r)*8)==15 or
	pget(x-sin(r+.75)*8,y+cos(r+.75)*8)==15 or
	pget(x-sin(r+.25)*8,y+cos(r+.25)*8)==15
end

function boat_draw(b)
	if t()%.25==0 then
  	newwave(b.x-sin(b.r)*4,
 	 	b.y+cos(b.r)*4)
 	end
	local s=sin(b.r)
  local c=cos(b.r)
  local _b=s*s+c*c
  local size = 8/2
  local w = sqrt(size^2*2)
  for y=-w,w do
    for x=-w,w do
      local ox=( s*y+c*x)/_b+size
      local oy=(-s*x+c*y)/_b+size
      local col=sget(ox+12,oy+4)
      if col>0 then
        pset(b.x+x,b.y+y,col)
      end
    end
	end

	if checklandcol(b.x,b.y,b.r) and not map and not player.draw then
		player.draw=true
		player.x=b.x+sin(b.r)*8
		player.y=b.y-cos(b.r)*8
		--stop()
		b.mx=0
		b.my=0
	end
end

waves={}
function newwave(_x,_y)
	local w={
	x=flr(_x),y=flr(_y),r=2,
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

function minimap()
	print(currentcellx,camx+102,camy+6,txt_shadow)
	print(currentcelly,camx+116,camy+19,txt_shadow)
	print(currentcellx,camx+102,camy+5,7)
	print(currentcelly,camx+116,camy+18,7)
	--print_s(camx+103,camy+12,currentcellx,7)
	--print_s(camx+116,camy+24,currentcelly,7)

	rectfill(camx+111,camy,camx+127,camy+16,12)
	rect(camx+111,camy,camx+127,camy+16,7)
	if (currentcell.seed<island_prob) circfill(camx+119,camy+8,island.size/16,15)
	if currentcell.seed<wp_prob then
		fillp(fillps[1])
		circfill(camx+119,camy+8,4,7)
		fillp()
	end
	pset(camx+112+flr(((boat.x+256)/512)*14),camy+1+flr(((boat.y+256)/512)*14),4)
	draw_wind_indicator(currentcell.wind)
end

function checkboatpos()
	if (boat.x < -256) then
		boat.x+=512
		currentcellx-=1
		if (currentcellx<1) currentcellx+=#cells
		setcell()
		for w in all(waves) do
			w.x+=512
		end
		for c in all(clouds) do
			c.x+=512
		end
	end
	if (boat.x > 256) then
		boat.x-=512
		currentcellx+=1
		if (currentcellx>#cells) currentcellx=1
		setcell()
		for w in all(waves) do
			w.x-=512
		end
		for c in all(clouds) do
			c.x-=512
		end
	end
	if (boat.y < -256) then
		boat.y+=512
		currentcelly-=1
		if (currentcelly<1) currentcelly+=#cells[currentcellx]
		setcell()
		for w in all(waves) do
			w.y+=512
		end
		for c in all(clouds) do
			c.y+=512
		end
	end
	if (boat.y > 256) then
		boat.y-=512
		currentcelly+=1
		if (currentcelly>#cells) currentcelly=1
		setcell()
		for w in all(waves) do
			w.y-=512
		end
		for c in all(clouds) do
			c.y-=512
		end
	end
end

currentcell={}

function setcell()
	wp_ps={}
	fps={}
	currentcell=cells[currentcellx][currentcelly]
	if currentcell.seed<island_prob then
		createisland(currentcell.seed)
	elseif currentcell.seed<wp_prob then
		wp_init()
	end
end


function ______________________wind()
		--remove me
end

function clouds_init()
	clouds={}
	local _dx=1
	local _dy=1
	if (rnd(1)>.5) _dx*=-1
	if (rnd(1)>.5) _dy*=-1
	for i=0,50 do
		local cloud={
			x=camx+rnd(127),y=camy+rnd(127),
			dx=rnd(3)*_dx,dy=rnd(3)*_dy,
			r=4+rnd(10),
			z=1.5+rnd(.5),vx=0,vy=0
		}
		add(clouds,cloud)
	end
end

function clouds_update()
	for c in all(clouds) do
		c.x+=cells[currentcellx][currentcelly].wind.wy*.5
		c.y-=cells[currentcellx][currentcelly].wind.wx*.5
		--[[if (c.x+c.vx>camx+160) c.x-=192
		if (c.y+c.vy>camy+160) c.y-=192
		if (c.x+c.vx<camx-160) c.x+=192
		if (c.y+c.vy<camy-160) c.y+=192]]

		if (c.x+c.vx>camx+128) c.x-=128
		if (c.y+c.vy>camy+128) c.y-=128
		if (c.x+c.vx<camx-0) c.x+=128
		if (c.y+c.vy<camy-0) c.y+=128

		c.vx=(c.x-camx-64)*c.z
		c.vy=(c.y-camy-64)*c.z

		c.vx=mid(-128,c.vx,128)
		c.vy=mid(-128,c.vy,128)

	end
end

function clouds_draw()
	--local inc=14
	for c in all(clouds) do
		fillp(fillps[2-flr(c.r/8)])
		circfill(c.x+c.vx,c.y+c.vy,c.r,7)
		--[[print(c.x+c.vx-camx,camx,camy+inc,7)
		print(c.y+c.vy-camy,camx,camy+inc+6,7)
		inc+=14]]--
	end
	fillp()
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

function draw_wind_indicator(v)
	local smooth=20
	local s=sin(atan2(flr(v.wx*smooth	)/smooth,flr(v.wy*smooth)/smooth))
	local c=cos(atan2(flr(v.wx*smooth)/smooth,flr(v.wy*smooth)/smooth))
	--local s=v.vx
  --local c=v.vy
  local _b=s*s+c*c
  local size = 8/2
  local w = sqrt(size^2*2)
  for y=-w,w do
    for x=-w,w do
      local ox=( s*y+c*x)/_b+size
      local oy=(-s*x+c*y)/_b+size
      local col=sget(ox+28,oy+4)
      if col>0 then
 				pset(camx+120+x,camy+42+y+1,txt_shadow)
				pset(camx+120+x,camy+42+y,7)
      end
    end
  end
	print("wIND",camx+112,camy+31,txt_shadow)
	print("wIND",camx+112,camy+30,7)
end

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

function _________island_generation()
		--remove me
end

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
		for t in all(island.trees) do
			if(t.c<2)t.draw(t)
		end
		for f in all(fps) do
			f.draw(f) --draw footprints
		end
		if (player.draw) player_draw(player)
		for t in all(island.trees) do
			if(t.c>1)t.draw(t)
		end
	end
}

function createisland(seed)
	srand(seed)
	--radius of this new island
	island.size=rnd(64)+6
	local size=island.size
	--create the various circles required to create this island
 	local totalcircs=size/2
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
	if size > 16 then
		size*=.66
	 	local totalcircs=size/2
		for i=0,size/2 do
			local r=i/(size/2)
			sz=rnd(4)+8
			newtree((rnd(10)-5)+cos(r)*size,(rnd(10)-5)-sin(r)*size,sz)
		end
		for i=0,size/4 do
			local r=i/(size/4)
			sz=rnd(2)+10
			newtree((rnd(10)-5)+(rnd(1)-.5)*size,(rnd(10)-5)-(rnd(1)-.5)*size,sz)
		end
		--sort trees by z value
		sorttrees(island.trees)
	end
end

function newtree(x,y,s)
	local z=rnd(.5)+1
	--trunk
	local trunksections=0
	for i=0,trunksections do
		new_tree_section(x,y,(z/trunksections)*i,4,s*.25)
	end
	--shadow
	new_tree_section(x,y,0,1,s,fillps[3])
	new_tree_section(x,y,0,1,s*1.1,fillps[1])
	--dark green leaves
	new_tree_section(x,y,z,3,s*.8)
	new_tree_section(x,y,z-.15,3,s*.9,fillps[1])
	new_tree_section(x,y,z-.25,3,s,fillps[2])
	--light green leaves (slightly smaller)
	new_tree_section(x,y,z+1,11,s/2)
	new_tree_section(x,y,z+.5,11,s/1.5,fillps[1])

	--whie bitys
	new_tree_section(x,y,z+1.5,7,s/5)
	new_tree_section(x,y,z+1.25,7,s/4,fillps[1])
end

function new_tree_section(_x,_y,_z,_c,_r,palette)
	local tree={
		x=_x,y=_y,z=_z*.1,vx=0,vy=0,c=_c,r=_r,
		update=function(t)
			t.vx=(t.x-camx-64)*t.z
			t.vy=(t.y-camy-64)*t.z
		end,
		draw=function(t)
			if (palette and treedith) fillp(palette,-camx,-camy)
		 circfill(t.x+t.vx,t.y+t.vy,t.r,t.c)
		 fillp()
		end
	}
	add(island.trees,tree)
end

function new_tree_section_h(_x,_y,_z,_c,_r,palette)
	local tree={
		x=_x,y=_y,z=_z*.1,vx=0,vy=0,c=_c,r=_r,
		update=function(t)
			t.vx=(t.x-camx-64)*t.z
			t.vy=(t.y-camy-64)*t.z
		end,
		draw=function(t)
		 fillp(palette)
		 circ(t.x+t.vx,t.y+t.vy,t.r,t.c)
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

function ________walk_about_islands()
		--remove me
end

player={
	x=0,y=0,draw=false,speed=1,
	fp_dist=0
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
	if (pget(p.x,p.y)==12) p.speed=.1
	if (pget(p.x,p.y)==15 and p.fp_dist>2) new_footprint(p.x,p.y) p.fp_dist=0
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
	print_str(str,x+1,y,c)
	print_str(str,x+1,y+1,c)
	print_str(str,x+1,y-1,c)
	print_str(str,x-1,y,c)
	print_str(str,x-1,y+1,c)
	print_str(str,x-1,y-1,c)
	print_str(str,x,y+1,c)
	print_str(str,x,y-1,c)
end

function print_o(str,x,y,c)
	print(str,x+1,y,c)
	print(str,x+1,y+1,c)
	print(str,x+1,y-1,c)
	print(str,x-1,y,c)
	print(str,x-1,y+1,c)
	print(str,x-1,y-1,c)
	print(str,x,y+1,c)
	print(str,x,y-1,c)
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

lighthouse={
	bits={},
	init=function()
		local r=12
		for i=0,6,.25 do
			local c=8
			if (flr(i)%2==0) c=7
			r-=0.1
			new_tree_section(-32,-64,i,c,r)
		end
		new_tree_section(-32,-64,6,6,r)
		new_tree_section_h(-32,-64,6.2,5,r)
		r*=.5
		for i=6,6.5,.1 do
			new_tree_section(-32,-64,i,13,r)
		end
		r*=1.1
		for i=6.5,7,.1 do
			r-=0.1
			new_tree_section(-32,-64,i,5,r)
		end
	end,
	update=function()
		for b in all(bits) do
			b.update(b)
		end
	end,
	draw=function()
			for b in all(bits) do
				b.draw(b)
			end
	end
}

function ____________________combat()
	--#RemoveMe
end


__gfx__
00000000700000000000000770000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000004000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000004000000000000066660000000000000000000000000000000000000000099999999999400000099999999999400000000000000000000000
0007700000000004f400000000000666666000000000000000000000000000000000000000955555555559240000957c5557c559240000000000000000000000
007007000000004fff400000000066666666000000fffffffffffd000aaaaaaaaaaa9000a95555555555922400098cb9a57a8a922400ffffffffffd000000000
00000000000000477740000000000066660000000f2222222222d210a22222222229240a99999999999992240097b9a897c9ab92240f222222222d2100000000
000000000000007f4f7000000000006666000000f2444444444d221a28888888889224aa11111111111144400ac9ac797a9ac94440f288888888d22100000000
000000000000004fff4000000000006666000000f2444ff4444d211a288aaaa2889244a11111111111144000a19b7a9c9ba9944000f288ffd288d21100000000
0000000000000077777000000000006666000000fffff11ddddd121aaaa11119999424aaaaaaaaaaa9424000aaaaaaaaaaa9424000fffff1ddddd12100000000
000000000000074f4f4700000000006666000000f222f11d222d221a22a11119229224a22911119229224000a22911119229224000f22ff1dd22d22100000000
0000000000000049f94000000000006666000000f244f11d244d221a28891192889224a28891192889224000a28891192889224000f288f1d288d22100000000
0000000000000049994000000000006666000000f2444dd2444d221a28891192889224a28891192889224000a28891192889224000f2888d2888d22100000000
0000000000000044444000000000000000000000f2444444444d221a28889928889224a28889928889224000a28889928889224000f288888888d22100000000
0000000000000000000000000000000000000000f2444444444d210a28888888889240a28888888889240000a28888888889240000f288888888d21000000000
0000000070000000000000077000000000000007fddddddddddd100a99999999999400a99999999999400000a99999999999400000fdddddddddd10000000000
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
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000001000000000000000000f0a0a0000000000000000000000000000000101010101010000000000000000040a09000000000000000000000000000000000001010101000000000000000000000000000000000000000000000000000000000101010100
__sfx__
0001000204610066101f6001d6001d6001c6001c60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
01080000213500f300133530f300133532e300133530f300133500f300133530f300133532e300133530030013350000000f3001f3541f3552e3001f35400000000001f354000000f30000000000000000000000
__music__
00 01424344
