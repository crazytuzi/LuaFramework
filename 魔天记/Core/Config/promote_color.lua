local promote_color={
[5]={5,{32,122,74,80},{24,107,48,60}},
[6]={6,{32,122,74,80},{24,107,48,60}},
[7]={7,{23,255,33,140},{152,255,200,45}},
[8]={8,{0,65,255,240},{72,177,255,35}},
[9]={9,{0,0,255,200},{72,177,255,35}},
[10]={10,{157,0,255,140},{175,68,255,30}},
[11]={11,{200,0,175,140},{175,68,255,30}},
[12]={12,{230,255,0,210},{255,183,54,35}},
[13]={13,{255,62,0,210},{255,161,88,35}},
[14]={14,{255,24,0,168},{255,68,68,38}},
[15]={15,{255,0,0,240},{255,0,0,60}}
}
local ks={promote_lev=1,glow_color=2,smoke_color=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(promote_color)do setmetatable(v,base)end base.__metatable=false
return promote_color
