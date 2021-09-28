local title_type={
[1]={1,'活动称号'},
[2]={2,'仙盟称号'}
}
local ks={id=1,type=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(title_type)do setmetatable(v,base)end base.__metatable=false
return title_type
