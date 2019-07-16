pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (2/7/18)
-- Token count 567

function stringToArray(str)
	local a,l={},0
	while l<#str do
		l+=1
		if sub(str,l,l)=="," then
			local s=sub(str,1,l-1)
			if s=="true" then
				add(a,true)
			elseif s=="false" then
				add(a,false)
			else
			add(a,tonum(s))
			end
		str,l=sub(str,l+1),0
		end
	end
	return a
end

function spr_rot(sx,sy,swh,dx,dy,rot,depth)
	local s=sin(rot)
	local c=cos(rot)
	local size = swh/2
	local _b=(s*s+c*c)
	local w = sqrt(size^2*2)
	for y=-w,w do
		for x=-w,w do
			local ox=(s*y+c*x)/_b+size
			local oy=(-s*x+c*y)/_b+size
			if ox<swh and oy<swh and ox>0 and oy>0 then
				for d=0,depth do
					local col=sget(ox+sx+d*12,oy+sy)
					if(col>0)_pset(dx+x,dy+y-d,col)
				end
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

function print_u(s,x,y,c,u)
	if (c==nil)c,u=7,1
	?s,x,y+1,u
	?s,x,y,c
end

shakeX,shakeY,shakeTimer=0,0,0
function screenShake()
	if shakeTimer > 0 then
		shakeX,shakeY=rrnd(0xfffc,4),rrnd(0xfffc,4)
		shakeTimer-=.33
	else
		shakeX,shakeY=0,0
	end
	camera(shakeX,shakeY)
end

function aabbOverlap(a,b)
	return ((a.x+a.w > b.x) and (a.x < b.x+b.w))
		and ((a.y+a.h > b.y) and (a.y < b.y+b.h))
end

function pal_all(c)
	for i=0,15 do
		pal(i,c)
	end
end

function lerp(a,b,t)
 return b*t+(a*(1-t))
end

function rrnd(min,max)
	return rnd(max-min)+min
end

function weighted_rnd(array)
	local total=0
	for a in all(array) do
		total+=a
	end
	r=rnd(total)
	for a in all(array) do
		if (r<a) return a
		r-=a
	end
end
