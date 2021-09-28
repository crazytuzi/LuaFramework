local vip_card={
[510010]={510010,4,1280,175200,'永久享用VIP，直升[ffc320]VIP4[-]，升级首选！'},
[510011]={510011,2,888,2160,'增加60天VIP时间，直升[ffc320]VIP2[-]。'},
[510012]={510012,1,288,720,'增加30天VIP时间，直升[ffc320]VIP1[-]。'}
}
local ks={id=1,vip_level=2,price=3,time=4,renew_desc=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(vip_card)do setmetatable(v,base)end base.__metatable=false
return vip_card
