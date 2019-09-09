pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (18/8/18)
-- Token count 2092
function comb_init(timeToFightAnOctopus)
  comb_boat=newComb_boat()
	camx,camy,comb_objs,victory,comb_boat.hp,comb_boat.isPlayer,boat_message,txt_timer=0,0,{},false,morale,true,"aLL HANDS\nON DECK! ",0xfffa
	camera(0,0)
	for j=1,0,0xffff do
    srand"1"
		for i=0,25 do
      	add(comb_objs,{
      		x=rnd"127"+j*2,y=rrnd(8,40)+j,r=rrnd(4,12)+j,c=7-j,vx=rnd".5",
      		update=function(c)
      			c.x+=c.vx
      		if (c.x>140) c.x -= 160
      		end,
      	draw=function(c)
      		_circfill(c.x,c.y,c.r,c.c)
      	end
      	})
		end
	end
	add(comb_objs,comb_boat)
	if timeToFightAnOctopus then
		enemyName,vals,tentacles,enemy="sEA MONSTER",stringToArray"119,96,112,92,87,90,79,88,73,97,★",{},{
  		hp=100,
  		x=88,y=88,w=24,h=72,
  		flashing=0,
  		timer=0,
  		stepIndex=4,
  		steps=
  		{
  			function(o) --sink below surface
  				o.y+=.5
  				for t in all(tentacles) do
  					t.y+=.5
  				end
  				if o.y>108 then
  					if o.hp>0 then
  						enemyTimer=0
  						if rnd"1">.5 then
  							o.stepIndex=3
  						else
  							o.stepIndex=5
  						end
  					else
              music"28"
  						victory_time,enemy,victory,boat_message,txt_timer=time(),null,true,"tAKE THAT,\nFOUL BEAST! ",0
  						victory_time+=0.01
  						score+=150
  						del(comb_objs,o)
  					end
  				end
  			end,
  			function(o) --rise above surface
  				o.y-=.5
  				for t in all(tentacles) do
  					t.y-=.5
  				end
  				if o.y<88 then
  					o.stepIndex,enemyTimer=4,0
  				end
  			end,
  			function(o)
  				local target=(abs(comb_boat.x-o.x)-4)/80
  				local ta={-rnd".2",0,rnd".2"}
  				for i=1,3 do
  					fireProjectile(o.x,o.y-8,true,2,ta[i],target+ta[i],o)
  				end
  				o.stepIndex=2--shoot at player
  			end,
  			function(o)--idle, exit after 5 seconds
  				if (enemyTimer>3) o.stepIndex=1 enemyTimer=0
  			end,
  			function(o)--attack with tentacles
  				local noodle = tentacles[1]
  				if (noodle.x==119) noodle.x,noodle.y=comb_boat.x,105
  				if enemyTimer < 1.5	and enemyTimer>1 then
  					noodle.y-=1
  				elseif enemyTimer>1 then
  					noodle.y+=.5
  					if noodle.y > 103 then
  						noodle.x,noodle.y=119,114
  						enemyTimer=0
  						o.stepIndex=2
  					end
  				end
  			end,
  		},
  		update=function(o)
  			enemyTimer+=0.03
  			o.y+=cos(t())*.25
  			if (o.hp<=0) o.stepIndex=1
  			o.steps[o.stepIndex](o)
  		end,
  		draw=function(o)
  			dmgFlash(o)
  			palt(0,true)
  				_sspr(0,34,29,24,o.x,o.y)
  			for i=o.x,o.x+33 do
  				if (o.hp>0) wpts[flr(i+16)]+=rnd(.25)
  			end
  			--draw tentacles
  			for t in all(tentacles) do
  				for y=0,24 do
  					local _x=t.x+2+(1.5*sin(time()+t.o+y*.1))
  					local _y=t.y+cos(time()+t.o*2)
  					if (y==1 and o.hp>0)	wpts[flr(_x+16)]+=rnd(.25)
  					_sspr(29,34+y,3,1,_x+1,_y+y)
  				end
  			end
  			pal()
  		 end
  	}
  	for i=1,10,2 do
  		add(tentacles,{x=vals[i],y=vals[i+1],o=rnd"1",w=5,h=24})
  	end
		add(comb_objs,enemy)
	else
		enemyName,enemy="eNEMY VESSEL",newComb_boat()
  	if (timeToFightAnOctopus==null) enemyName,enemy.w,enemy.h="tHE pIRATE kING",29,26
		enemy.isPlayer,enemy.x=timeToFightAnOctopus,114
	end
	add(comb_objs,enemy)
end

--get corrected array value for water
function pt(i)
	return wpts[mid(1,flr(i),#wpts-1)]
end

function drawUpdateWater()
	for i=1,#wpts do
		prevwpts[i],diff,surroundingPoints=wpts[i],wpts[i]-prevwpts[i],0
		wpts[i]+=.975+diff*1.125
		for j=0xfffc,4 do
			surroundingPoints+=pt(i+j)
		end
		wpts[i]=mid(wpts[i]-surroundingPoints*.005*wpts[i],0,128)
		_line(i-16,160,i-16,wpts[i]+97,1)
		if abs(diff)>.3 then
			_pset(i-16,wpts[i]+97,7)
		end
	end
end

function comb_boat_move(obj,m)
	obj.vx,obj.flipx,x=mid(-1.5,obj.vx+m,1.5),m<0,18
	if (m<0) x=23
	wpts[mid(1,flr(obj.x+x),160)]-=.7
	sfx"49"
end

function comb_boat_fire_projectile(b)
	sfx"48"
	local max,traj,size,x,y=1,0,1,b.x,b.y
	if (b.isPlayer) max=extra_canons
	if (b.isPlayer==null) max,size=2,2 x+=12 y+=18
	for i=1,max do
		if (i>0) traj=rrnd(-.2,.2)
		fireProjectile(2+x,5+y,b.flipx,size,b.vx+traj,b.aim+traj,b)
	end
	b.aim,b.firecd=.1,1
  if b.isPlayer!=null then
    max=max*.5+1
    b.vx-=max
  	if (b.flipx) b.vx+=max*2
  else
    b.firecd=1.4
  end
end

--combat comb_boat--
function newComb_boat()
	return {
		x=16,y=62,w=8,h=8,vx=0,
		flipx=false,aim=.1,firecd=0,
		hp=100,flashing=0,isPlayer=false,
		update=function(b)
			b.firecd=max(b.firecd-.0333,0)

			--combat boat movement/firing
			if b.isPlayer then
				if (btn"0") comb_boat_move(b,-.1)
				if (btn"1") comb_boat_move(b,.1)
				if (btn"5" and b.firecd==0) b.aim+=0.025
				if (btn4 and not btn"5" and b.firecd==0 or b.aim>1) comb_boat_fire_projectile(b)
				btn4=btn"5"
			elseif morale>0 then
				b.flipx=true
				if (abs(comb_boat.x-b.x) < 48) comb_boat_move(b,.1)
				if (abs(comb_boat.x-b.x) > 72 or b.x>114) comb_boat_move(b,-.1)
				if (b.x>125) b.flipx=true

				local target=(abs(comb_boat.x-b.x)-4)/80

				local a=0.01
        if (b.isPlayer==null) a*=2
				if (b.aim>target) a*=0xffff
				b.aim+=a
				if (b.firecd==0 and abs(b.aim-target)<.1 and b.flipx) comb_boat_fire_projectile(b)
			end

			if b.flashing<=0 and enemy!=null then
				if b.isPlayer and enemy.hp>0 then
					if (aabbOverlap(b,enemy)) hit(b,rrnd(12,17)) sfx"61"
				end
				for t in all(tentacles) do
					if (aabbOverlap(b,t)) hit(b,rrnd(12,17)) sfx"61"
				end
			end
			if b.hp<=0 then
				b.update=function(b)
					b.y+=0.1
					if not b.isPlayer and b.y>103 then
						victory,txt_timer,currentcell.type,boat_message,npcBoat,victory_time,b.update,boatCell.type=true,0,"sea","gLORIOUS\nVICTORY! ",0,time()+.01,function()b.y+=0.1 end,"sea"
						if (rnd"1">.5) boat_message="eXCELLENT\nPIRATING MEN! "
						score+=100
						music"28"
					end
				end

				if b.isPlayer then
 				  sfx"58"
					boat_message,txt_timer="abandon ship!",0
					b._draw=comb_boat.draw
					b.draw=function(b)
						b._draw(b)
						if b.y>100 then
							--game over
							print_str('47414d45204f564552',30,40,8)
						end
						if b.y>105 then
							--your crew abondonded
							--the sinking ship
							print_str('596f75722063726577206162616e646f6e6564',8,56,7)
							print_str('7468652073696e6b696e672073686970',20,64,7)
						end
						if b.y>115 then
							print_str('596f752077657265206e6f74',28,80,7)
							print_str('736f20636f776172646c79',32,88,7)
						end
					end
				end
			end
			b.vx*=.95
			b.x,j=mid(0,b.x+b.vx,120),0
			for i=3,5 do
				j+=pt(b.x+i)
			end
			b.y=j/3+90
   if (b.isPlayer==null) b.y-=20
		end,
		draw=function(b)
			dmgFlash(b)
			pal(1,0)
			local s=1
			if (b.isPlayer) s=0
  		if b.isPlayer!=null then
        spr(s,b.x,b.y,1,1,b.flipx,false)
      else
        sspr(113,72,15,16,b.x,b.y,30,32,b.flipx)
      end
			pal()
			if (b.firecd>0.9 and b.firecd<1.3 and b.isPlayer!=null) _circfill(b.x+4,b.y+5,1,b.firecd*25)
		end
	}
end

function cannonLines(x0,y0,b)
	local c=11
	if (b.firecd > 0)	c=5
  if (b.isPlayer==null) x0+=12 y0+=18
	for x=0,84,2 do
		local y=y0+(x^2-b.aim*80*x)/32
		local _x=x
		if (b.flipx) _x*=0xffff
		if (y<103) _pset(x0+_x,y,c)
	end
end

function fireProjectile(_x,_y,_left,_r,_vx,_vy,_owner)
	proj={
		x0=_x,y0=_y,x=_x,y=_y,r=_r,owner=_owner,
		w=_r*2,h=_r*2,
		t=0,
		vx=1.32+abs(_vx),vy=_vy,
		left=_left,
		x2=0,y2=-64,
		x1=0,y1=-64,
	update=function(p)
		p.t+=.66
		if (p.left) p.x-=p.vx*2
		p.x+=p.vx
		p.y=p.y0-(p.vy*5*p.t)+(.125*p.t^2)
		if p.y > 102 then
			del(comb_objs,p)
			sfx"63"
			for i=p.x+15,p.x+17 do
				wpts[mid(1,flr(i),160)]-=10
			end
		end
		local b=p.owner.isPlayer
		if b and enemy!=null then
			for t in all(tentacles) do --tentacle collision
				if aabbOverlap(t,p) then
					del(comb_objs,p)
					hit(enemy,rrnd(6,11))
					sfx"62"
					sfx"63"
				end
			end
			if aabbOverlap(enemy,p) then --enemy collision
				del(comb_objs,p)
				hit(enemy,rrnd(12,18))
				sfx"62"
				sfx"63"
			end
		elseif not b then
			if aabbOverlap(comb_boat,p) then --player collision
				del(comb_objs,p)
				hit(comb_boat,rrnd(10,14))
				sfx"62"
				sfx"63"
			end
		end
	end,
	draw=function(p)
    local r,x,x1,y,y1=p.r-1,p.x,p.x1,p.y,p.y1
		if p.owner.steps==null then
			_circfill(p.x2,p.y2,r,7)
			_circfill((x1+p.x2)/2,(y1+p.y2)/2,r,10)
			_circfill(x1,y1,r,9)
			_circfill((x+x1)/2,(y1+y)/2,r,8)
		end
			_circfill(x,y,p.r,0)
			p.x2,p.y2=x1,y1
			p.x1,p.y1=x,y
	end}
	add(comb_objs,proj)
end

function dmgFlash(e)
	e.flashing-=1
	if (t()%.01>.005 and e.flashing>0) pal_all"7"
end

function hit(this,dmg)
	flip""
  if (enemyName == "tHE pIRATE kING" and not this.isPlayer) dmg/=3
  this.hp,this.flashing,shakeTimer=max(0,this.hp-dmg),10,1
	if this.isPlayer then
		morale,this.flashing,playerHpTimer=this.hp,25,2
	else
		enemyHpTimer=2
	end
end
