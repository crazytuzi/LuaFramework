
local tb    = {
	partner_normal=
    { 
		attack_usebasedamage_p={{{1,100},{20,130}}},
		state_npchurt_attack={50,9},
		missile_hitcount={0,0,1},
    },
	partner_normal_hurt=
    { 
		attack_usebasedamage_p={{{1,100},{20,130}}},
		state_npchurt_attack={100,9},
    },
	partner_heavy1=
    { 
		attack_usebasedamage_p={{{1,150},{20,200}}},
		state_npchurt_attack={100,9},
		missile_hitcount={0,0,5},
    },
	partner_heavy2=
    { 
		attack_usebasedamage_p={{{1,150},{20,200}}},
		state_npchurt_attack={100,9},
		missile_hitcount={0,0,5},
    },
	partner_normal_c= 	--C级同伴普攻
    { 
		attack_usebasedamage_p={{{1,60},{20,80}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_b=	--B级同伴普攻
    { 
		attack_usebasedamage_p={{{1,80},{20,100}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_b2=	--B级同伴普攻2
    { 
		attack_usebasedamage_p={{{1,160},{20,200}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_a=	--A级同伴普攻
    { 
		attack_usebasedamage_p={{{1,100},{20,120}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_s=	--S级同伴普攻
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_s2=	--S级同伴普攻2
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},
		missile_hitcount={0,0,1},
    },
	partner_normal_ss=	--SS级同伴普攻
    { 
		attack_usebasedamage_p={{{1,130},{20,150}}},
		missile_hitcount={0,0,1},
    },
	partner_heavy_c=	--C级同伴重击
    { 
		attack_usebasedamage_p={{{1,257},{20,257}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_b=	--B级同伴重击
    { 
		attack_usebasedamage_p={{{1,160},{20,200}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_b2=	--B级同伴重击2次伤害
    { 
		attack_usebasedamage_p={{{1,90},{20,120}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_b3=	--B级同伴重击3次伤害
    { 
		attack_usebasedamage_p={{{1,60},{20,80}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_a=	--A级同伴重击
    { 
		attack_usebasedamage_p={{{1,200},{20,240}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_a2=	--A级同伴重击2次伤害
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_a3=	--A级同伴重击3次伤害
    { 
		attack_usebasedamage_p={{{1,70},{20,90}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_a6=	--A级同伴重击6次伤害
    { 
		attack_usebasedamage_p={{{1,70},{20,90}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_s=	--S级同伴重击
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_s2=	--S级同伴重击2次伤害
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_s3=	--S级同伴重击3次伤害
    { 
		attack_usebasedamage_p={{{1,100},{20,120}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_s6=	--S级同伴重击6次伤害
    { 
		attack_usebasedamage_p={{{1,50},{20,70}}},
		missile_hitcount={0,0,3},
    },
	partner_heavy_ss=	--SS级同伴重击
    { 
		attack_usebasedamage_p={{{1,260},{20,300}}},
		missile_hitcount={0,0,3},
    },
    partner_up_a5 = --A级同伴全抗、闪避、命中、会心
    {
		all_series_resist_v={{{1,5},{20,15}}},
		defense_v={{{1,20},{20,60}}},
		attackrate_v={{{1,40},{20,120}}},
		deadlystrike_v={{{1,10},{20,30}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_up_a6 = --A级同伴生命、攻击力
    {
		lifemax_v={{{1,400},{20,1200}}},
		physical_damage_v={
			[1]={{1,20},{20,60}},
			[3]={{1,20},{20,60}}
			},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_up_a7 = --A级同伴攻击、命中、会心
    {
		physical_damage_v={
			[1]={{1,20},{20,60}},
			[3]={{1,20},{20,60}}
			},	
		attackrate_v={{{1,40},{20,120}}},
		deadlystrike_v={{{1,10},{20,30}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_share_s1 = --S级同伴全抗
    {
		all_series_resist_v={{{1,20},{20,60}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s2 = --S级同伴攻击力
    {
		physical_damage_v={
			[1]={{1,40},{20,120}},
			[3]={{1,40},{20,120}}
			},	
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s3 = --S级同伴命中、会心
    {
		attackrate_v={{{1,80},{20,240}}},
		deadlystrike_v={{{1,20},{20,60}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s4 = --S级同伴全抗、闪避
    {
		all_series_resist_v={{{1,10},{20,30}}},
		defense_v={{{1,40},{20,120}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s5 = --S级同伴全抗、闪避、命中、会心
    {
		all_series_resist_v={{{1,5},{20,15}}},
		defense_v={{{1,20},{20,60}}},
		attackrate_v={{{1,40},{20,120}}},
		deadlystrike_v={{{1,10},{20,30}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s6 = --S级同伴全抗、攻击力
    {
		all_series_resist_v={{{1,10},{20,30}}},
		physical_damage_v={
			[1]={{1,20},{20,60}},
			[3]={{1,20},{20,60}}
			},	
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s7 = --S级同伴攻击、命中、会心
    {
		physical_damage_v={
			[1]={{1,20},{20,60}},
			[3]={{1,20},{20,60}}
			},	
		attackrate_v={{{1,40},{20,120}}},
		deadlystrike_v={{{1,10},{20,30}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    partner_share_s8 = --S级同伴恢复生命
    {
		recover_life_v={{{1,200},{20,600}},15*5},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    partner_share_s9 = --S级同伴临时第四技能…加力量
    {
		strength_v={{{1,20},{20,40}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    partner_share_s10 = --S级同伴临时第四技能…加体质
    {
		vitality_v={{{1,20},{20,40}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    partner_share_s11 = --S级同伴临时第四技能…加敏捷
    {
		dexterity_v={{{1,20},{20,40}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    partner_share_s12 = --S级同伴临时第四技能…加灵巧
    {
		energy_v={{{1,20},{20,40}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    partner_share_ss1 = --S级同伴攻击力、全抗、闪避
    {
		physical_damage_v={
			[1]={{1,40},{20,120}},
			[3]={{1,40},{20,120}}
			},	
		all_series_resist_v={{{1,10},{20,30}}},
		defense_v={{{1,40},{20,120}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	userdesc_1266=
    { 
		userdesc_000={1266},
    },
	userdesc_1279=
    { 
		userdesc_000={1279},
    },
	userdesc_2592=
    { 
		userdesc_000={2592},
    },
	partner2_1 = --慕容越-五星连珠
    { 
		attack_usebasedamage_p={{{1,90},{20,120}}},
		missile_hitcount={0,0,3},
    },
	partner3_1 = --徐铁心-重拳三连击
    { 
		attack_usebasedamage_p={{{1,60},{20,80}}},
		missile_hitcount={0,0,3},
    },
    partner4_2 = --苏墨芸-剑阵
    { 
		recover_life_v={{{1,100},{30,1000},{31,1000}},15},
		physics_potentialdamage_p={{{1,11},{30,40}}},			
		skill_statetime={{{1,20},{30,20}}},
    },
    partner4_3 = --苏墨芸被动属性
    {
		all_series_resist_v={{{1,50},{30,200}}},
		lifemax_p={{{1,35},{30,50}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner4_4 = --苏墨芸-飞斩
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
		missile_hitcount={0,0,3},
    },
	userdesc_1294=
    { 
		userdesc_000={1294},
    },
	partner5_4= --姬御天-排山倒海
    { 
		attack_usebasedamage_p={{{1,150},{20,250}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		missile_hitcount={0,0,3},
    },
	userdesc_2503= --满城花雨
    { 
		userdesc_000={2503},
    },
	userdesc_2503_child= --满城花雨_子
    { 
		attack_usebasedamage_p={{{1,100},{20,120}}},
		missile_hitcount={0,0,3},
    },
	partner6_3 = --紫轩被动属性
    {
		physics_potentialdamage_p={{{1,11},{30,40}}},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
	userdesc_2506=
    { 
		userdesc_000={2506},
    },
	partner6_4_child1 = --紫轩-燕舞_子1
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,35},{30,35}},{{1,15*0.5},{30,15*0.5}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	partner6_4_child2 = --紫轩-燕舞_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
	partner7_2 = --蔷薇-连环星月
    { 
		attack_usebasedamage_p={{{1,100},{20,120}}},
		missile_hitcount={{{1,3},{20,3}}},			
    },
	partner7_3 = --蔷薇被动属性
    {
		attackspeed_v={{{1,1},{30,30}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner7_4 = --蔷薇-连环三星月
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	partner8_2= --哲别-铁骑突袭
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,8,40},
		state_npcknock_attack={100,8,40},
		spe_knock_param={3 , 4, 4},			--停留时间，角色动作ID，NPC动作ID
		missile_hitcount={0,0,3},
    },
	partner8_3= --哲别-共享属性
    { 
	 	deadlystrike_v={{{1,100},{30,300}}},
		skill_statetime={{{1,15*30},{30,15*30}}},			
    },
	partner9_3= --袁承志-共享属性
    { 
		physics_potentialdamage_p={{{1,11},{30,40}}},	
		skill_statetime={{{1,15*30},{30,15*30}}},			
    },
	partner9_4 = --袁承志-太乙生风
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_float_attack={{{1,100},{30,100},{31,100}},{{1,15*3},{30,15*3},{31,15*3}}},
		missile_hitcount={0,0,3},
    },
	userdesc_2526= --叶无心-旋扇
    { 
		userdesc_000={2526},
    },
	partner10_2 = --叶无心-旋扇
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		missile_hitcount={0,0,3},
    },
	partner10_3= --叶无心-共享属性
    { 
		deadlystrike_v={{{1,11},{30,40}}},	
		deadlystrike_damage_p={{{1,11},{30,40}}},	
		skill_statetime={{{1,15*30},{30,15*30}}},		
    },
	partner11_2 = --薛银药-劈空掌
    { 
		attack_usebasedamage_p={{{1,150},{20,280}}},
		userdesc_000={2554},
		missile_hitcount={0,0,3},		
    },
	partner11_2_child = --薛银药-劈空掌_子
	{ 
		all_series_resist_v={{{1,-100},{20,-300}}},	
		skill_statetime={{{1,15*10},{20,15*10}}},
	},	
	userdesc_2530= --薛银药-毒
    { 
		userdesc_000={2530},
    },
	partner11_3 = --薛银药-毒
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		missile_hitcount={0,0,3},
    },
	partner12_3 = --狼王被动属性
    {
		attackrate_v={{{1,11},{30,40}}},	
		deadlystrike_v={{{1,11},{30,40}}},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
	userdesc_2537= --大地狼王-瞬身撕咬
    { 
		userdesc_000={2537},
    },
    partner12_4= --大地狼王-瞬身撕咬
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	userdesc_2542= --奔焰豹王-烈焰奔袭
    { 
		userdesc_000={2542},
    },
    partner13_2= --奔焰豹王-烈焰奔袭
    { 
		attack_usebasedamage_p={{{1,70},{30,70}}},
		missile_hitcount={{{1,6},{20,6}}},
    },
	partner13_3 = --豹王被动属性
    {
		defense_v={{{1,11},{30,40}}},	
		all_series_resist_v={{{1,11},{30,40}}},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner13_4= --奔焰豹王-天火烈爪
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	partner14_3 = --狐王被动属性
    {
		defense_v={{{1,11},{30,40}}},	
		all_series_resist_v={{{1,11},{30,40}}},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
	userdesc_2550= --九尾狐王-影风斩
    { 
		userdesc_000={2550},
    },
	partner14_4 = --九尾狐王-影风斩
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 	
		missile_hitcount={0,0,3},		
    },
	userdesc_2556= --九尾狐王-影风斩
    { 
		userdesc_000={2556},
    },
	partner15_4 = --寒玉鹿王-寒冰冲顶
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
		missile_hitcount={0,0,3},		
    },
	partner18_2= --秦沐白-怒风
    { 
		dotdamage_wood={{{1,70},{20,90}},{{1,0},{30,0}},{{1,8},{30,8}}},
		state_float_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
		missile_hitcount={0,0,3},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
	partner18_4 = --秦沐白-龙卷风
    { 
		attack_usebasedamage_p={{{1,100},{20,130}}},
		missile_hitcount={0,0,3},		
    },
	partner19_2 = --纳兰潜凛-剑刺
    { 
		attack_usebasedamage_p={{{1,100},{20,130}}},
		missile_hitcount={0,0,3},			
    },
	partner19_4 = --纳兰潜凛-重剑破尘
    { 
		attack_usebasedamage_p={{{1,150},{20,200}}},
		state_npchurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	partner20_2 = --卓非凡-飞剑
    { 
		attack_usebasedamage_p={{{1,200},{20,240}}},
		missile_hitcount={0,0,3},			
    },
	partner20_4 = --卓非凡-剑雨
    { 
		attack_usebasedamage_p={{{1,150},{20,200}}},
		state_npchurt_attack={100,9},
		missile_hitcount={0,0,3},
    },
	partner21_1 = --沐紫衣-暗刺
    { 
		attack_usebasedamage_p={{{1,300},{20,400}}},	
		missile_hitcount={0,0,3},	
    },
	userdesc_2627 = --霹雳火-暗刺
    { 
		userdesc_000={2627},
    },
	partner25_1 = --月眉儿-慈航普度
	{ 
	 	userdesc_000={2643},
		missile_hitcount={0,0,1},
	},	
	partner25_1_child = --月眉儿-慈航普度_子
	{ 
	 	vitality_recover_life={{{1,20*2},{30,20*10}},15},
		skill_statetime={{{1,15*5},{30,15*5}}},
	},
	partner26_1 = --涌泉
    { 
		attack_usebasedamage_p={{{1,70},{20,70}}},	
		missile_hitcount={0,0,3},
    },
	partner26_1 = --涌泉
    { 
		attack_usebasedamage_p={{{1,70},{20,70}}},	
		missile_hitcount={0,0,3},
    },
	partner28_1= --开天劈地
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},  
		state_knock_attack={100,12,20},
		state_npcknock_attack={100,12,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
		missile_hitcount={0,0,3},		
    },
	partner29_1 = --霸风
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},
		state_knock_attack={100,12,20},
		state_npcknock_attack={100,12,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID		
		missile_hitcount={0,0,3},	
    },
	partner31_1 = --无敌斩
    { 
	 	userdesc_000={2682},
    },	
	partner31_1_child = --无敌斩
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},		
		missile_hitcount={0,0,3},	
    },
	partner33_1 = --玄冥吸星
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},	
		state_drag_attack={{{1,100},{30,100}},8,70},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
		missile_hitcount={0,0,3},			
    },
	partner34_1 = --怒风破袭
    { 
		attack_usebasedamage_p={{{1,120},{20,140}}},	
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		missile_hitcount={0,0,3},			
    },
	partner35_1 = --岳飞-怒海戟
    { 
		attack_usebasedamage_p={{{1,400},{20,480}}},	
		state_stun_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		missile_hitcount={0,0,3}, 			
    },
	partner36_1= --碧海潮生
    { 
		attack_usebasedamage_p={{{1,100},{20,120}}},
		missile_hitcount={0,0,3},
    },
	partner38_1 = --夺魂链
    { 
		attack_usebasedamage_p={{{1,260},{20,300}}},
		state_drag_attack={{{1,100},{30,100}},12,60},
		skill_drag_npclen={50},
		userdesc_000={2845},
    },
	partner38_1_child = --夺魂链_子
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
	userdesc_2849= --天蛊毒尸-毒
    { 
		userdesc_000={2849},
    },
	partner40_1 = --玄天真人-八卦阵
    { 
		userdesc_000={2855},		
    },
	partner40_1_child = --玄天真人-八卦阵
    { 
		attack_usebasedamage_p={{{1,260},{20,300}}},	
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		missile_hitcount={0,0,3}, 			
    },
    partner_juexing = --同伴觉醒
    {
		userdesc_101={1},
		skill_statetime={{{1,-1},{20,-1}}},
    },
}

FightSkill:AddMagicData(tb)