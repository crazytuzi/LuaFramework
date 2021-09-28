local tongbattle_pos={
[1]={1,1,0,0,-6910,400,0,'','A本阵'},
[2]={2,1,0,0,6910,400,0,'','B本阵'},
[3]={3,2,2,0,-25,1000,0,'',''},
[4]={4,0,2570,0,-3740,1000,0,'',''},
[5]={5,0,-2539,0,-3740,1000,0,'',''},
[6]={6,0,2570,0,3690,1000,0,'',''},
[7]={7,0,-2660,0,3690,1000,0,'',''}
}
local ks={id=1,type=2,x=3,y=4,z=5,r=6,face=7,modle=8,l_name=9}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tongbattle_pos)do setmetatable(v,base)end base.__metatable=false
return tongbattle_pos
