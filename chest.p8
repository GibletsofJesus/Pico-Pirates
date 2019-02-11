pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
egg=t()
	chestClouds={}
	for i=0,15 do
		add(chestClouds,{rnd(72),rnd(4),1+rnd(3)})
	end
	for x=0,8,0.5 do
		for y=1,3 do
			add(staticSand,{x*8,y*8+(48-x^1.05),6,15})
		end
	end
	srand(3)
	for y=0,7,.75 do
		for x=-3,5 do
			if (y%2==0) x*=-1
			local r=3+rnd(2)
			newGrainOfSand(32+x*2,54+y*.4,r)
			if (y%2==0) x*=-1
		end
	end
end

index=1

circTrans_start=0
circTrans_end=0
function circTransition(x,y,t)
	for i=72,t-16,-1 do
		circ(x,y,i,0)
		circ(x,y+1,i,0)
		circ(x,y-1,i,0)
	end
end

function _update()
	poke(0x5f2c,3)
	if btnp(4) then
		sfx(7-rnd(2))
		for i=0,9 do
			if index<#sand+1 then
				circTrans_end=t()
				local grain=sand[index]
				grain.moving=true
				grain.vy-=4	+rnd(2)
				grain.vx=.5+rnd(1)
				grain.r-=1.5
				if (rnd(1)>.5) grain.vx*=-1
				index+=1
				chestPos-=0.1
			end
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

function _draw()
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

	h=16
	w=18
	--draw chest
	for i=1,#chestCols[1] do
		pal(chestCols[1][i],chestCols[chestCol][i])
	end
	if flr(chestPos)==44 then
		sspr(59,0,w,h,32-w/2,chestPos-h/2,w,h)--draw open chest
		pal()
		?"yOU FOUND SOME\n   TREASURE!",4,16,0
		?"yOU FOUND SOME\n   TREASURE!",4,15,9.5+p
		sspr(80,0,12,5,25,40)--draw chest contents
	else
		--draw closed chest
		sspr(40,0,w,h,32-w/2-sin(chestPos/1.5)*.5,chestPos-h/2,w,h)
	end
	--draw sand particles
	for s in all(sand) do
		s.draw(s)
	end

	if flr(chestPos)==44 then
		circTransition(32,32,128+(circTrans_end-t())*50)

	else
		circTransition(32,32,t()*50)
	end
	?egg,0,0,7
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
0000000000400000000000007000000000000007000000000000000000000000000000000000000000007c0007c000000000000000000008800000800ddf0d00
00000000004000000000000000000000000000000000000000000000000000000000000000000000008cb9a07a8a00000000000000000088880008880dff0fd0
0070070000700000000000000000000660000000000000000000000000000000000000000000000007b9a897c9ab00000000000000000018888088880dff0fd0
00077000074700000000000000000066660000000000000000000000000000009999999999940000c9ac797a9ac900000000000000000001888888810dff0fd0
000770004444400000000000000006666660000000000000000000000000000955555555559240009b7a9c9ba99000000000000000000000188888100ddf0fdd
007007007747700000000000000066666666000000aaaaaaaaaaa900000000955555555559224000000000000000000000000000000000008888810000df0ffd
00000000774770000000000000000066660000000a22222222229240000009999999999999224000000000000000000000000000000000088888880000df0ffd
000000004f4f4000000000000000006666000000a2888888888922400000a1111111111114440000000000000000000000000000000000888818888000df0ffd
000000004f4f4000000000000000006666000000a2888aa288892440000a1111111111114400000000000000000000000000000000000088810188880ddf0fdd
000000004f4f4000000000000000006666000000aaaaa11999994240000aaaaaaaaaaa942400000000000000000000000000000000000018100018810dff0fd0
0000000049f94000000000000000006666000000a222a11922292240000a222a119222922400000000000000000000000000000000000001000001100dff0fd0
0000000044444000000000000000006666000000a288a11928892240000a288a119288922400000000000000000000000000000000000000000000000dff0fd0
0000000044444000000000000000006666000000a288899288892240000a2888992888922400000000000000000000000000000000000000000000000ddf0fdd
0000000004440000000000000000000000000000a288888888892240000a2888888888922400000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000a288888888892400000a2888888888924000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000007000000000000007a999999999994000000a9999999999940000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
aae5fba057770008eff908ff7daa0bffd9005dddd04661776000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0e501e088528d804d284008700f00c708500e14ad00632060000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
06b3b60085f580050a04000f6e10007d4000a3d2a00702370000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
070816008d28900582850007807040b04e00a1e8a00700270000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
23edf320df7b8008dfd8007ff9600ffffb023dde222275520000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
1000000000000002200440000006000000100000000000002000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000110000000000000000000000000000880000000000000000000000888000000000888000000000000000000000220000000000222000222000dff0ffd
00000811000000000000000000000000000002aa750aaa008801777740000008e73b9800006ff753aa80001bbffdd1000067555557200046651574000ddf0fdd
000088900000000000000000000000000000002e9550a00009d40aa9d48800049e6090004512a845380000097208d10000623540370000067200700000df0fd0
0008c8880000000000000000000020000044006f8114b100008817e9140800459a2c00000006f906910000017688010000223540230000077200600000df0fd0
000cc88800000000000000000002200000440467993b6000008817fd400804551aa040000006fd68110000013ec5000000203743020000175220600000df0fd0
0044e98002000000023400000022650000040067aa19640000089f69908000451aa0440000067be011000001bb154000002037530200000752217000000d0fdd
0046ffd42220022227777222002677775440007608817000000097609900004592a840000006798710000001fa01060000201761020000075022700000df0ffd
0467ffd72222002453777720027727775510003608853000000097619800000c12ac0100000679871000000db200c20000201760020000065022700000df0ffd
0246fbb022200065510776400577200115100133ecdb33000009ff7f88800088c77d90000047ff9960000019ffffb31002225554222000226557200000df0ffd
00467b10020000475102764005772000511002000000000000000000000000000200c400002000000600000200000000000100000000000000002000000d0fdd
00467b10000000475102264405772004111000000000000000000000000000222000088000000000006600000000000000000000000000000000022000df0fd0
00467b10000000677102260005772044551300000000000022222000000000030000000000000000000000000000000000000000000000000000000000df0fd0
00467b10000002655306620005776044555000000000002288888220000000000000000000000000000000000000000000000000000000000000000000df0fd0
00467b100000026551622200057764045550000000002288882828820000000000000000000000000000000000000000000000000000000000000000000d0fdd
00467b10000022655502220001776000555000000002888888828888200000000000000000000000000000000000000000000000000000000000000000df0ffd
00467310000022655102220001336000555000000028888888282888200000000000000000000000000000000000000000000000000000000000000000df0ffd
00467b10000022655102220001372000555000000298888882888888200000000000000000000000000000000000000000000000000000000000000000df0ffd
0046fb901000226751222240117330005550000002a988888888888820000000000000000000000000000000000000000000000000000000000000000ddf0fdd
046effbd20002677775327221377775251000000029a98889999888820000000000000000000000000000000000000000000000000000000000000000dff0ffd
0046fff20000022675577200046777750000000002898889aaa9888820000000000000000000000000000000000000000000000000000000000000000dff0ffd
00004b0000000020041020004000215000000000028888899998888200000000000000000000000000000000000000000000000000000000000000000dff0ffd
0001111100001000100000000000000000000000028888888888888200000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0011111110001011111000000200000000000000028888888888882000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0100001111001111111100002880000000000000028888888888828200000000000000000000000000000000000000000000000000000000000000000dff0fd0
00000001110110000111100028e0000000000000288888888882288200000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000111101000001111002880000000000002888888888228828820000000000000000000000000000000000000000000000000000000000000000ddf0fdd
00000001110010000001111028e00000000000288888888828828288200000000000000000000000000000000000000000000000000000000000000000df0ffd
00000011110010000000111028800000000002888228828828828288200000000000000000000000000000000000000000000000000000000000000000df0ffd
00000101110010000000111028e00000000028882888828828828228822800000000000000000000000000000000000000000000000000000000000000df0ffd
000110011100110000011110288000000000288288222888828288228888000000000000000000000000000000000000000000000000000000000000000d0fdd
00111001110010111110111028e00000000028288200288882882888288200000000000000000000000000000000000000000000000000000000000000df0fd0
01111101110010000000111028800000000288288202882888288288822002800000000000000000000000000000000000000000000000000000000000df0fd0
00011111110010000000111028e00000000288828822820288828828888228820000000000000000000000000000000000000000000000000000000000df0fd0
000011111100100000001110288000000000288828288200288828828888882000000000000000000000000000000000000000000000000000000000000d0fdd
00000011110010111110111028e00000000302828828200228828820222222030000000000000000000000000000000000000000000000000000000000df0ffd
00000011110011000001111028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00000001110010000000111028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
000000011100100000001110288000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0fdd
00000001110010000000111028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000111110011110000110028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00011111110011111110100028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
011111111100111111110000288000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0d00
11000001110010000110000028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000001110010000000000028800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000001110010000000000028e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
000000011100100000000000288000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0fdd
00000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
000ddddd000ddddd0000000ddddddddddddddddddddd000ddddddddd000ddddd0000000ddddd0000000ddddddddd000ddddd0000000000000000000000df0ffd
00ddfffdddddfffdddd0ddddfffdfffdfffdfffdfffdddddfffdfffdddddfffdddd0ddddfffdddd0ddddfffdfffdddddfffdddd0ddd000000000000000df0ffd
0dfffffffffffffffffdfffffffffffffffffffffffffffffffffffffffffffffffdfffffffffffdfffffffffffffffffffffffdfffdd00000000000000d0fdd
ddf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000df0fd0
0dfffffffffffffffffffffffffffffdfffffffffffffffffffffffffffdfffdfffffffffffffffffffffffffffdfffffffffffffffdd0000000000000df0fd0
00ddfffdfffdddddfffdddddfffdddd0ddddfffdddddfffdfffdfffdddd0ddd0ddddfffdfffdfffdfffdfffdddd0ddddfffdfffdddd000000000000000df0fd0
000ddddddddd000ddddd000ddddd0000000ddddd000ddddddddddddd00000000000ddddddddddddddddddddd0000000ddddddddd0000000000000000000d0fdd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000df0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0d00
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0ffd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddf0fdd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dff0fd0
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
__sfx__
0003000004610066101f6001d6001d6001c6001c60000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000100000661005650076503460037600236003e6003f6003f6003f6003c600346002b600236001b600126000d6000c6000c6000d60011600166001b600236002d6003360033600316002e60028600236001c600
00010000060100505007050340001f000230003e0003f0003f0003f0003c000340002b000230001b000120000d0000c0000c0000d00011000160001b000230002d0003300033000310002e00028000230001c000
000200000c1500f150101500a15012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
000200000c1500f150101501515012100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0003000014753187531475309703187001870018700187001870318703187031b7030070300703007032770300703007030070300703007030070300703007030070300703007030070300703007030070300703
00040000137531c753107530070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000c0000205551b5551d55521555005001b5552655500505005050050500500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00100000145550f55511555155550c5050f5550d5051a5551a5001a5001a500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
