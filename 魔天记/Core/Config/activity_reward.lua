local activity_reward={
[1]={1,1,500,{20,40,60,80,100},{500001,500101,500112,390000,500112}}
}
local ks={id=1,min_lev=2,max_lev=3,active_condition=4,active_reward=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(activity_reward)do setmetatable(v,base)end base.__metatable=false
return activity_reward
