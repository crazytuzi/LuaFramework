local online_reward={
[1]={1,5,5,{'1_50000'}},
[2]={2,10,5,{'1_100000'}},
[3]={3,30,25,{'350000_1'}},
[4]={4,60,35,{'500100_2'}},
[5]={5,90,55,{'3_50'}}
}
local ks={id=1,online=2,interval=3,reward=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(online_reward)do setmetatable(v,base)end base.__metatable=false
return online_reward
