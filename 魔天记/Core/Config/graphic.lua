local graphic={
[1]={1,'攻击神器',{'phy_att'},{506050,506051,506052}},
[2]={2,'生命神器',{'hp_max|block'},{506060,506061,506062}},
[3]={3,'必杀神器',{'fatal|fatal_bonus'},{506070,506071,506072}},
[4]={4,'吸血神器',{'phy_bld'},{506080,506081,506082}}
}
local ks={id=1,name=2,type=3,need_item=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(graphic)do setmetatable(v,base)end base.__metatable=false
return graphic
