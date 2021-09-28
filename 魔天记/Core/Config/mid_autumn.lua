local mid_autumn={
[1]={1,3,'401000_3',{'401000_3','400000_3'}},
[2]={2,2,'3_50',{'3_50','350001_3'}},
[3]={3,3,'359001_10',{'359001_10'}},
[4]={4,3,'1_500000',{'1_500000','350001_3'}},
[5]={5,2,'506051_1',{'506051_1','506050_5'}},
[6]={6,3,'506061_1',{'506061_1','506060_5'}},
[7]={7,2,'3_100',{'3_100','390000_10'}}
}
local ks={id=1,base_map=2,show_icon=3,reward=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(mid_autumn)do setmetatable(v,base)end base.__metatable=false
return mid_autumn
