local login_reward={
[1]={1,3,'500070_1',{'500070_1','350000_2','1_100000'}},
[2]={2,3,'504077_1',{'504077_1','500071_1','506060_2'}},
[3]={3,3,'390000_15',{'390000_15','500101_2'}},
[4]={4,2,'359001_20',{'359001_20','310205_3'}},
[5]={5,2,'505074_1',{'505074_1','350000_5'}},
[6]={6,2,'401001_1',{'359001_10','400001_1','401001_1'}},
[7]={7,2,'505076_1',{'505076_1','500070_2','506050_5'}}
}
local ks={id=1,base_map=2,show=3,reward=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(login_reward)do setmetatable(v,base)end base.__metatable=false
return login_reward
