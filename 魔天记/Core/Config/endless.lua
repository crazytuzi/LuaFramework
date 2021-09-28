local endless={
[1]={1,20000,5,5,300118,218000,{500071,706,50,500070,705,15},{'500071_50','500070_15'}}
}
local ks={id=1,monet_cost=2,money_limit=3,gold_cost=4,encourage_buff=5,exp_buff=6,exp_item=7,exp_cost=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(endless)do setmetatable(v,base)end base.__metatable=false
return endless
