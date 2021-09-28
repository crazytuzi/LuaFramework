local relive={
[0]={0,15,3,0,500010,10,0,1},
[1]={1,15,0,5,500010,10,0,0},
[2]={2,15,0,0,0,0,0,0},
[3]={3,10,0,0,0,0,0,0},
[4]={4,15,0,0,500010,10,0,1}
}
local ks={id=1,time=2,free_num=3,max_num=4,relive_item=5,cost=6,free_born=7,charge_born=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(relive)do setmetatable(v,base)end base.__metatable=false
return relive
