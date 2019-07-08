pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function draw_map()
--Draw base map
local _y=camy+20
local _x=camx-mapPos+1
local x0s=stringToArray"124,124,0,0"
local x1s=stringToArray""
local _y=camy+20
local _x=camx-mapPos+1
--draw border of map
local e=stringToArray"124,0,3,104,107,18,3,104,true,true,124,0,3,104,107,18,3,104,true,false,124,0,3,104,0,18,3,104,false,true,124,0,3,104,0,18,3,104,false,false,0,58,109,3,2,16,109,3,false,false,0,58,109,3,2,121,109,3,false,true,★"
for i=1,#e,10 do
sspr(e[i],e[i+1],e[i+2],e[i+3],_x+e[i+4],camy+e[i+5],e[i+6],e[i+7],e[i+8],e[i+9])
end

rectfill(_x+3,_y-2,_x+106,_y+100,15)
_x+=4

--Fill map in with discovered areas
for x=1,32 do
for y=1,32 do
if cells[x][y].visited then
_circfill(_x+x*3,_y+y*3,3,13)
end
end
end
for x=1,32 do
for y=1,32 do
if cells[x][y].visited then
_circfill(_x+x*3,_y+y*3,2,12)
end
end
end
for x=1,32 do
for y=1,32 do
local c,r,type=15,1,cells[x][y].type
if (type=="island") _circfill(_x+x*3,_y+y*3,r,c)
end
end
_x+=boat.x/128
_y+=boat.y/128
if (flr(t()*4)%2>0) _pset(_x+currentcellx*3,_y+currentcelly*3,4)
end

function draw_minimap()
print_u(currentcellx,camx+102,camy+5)
print_u(currentcelly,camx+116,camy+18)
_rectfill(camx+111,camy,camx+127,camy+16,12)
_rect(camx+111,camy,camx+127,camy+16,7)
if (celltype=="island") _circfill(camx+119,camy+8,island_size/16,15)
--player indicator on minimap
_pset(camx+112+minimapPos(boat.x),camy+1+minimapPos(boat.y),4)
if (npcBoat!=0) _pset(camx+112+minimapPos(npcBoat.y),camy+1+minimapPos(npcBoat.x),2)
end

function minimapPos(value)
return min((value+256)/512*14,111)
end

function draw_morale_bar()
--"Morale"
print_str('4d6f72616c65a',camx+1,camy+11,7)
local x=camx+42
local y=camy+1
local _x=x+57
local l=lerp(57,0,morale/100)
local _l=lerp(57,0,prevMorale/100)
local _y=y+10

if playerHpTimer>0 then
 playerHpTimer=max(0,playerHpTimer-.1)
 if (playerHpTimer<=1) _l=lerp(l,_l,playerHpTimer)
else
prevMorale=morale
_l=l
end
--Drawing morale bar
_rectfill(x,y,_x,_y+1,1)
_rectfill(x,y,_x-_l,_y,14)
_rectfill(x+1,y+1,_x-l,_y-1,8)
_rect(x,y,_x-_l,_y-1,2)
_rect(x,y,_x,_y,7)
end
