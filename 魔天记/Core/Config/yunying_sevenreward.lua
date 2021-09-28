local yunying_sevenreward={
[1]={1,1,1,'首日目标',14,1,{'380125_1','500071_1'},'[FFFF00]战力立涨4953，1小时畅爽双倍升级！[-]'}
}
local ks={id=1,yunying_id=2,type=3,name=4,num=5,effective_time=6,total_reward=7,reward_des=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(yunying_sevenreward)do setmetatable(v,base)end base.__metatable=false
return yunying_sevenreward
