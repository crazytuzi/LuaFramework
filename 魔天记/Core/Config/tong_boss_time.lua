local tong_boss_time={
[2,4,5,7]={{2,4,5,7},'20:59:00',{'20:59:00'},'21:15:00'}
}
local ks={week_time=1,notice_time=2,start_time=3,end_time=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tong_boss_time)do setmetatable(v,base)end base.__metatable=false
return tong_boss_time
