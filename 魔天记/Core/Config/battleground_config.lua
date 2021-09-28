local battleground_config={
[1]={1,707100,2400,10,2,{'301214','301215','301216'},{'500020','500021','500022','500023','500024'},5,10,15,20,80,50,'天宫','北斗',{'370118_1','400000_1','401000_1','9_1','506060_1'}}
}
local ks={id=1,map_id=2,winpoint_need=3,winpoint_add=4,join_award_time=5,ground_buff=6,hp_potion_item=7,hp_potion_CD=8,kill_hornor=9,firstk_honor=10,assist_honor=11,mine_honor=12,buff_honor=13,camp1_name=14,camp2_name=15,award_show=16}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(battleground_config)do setmetatable(v,base)end base.__metatable=false
return battleground_config
