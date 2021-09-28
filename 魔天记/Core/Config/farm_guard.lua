local farm_guard={
[1]={1,10,'中',10,'中',10,'中',5,'低',15,'高'},
[2]={2,5,'低',10,'中',15,'高',10,'中',10,'中'},
[3]={3,15,'高',10,'中',10,'中',10,'中',5,'低'},
[4]={4,10,'中',15,'高',5,'低',10,'中',10,'中'},
[5]={5,10,'中',5,'低',10,'中',15,'高',10,'中'}
}
local ks={id=1,gold=2,gold_des=3,wood=4,wood_des=5,water=6,water_des=7,fire=8,fire_des=9,soil=10,soil_des=11}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(farm_guard)do setmetatable(v,base)end base.__metatable=false
return farm_guard
