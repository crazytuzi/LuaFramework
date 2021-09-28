local star_open={
[1]={1,0,0},
[2]={2,756004,5},
[3]={3,756014,15},
[4]={4,756024,25},
[5]={5,756034,35},
[6]={6,756044,45},
[7]={7,756054,55},
[8]={8,756064,65}
}
local ks={id=1,unlock=2,num=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(star_open)do setmetatable(v,base)end base.__metatable=false
return star_open
