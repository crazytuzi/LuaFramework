-- L-领土战.xls
return {
other={
{}},

building={
{building_index=0,building_pos_x=230,building_pos_y=74,guild_credit_reward=197,personal_credit_reward=197,assist_credit_reward=79,side=2,},
{building_id=4107,guild_credit_reward=794,personal_credit_reward=794,assist_credit_reward=318,},
{building_id=4108,building_index=2,building_pos_y=47,guild_credit_reward=794,personal_credit_reward=794,assist_credit_reward=318,},
{building_id=4109,building_index=3,building_pos_x=150,guild_credit_reward=958,personal_credit_reward=958,assist_credit_reward=383,preposition_monster_1=4107,preposition_monster_2=4108,},
{building_id=4110,building_index=4,building_pos_x=150,building_pos_y=47,guild_credit_reward=958,personal_credit_reward=958,assist_credit_reward=383,preposition_monster_1=4107,preposition_monster_2=4108,},
{building_id=4111,building_index=5,building_pos_x=103,building_pos_y=106,guild_credit_reward=1122,personal_credit_reward=1122,assist_credit_reward=449,preposition_monster_1=4109,preposition_monster_2=4110,},
{building_id=4112,building_index=6,building_pos_x=103,building_pos_y=41,guild_credit_reward=1122,personal_credit_reward=1122,assist_credit_reward=449,preposition_monster_1=4109,preposition_monster_2=4110,},
{building_id=4115,building_index=7,building_pos_x=69,building_pos_y=73,preposition_monster_1=4111,preposition_monster_2=4112,},
{building_id=4113,building_index=8,building_pos_x=35,building_pos_y=86,preposition_monster_1=4115,preposition_monster_2=4115,},
{building_id=4114,building_index=9,building_pos_x=35,building_pos_y=61,preposition_monster_1=4115,preposition_monster_2=4115,},
{building_id=4118,building_pos_x=271,guild_credit_reward=794,personal_credit_reward=794,assist_credit_reward=318,side=0,},
{building_id=4119,building_index=2,building_pos_x=271,building_pos_y=46,guild_credit_reward=794,personal_credit_reward=794,assist_credit_reward=318,side=0,},
{building_id=4120,building_index=3,building_pos_x=312,guild_credit_reward=958,personal_credit_reward=958,assist_credit_reward=383,side=0,preposition_monster_1=4118,preposition_monster_2=4119,},
{building_id=4121,building_index=4,building_pos_x=312,building_pos_y=46,guild_credit_reward=958,personal_credit_reward=958,assist_credit_reward=383,side=0,preposition_monster_1=4118,preposition_monster_2=4119,},
{building_id=4122,building_index=5,building_pos_x=359,building_pos_y=106,guild_credit_reward=1122,personal_credit_reward=1122,assist_credit_reward=449,side=0,preposition_monster_1=4120,preposition_monster_2=4121,},
{building_id=4123,building_index=6,building_pos_x=359,building_pos_y=40,guild_credit_reward=1122,personal_credit_reward=1122,assist_credit_reward=449,side=0,preposition_monster_1=4120,preposition_monster_2=4121,},
{building_id=4126,building_index=7,building_pos_x=393,building_pos_y=73,side=0,preposition_monster_1=4122,preposition_monster_2=4123,},
{building_id=4124,building_index=8,building_pos_x=426,building_pos_y=86,side=0,preposition_monster_1=4126,preposition_monster_2=4126,},
{building_id=4125,building_index=9,building_pos_x=426,building_pos_y=62,side=0,preposition_monster_1=4126,preposition_monster_2=4126,}},

fight_shop={
{image_id=3016001,image_id2=3017001,},
{goods_id=1,name="攻城车（防）",image_id=3018001,image_id2=3019001,},
{goods_id=2,name="修复车",image_id=3020001,image_id2=3021001,},
{type=1,cost_credit=85,param1=300000,param2=3000,name="利刃药剂",},
{type=1,goods_id=1,cost_credit=125,param1=60,param2=100,name="复活药剂",},
{type=2,cost_credit=100,guild_credit_reward=0,personal_credit_reward=0,param1=1500,param2=2000,param4=6,param5=8,param6=5,name="爆裂地雷",image_id=14001001,image_id2=14001001,},
{type=2,goods_id=1,cost_credit=100,guild_credit_reward=0,personal_credit_reward=0,param1=1500,param2=1000,param3=3,param4=6,param5=8,param6=5,name="冰霜地雷",image_id=14002001,image_id2=14002001,}},

relive_shop={
{param1=5000,param2=300,},
{goods_id=1,cost_credit=125,name="传送",},
{goods_id=2,name="传送到中央复活点",}},

skill_list={
{},
{skill_index=2,},
{skill_index=3,},
{skill_index=4,name="元素炮",enemy_num=3,cd_s=60,hurt_percent=750,fix_hurt_on_fight_car=3000,fix_hurt_on_fang_car=3000,fix_hurt_on_cure_car=3000,fix_hurt=4000,icon_res="Zaiju_3",},
{skill_index=5,name="无敌",enemy_num=3,cd_s=60,hurt_percent=0,fix_hurt_on_fight_car=0,fix_hurt_on_fang_car=0,fix_hurt_on_cure_car=0,fix_hurt=0,param_a=3000,icon_res="Zaiju_2",},
{skill_index=6,name="治疗",enemy_num=3,cd_s=60,hurt_percent=0,fix_hurt_on_fight_car=0,fix_hurt_on_fang_car=0,fix_hurt_on_cure_car=0,fix_hurt=0,param_a=4000,param_b=20,icon_res="Zaiju_1",}},

personal_credit_reward={
{},
{reward_index=2,person_credit_min=4000,person_credit_max=5999,},
{reward_index=3,person_credit_min=6000,person_credit_max=7999,item2={item_id=26503,num=4,is_bind=1},},
{reward_index=4,person_credit_min=8000,person_credit_max=9999,banggong=200,item1={item_id=26304,num=2,is_bind=1},item2={item_id=26503,num=4,is_bind=1},},
{reward_index=5,person_credit_min=10000,person_credit_max=11999,banggong=200,item1={item_id=26304,num=2,is_bind=1},item2={item_id=26503,num=6,is_bind=1},},
{reward_index=6,person_credit_min=12000,person_credit_max=13999,banggong=200,item1={item_id=26304,num=2,is_bind=1},item2={item_id=26503,num=6,is_bind=1},},
{reward_index=7,person_credit_min=14000,person_credit_max=15999,banggong=300,item1={item_id=26304,num=3,is_bind=1},item2={item_id=26503,num=8,is_bind=1},},
{reward_index=8,person_credit_min=16000,person_credit_max=37000,banggong=300,item1={item_id=26304,num=4,is_bind=1},item2={item_id=26503,num=8,is_bind=1},}},

guaji_monster={
{},
{monster_id=4022,}},

activity_close_reward={
{banggong=1000,item1={item_id=26314,num=6,is_bind=1},},
{reward_index=1,},
{room_index=1,},
{room_index=1,reward_index=1,banggong=600,item1={item_id=26314,num=4,is_bind=1},},
{room_index=2,banggong=600,item1={item_id=26314,num=4,is_bind=1},},
{room_index=2,reward_index=1,banggong=400,item1={item_id=26314,num=3,is_bind=1},},
{room_index=3,banggong=400,item1={item_id=26314,num=3,is_bind=1},},
{room_index=3,reward_index=1,banggong=200,item1={item_id=26314,num=2,is_bind=1},},
{room_index=4,banggong=200,item1={item_id=26314,num=2,is_bind=1},},
{room_index=4,reward_index=1,banggong=100,item1={item_id=26314,num=1,is_bind=1},}},

player_fix_hurt={
{}},

magic_tower={
{},
{magic_tower_name="红方第一排2",magic_tower_id=4108,},
{magic_tower_name="红方第二排1",magic_tower_id=4109,},
{magic_tower_name="红方第二排2",magic_tower_id=4110,},
{magic_tower_name="红方第三排1",magic_tower_id=4111,},
{magic_tower_name="红方第三排2",magic_tower_id=4112,},
{magic_tower_name="红方第四排1",magic_tower_id=4113,},
{magic_tower_name="红方第四排2",magic_tower_id=4114,},
{magic_tower_name="蓝方第一排1",magic_tower_id=4118,},
{magic_tower_name="蓝方第一排2",magic_tower_id=4119,},
{magic_tower_name="蓝方第二排1",magic_tower_id=4120,},
{magic_tower_name="蓝方第二排2",magic_tower_id=4121,},
{magic_tower_name="蓝方第三排1",magic_tower_id=4122,},
{magic_tower_name="蓝方第三排2",magic_tower_id=4123,},
{magic_tower_name="蓝方第四排1",magic_tower_id=4124,},
{magic_tower_name="蓝方第四排2",magic_tower_id=4125,}},

other_default_table={scene_id=1003,center_relive_point_id=4106,red_fortress_id=4115,blue_fortress_id=4126,attack_notice_interval=30,blue_relive_pos_x=439,blue_relive_pos_y=74,red_relive_pos_x=24,red_relive_pos_y=73,kill_player_credit=83,kill_player_assist_credit=33,kill_player_guild_credit=83,kill_car_credit=83,kill_car_assist_credit=33,assist_vaild_time=10,kill_car_guild_credit=83,ice_landmine_num_limit=5,fire_landmine_num_limit=5,huizhang_extra_reward={[0]={item_id=22205,num=1,is_bind=1}},red_guaji_pos_x=221,red_guaji_pos_y=74,blue_guaji_pos_x=240,blue_guaji_pos_y=74,red_npc_id=4004,blue_npc_id=4001,red_guaji_x=214,red_guaji_y=74,blue_guaji_x=247,blue_guaji_y=74,resurrection_id=4106,lucky_interval=180,lucky_item={item_id=28728,num=1,is_bind=1},luck_people=3,},

building_default_table={building_id=4106,building_index=1,building_pos_x=191,building_pos_y=101,guild_credit_reward=1,personal_credit_reward=1,assist_credit_reward=1,assist_vaild_time=10,side=1,preposition_monster_1=0,preposition_monster_2=0,},

fight_shop_default_table={type=0,goods_id=0,cost_credit=500,guild_credit_reward=1,personal_credit_reward=1,param1=0,param2=0,param3=0,param4=0,param5=0,param6=0,name="攻城车（攻）",image_id="",image_id2="",},

relive_shop_default_table={goods_id=0,cost_credit=1,param1=0,param2=0,param3=0,name="塔无敌",},

skill_list_default_table={skill_index=1,skill_level=1,name="普攻",distance=20,attack_range=20,enemy_num=1,cd_s=1,hurt_percent=250,fix_hurt_on_fight_car=1000,fix_hurt_on_fang_car=1000,fix_hurt_on_cure_car=1000,fix_hurt=1000,param_a=0,param_b=0,param_c=0,param_d=0,icon_res="Zaiju_4",},

personal_credit_reward_default_table={reward_index=1,person_credit_min=2000,person_credit_max=3999,banggong=100,shengwang=0,item1={item_id=26304,num=1,is_bind=1},item2={item_id=26503,num=2,is_bind=1},item3={item_id=0,num=1,is_bind=1},},

guaji_monster_default_table={monster_id=4021,kill_credit_reward=1,},

activity_close_reward_default_table={room_index=0,reward_index=0,banggong=800,shengwang=0,item1={item_id=26314,num=5,is_bind=1},item2={item_id=0,num=1,is_bind=1},item3={item_id=0,num=1,is_bind=1},},

player_fix_hurt_default_table={},

magic_tower_default_table={magic_tower_name="红方第一排1",magic_tower_id=4107,}

}

