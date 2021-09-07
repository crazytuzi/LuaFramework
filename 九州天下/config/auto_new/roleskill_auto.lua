-- J-角色技能.xls
local fun100 = function(skill_level)
return 216*(skill_level-1)
end

local fun101 = function(skill_level)
return 631*(skill_level-1)
end

local fun102 = function(skill_level)
return 852*(skill_level-1)
end

local fun103 = function(skill_level)
return 900*(skill_level-1)
end

local fun104 = function(skill_level)
return 1500*(skill_level-1)
end

local fun100 = function(skill_level)
return 216*(skill_level-1)
end

local fun101 = function(skill_level)
return 631*(skill_level-1)
end

local fun102 = function(skill_level)
return 852*(skill_level-1)
end

local fun103 = function(skill_level)
return 900*(skill_level-1)
end

local fun104 = function(skill_level)
return 1500*(skill_level-1)
end

local fun100 = function(skill_level)
return 216*(skill_level-1)
end

local fun101 = function(skill_level)
return 631*(skill_level-1)
end

local fun102 = function(skill_level)
return 852*(skill_level-1)
end

local fun103 = function(skill_level)
return 900*(skill_level-1)
end

local fun104 = function(skill_level)
return 1500*(skill_level-1)
end

local fun100 = function(skill_level)
return 216*(skill_level-1)
end

local fun101 = function(skill_level)
return 631*(skill_level-1)
end

local fun102 = function(skill_level)
return 852*(skill_level-1)
end

local fun103 = function(skill_level)
return 900*(skill_level-1)
end

local fun104 = function(skill_level)
return 1500*(skill_level-1)
end

return {
skillinfo_default_table={skill_id=5,is_buff=0,skill_use_type=1,skill_name="追魂夺命",skill_icon=500001,skill_action="skill1_1",hit_count=1,skill_desc="技能类型：<color=#532F1E>被动</color>",skill_desc2="",skill_index=5,can_move=0,blood_delay=1,play_speed=1,skill_delay=0,show_cap=0,},

normal_skill_default_table={skill_id=1,skill_level=1,skill_name="攻击",distance=14,range_type=0,attack_range=1,attack_range2=0,enemy_num=1,cd_s=15,cost_mp=0,prof_limit=5,is_repel=0,hurt_percent=0,fix_hurt=0,param_a=5000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,skill_desc="",},

s5_default_table={skill_id=5,skill_level=1,skill_name="追魂夺命",distance=25,range_type=0,attack_range=25,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=1,hurt_percent=30000,fix_hurt=0,is_repel=0,param_a=30000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=4000000,capbility=1000,learn_level_limit=10,},

s6_default_table={skill_id=6,skill_level=1,skill_name="破釜沉舟",distance=25,range_type=0,attack_range=25,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=2,hurt_percent=30000,fix_hurt=0,is_repel=0,param_a=30000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=4000000,capbility=1000,learn_level_limit=10,},

s7_default_table={skill_id=7,skill_level=1,skill_name="箭无虚发",distance=18,range_type=0,attack_range=18,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=3,hurt_percent=30000,fix_hurt=0,is_repel=0,param_a=30000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=4000000,capbility=1000,},

s8_default_table={skill_id=8,skill_level=1,skill_name="勾魂夺魄",distance=25,range_type=0,attack_range=18,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=4,hurt_percent=30000,fix_hurt=0,is_repel=0,param_a=30000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=4000000,capbility=1000,learn_level_limit=10,},

s41_default_table={skill_id=41,skill_level=1,skill_name="生命",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=6000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26512,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s42_default_table={skill_id=42,skill_level=1,skill_name="攻击",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=300,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26510,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s43_default_table={skill_id=43,skill_level=1,skill_name="防御",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=300,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26511,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s44_default_table={skill_id=44,skill_level=1,skill_name="命中",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=100,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26513,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s45_default_table={skill_id=45,skill_level=1,skill_name="闪避",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=100,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26514,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s46_default_table={skill_id=46,skill_level=1,skill_name="暴击",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=100,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26515,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s47_default_table={skill_id=47,skill_level=1,skill_name="抗暴",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=100,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26516,item_cost=5,coin_cost=100000,capbility=0,learn_level_limit=1,},

s48_default_table={skill_id=48,skill_level=1,skill_name="控制",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=12,param_b=3,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26607,item_cost=1,coin_cost=2000000,capbility=4000,learn_level_limit=1,},

s49_default_table={skill_id=49,skill_level=1,skill_name="免控",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=88,param_b=1200,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26608,item_cost=1,coin_cost=100000,capbility=8000,learn_level_limit=1,},

s70_default_table={skill_id=70,skill_level=1,skill_name="拉人",distance=15,range_type=0,attack_range=15,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=10000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s71_default_table={skill_id=71,skill_level=1,skill_name="变形",distance=15,range_type=0,attack_range=15,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=3000,param_b=8000,param_c=0,param_d=0,param_e=0,param_f=0,zhenqi_cost=0,param_g=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s72_default_table={skill_id=72,skill_level=1,skill_name="护盾",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=3000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s73_default_table={skill_id=73,skill_level=1,skill_name="复活",distance=0,range_type=0,attack_range=0,attack_range2=0,enemy_num=0,cd_s=300,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s80_default_table={skill_id=80,skill_level=1,skill_name="晕眩",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=3000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s81_default_table={skill_id=81,skill_level=1,skill_name="减伤",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=2000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s82_default_table={skill_id=82,skill_level=1,skill_name="破防",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=2000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s83_default_table={skill_id=83,skill_level=1,skill_name="强力",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=2000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s84_default_table={skill_id=84,skill_level=1,skill_name="防御",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=2000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s85_default_table={skill_id=85,skill_level=1,skill_name="暴击",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=1000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s86_default_table={skill_id=86,skill_level=1,skill_name="减速",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=6000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,},

s111_default_table={skill_id=111,skill_level=1,skill_name="破军击",distance=7,range_type=0,attack_range=7,attack_range2=0,enemy_num=1,cd_s=0.5,cost_mp=0,prof_limit=1,hurt_percent=3600,fix_hurt=fun100,is_repel=0,param_a=3600,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,zhenqi_cost=0,param_g=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=1,fix_hurt_params={"skill_level"},},

s121_default_table={skill_id=121,skill_level=1,skill_name="力劈华山",distance=7,range_type=5,attack_range=12,attack_range2=8,enemy_num=20,cd_s=3.5,cost_mp=0,prof_limit=1,hurt_percent=10530,fix_hurt=fun101,is_repel=0,param_a=5400,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=3,fix_hurt_params={"skill_level"},},

s131_default_table={skill_id=131,skill_level=1,skill_name="横扫千军",distance=7,range_type=3,attack_range=7,attack_range2=0,enemy_num=20,cd_s=1.6,cost_mp=0,prof_limit=1,hurt_percent=14200,fix_hurt=fun102,is_repel=0,param_a=12000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=100,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=7,fix_hurt_params={"skill_level"},},

s141_default_table={skill_id=141,skill_level=1,skill_name="沧海游龙",distance=9,range_type=5,attack_range=12,attack_range2=8,enemy_num=20,cd_s=4,cost_mp=0,prof_limit=1,hurt_percent=15000,fix_hurt=fun103,is_repel=0,param_a=7200,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=10,fix_hurt_params={"skill_level"},},

s151_default_table={skill_id=151,skill_level=1,skill_name="追魂夺命",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=1,hurt_percent=25000,fix_hurt=fun104,is_repel=0,param_a=30000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=500,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=12,fix_hurt_params={"skill_level"},},

s211_default_table={skill_id=211,skill_level=1,skill_name="贪狼斩",distance=7,range_type=0,attack_range=7,attack_range2=0,enemy_num=1,cd_s=0.5,cost_mp=0,prof_limit=2,hurt_percent=3600,fix_hurt=fun100,is_repel=0,param_a=3600,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=1,fix_hurt_params={"skill_level"},},

s221_default_table={skill_id=221,skill_level=1,skill_name="玉女穿梭",distance=7,range_type=6,attack_range=12,attack_range2=135,enemy_num=20,cd_s=3.5,cost_mp=0,prof_limit=2,hurt_percent=10530,fix_hurt=fun101,is_repel=0,param_a=5400,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=3,fix_hurt_params={"skill_level"},},

s231_default_table={skill_id=231,skill_level=1,skill_name="清风乱影",distance=7,range_type=3,attack_range=7,attack_range2=0,enemy_num=20,cd_s=1.6,cost_mp=0,prof_limit=2,hurt_percent=14200,fix_hurt=fun102,is_repel=0,param_a=12000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=100,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=7,fix_hurt_params={"skill_level"},},

s241_default_table={skill_id=241,skill_level=1,skill_name="雷动九天",distance=7,range_type=3,attack_range=12,attack_range2=0,enemy_num=20,cd_s=4,cost_mp=0,prof_limit=2,hurt_percent=15000,fix_hurt=fun103,is_repel=0,param_a=7200,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=10,fix_hurt_params={"skill_level"},},

s251_default_table={skill_id=251,skill_level=1,skill_name="破釜沉舟",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=2,hurt_percent=25000,fix_hurt=fun104,is_repel=0,param_a=30000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=500,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=12,fix_hurt_params={"skill_level"},},

s311_default_table={skill_id=311,skill_level=1,skill_name="精准射击",distance=21,range_type=0,attack_range=21,attack_range2=0,enemy_num=1,cd_s=0.5,cost_mp=0,prof_limit=3,hurt_percent=3600,fix_hurt=fun100,is_repel=0,param_a=3600,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=1,fix_hurt_params={"skill_level"},},

s321_default_table={skill_id=321,skill_level=1,skill_name="冰封万刃",distance=21,range_type=6,attack_range=12,attack_range2=135,enemy_num=20,cd_s=3.5,cost_mp=0,prof_limit=3,hurt_percent=10530,fix_hurt=fun101,is_repel=0,param_a=5400,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=3,fix_hurt_params={"skill_level"},},

s331_default_table={skill_id=331,skill_level=1,skill_name="暴雨梨花",distance=21,range_type=4,attack_range=7,attack_range2=0,enemy_num=20,cd_s=1.6,cost_mp=0,prof_limit=3,hurt_percent=14200,fix_hurt=fun102,is_repel=0,param_a=12000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=100,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=7,fix_hurt_params={"skill_level"},},

s341_default_table={skill_id=341,skill_level=1,skill_name="如影随形",distance=21,range_type=5,attack_range=12,attack_range2=8,enemy_num=20,cd_s=4,cost_mp=0,prof_limit=3,hurt_percent=15000,fix_hurt=fun103,is_repel=0,param_a=7200,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=10,fix_hurt_params={"skill_level"},},

s351_default_table={skill_id=351,skill_level=1,skill_name="箭无虚发",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=3,hurt_percent=25000,fix_hurt=fun104,is_repel=0,param_a=30000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=500,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=12,fix_hurt_params={"skill_level"},},

s411_default_table={skill_id=411,skill_level=1,skill_name="灵动法术",distance=21,range_type=0,attack_range=13,attack_range2=0,enemy_num=1,cd_s=0.5,cost_mp=0,prof_limit=4,hurt_percent=3600,fix_hurt=fun100,is_repel=0,param_a=3600,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=1,fix_hurt_params={"skill_level"},},

s421_default_table={skill_id=421,skill_level=1,skill_name="仙女散花",distance=21,range_type=5,attack_range=12,attack_range2=8,enemy_num=20,cd_s=3.5,cost_mp=0,prof_limit=4,hurt_percent=10530,fix_hurt=fun101,is_repel=0,param_a=5400,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=3,fix_hurt_params={"skill_level"},},

s431_default_table={skill_id=431,skill_level=1,skill_name="天罗地网",distance=21,range_type=4,attack_range=7,attack_range2=0,enemy_num=20,cd_s=1.6,cost_mp=0,prof_limit=4,hurt_percent=14200,fix_hurt=fun102,is_repel=0,param_a=12000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=100,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=7,fix_hurt_params={"skill_level"},},

s441_default_table={skill_id=441,skill_level=1,skill_name="蜻蜓点水",distance=21,range_type=5,attack_range=12,attack_range2=8,enemy_num=20,cd_s=4,cost_mp=0,prof_limit=4,hurt_percent=15000,fix_hurt=fun103,is_repel=0,param_a=7200,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=10,fix_hurt_params={"skill_level"},},

s451_default_table={skill_id=451,skill_level=1,skill_name="勾魂夺魄",distance=30,range_type=0,attack_range=30,attack_range2=0,enemy_num=1,cd_s=25,cost_mp=0,prof_limit=4,hurt_percent=25000,fix_hurt=fun104,is_repel=0,param_a=30000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=500,zhenqi_cost=0,item_cost_id=0,item_cost=0,coin_cost=2000000,capbility=200,learn_level_limit=12,fix_hurt_params={"skill_level"},},

s501_default_table={skill_id=501,skill_level=1,skill_name="坐骑被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26330,baoji=100,},

s502_default_table={skill_id=502,skill_level=1,skill_name="坐骑被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26330,ice_master=18,},

s503_default_table={skill_id=503,skill_level=1,skill_name="坐骑被动技能3",cd_s=20,param_a=61,param_b=6,param_c=10,param_d=5,item_cost=10,item_cost_id=26330,capbility=800,},

s504_default_table={skill_id=504,skill_level=1,skill_name="坐骑被动技能4",prof_limit=5,param_a=81,param_b=5,param_c=600,param_d=0,item_cost=20,item_cost_id=26330,capbility=1600,},

s511_default_table={skill_id=511,skill_level=1,skill_name="羽翼被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26331,learn_level_limit=0,shanbi=100,},

s512_default_table={skill_id=512,skill_level=1,skill_name="羽翼被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26331,fire_master=18,},

s513_default_table={skill_id=513,skill_level=1,skill_name="羽翼被动技能3",cd_s=20,param_a=61,param_b=6,param_c=16000,param_d=0,item_cost=10,item_cost_id=26331,capbility=800,},

s514_default_table={skill_id=514,skill_level=1,skill_name="羽翼被动技能4",param_a=81,param_b=1,param_c=0,param_d=0,item_cost=20,item_cost_id=26331,learn_level_limit=0,capbility=1600,},

s521_default_table={skill_id=521,skill_level=1,skill_name="光环被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26332,jianren=100,},

s522_default_table={skill_id=522,skill_level=1,skill_name="光环被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26332,thunder_master=18,},

s523_default_table={skill_id=523,skill_level=1,skill_name="光环被动技能3",attack_range=30,param_a=61,param_b=6,param_c=10,param_d=0,item_cost=10,item_cost_id=26332,capbility=800,},

s524_default_table={skill_id=524,skill_level=1,skill_name="光环被动技能4",cd_s=30,attack_range=50,param_a=81,param_b=6,param_c=2,param_d=0,item_cost=20,item_cost_id=26332,capbility=1600,},

s531_default_table={skill_id=531,skill_level=1,skill_name="法印被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26335,mingzhong=100,},

s532_default_table={skill_id=532,skill_level=1,skill_name="法印被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26335,poison_master=18,},

s533_default_table={skill_id=533,skill_level=1,skill_name="法印被动技能3",cd_s=30,param_a=61,param_b=6,param_c=2,param_d=0,item_cost=10,item_cost_id=26335,capbility=800,},

s534_default_table={skill_id=534,skill_level=1,skill_name="法印被动技能4",param_a=81,param_b=600,param_c=600,param_d=0,item_cost=20,item_cost_id=26335,capbility=1600,},

s541_default_table={skill_id=541,skill_level=1,skill_name="美人光环被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26336,per_mianshang=150,},

s542_default_table={skill_id=542,skill_level=1,skill_name="美人光环被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26336,per_pvp_hurt_reduce=36,},

s543_default_table={skill_id=543,skill_level=1,skill_name="美人光环被动技能3",cd_s=10,prof_limit=5,param_a=61,param_b=6,param_c=50,param_d=5,item_cost=10,item_cost_id=26336,capbility=800,},

s544_default_table={skill_id=544,skill_level=1,skill_name="美人光环被动技能4",param_a=81,param_b=12,param_c=0,param_d=0,item_cost=20,item_cost_id=26336,capbility=1600,},

s551_default_table={skill_id=551,skill_level=1,skill_name="法宝被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26337,per_pofang=150,},

s552_default_table={skill_id=552,skill_level=1,skill_name="法宝被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26337,per_pvp_hurt_increase=36,},

s553_default_table={skill_id=553,skill_level=1,skill_name="法宝被动技能3",cd_s=20,param_a=61,param_b=6,param_c=600,param_d=5,item_cost=10,item_cost_id=26337,capbility=800,},

s554_default_table={skill_id=554,skill_level=1,skill_name="法宝被动技能4",cd_s=300,param_a=81,param_b=1,param_c=0,param_d=0,item_cost=20,item_cost_id=26337,capbility=1600,},

s561_default_table={skill_id=561,skill_level=1,skill_name="披风被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26338,ignore_fangyu=300,},

s562_default_table={skill_id=562,skill_level=1,skill_name="披风被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26338,per_pofang=24,},

s563_default_table={skill_id=563,skill_level=1,skill_name="披风被动技能3",cd_s=20,param_a=61,param_b=6,param_c=6,param_d=5,item_cost=10,item_cost_id=26338,capbility=800,},

s564_default_table={skill_id=564,skill_level=1,skill_name="披风被动技能4",param_a=81,param_b=12,param_c=0,param_d=0,item_cost=20,item_cost_id=26338,capbility=1600,},

s571_default_table={skill_id=571,skill_level=1,skill_name="足迹被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=26339,gongji=300,},

s572_default_table={skill_id=572,skill_level=1,skill_name="足迹被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=26339,per_mianshang=24,},

s573_default_table={skill_id=573,skill_level=1,skill_name="足迹被动技能3",cd_s=20,param_a=61,param_b=6,param_c=0,param_d=0,item_cost=10,item_cost_id=26339,capbility=800,},

s574_default_table={skill_id=574,skill_level=1,skill_name="足迹被动技能4",param_a=81,param_b=12,param_c=0,param_d=0,item_cost=20,item_cost_id=26339,capbility=1600,},

s575_default_table={skill_id=575,skill_level=1,skill_name="吸血",param_a=9,param_b=12,param_c=0,param_d=0,item_cost=20,item_cost_id=26337,},

s576_default_table={skill_id=576,skill_level=1,skill_name="眩晕",param_a=9,param_b=12,param_c=0,param_d=0,item_cost=20,item_cost_id=26337,},

s581_default_table={skill_id=581,skill_level=1,skill_name="麒麟臂被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27727,gongji=300,},

s582_default_table={skill_id=582,skill_level=1,skill_name="麒麟臂被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27727,per_mianshang=24,},

s583_default_table={skill_id=583,skill_level=1,skill_name="麒麟臂被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27727,},

s584_default_table={skill_id=584,skill_level=1,skill_name="麒麟臂被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27727,},

s591_default_table={skill_id=591,skill_level=1,skill_name="头饰被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27722,gongji=300,},

s592_default_table={skill_id=592,skill_level=1,skill_name="头饰被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27722,per_pofang=24,},

s593_default_table={skill_id=593,skill_level=1,skill_name="头饰被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27722,},

s594_default_table={skill_id=594,skill_level=1,skill_name="头饰被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27722,},

s641_default_table={skill_id=641,skill_level=1,skill_name="腰饰被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27723,gongji=300,},

s642_default_table={skill_id=642,skill_level=1,skill_name="腰饰被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27723,ice_master=18,},

s643_default_table={skill_id=643,skill_level=1,skill_name="腰饰被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27723,},

s644_default_table={skill_id=644,skill_level=1,skill_name="腰饰被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27723,},

s611_default_table={skill_id=611,skill_level=1,skill_name="面饰被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27724,gongji=300,},

s612_default_table={skill_id=612,skill_level=1,skill_name="面饰被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27724,fire_master=18,},

s613_default_table={skill_id=613,skill_level=1,skill_name="面饰被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27724,},

s614_default_table={skill_id=614,skill_level=1,skill_name="面饰被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27724,},

s621_default_table={skill_id=621,skill_level=1,skill_name="灵珠被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27726,gongji=300,},

s622_default_table={skill_id=622,skill_level=1,skill_name="灵珠被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27726,thunder_master=18,},

s623_default_table={skill_id=623,skill_level=1,skill_name="灵珠被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27726,},

s624_default_table={skill_id=624,skill_level=1,skill_name="灵珠被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27726,},

s631_default_table={skill_id=631,skill_level=1,skill_name="法宝被动技能1",param_a=21,param_b=0,param_c=0,param_d=0,item_cost=1,item_cost_id=27725,gongji=300,},

s632_default_table={skill_id=632,skill_level=1,skill_name="法宝被动技能2",param_a=41,param_b=0,param_c=0,param_d=0,item_cost=5,item_cost_id=27725,poison_master=18,},

s633_default_table={skill_id=633,skill_level=1,skill_name="法宝被动技能3",param_a=61,param_b=0,param_c=1200,param_d=0,item_cost=10,item_cost_id=27725,},

s634_default_table={skill_id=634,skill_level=1,skill_name="法宝被动技能4",param_a=81,param_b=6,param_c=1600,param_d=0,item_cost=20,item_cost_id=27725,},

s701_default_table={skill_id=701,skill_level=1,skill_name="太极劲",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=11,param_b=5000,param_c=0,param_d=0,},

s702_default_table={skill_id=702,skill_level=1,skill_name="玄黄劲",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1100,param_b=30,param_c=3000,param_d=0,},

s703_default_table={skill_id=703,skill_level=1,skill_name="乾坤劲",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1200,param_b=0,param_c=0,param_d=0,},

s704_default_table={skill_id=704,skill_level=1,skill_name="白虎象",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1500,param_b=5000,param_c=0,param_d=0,},

s705_default_table={skill_id=705,skill_level=1,skill_name="朱雀象",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1500,param_b=5000,param_c=0,param_d=0,},

s706_default_table={skill_id=706,skill_level=1,skill_name="苍龙象",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1500,param_b=5000,param_c=0,param_d=0,},

s707_default_table={skill_id=707,skill_level=1,skill_name="龟蛇象",distance=40,range_type=0,attack_range=40,attack_range2=0,enemy_num=0,cd_s=120,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=1500,param_b=5000,param_c=0,param_d=0,}

}

