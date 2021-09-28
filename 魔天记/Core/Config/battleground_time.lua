local battleground_time={
[1]={1,1,'19:50:00','20:00:00','20:03:00','20:03:20','20:14:00',{1,3,5,6}},
[2]={2,1,'19:50:00','20:15:00','20:18:00','20:18:20','20:29:00',{1,3,5,6}}
}
local ks={id=1,turn=2,broadcast_time=3,notice_time=4,enter=5,start=6,['end']=7,week=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(battleground_time)do setmetatable(v,base)end base.__metatable=false
return battleground_time
