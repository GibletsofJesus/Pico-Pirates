pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
array={1,1.5,2,3}
cls()
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
--39 tokens
::★::
r=weighted_rnd(array)
pset(r*8,rnd(127),r*2)
flip()
goto ★
