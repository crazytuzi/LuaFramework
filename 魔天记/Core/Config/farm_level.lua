local farm_level={
[1]={1,7850,4},
[2]={2,13650,4},
[3]={3,34800,4},
[4]={4,70500,4},
[5]={5,116200,4},
[6]={6,149400,4},
[7]={7,182600,4},
[8]={8,232400,4},
[9]={9,282200,4},
[10]={10,999999,4}
}
local ks={id=1,up_exp=2,number=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(farm_level)do setmetatable(v,base)end base.__metatable=false
return farm_level
