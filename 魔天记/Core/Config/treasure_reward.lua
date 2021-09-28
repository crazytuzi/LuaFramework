local treasure_reward={
[1]={1,1,0,'玄宝刹月',7,{'310303'},310303,'完成所有目标后可获得【玄宝】[FFFF00]刹月剑[-]','[00FF00]击杀怪物[-]时额外增加[00FF00]30%[-]经验'},
[2]={2,2,1,'玄宝噬魂',7,{'310304'},310304,'完成所有目标后可获得【玄宝】[FFFF00]噬魂鼎[-]','目标为[00FF00]怪物且非boss[-]时，所有技能伤害增加[00FF00]10%[-]'},
[3]={3,3,2,'玄宝破军',5,{'310302'},310302,'完成所有目标后可获得【玄宝】[FFFF00]破军蓝[-]','[00FF00]目标为玩家[-]时技能伤害增加[00FF00]10%[-]'},
[4]={4,4,3,'玄宝螭火',5,{'310305'},310305,'完成所有目标后可获得【玄宝】[FFFF00]螭火灯[-]','永久提升角色[00FF00]5%[-]移动速度以及生命上限'}
}
local ks={id=1,type=2,activation=3,name=4,num=5,total_reward=6,reward_icon=7,reward_des=8,reward_function=9}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(treasure_reward)do setmetatable(v,base)end base.__metatable=false
return treasure_reward
