pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
array={1,2,3,4}
cls()
total_weight=0
for a in all(array) do
	total_weight+=a
end
::★::
r=rnd(total_weight)
for a in all(array) do
	if (r<a) pset(a*8,rnd(127),a*3)
	r-=a
end
flip()
goto ★
