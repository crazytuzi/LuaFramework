local fairy_attribute={
['9_101000']={'9_101000',101000,9,{'phy_att','phy_pen'}},
['9_102000']={'9_102000',102000,9,{'phy_att','phy_pen'}},
['9_103000']={'9_103000',103000,9,{'phy_att','phy_pen'}},
['9_104000']={'9_104000',104000,9,{'phy_att','phy_pen'}},
['10_101000']={'10_101000',101000,10,{'hp_max','phy_def'}},
['10_102000']={'10_102000',102000,10,{'hp_max','phy_def'}},
['10_103000']={'10_103000',103000,10,{'hp_max','phy_def'}},
['10_104000']={'10_104000',104000,10,{'hp_max','phy_def'}}
}
local ks={key=1,career=2,kind=3,fairy_attribute=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(fairy_attribute)do setmetatable(v,base)end base.__metatable=false
return fairy_attribute
