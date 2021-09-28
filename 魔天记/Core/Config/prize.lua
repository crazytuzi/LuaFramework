local prize={
[1]={1,2,98,366,{'390000_28','350000_5','500071_1','500002_1','310207_3'},{}},
[2]={2,2,198,566,{'390000_38','350000_10','500071_2','500005_1','310207_5'},{}},
[3]={3,3,98,366,{'359001_28','350000_5','500071_1','500002_1','310207_3'},{}},
[4]={4,3,198,566,{'359001_38','350000_10','500071_2','500005_1','310207_5'},{}}
}
local ks={id=1,yunying_id=2,cost=3,rewards_value=4,reward=5,career_award=6}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(prize)do setmetatable(v,base)end base.__metatable=false
return prize
