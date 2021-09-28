local drop_score={
[3000]={3000,{45,55},1000,10000,1000}
}
local ks={id=1,score_interval=2,score_limit=3,count=4,new_id=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(drop_score)do setmetatable(v,base)end base.__metatable=false
return drop_score
