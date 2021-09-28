local achievement_type={
[1]={1,'首次成就'},
[2]={2,'角色成就'},
[3]={3,'任务成就'},
[4]={4,'副本成就'},
[5]={5,'活动成就'},
[6]={6,'装备成就'},
[7]={7,'成长成就'},
[8]={8,'荣誉成就'}
}
local ks={id=1,type=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(achievement_type)do setmetatable(v,base)end base.__metatable=false
return achievement_type
