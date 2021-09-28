local tong_battle_point={
[1]={1,1,1000,650},
[2]={2,2,800,550},
[3]={3,3,700,450},
[4]={4,4,600,425},
[5]={5,5,400,350},
[6]={6,6,400,250},
[7]={7,7,300,150},
[8]={8,8,300,150},
[9]={9,9,300,150},
[10]={10,10,300,150}
}
local ks={id=1,rank=2,basic_victory_point=3,basic_lost_point=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tong_battle_point)do setmetatable(v,base)end base.__metatable=false
return tong_battle_point
