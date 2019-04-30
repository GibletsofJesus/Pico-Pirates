pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--Current cart stats (30/4/18)
-- Token count 592

function init_boat(isPlayer)
	return {x=-0xff60,y=0xff60,r=0,d=0,mx=0,my=0,max=2.5,player=isPlayer}
end

function boat_update(b)
	local speed,c,s=.05,cos(b.r),sin(b.r)
	local sc=(s*s)+(c*c)

	if b.player then
		if(btn"0") b.r=b.r%1+.01
		if(btn"1") b.r=b.r%1-.01
	else
		--get angle between the two boat
		--turn towards player?
	end

	b.mx+=cellwindy*.05
	b.my-=cellwindx*.05

	if b.player then
		if btn"2" then
			b.mx+=s*speed
			b.my-=c*speed
			sfx(0)
		else
			b.mx*=.99
			b.my*=.99
		end
	else
		local bx,by=boat.x,boat.y
		local px=bx+boat.mx*5
		local py=by+boat.my*5
		local angle=atan2(b.x-px,b.y-py)-.25
		dist = abs(sqrt((b.y-by)^2+(b.x-bx)^2))
		b.r=lerp(b.r,angle+.5,.1)
		if dist>140 then
			b.x=bx+sin(angle)*128
			b.y=by-cos(angle)*128
			b.mx/=4
			b.my/=4
		elseif anglediff(b.r,atan2(px,py))<.5 then
			b.mx+=s*speed
			b.my-=c*speed
		else
			b.mx*=.95
			b.my*=.95
		end
	end
	b.mx,b.my=mid(-b.max,b.mx,b.max),mid(-b.max,b.my,b.max)
	sc=abs(b.mx*b.my)
	b.d+=sc
	if (flr(b.d)>2) newWave(b.x-sin(b.r)*4,b.y+cos(b.r)*4) b.d=0

	if b.player or celltype=="sea" then
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
		if checklandcol(b.x,b.y,b.r) and not player.draw then
			player.draw=true
			sfx(3)
			player.x=b.x+sin(b.r)*8
			player.y=b.y-cos(b.r)*8
			b.mx=0 b.my=0
		end
	end
end

function boat_draw(b)
	if t()%.25==0 then
		newWave(b.x-sin(b.r)*4,
		b.y+cos(b.r)*4)
	end
	pal(0,5)
	if not b.player then
		pal(4,2)pal(15,6)pal(7,13)pal(9,15)
	end

	spr_rot(-2,76,12,flr(b.x),flr(b.y),b.r,6)
	pal()

		if dist<48 then
			nextState,state,st_t,boat_message,dist=5,2,0,"",512
			npcBoat=0
			return
		end
end
