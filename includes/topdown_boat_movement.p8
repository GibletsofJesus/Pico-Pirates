pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--Current cart stats (2/7/18)
-- Token count 566

function init_boat(isPlayer)
	return {x=-0,y=0,r=0,d=0,mx=0,my=0,max=2.5,player=isPlayer}
end

function boat_update(b)
	local speed,c,s=.05,cos(b.r),sin(b.r)

	b.mx+=cellwindy*.05
	b.my-=cellwindx*.05
	if b.player then
		if(btn"0") b.r=b.r%1+.01
		if(btn"1") b.r=b.r%1-.01
		if btn"2" then
			b.mx+=s*speed
			b.my-=c*speed
			sfx"49"
		else
			b.mx*=.99
			b.my*=.99
		end
	else
		local bx,by=boat.x,boat.y
		local px=bx+boat.mx*5
		local py=by+boat.my*5
		local angle=atan2(b.x-px,b.y-py)-.25
		--Dividing by 100 here since big numbers squared can
		-- easily exceed pico 8's max int value
		dist=sqrt(abs(((b.y-by)/100)^2+((b.x-bx)/100)^2))
		b.r=lerp(b.r,angle+.5,.1)
		if dist>4 and compass_chunks<3 then
			npcBoat=0
			return
		else
			b.mx+=s*speed*5
			b.my-=c*speed*5
		end
	end
	b.mx,b.my=mid(-b.max,b.mx,b.max),mid(-b.max,b.my,b.max)
	b.d+=abs(b.mx*b.my)
	if (flr(b.d)>2) newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4) b.d=0

	if b.player or celltype!="island" then
		b.x,b.y=flr((b.x+b.mx)*2)/2,flr((b.y+b.my)*2)/2
	end

	if b.player then
		if b.x < camx+56 then
			camx=flr(b.x-56)
		elseif b.x > camx+72 then
			camx=flr(b.x-72)
		end
		if b.y < camy+56 then
			camy=flr(b.y-56)
		elseif b.y > camy+72 then
			camy=flr(b.y-72)
		end
		if checklandcol(b.x,b.y,b.r) and not player_draw then
			sfx"52"
			player_draw,player_x,player_y,b.mx,b.my=true,b.x+sin(b.r)*8,b.y-cos(b.r)*8,0,0
		end
	end
end

function boat_draw(b)
	if t()%.25==0 then
		newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4)
	end
	pal(0,5)
	if not b.player then
		pal(4,2)pal(15,6)pal(7,13)pal(9,15)
		if (dist<.25) nextState,state,st_t,boat_message,dist=5,2,0,"",512 music"10"
	end
	spr_rot(-2,76,12,flr(b.x),flr(b.y),b.r,6,b.player==null)

	pal()
end
