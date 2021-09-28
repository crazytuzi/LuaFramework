local fairy_groove_pos={
[1]={1,1,0,'[ebffd1]白色仙器[-]可开启此附魔槽'},
[2]={2,2,1,'[77ff47]绿色仙器[-]可开启此附魔槽'},
[3]={3,3,2,'[34e0ff]蓝色仙器[-]可开启此附魔槽'},
[4]={4,4,3,'[e57bff]紫色仙器[-]可开启此附魔槽'},
[5]={5,5,4,'[fdff77]金色仙器[-]可开启此附魔槽'},
[6]={6,6,5,'[ffc320]橙色仙器[-]可开启此附魔槽'},
[7]={7,6,6,'[ffc320]橙色仙器[-]可开启此附魔槽'}
}
local ks={id=1,groove_pos=2,quality_req=3,rec_fighting=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(fairy_groove_pos)do setmetatable(v,base)end base.__metatable=false
return fairy_groove_pos
