local fairy_groove_attr={
[1]={1,9,{'hp_max','phy_att','hit','crit','fatal','phy_pen'}},
[2]={2,10,{'hp_max','phy_att','phy_def','eva','tough','block'}}
}
local ks={id=1,kind=2,fairy_attr=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(fairy_groove_attr)do setmetatable(v,base)end base.__metatable=false
return fairy_groove_attr
