local tongbattle_config={
[1]={1,707200,{'2_05:00:00','6_19:30:00'},{3,6},'20:50:00','21:00:00','21:15:00','21:01:00','21:01:00','21:15:00',10,60000,2,10000,2000,15,10,5,25,25,10,500,500,2,2,1,100,100,25,250,250,100,'仙盟气运战','每周2 21:00-21:15\n每周5 21:00-21:15',{'116_1','506050_1','358007_1','500156_1'}}
}
local ks={id=1,map_id=2,sign_up_time=3,week_time=4,notice_time=5,start_time=6,end_time=7,unblock_time=8,born_time=9,reward_time=10,collect_point=11,collect_interval=12,main_point=13,main_interval=14,main_range=15,main_max=16,kill_point=17,monster_point=18,player_team_point=19,player_single_point=20,player_single_assitpoint=21,tower_team_point=22,tower_totalpoint=23,monster_team_point=24,monster_single_point=25,monster_single_assitpoint=26,elite_team_point=27,elite_single_point=28,elite_single_assitpoint=29,boss_team_point=30,boss_single_point=31,boss_single_assitpoint=32,desc=33,desc_time=34,award_show=35}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tongbattle_config)do setmetatable(v,base)end base.__metatable=false
return tongbattle_config
