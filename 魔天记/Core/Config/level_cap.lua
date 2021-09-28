local level_cap={
['role_system']={'role_system',1,500},
['equip_transport']={'equip_transport',2,500},
['equip_refine']={'equip_refine',3,30},
['role_skill']={'role_skill',4,50},
['partner_level']={'partner_level',5,500},
['magic_refine']={'magic_refine',6,18},
['tong_level']={'tong_level',7,10},
['medic_system']={'medic_system',8,10},
['partner_advance']={'partner_advance',10,100}
}
local ks={client_id=1,id=2,lev_max=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(level_cap)do setmetatable(v,base)end base.__metatable=false
return level_cap
