local gem_effect={
[101000]={101000,'clothes_light',0,0,0,0,0,0,5.8,1.5},
[102000]={102000,'clothes_light',0,0,0,-90,90,0,6,1.2},
[103000]={103000,'clothes_light',0,0,0,-90,90,0,5,1.5},
[104000]={104000,'clothes_light',0,0.1,0,-90,90,0,4.8,1.5}
}
local ks={career=1,effect_name=2,position_x=3,position_y=4,position_z=5,rotation_x=6,rotation_y=7,rotation_z=8,glow_start_size=9,smoke_start_size=10}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(gem_effect)do setmetatable(v,base)end base.__metatable=false
return gem_effect
