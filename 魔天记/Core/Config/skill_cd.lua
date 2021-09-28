local skill_cd={
[1]={1,30000},
[2]={2,15000},
[3]={3,15000}
}
local ks={id=1,cd_time=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(skill_cd)do setmetatable(v,base)end base.__metatable=false
return skill_cd
