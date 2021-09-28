local weal={
[1]={1,'每日签到',1,1,true},
[2]={2,'vip礼包',1,6,true},
[3]={3,'在线奖励',1,2,true},
[4]={4,'升级赠礼',1,4,true},
[5]={5,'七天好礼',5,5,true},
[6]={6,'奖励找回',20,3,true}
}
local ks={id=1,title_name=2,openVal=3,code_id=4,isOpen=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(weal)do setmetatable(v,base)end base.__metatable=false
return weal
