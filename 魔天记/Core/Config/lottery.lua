local lottery={
[1]={1,390000,48,20,200,900,1000,{380300,359015},{380301,301750,301755,390000,359001,400003,401003,500070,500071,500002,506060,350000},{380301,302750,302755,390000,359001,400003,401003,500070,500071,500002,506060,350000},{380301,303750,303755,390000,359001,400003,401003,500070,500071,500002,506060,350000},{380301,304750,304755,390000,359001,400003,401003,500070,500071,500002,506060,350000}}
}
local ks={id=1,item_id=2,free_time=3,need_gold=4,spend_gold=5,fifty_gold=6,double_upper=7,show=8,show_101000=9,show_102000=10,show_103000=11,show_104000=12}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(lottery)do setmetatable(v,base)end base.__metatable=false
return lottery
