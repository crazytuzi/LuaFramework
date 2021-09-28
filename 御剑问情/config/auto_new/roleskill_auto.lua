-- J-角色技能.xls
return {
skillinfo_default_table={skill_id=5,is_buff=0,skill_use_type=1,skill_name="必杀技",skill_icon=500000,skill_action="combo1_1",hit_count=1,skill_desc="冷却时间：<color=#0000f1>[cd_s]秒</color>\n\n技能效果：对<color=#0000f1>[enemy_num]</color>个目标造成<color=#0000f1>[hurt_percent]%</color>攻击+<color=#0000f1>[fix_hurt]</color>点伤害",skill_index=6,can_move=0,blood_delay=1,play_speed=1,},

normal_skill_default_table={skill_id=1,skill_level=1,skill_name="攻击",distance=14,attack_range=1,enemy_num=1,cd_s=15,cost_mp=100,prof_limit=5,is_repel=0,hurt_percent=0,fix_hurt=0,param_a=5000,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=100,effect_to_other_target=0,skill_desc="",},

s5_default_table={skill_id=5,skill_level=1,skill_name="必杀技",distance=14,attack_range=10,enemy_num=10,cd_s=60,cost_mp=0,prof_limit=5,hurt_percent=50000,fix_hurt=0,is_repel=1,param_a=500,param_b=200,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=-10,zhenqi_cost=30,item_cost_id=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=101,calc_hurt_by_hp_per=500,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s41_default_table={skill_id=41,skill_level=1,skill_name="生命",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=750,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26512,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s42_default_table={skill_id=42,skill_level=1,skill_name="攻击",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=37,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26510,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s43_default_table={skill_id=43,skill_level=1,skill_name="防御",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=45,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26511,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s44_default_table={skill_id=44,skill_level=1,skill_name="命中",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=100,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26513,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s45_default_table={skill_id=45,skill_level=1,skill_name="闪避",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=84,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26514,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s46_default_table={skill_id=46,skill_level=1,skill_name="暴击",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=63,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26515,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s47_default_table={skill_id=47,skill_level=1,skill_name="抗暴",distance=0,attack_range=0,enemy_num=0,cd_s=0,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=79,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost_id=26516,item_cost=2,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s70_default_table={skill_id=70,skill_level=1,skill_name="拉人",distance=15,attack_range=15,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=10000,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s71_default_table={skill_id=71,skill_level=1,skill_name="变形",distance=15,attack_range=15,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=3000,param_b=8000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s72_default_table={skill_id=72,skill_level=1,skill_name="护盾",distance=0,attack_range=0,enemy_num=0,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=3000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s73_default_table={skill_id=73,skill_level=1,skill_name="复活",distance=0,attack_range=0,enemy_num=0,cd_s=300,cost_mp=0,prof_limit=5,hurt_percent=0,fix_hurt=0,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s80_default_table={skill_id=80,skill_level=1,skill_name="减伤",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=2000,param_b=5000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s81_default_table={skill_id=81,skill_level=1,skill_name="群攻",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=20000,param_b=14,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s82_default_table={skill_id=82,skill_level=1,skill_name="沉默",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=0,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s83_default_table={skill_id=83,skill_level=1,skill_name="禁疗",distance=30,attack_range=30,enemy_num=1,cd_s=40,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=0,param_b=20000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s84_default_table={skill_id=84,skill_level=1,skill_name="定身",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=0,param_b=3000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s85_default_table={skill_id=85,skill_level=1,skill_name="眩晕",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=0,param_b=1500,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s86_default_table={skill_id=86,skill_level=1,skill_name="净化",distance=30,attack_range=30,enemy_num=1,cd_s=30,cost_mp=0,prof_limit=5,hurt_percent=1000,fix_hurt=0,is_repel=0,param_a=0,param_b=6000,param_c=0,param_d=0,param_e=0,param_f=0,param_g=0,zhenqi_cost=0,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=0,effect_to_other_target=0,},

s111_default_table={skill_id=111,skill_level=1,skill_name="刀剑乱舞",distance=8,attack_range=8,enemy_num=3,cd_s=0,cost_mp=0,prof_limit=1,hurt_percent=10600,fix_hurt=75,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=200,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=100,effect_to_other_target=0,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s121_default_table={skill_id=121,skill_level=1,skill_name="血战八荒",distance=8,attack_range=10,enemy_num=8,cd_s=8,cost_mp=0,prof_limit=1,hurt_percent=40000,fix_hurt=238,is_repel=0,param_a=0,param_b=500,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=15,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s131_default_table={skill_id=131,skill_level=1,skill_name="惊天裂地",distance=8,attack_range=8,enemy_num=4,cd_s=5,cost_mp=0,prof_limit=1,hurt_percent=28900,fix_hurt=235,is_repel=1,param_a=3000,param_b=1000,param_c=1250,param_d=0,param_e=2000,param_f=10000,param_g=-10,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=30,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s141_default_table={skill_id=141,skill_level=1,skill_name="长虹贯日",distance=10,attack_range=8,enemy_num=5,cd_s=10,cost_mp=0,prof_limit=1,hurt_percent=59500,fix_hurt=341,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=45,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s211_default_table={skill_id=211,skill_level=1,skill_name="生杀予夺",distance=8,attack_range=8,enemy_num=3,cd_s=0,cost_mp=0,prof_limit=2,hurt_percent=9800,fix_hurt=70,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=200,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=100,effect_to_other_target=0,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s221_default_table={skill_id=221,skill_level=1,skill_name="蚀骨断魂",distance=8,attack_range=8,enemy_num=8,cd_s=8,cost_mp=0,prof_limit=2,hurt_percent=40000,fix_hurt=238,is_repel=1,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=-10,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=15,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s231_default_table={skill_id=231,skill_level=1,skill_name="紫霄神雷",distance=8,attack_range=8,enemy_num=4,cd_s=5,cost_mp=0,prof_limit=2,hurt_percent=36400,fix_hurt=235,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=30,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s241_default_table={skill_id=241,skill_level=1,skill_name="浮光掠影",distance=10,attack_range=8,enemy_num=5,cd_s=10,cost_mp=0,prof_limit=2,hurt_percent=44500,fix_hurt=341,is_repel=0,param_a=7500,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=45,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_1=3,atk_2=4.2,atk_3=5.4,atk_4=6.6,atk_5=9,},

s311_default_table={skill_id=311,skill_level=1,skill_name="碎荧流袂",distance=14,attack_range=8,enemy_num=3,cd_s=0,cost_mp=0,prof_limit=3,hurt_percent=12100,fix_hurt=86,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=200,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=100,effect_to_other_target=0,atk_3=5.4,atk_4=6.6,atk_5=9,},

s321_default_table={skill_id=321,skill_level=1,skill_name="背水殇歌",distance=14,attack_range=8,enemy_num=4,cd_s=8,cost_mp=0,prof_limit=3,hurt_percent=40000,fix_hurt=238,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=15,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s331_default_table={skill_id=331,skill_level=1,skill_name="青龙乱舞",distance=14,attack_range=8,enemy_num=4,cd_s=5,cost_mp=0,prof_limit=3,hurt_percent=36400,fix_hurt=235,is_repel=1,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=-10,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=30,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s341_default_table={skill_id=341,skill_level=1,skill_name="玉碎九渊",distance=14,attack_range=8,enemy_num=5,cd_s=10,cost_mp=0,prof_limit=3,hurt_percent=45600,fix_hurt=341,is_repel=0,param_a=10000,param_b=3000,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=45,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s411_default_table={skill_id=411,skill_level=1,skill_name="曲水流觞",distance=14,attack_range=8,enemy_num=3,cd_s=0,cost_mp=0,prof_limit=4,hurt_percent=10600,fix_hurt=75,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=200,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=1,calc_hurt_by_hp_per=100,effect_to_other_target=0,atk_3=5.4,atk_4=6.6,atk_5=9,},

s421_default_table={skill_id=421,skill_level=1,skill_name="高山流水",distance=14,attack_range=8,enemy_num=4,cd_s=8,cost_mp=0,prof_limit=4,hurt_percent=40000,fix_hurt=238,is_repel=0,param_a=0,param_b=0,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=15,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s431_default_table={skill_id=431,skill_level=1,skill_name="梅花三弄",distance=14,attack_range=10,enemy_num=8,cd_s=5,cost_mp=0,prof_limit=4,hurt_percent=36400,fix_hurt=235,is_repel=1,param_a=0,param_b=500,param_c=0,param_d=0,param_e=2000,param_f=10000,param_g=-10,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=30,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,},

s441_default_table={skill_id=441,skill_level=1,skill_name="平沙落雁",distance=14,attack_range=8,enemy_num=5,cd_s=10,cost_mp=0,prof_limit=4,hurt_percent=44500,fix_hurt=341,is_repel=0,param_a=3000,param_b=1000,param_c=2500,param_d=0,param_e=2000,param_f=10000,param_g=0,zhenqi_cost=100,item_cost=0,coin_cost=0,capbility=0,learn_level_limit=45,calc_hurt_by_hp_per=200,effect_to_other_target=1,atk_3=5.4,atk_4=6.6,atk_5=9,}

}

