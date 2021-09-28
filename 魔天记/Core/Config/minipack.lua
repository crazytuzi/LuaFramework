local minipack={
[1]={1,'minipack',{'3_50','500005_1','390000_5'}}
}
local ks={id=1,banner=2,award=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(minipack)do setmetatable(v,base)end base.__metatable=false
return minipack
