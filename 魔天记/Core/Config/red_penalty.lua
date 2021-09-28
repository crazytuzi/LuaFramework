local red_penalty={
[1]={1,40,700008,25,250000,{2,5,7,8,10}},
[2]={2,200,700009,30,300000,{2,5,7,8,10}},
[3]={3,300,700010,35,350000,{2,5,7,8,10}},
[4]={4,400,700011,40,400000,{2,5,7,8,10}},
[5]={5,500,700012,45,450000,{2,5,7,8,10}}
}
local ks={id=1,killpower=2,addbuff=3,sub_yu=4,sub_money=5,map_type=6}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(red_penalty)do setmetatable(v,base)end base.__metatable=false
return red_penalty
