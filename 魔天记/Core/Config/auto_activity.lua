local auto_activity={
[1]={1,1,49,701001},
[2]={2,50,99,701002},
[3]={3,100,149,701003},
[4]={4,150,199,701004},
[5]={5,200,249,701005},
[6]={6,250,299,701006},
[7]={7,300,339,701008},
[8]={8,340,379,701009},
[9]={9,380,419,701010},
[10]={10,420,459,701011},
[11]={11,460,500,701012}
}
local ks={id=1,level_lower=2,level_upper=3,map_name=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(auto_activity)do setmetatable(v,base)end base.__metatable=false
return auto_activity
