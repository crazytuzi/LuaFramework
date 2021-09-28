local mount_att_mod={
['1_1']={'1_1',1,1,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}
}
local ks={key=1,id=2,lev=3,hp_max_mod=4,mp_max_mod=5,phy_att_mod=6,phy_def_mod=7,hit_mod=8,eva_mod=9,crit_mod=10,tough_mod=11,fatal_mod=12,block_mod=13,direct_dmg_mod=14,phy_pen_mod=15,cd_rdc_mod=16,phy_bld_rate_mod=17,phy_bns_rate_mod=18,phy_bns_per_mod=19,stun_resist_mod=20,silent_resist_mod=21,still_resist_mod=22,taunt_resist_mod=23,mag_att_mod=24,mag_def_mod=25,mag_pen_mod=26,mag_bld_rate_mod=27,mag_bns_rate_mod=28,mag_bns_per_mod=29}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(mount_att_mod)do setmetatable(v,base)end base.__metatable=false
return mount_att_mod
