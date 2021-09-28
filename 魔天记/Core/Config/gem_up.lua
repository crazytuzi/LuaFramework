local gem_up={
[1]={1,20},
[2]={2,60},
[3]={3,180},
[4]={4,540},
[5]={5,1620},
[6]={6,4860},
[7]={7,14580},
[8]={8,43740},
[9]={9,131220},
[10]={10,393660},
[11]={11,1180980},
[12]={12,3542940}
}
local ks={gem_lev=1,gem_price=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(gem_up)do setmetatable(v,base)end base.__metatable=false
return gem_up
