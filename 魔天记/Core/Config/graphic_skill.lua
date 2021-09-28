local graphic_skill={
['3_50']={'3_50',3,'必杀神器',50,207011},
['3_100']={'3_100',3,'必杀神器',100,207003},
['3_160']={'3_160',3,'必杀神器',160,207013},
['3_240']={'3_240',3,'必杀神器',240,207002},
['4_50']={'4_50',4,'吸血神器',50,207012},
['4_100']={'4_100',4,'吸血神器',100,207001},
['4_160']={'4_160',4,'吸血神器',160,207009},
['4_240']={'4_240',4,'吸血神器',240,207010}
}
local ks={key=1,id=2,name=3,level=4,skill_id=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(graphic_skill)do setmetatable(v,base)end base.__metatable=false
return graphic_skill
