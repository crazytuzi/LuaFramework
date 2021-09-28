local farm_base={
[1]={1,10,50,{'300000_85','100000_70','50000_60','-50000_50','-100000_30','-300000_20'},3,{'355015_1'},200,28800,10,20,{'355015_1'},50}
}
local ks={id=1,stolen_times=2,stolen_exp=3,stolen_odds=4,guard_num=5,guard_reward=6,guard_exp=7,guard_time=8,water_award_times=9,water_times=10,watering_award=11,watering_exp=12}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(farm_base)do setmetatable(v,base)end base.__metatable=false
return farm_base
