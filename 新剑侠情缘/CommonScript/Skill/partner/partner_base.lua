
local tb    = {
    partner_base_attackrate_1 = --初级命中
    {
		attackrate_v={{{1,240},{20,240}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_attackrate_2 = --中级命中
    {
		attackrate_v={{{1,480},{20,480}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_attackrate_3 = --高级命中
    {
		attackrate_v={{{1,720},{20,720}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_defense_1 = --初级闪避
    {
		defense_v={{{1,160},{20,160}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_defense_2 = --中级闪避
    {
		defense_v={{{1,320},{20,320}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_defense_3 = --高级闪避
    {
		defense_v={{{1,480},{20,480}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igdefense_1 = --初级忽闪
    {
		ignore_defense_v={{{1,160},{20,160}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igdefense_2 = --中级忽闪
    {
		ignore_defense_v={{{1,320},{20,320}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igdefense_3 = --高级忽闪
    {
		ignore_defense_v={{{1,480},{20,480}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_wkdeadlystrike_v_1 = --初级减会心
    {
		weaken_deadlystrike_v={{{1,40},{20,40}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_wkdeadlystrike_v_2 = --中级减会心
    {
		weaken_deadlystrike_v={{{1,80},{20,80}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_wkdeadlystrike_v_3 = --高级减会心
    {
		weaken_deadlystrike_v={{{1,160},{20,160}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_recoverlife_1 = --初级回复
    {
		recover_life_v={{{1,150},{20,150}},15*5},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_recoverlife_2 = --中级回复
    {
		recover_life_v={{{1,350},{20,350}},15*5},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_recoverlife_3 = --高级回复
    {
		recover_life_v={{{1,650},{20,650}},15*5},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resisthurt_1 = --初级减受伤
    {
		state_hurt_resistrate={{{1,40},{20,40}}},  		--减几率
		state_hurt_resisttime={{{1,40},{20,40}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resisthurt_2 = --中级减受伤
    {
		state_hurt_resistrate={{{1,80},{20,80}}},  		--减几率
		state_hurt_resisttime={{{1,80},{20,80}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resisthurt_3 = --高级减受伤
    {
		state_hurt_resistrate={{{1,160},{20,160}}},  		--减几率
		state_hurt_resisttime={{{1,160},{20,160}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistslowall_1 = --初级减迟缓
    {
		state_slowall_resistrate={{{1,40},{20,40}}},  		--减几率
		state_slowall_resisttime={{{1,40},{20,40}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistslowall_2 = --中级减迟缓
    {
		state_slowall_resistrate={{{1,80},{20,80}}},  		--减几率
		state_slowall_resisttime={{{1,80},{20,80}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistslowall_3 = --高级减迟缓
    {
		state_slowall_resistrate={{{1,160},{20,160}}},   		--减几率
		state_slowall_resisttime={{{1,160},{20,160}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistzhican_1 = --初级减致缠
    {
		state_zhican_resistrate={{{1,40},{20,40}}},  		--减几率
		state_zhican_resisttime={{{1,40},{20,40}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistzhican_2 = --中级减致缠
    {
		state_zhican_resistrate={{{1,80},{20,80}}},   		--减几率
		state_zhican_resisttime={{{1,80},{20,80}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistzhican_3 = --高级减致缠
    {
		state_zhican_resistrate={{{1,160},{20,160}}},  		--减几率
		state_zhican_resisttime={{{1,160},{20,160}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistpalsy_1 = --初级减麻痹
    {
		state_palsy_resistrate={{{1,40},{20,40}}},  		--减几率
		state_palsy_resisttime={{{1,40},{20,40}}}, 		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistpalsy_2 = --中级减麻痹
    {
		state_palsy_resistrate={{{1,80},{20,80}}},   		--减几率
		state_palsy_resisttime={{{1,80},{20,80}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistpalsy_3 = --高级减麻痹
    {
		state_palsy_resistrate={{{1,160},{20,160}}},   		--减几率
		state_palsy_resisttime={{{1,160},{20,160}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resiststun_1 = --初级减眩晕
    {
		state_stun_resistrate={{{1,40},{20,40}}},  		--减几率
		state_stun_resisttime={{{1,40},{20,40}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resiststun_2 = --中级减眩晕
    {
		state_stun_resistrate={{{1,80},{20,80}}},   		--减几率
		state_stun_resisttime={{{1,80},{20,80}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resiststun_3 = --高级减眩晕
    {
		state_stun_resistrate={{{1,160},{20,160}}},   		--减几率
		state_stun_resisttime={{{1,160},{20,160}}},   		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_deadlystrike_1 = --初级会心
    {
		deadlystrike_v={{{1,80},{20,80}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_deadlystrike_2 = --中级会心
    {
		deadlystrike_v={{{1,160},{20,160}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_deadlystrike_3 = --高级会心
    {
		deadlystrike_v={{{1,300},{20,300}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_damage_1 = --初级攻击
    {
		basic_damage_v={
			[1]={{1,80},{20,80}},
			[3]={{1,80},{20,80}}
			},			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_damage_2 = --中级攻击
    {
		basic_damage_v={
			[1]={{1,160},{20,160}},
			[3]={{1,160},{20,160}}
			},	 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_damage_3 = --高级攻击
    {
		basic_damage_v={
			[1]={{1,300},{20,300}},
			[3]={{1,300},{20,300}}
			},	  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_lifemax_1 = --初级生命
    {
		lifemax_v={{{1,1600},{20,1600}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_lifemax_2 = --中级生命
    {
		lifemax_v={{{1,3200},{20,3200}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_lifemax_3 = --高级生命
    {
		lifemax_v={{{1,6000},{20,6000}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_runspeed_1 = --初级跑速
    {
		runspeed_v={{{1,20},{20,20}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_runspeed_2 = --中级跑速
    {
		runspeed_v={{{1,40},{20,40}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_runspeed_3 = --高级跑速
    {
		runspeed_v={{{1,80},{20,80}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistmetal_1 = --初级金抗
    {
		metal_resist_v={{{1,100},{20,100}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistmetal_2 = --中级金抗
    {
		metal_resist_v={{{1,200},{20,200}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistmetal_3 = --高级金抗
    {
		metal_resist_v={{{1,375},{20,375}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwood_1 = --初级木抗
    {
		wood_resist_v={{{1,100},{20,100}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwood_2 = --中级木抗
    {
		wood_resist_v={{{1,200},{20,200}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwood_3 = --高级木抗
    {
		wood_resist_v={{{1,375},{20,375}}}, 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwater_1 = --初级水抗
    {
		water_resist_v={{{1,100},{20,100}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwater_2 = --中级水抗
    {
		water_resist_v={{{1,200},{20,200}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistwater_3 = --高级水抗
    {
		water_resist_v={{{1,375},{20,375}}}, 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistfire_1 = --初级火抗
    {
		fire_resist_v={{{1,100},{20,100}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistfire_2 = --中级火抗
    {
		fire_resist_v={{{1,200},{20,200}}}, 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistfire_3 = --高级火抗
    {
		fire_resist_v={{{1,375},{20,375}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistearth_1 = --初级土抗
    {
		earth_resist_v={{{1,100},{20,100}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistearth_2 = --中级土抗
    {
		earth_resist_v={{{1,200},{20,200}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_resistearth_3 = --高级土抗
    {
		earth_resist_v={{{1,375},{20,375}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseriesstate_1 = --初级减效果
    {
		resist_allseriesstate_rate_v={{{1,20},{20,20}}},  		--减几率
		resist_allseriesstate_time_v={{{1,20},{20,20}}},  		--减时间
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseriesstate_2 = --中级减效果
    {
		resist_allseriesstate_rate_v={{{1,40},{20,40}}},  		
		resist_allseriesstate_time_v={{{1,40},{20,40}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseriesstate_3 = --高级减效果
    {
		resist_allseriesstate_rate_v={{{1,60},{20,60}}},  		
		resist_allseriesstate_time_v={{{1,60},{20,60}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_steallife_1 = --初级吸血
    {
		steallife_p={{{1,5},{20,5}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_steallife_2 = --中级吸血
    {
		steallife_p={{{1,10},{20,10}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_steallife_3 = --高级吸血
    {
		steallife_p={{{1,15},{20,15}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkhurt_1 = --初级受伤
    {
		state_hurt_normalattack={{{1,50},{20,50}},{{1,15*1},{20,15*1}}},  
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkhurt_2 = --中级受伤
    {
		state_hurt_normalattack={{{1,80},{20,80}},{{1,15*1},{20,15*1}}},			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkhurt_3 = --高级受伤
    {
		state_hurt_normalattack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkslowall_1 = --初级迟缓
    {
		state_slowall_normalattack={{{1,50},{20,50}},{{1,15*1.5},{20,15*1.5}}},	  		 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkslowall_2 = --中级迟缓
    {
		state_slowall_normalattack={{{1,80},{20,80}},{{1,15*1.5},{20,15*1.5}}},	 			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkslowall_3 = --高级迟缓
    {
		state_slowall_normalattack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkzhican_1 = --初级致缠
    {
		state_zhican_normalattack={{{1,50},{20,50}},{{1,15*1},{20,15*1}}},  			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkzhican_2 = --中级致缠
    {
		state_zhican_normalattack={{{1,80},{20,80}},{{1,15*1},{20,15*1}}},	 		 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkzhican_3 = --高级致缠
    {
		state_zhican_normalattack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},					
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkpalsy_1 = --初级麻痹
    {
		state_palsy_normalattack={{{1,50},{20,50}},{{1,15*1},{20,15*1}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkpalsy_2 = --中级麻痹
    {
		state_palsy_normalattack={{{1,80},{20,80}},{{1,15*1},{20,15*1}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkpalsy_3 = --高级麻痹
    {
		state_palsy_normalattack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},	 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkstun_1 = --初级眩晕
    {
		state_stun_normalattack={{{1,50},{20,50}},{{1,15*1},{20,15*1}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkstun_2 = --中级眩晕
    {
		state_stun_normalattack={{{1,80},{20,80}},{{1,15*1},{20,15*1}}},			
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkstun_3 = --高级眩晕
    {
		state_stun_normalattack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},  		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseries_1 = --初级全抗
    {
		all_series_resist_v={{{1,50},{20,50}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseries_2 = --中级全抗
    {
		all_series_resist_v={{{1,100},{20,100}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_allseries_3 = --高级全抗
    {
		all_series_resist_v={{{1,200},{20,200}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igallresist_1 = --初级忽抗
    {
		ignore_all_resist_v={{{1,100},{20,100}},{{1,50},{20,50}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igallresist_2 = --中级忽抗
    {
		ignore_all_resist_v={{{1,100},{20,100}},{{1,100},{20,100}}}, 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_igallresist_3 = --高级忽抗
    {
		ignore_all_resist_v={{{1,100},{20,100}},{{1,200},{20,200}}},   		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_fj_1 = --初级反击
    {
		userdesc_000={1986},
		userdesc_107={{{1,40},{20,40}}},
		autoskill={2,{{1,1},{20,20}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_fj_1_child = --初级反击_子
    {
		attack_usebasedamage_p={{{1,100},{20,100}}},
		missile_hitcount={0,0,3},
    },
    partner_base_fj_2 = --中级反击
    {
		userdesc_000={1989},
		userdesc_107={{{1,40},{20,40}}},		
		autoskill={3,{{1,1},{20,20}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_fj_2_child = --中级反击_子
    {
		attack_usebasedamage_p={{{1,135},{20,135}}},
		missile_hitcount={0,0,3},
    },
    partner_base_fj_3 = --高级反击
    {
		userdesc_000={1992},	
		userdesc_107={{{1,50},{20,50}}},		
		autoskill={4,{{1,1},{20,20}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_fj_3_child = --高级反击_子
    {
		attack_usebasedamage_p={{{1,200},{20,200}}},
		missile_hitcount={0,0,3},
    },
    partner_base_atkspeed_1 = --初级攻速
    {
		attackspeed_v={{{1,20},{20,20}}},  		 		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkspeed_2 = --中级攻速
    {
		attackspeed_v={{{1,40},{20,40}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_atkspeed_3 = --高级攻速
    {
		attackspeed_v={{{1,60},{20,60}}},  				
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_normal_gold1 = --挥砍术
    {
		attack_usebasedamage_p={{{1,260},{20,260}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_water1 = --冰锥术
    {
		attack_usebasedamage_p={{{1,260},{20,260}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_wood1 = --飞镖术
    {
		attack_usebasedamage_p={{{1,260},{20,260}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_fire1 = --火球术
    {
		attack_usebasedamage_p={{{1,260},{20,260}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_earth1 = --雷光术
    {
		attack_usebasedamage_p={{{1,260},{20,260}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_gold2 = --破天斩
    {
		attack_usebasedamage_p={{{1,325},{20,325}}},
		state_npchurt_attack={100,15*1},
		state_hurt_attack={100,15*1},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_water2 = --冰封指
    {
		attack_usebasedamage_p={{{1,325},{20,325}}},
		state_slowall_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_wood2 = --袖里箭
    {
		attack_usebasedamage_p={{{1,325},{20,325}}},
		state_zhican_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_fire2 = --烈焰指
    {
		attack_usebasedamage_p={{{1,325},{20,325}}},
		state_palsy_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_earth2 = --怒雷指
    {
		attack_usebasedamage_p={{{1,325},{20,325}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_gold3 = --半月斩
    {
		attack_usebasedamage_p={{{1,400},{20,400}}},
		attack_steallife_p={{{1,5},{20,5}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_water3 = --惊涛骇浪
    {
	 	userdesc_000={913},
    },
    partner_base_normal_water3_zi = --惊涛骇浪_子
    {
		attack_usebasedamage_p={{{1,400},{20,400}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_wood3 = --穿心刺
    {
		attack_usebasedamage_p={{{1,400},{20,400}}},
		missile_hitcount={0,0,3},
    },
    partner_base_normal_fire3 = --推山填海
    {
		attack_usebasedamage_p={{{1,80},{20,80}}},
    },
    partner_base_normal_earth3 = --九天狂雷
    {
	 	userdesc_000={918},
    },
    partner_base_normal_earth3_zi = --九天狂雷_子
    {
		attack_usebasedamage_p={{{1,200},{20,200}}},
		missile_hitcount={0,0,1}, 
    },
    partner_base_cure = --治愈术
    { 
	 	userdesc_000={922},
		missile_hitcount={0,0,1}, 
    },	
    partner_base_cure_child = --治愈术_子
    { 
		vitality_recover_life={{{1,12},{15,12}},15},
		skill_statetime={{{1,15*5},{15,15*5}}},
    },
    partner_base_mulcure = --群体治愈术
    { 
	 	userdesc_000={924},
		missile_hitcount={0,0,5}, 
    },	
    partner_base_mulcure_child = --群体治愈术_子
    { 
	 	vitality_recover_life={{{1,15},{20,15}},15},
		skill_statetime={{{1,15*5},{15,15*5}}},
    },
    partner_base_baicao = --百草仙露
    { 
	 	userdesc_000={926},
		missile_hitcount={0,0,5}, 
    },	
    partner_base_baicao_child = --百草仙露_子
    { 
	 	vitality_recover_life={{{1,20},{20,20}},15},
	 	ignore_series_state={},
	 	ignore_abnor_state={},
		ignore_skillstate1={927},
		ignore_skillstate2={929},
		skill_statetime={{{1,15*5},{15,15*5}}},
    },
    partner_base_poison = --毒瘴术
    { 
		forbid_recover={1},
		shield_attrib={-50},                            --减掉盾50%的抵伤
		skill_statetime={{{1,15*10},{15,15*10}}},
    },
    partner_base_mulpoison = --群体毒瘴
    { 
	 	userdesc_000={929},
		missile_hitcount={0,0,5}, 
    },	
    partner_base_mulpoison_child = --群体毒瘴_子
    { 
		forbid_recover={1},
		shield_attrib={-50},                            --减掉盾50%的抵伤        
		skill_statetime={{{1,15*10},{15,15*10}}},
    },
    partner_base_jingang  = --金刚护体
    {
		invincible_b={1},
		skill_statetime={{{1,15*4},{20,15*4}}},
    },
    partner_base_muljingang = --群体金刚
    { 
	 	userdesc_000={932},
		missile_hitcount={0,0,5}, 
    },	
    partner_base_muljingang_child = --群体金刚_子
    { 
		invincible_b={1},
		skill_statetime={{{1,15*4},{20,15*4}}},
    },
    partner_base_mingwang  = --不动明王
    {
	 	ignore_series_state={},
	 	ignore_abnor_state={},
		skill_statetime={{{1,15*8},{20,15*8}}},
    },
    partner_base_mulmingwang = --群体明王
    { 
	 	userdesc_000={935},
		missile_hitcount={0,0,5}, 
    },	
    partner_base_mulmingwang_child = --群体明王_子
    { 
	 	ignore_series_state={},
	 	ignore_abnor_state={},
		skill_statetime={{{1,15*12},{20,15*12}}},
    },
    partner_base_kmfc = --枯木逢春
    {
	 	userdesc_000={937},	
		userdesc_107={{{1,50},{20,50}}},
		autoskill={5,{{1,1},{20,20}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_kmfc_child = --枯木逢春_子
    { 
		recover_life_p={{{1,20},{20,20}},15},
		skill_statetime={{{1,14},{20,14}}},
    },	
    partner_base_chongshen = --涅槃重生
    {
		userdesc_000={939},	
		userdesc_107={{{1,50},{20,50}},20},
		userdesc_108={{{1,15*5},{20,15*5}}},
		autoskill={6,{{1,1},{20,20}}},		
		skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_chongshen_child1 = --涅槃重生_子1
    { 
		ignore_series_state={},
	 	ignore_abnor_state={},
		skill_statetime={{{1,15*5},{20,15*5}}},
    },	
    partner_base_chongshen_child2 = --涅槃重生_子2
    { 
		recover_life_p={{{1,20},{20,20}},15},
		skill_statetime={{{1,14},{20,14}}},
    },
    partner_base_xulijian = --蓄力箭
    { 
		attack_usebasedamage_p={{{1,325},{20,325}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
		missile_hitcount={0,0,3},
    },	
    partner_base_gjnl = --青龙分海爪
    { 
        basic_damage_v={
            [1]={{1,400},{20,400}},
            [3]={{1,400},{20,400}}
            }, 
        ignore_defense_v={{{1,600},{20,600}}},  
        deadlystrike_v={{{1,300},{20,300}}},  
        skill_statetime={{{1,-1},{20,-1}}},
    },  
    partner_base_fynl = --玄武大荒钟
    { 
        lifemax_v={{{1,10000},{20,10000}}},  
        defense_v={{{1,600},{20,600}}},   
        resist_allseriesstate_time_v={{{1,100},{20,100}}},  
        skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_jxqg = --金系群攻
    {
        attack_usebasedamage_p={{{1,600},{20,600}}},
        state_hurt_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        state_npchurt_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        missile_hitcount={0,0,3},
    },  
    partner_base_mxqg = --木系群攻
    {
        attack_usebasedamage_p={{{1,600},{20,600}}},
        state_zhican_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        missile_hitcount={0,0,3},
    }, 
    partner_base_sxqg = --水系群攻
    {
        attack_usebasedamage_p={{{1,600},{20,600}}},
        state_slowall_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        missile_hitcount={0,0,3},
    }, 
    partner_base_hxqg = --火系群攻
    {
        attack_usebasedamage_p={{{1,600},{20,600}}},
        state_palsy_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        missile_hitcount={0,0,3},
    }, 
    partner_base_txqg = --八方星雷恸
    {
        attack_usebasedamage_p={{{1,600},{20,600}}},
        state_stun_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        missile_hitcount={0,0,3},
    }, 
    partner_base_gjjingang = --高级群体金刚
    { 
        userdesc_000={3263},
        userdesc_101={{{1,15*4},{20,15*4}}},        --无敌的持续时间
        userdesc_102={{{1,15*5},{20,15*5}}},        --回血的持续时间
        missile_hitcount={0,0,5}, 
    },  
    partner_base_gjjingang_child1 = --高级群体金刚_子1
    { 
        invincible_b={1},
        skill_statetime={{{1,15*4},{20,15*4}}},
    },
    partner_base_gjjingang_child2 = --高级群体金刚_子2
    { 
        vitality_recover_life={{{1,15},{20,15}},15},
        skill_statetime={{{1,15*5},{20,15*5}}},
    },
    partner_base_gjmingwang = --高级群体明王
    { 
        userdesc_000={3253},
        missile_hitcount={0,0,5}, 
    },  
    partner_base_gjmingwang_child = --高级群体明王_子
    { 
        ignore_series_state={},
        ignore_abnor_state={},
        defense_v={{{1,600},{20,600}}},          
        skill_statetime={{{1,15*12},{20,15*12}}},
    },
    partner_base_lhws = --轮回往生
    {
        userdesc_000={3255}, 
        userdesc_107={{{1,80},{20,80}},25},
        userdesc_108={{{1,15*8},{20,15*8}}},
        autoskill={30,{{1,1},{20,20}}},      
        skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_lhws_child1 = --轮回往生_子1
    { 
        ignore_series_state={},
        ignore_abnor_state={},
        basic_damage_v={
            [1]={{1,300},{20,300}},
            [3]={{1,300},{20,300}}
            },  
        skill_statetime={{{1,15*8},{20,15*8}}},
    },  
    partner_base_lhws_child2 = --轮回往生_子2
    { 
        recover_life_p={{{1,25},{20,25}},15},
        skill_statetime={{{1,14},{20,14}}},
    },
    partner_base_ptyj = --破天一击
    { 
        dotdamage_maxlife_p={{{1,20},{20,20}},15,30000},        --掉血百分比，debuff每间隔帧掉血，每次掉血上限
        skill_statetime={{{1,1},{30,1}}},                       --debuff持续时间 填的短代表只掉血1次
        state_knock_attack={100,10,70},
        state_npcknock_attack={100,10,70}, 
        spe_knock_param={6 , 4, 4},         --停留时间，角色动作ID，NPC动作ID  
        state_fixed_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},      
        missile_hitcount={0,0,3},      
    },
    partner_base_sfjj = --十方俱静
    { 
        rand_ignoreskill={{{1,100},{20,100}},1,1},       --概率，数量，类型（skillsetting下定义类型）
        missile_hitcount={0,0,4}, 
    },
    partner_base_gjpoison = --高级群体毒瘴
    { 
        userdesc_000={3262},
        missile_hitcount={0,0,5}, 
    },  
    partner_base_gjpoison_child = --高级群体毒瘴_子
    { 
        forbid_recover={1},
        shield_attrib={-50},                            --减掉盾50%的抵伤        
        all_series_resist_v={{{1,-500},{20,-500}}},                                   
        skill_statetime={{{1,15*10},{15,15*10}}},
    },
    partner_base_bscfwd = --濒死触发无敌
    { 
        invincible_b={1},
        skill_statetime={{{1,1},{20,1}}},
    },

    partner_base_4s_qlztt = --青龙遮天体
    { 
        basic_damage_v={
            [1]={{1,600},{20,600}},
            [3]={{1,600},{20,600}}
            }, 
        ignore_defense_v={{{1,900},{20,900}}},  
        deadlystrike_v={{{1,450},{20,450}}},  
        deadlystrike_damage_p={{{1,30},{20,30}}}, 
        skill_statetime={{{1,-1},{20,-1}}},
    },  
    partner_base_4s_xwyyj = --玄武御阳甲
    { 
        lifemax_v={{{1,15000},{20,15000}}},  
        defense_v={{{1,900},{20,900}}},   
        resist_allseriesstate_time_v={{{1,150},{20,150}}},  
        steallife_resist_p={{{1,30},{20,30}}},
        skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_4s_qmzn = --启明之怒
    {
        attack_usebasedamage_p={{{1,300},{20,300}}},
        state_hurt_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},        
        state_npchurt_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},  
        userdesc_000={5704},      
        missile_hitcount={0,0,3},
    },  
    partner_base_4s_qmzn_child = --启明之怒_增加受伤几率与时间
    {
        state_hurt_attackrate={{{1,500},{20,500}}},
        state_hurt_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_gmhj = --句芒唤荆
    {
        attack_usebasedamage_p={{{1,300},{20,300}}},
        state_zhican_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},  
        userdesc_000={5706},      
        missile_hitcount={0,0,3},
    }, 
    partner_base_4s_gmhj_child = --句芒唤荆_增加致缠几率与时间
    {
        state_zhican_attackrate={{{1,500},{20,500}}},
        state_zhican_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_nskt = --怒霜狂滔
    {
        attack_usebasedamage_p={{{1,300},{20,300}}},
        state_slowall_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},  
        userdesc_000={5708},        
        missile_hitcount={0,0,3},
    }, 
    partner_base_4s_nskt_child = --怒霜狂滔_增加迟缓几率与时间
    {
        state_slowall_attackrate={{{1,500},{20,500}}},
        state_slowall_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_fthj = --焚天火祭
    {
        attack_usebasedamage_p={{{1,300},{20,300}}},
        state_palsy_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},   
        userdesc_000={5710},       
        missile_hitcount={0,0,3},
    }, 
    partner_base_4s_fthj_child = --焚天火祭_增加麻痹几率与时间
    {
        state_palsy_attackrate={{{1,500},{20,500}}},
        state_palsy_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_ddmd = --大地蟒动
    {
        attack_usebasedamage_p={{{1,300},{20,300}}},
        state_stun_attack={{{1,100},{20,100}},{{1,15*1.5},{20,15*1.5}}},    
        userdesc_000={5712},     
        missile_hitcount={0,0,3},
    }, 
    partner_base_4s_ddmd_child = --大地蟒动_增加眩晕几率与时间
    {
        state_stun_attackrate={{{1,500},{20,500}}},
        state_stun_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_cqjg = --超群金刚
    { 
        userdesc_000={5715},
        userdesc_101={{{1,15*4},{20,15*4}}},        --无敌的持续时间
        userdesc_102={{{1,15*6},{20,15*6}}},        --回血的持续时间
        missile_hitcount={0,0,5}, 
    },  
    partner_base_4s_cqjg_child1 = --超群金刚_子1
    { 
        invincible_b={1},
        skill_statetime={{{1,15*4},{20,15*4}}},
    },
    partner_base_4s_cqjg_child2 = --超群金刚_子2
    { 
        vitality_recover_life={{{1,22},{20,22}},15},
        physics_potentialdamage_p={{{1,30},{20,30}}},
        skill_statetime={{{1,15*6},{20,15*6}}},
    },
    partner_base_4s_cqmw = --超群明王
    { 
        userdesc_000={5717},
        missile_hitcount={0,0,5}, 
    },  
    partner_base_4s_cqmw_child = --超群明王_子
    { 
        ignore_series_state={},
        ignore_abnor_state={},
        defense_v={{{1,900},{20,900}}},          
        deadlystrike_damage_p={{{1,10},{20,10}}},      
        skill_statetime={{{1,15*12},{20,15*12}}},
    },
    partner_base_4s_ldlh = --六道轮回
    {
        userdesc_000={5719}, 
        userdesc_107={{{1,100},{20,100}},30},
        userdesc_108={{{1,15*8},{20,15*8}}},
        autoskill={32,{{1,1},{20,20}}},      
        skill_statetime={{{1,-1},{20,-1}}},
    },
    partner_base_4s_ldlh_child1 = --六道轮回_子1
    { 
        ignore_series_state={},
        ignore_abnor_state={},
        basic_damage_v={
            [1]={{1,500},{20,500}},
            [3]={{1,500},{20,500}}
            }, 
        reduce_cd_time_point1={953,20*15},            --减张三丰天赋技能    
        skill_statetime={{{1,15*8},{20,15*8}}},
    },  
    partner_base_4s_ldlh_child2 = --六道轮回_子2
    { 
        recover_life_p={{{1,30},{20,30}},15},
        skill_statetime={{{1,14},{20,14}}},
    },
    partner_base_4s_ptjy = --破天惊月
    { 
        dotdamage_maxlife_p={{{1,15},{20,15}},15,45000},        --掉血百分比，debuff每间隔帧掉血，每次掉血上限
        skill_statetime={{{1,1},{30,1}}},                       --debuff持续时间 填的短代表只掉血1次
        state_confuse_attack={{{1,100},{20,100}},{{1,15*3},{20,15*3}}},  
        userdesc_000={5723}, 
        missile_hitcount={0,0,3},      
    },
    partner_base_4s_ptjy_child = --破天惊月_增加混乱几率与时间
    {
        state_confuse_attackrate={{{1,500},{20,500}}},
        state_confuse_attacktime={{{1,300},{20,300}}},
        skill_statetime={{{1,-1},{20,-1}}},
    }, 
    partner_base_4s_bnjm = --百念惧灭
    { 
        rand_ignoreskill={{{1,100},{20,100}},2,1},       --概率，数量，类型（skillsetting下定义类型）enhance_final_damage_p
        userdesc_000={5725}, 
        missile_hitcount={0,0,5}, 
    },
    partner_base_4s_bnjm_child = --百念惧灭_降伤害放大
    { 
        enhance_final_damage_p={{{1,-5},{20,-5}}},       --降低最终伤害放大
        skill_statetime={{{1,15*10},{20,15*10}}}, 
    },
    partner_base_4s_dlew = --毒泷恶雾
    { 
        userdesc_000={5727},
        missile_hitcount={0,0,5}, 
    },  
    partner_base_4s_dlew_child = --毒泷恶雾_子
    { 
        forbid_recover={1},
        shield_attrib={-50},                            --减掉盾50%的抵伤     
        all_series_resist_v={{{1,-750},{20,-750}}},    
        reduce_final_damage_p={{{1,-5},{20,-5}}},       --降低最终伤害抵消                    
        skill_statetime={{{1,15*10},{15,15*10}}},
    },
    partner_base_4s_cjpk = --穿甲破铠
    { 
        --ignore_invincible_rate={0,80},                  --忽略无敌的类型，忽略几率   
        userdesc_101={0,80},                            --描述用
        skill_statetime={{{1,15*10},{20,15*10}}},
    },
    partner_base_4s_dj = --断汲
    { 
        steallife_resist_p={{{1,40},{20,40}}},
        userdesc_101={{{1,50},{20,50}}},  
        userdesc_102={{{1,10},{20,10}}},     
        skill_statetime={{{1,15*10},{20,15*10}}},
    },
    partner_base_4s_dj_child = --断汲_玩家
    { 
        steallife_resist_p={{{1,10},{20,10}}},
        skill_statetime={{{1,15*10},{20,15*10}}},
    },
}

FightSkill:AddMagicData(tb)