local recharge_gift={
[1]={1,'充  值',1,3,true},
[2]={2,'每日限购',10,1,true},
[3]={3,'月卡礼包',1,2,true},
[4]={4,'累计充值',1,4,true},
[5]={5,'成长基金',1,5,true}
}
local ks={id=1,title_name=2,openVal=3,code_id=4,isOpen=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(recharge_gift)do setmetatable(v,base)end base.__metatable=false
return recharge_gift
