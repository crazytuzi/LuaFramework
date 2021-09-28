local legend_boss_times={
[999]={999,3,3}
}
local ks={participation_award=1,firstattack_award=2,lastattack_award=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(legend_boss_times)do setmetatable(v,base)end base.__metatable=false
return legend_boss_times
