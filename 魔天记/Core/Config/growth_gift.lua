local growth_gift={
[1]={1,1,1,150,{'3_260'},'2_0'},
[2]={2,2,1,180,{'3_350'},'2_0'},
[3]={3,3,1,210,{'3_440'},'2_0'},
[4]={4,4,1,240,{'3_520'},'2_0'},
[5]={5,5,1,270,{'3_610'},'2_0'},
[6]={6,6,1,300,{'3_700'},'2_0'},
[7]={7,7,1,330,{'3_800'},'2_0'},
[8]={8,8,1,360,{'3_890'},'2_0'},
[9]={9,9,1,390,{'3_980'},'2_0'},
[10]={10,10,1,420,{'3_1060'},'2_0'},
[11]={11,11,1,450,{'3_1150'},'2_0'},
[12]={12,12,1,480,{'3_1240'},'2_0'}
}
local ks={id=1,kind=2,totalcountlimit=3,reward_level=4,reward=5,extra_reward=6}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(growth_gift)do setmetatable(v,base)end base.__metatable=false
return growth_gift
