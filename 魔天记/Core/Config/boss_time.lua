local boss_time={
[1]={1,'魔主之战',50,{2,4,7},'19:55:00','20:00:00','20:30:00'}
}
local ks={id=1,name=2,level=3,weeks=4,ready_notice=5,open_time=6,end_time=7}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(boss_time)do setmetatable(v,base)end base.__metatable=false
return boss_time
