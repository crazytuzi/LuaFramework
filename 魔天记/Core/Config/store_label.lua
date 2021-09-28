local store_label={
[1]={1,'超值'},
[2]={2,'日常'},
[3]={3,'变强'},
[4]={4,'外观'}
}
local ks={id=1,name=2}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(store_label)do setmetatable(v,base)end base.__metatable=false
return store_label
