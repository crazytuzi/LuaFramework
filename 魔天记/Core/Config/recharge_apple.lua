local recharge_apple={
[1]={1,10001,8001,1},
[2]={2,10001,8002,2},
[3]={3,10001,8003,3},
[4]={4,10001,8004,4},
[5]={5,10001,8005,5},
[6]={6,10001,8006,6},
[7]={7,10001,8007,7},
[8]={8,10001,8008,8},
[9]={9,10001,8009,9},
[10]={10,10001,8010,10},
[11]={11,10001,8011,11}
}
local ks={id=1,channel_id=2,apple_pid=3,recharge_id=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(recharge_apple)do setmetatable(v,base)end base.__metatable=false
return recharge_apple
