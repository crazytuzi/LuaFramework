local farm_extend={
[1]={1,0},
[2]={2,0},
[3]={3,0},
[4]={4,0},
[5]={5,50},
[6]={6,100},
[7]={7,200},
[8]={8,400},
[9]={9,800},
[10]={10,1600},
[11]={11,3200},
[12]={12,6400}
}
local ks={id=1,cost=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(farm_extend)do setmetatable(v,base)end base.__metatable=false
return farm_extend
