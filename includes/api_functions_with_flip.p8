pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--Current cart stats (30/4/18)
-- Token count 147

function putAFlipInIt()
	tempFlip=true
end

function _flip()
	if (tempFlip) flip""
end

function _circ(x,y,r,c)
	_flip""
	circ(x,y,r,c)
end

function _circfill(x,y,r,c)
	_flip""
	circfill(x,y,r,c)
end

function _pset(x,y,c)
	_flip""
	pset(x,y,c)
end

function _line(x1,y1,x2,y2,c)
	_flip""
	line(x1,y1,x2,y2,c)
end

function _rect(x1,y1,x2,y2,c)
	_flip""
	rect(x1,y1,x2,y2,c)
end

function _rectfill(x1,y1,x2,y2,c)
	if (tempFlip) flip""
	rectfill(x1,y1,x2,y2,c)
end

function _spr(n,x,y,tx,ty)
	_flip""
	spr(n,x,y,tx,ty)
end

function _sspr(sx,sy,sw,sh,dx,dy)
	_flip""
	sspr(sx,sy,sw,sh,dx,dy)
end
