pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
ps={}
camx=0
camy=0

function _init()
  local tot=128
  for i=0,tot do
    local _r=(128/tot)*i
    local _o=rnd(2)
    for j=0,10 do
      add(ps,{x=0,y=0,r=_r,o=_o})
    end
  end
end

function _update()

  if (btn(0)) camx-=1
  if (btn(1)) camx+=1
  if (btn(2)) camy-=1
  if (btn(3)) camy+=1

  for p in all(ps) do
    local t_=t()+p.o-rnd(.25)
    p.x=64+(sin(t_*(15/p.r))*p.r)+rnd(p.r/32)
    p.y=64-(cos(t_*(15/p.r))*p.r)+rnd(p.r/32)
  end
end

function _draw()
  cls(12)
  camera(camx,camy)
  print(stat(0),camx,camy+8,7)
  print(stat(1),camx,camy,7)
  for p in all(ps) do
    pset(p.x,p.y,7)
  end
end
