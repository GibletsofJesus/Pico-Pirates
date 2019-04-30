pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

function putAFlipInIt()
	tempFlip=true
end

function _circ(x,y,r,c)
	if (tempFlip) flip()
	circ(x,y,r,c)
end

function _circfill(x,y,r,c)
	if (tempFlip) flip()
	circfill(x,y,r,c)
end

function _pset(x,y,c)
	if (tempFlip) flip()
	pset(x,y,c)
end

function _line(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	line(x1,y1,x2,y2,c)
end

function _rect(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	rect(x1,y1,x2,y2,c)
end

function _rectfill(x1,y1,x2,y2,c)
	if (tempFlip) flip()
	rectfill(x1,y1,x2,y2,c)
end

function _spr(n,x,y,tx,ty)
	if (tempFlip) flip()
	spr(n,x,y,tx,ty)
end

function _sspr(sx,sy,sw,sh,dx,dy)
	if (tempFlip) flip()
	sspr(sx,sy,sw,sh,dx,dy)
end
