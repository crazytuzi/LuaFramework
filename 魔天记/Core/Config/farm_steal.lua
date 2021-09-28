local farm_steal={
[1]={1,0,30,'[ff4b4b]低[-]'},
[2]={2,31,70,'[fff9b1]中[-]'},
[3]={3,71,100,'[9cff94]高[-]'}
}
local ks={id=1,min_per=2,max_per=3,des=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(farm_steal)do setmetatable(v,base)end base.__metatable=false
return farm_steal
