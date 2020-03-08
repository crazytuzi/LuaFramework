
local tb    = {
	npc_normal=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
    },
	npc_normal_hurt=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_normal_heavy=
    { 
		attack_usebasedamage_p={{{1,200},{30,490}}},
    },
	npc_300_10=
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
	npc_normal_gold1=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_npchurt_attack={30,9},
		state_hurt_attack={30,9},
    },
	npc_normal_wood1=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_zhican_attack={{{1,30},{30,30}},{{1,15*2},{30,15*2}}},
    }, 
	npc_normal_water1=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_slowall_attack={{{1,30},{30,30}},{{1,15*2},{30,15*2}}},
    },
	npc_normal_fire1=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_palsy_attack={{{1,30},{30,30}},{{1,15*2},{30,15*2}}},
    },
	npc_normal_earth1=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_stun_attack={{{1,30},{30,30}},{{1,15*2},{30,15*2}}},
    },	
	npc_sp_gold=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={{{1,30},{10,100}},35,30},
		state_npcknock_attack={{{1,30},{10,100}},35,30}, 
		spe_knock_param={26 , 26, 26},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_sp_wood=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_float_attack={{{1,30},{10,100}},{{1,15*3},{30,15*3}}},
    }, 
	npc_sp_water=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_freeze_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_sp_fire=
    { 
		attack_usebasedamage_p={{{1,200},{2,100},{3,200}}},
		state_confuse_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_sp_earth=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },	
	npc_sp_gold2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_knock_attack={{{1,30},{10,30}},35,30},
		state_npcknock_attack={{{1,30},{10,30}},35,30}, 
		spe_knock_param={26 , 26, 26},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_sp_wood2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_float_attack={{{1,30},{10,30}},{{1,15*5},{30,15*5}}},
    }, 
	npc_sp_water2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_freeze_attack={{{1,30},{10,30}},{{1,15*5},{30,15*5}}},
    },
	npc_sp_fire2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_confuse_attack={{{1,30},{10,30}},{{1,15*5},{30,15*5}}},
    },
	npc_sp_earth2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_stun_attack={{{1,30},{10,30}},{{1,15*5},{30,15*5}}},
    },	
	npc_heavy1=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={{{1,5},{30,5}}},
    },
	npc_heavy2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		missile_hitcount={{{1,5},{30,5}}},
    },
	npc_shanghui=
    { 
		attack_usebasedamage_p={{{1,10},{30,10}}},
    },
	npc_xianjing=
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_zibao=
    { 
		attack_usebasedamage_p={{{1,200},{30,780}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_control_gold1=
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={{{1,30},{10,100},{11,100}},9},
		state_hurt_attack={{{1,30},{10,100},{11,100}},9},
    },
	npc_control_wood1=
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_zhican_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    }, 
	npc_control_water1=
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_slowall_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_fire1=
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_palsy_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_earth1=
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_stun_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },	
	npc_control_gold2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={{{1,30},{10,100},{11,100}},9},
		state_hurt_attack={{{1,30},{10,100},{11,100}},9},
    },
	npc_control_wood2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_zhican_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_water2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_slowall_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_fire2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_palsy_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_earth2=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_control_gold3=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_npchurt_attack={{{1,30},{10,30}},9},
		state_hurt_attack={{{1,30},{10,30}},9},
    },
	npc_control_wood3=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_zhican_attack={{{1,30},{10,30}},{{1,15*5},{10,15*5},{11,15*5}}},
    }, 
	npc_control_water3=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_slowall_attack={{{1,30},{10,30}},{{1,15*5},{10,15*5},{11,15*5}}},
    },
	npc_control_fire3=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_palsy_attack={{{1,30},{10,30}},{{1,15*5},{10,15*5},{11,15*5}}},
    },
	npc_control_earth3=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_stun_attack={{{1,30},{10,30}},{{1,15*5},{10,15*5},{11,15*5}}},
    },	
	npc_mianyi = --BOSS免疫受伤；抗属性、负面时间增加
    { 
		resist_allseriesstate_time_v={{{1,300},{2,300},{30,3000}}},		--抗属性时间
		resist_allspecialstate_time_v={{{1,300},{2,300},{30,3000}}},	--抗负面时间
		state_npchurt_ignore={1},									--免疫NPC受伤状态
		state_npcknock_ignore={1},									--免疫NPC击退状态
		state_stun_ignore={1},										--免疫眩晕状态
		state_zhican_ignore={1},									--免疫致残状态
		state_slowall_ignore={1},									--免疫迟缓状态
		state_palsy_ignore={1},										--免疫麻痹状态
		state_float_ignore={1},										--免疫浮空状态		
		damage4npc_p={{{1,-25},{2,-67},{3,-100},{30,-100}}},					--减少对同伴的攻击伤害,正数为1+p,负数为:1/(1-p),-100为1/2
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_mianyi_p = --BOSS免疫受伤；抗属性、负面时间增加
    { 
		spe_npchurt={100,12},
		resist_allseriesstate_time_v={{{1,300},{2,300},{30,3000}}},		--抗属性时间
		resist_allspecialstate_time_v={{{1,300},{2,300},{30,3000}}},	--抗负面时间
		state_npchurt_ignore={1},									--免疫NPC受伤状态
		state_npcknock_ignore={1},									--免疫NPC击退状态
		state_stun_ignore={1},										--免疫眩晕状态
		state_zhican_ignore={1},									--免疫致残状态
		state_slowall_ignore={1},									--免疫迟缓状态
		state_palsy_ignore={1},										--免疫麻痹状态
		damage4npc_p={{{1,-25},{2,-67},{3,-100},{30,-100}}},					--减少对同伴的攻击伤害,正数为1+p,负数为:1/(1-p),-100为1/2
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_jueduimianyi = --npc绝对免疫
    { 
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		damage4npc_p={{{1,-25},{2,-67},{3,-100},{30,-100}}},					--减少对同伴的攻击伤害,正数为1+p,负数为:1/(1-p),-100为1/2
		skill_statetime={{{1,-1},{30,-1}}},
    },
	partner_mianyi = --同伴免疫受伤
    { 
		state_npchurt_ignore={1},									--免疫NPC受伤状态
		state_npcknock_ignore={1},									--免疫NPC击退状态
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_yujingmianyi = --npc预警免疫效果2.5秒
    { 
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*3},{30,15*3}}},
    },	
	ignore_allknock = --免疫所有击退
    { 
		state_knock_ignore={1},									--免疫击退状态
		state_npcknock_ignore={1},								--免疫NPC击退状态
		skill_statetime={{{1,-1},{30,-1}}},
    },
	resist_npchurtknock = --增加防受伤、击退概率
    { 
		state_npchurt_resistrate={{{1,200},{30,300}}}, 									
		state_npcknock_resistrate={{{1,200},{30,300}}},									
		skill_statetime={{{1,-1},{30,-1}}},
    },
	wlmz_1 =  --独孤剑普攻
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	wlmz_2 = --独孤剑天外飞仙
    { 
		attack_usebasedamage_p={{{1,260},{20,260}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_3 = --独孤剑苍蓝雨剑
    { 
		attack_usebasedamage_p={{{1,2000},{20,2000}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },	
	wlmz_ngfy_1 =  --南宫飞云普攻
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	wlmz_ngfy_2 = --南宫飞云梦蝶剑
    { 
		attack_usebasedamage_p={{{1,600},{20,600}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_ngfy_3 = --南宫飞云花飞蝴蝶剑
    { 
		attack_usebasedamage_p={{{1,200},{20,200}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_yyf_1 =  --杨影枫普攻
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	wlmz_yyf_2 = --杨影枫烈火情天
    { 
		attack_usebasedamage_p={{{1,600},{20,600}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_yyf_3= --杨影枫-镇狱破天劲
    { 
		defense_v={{{1,500},{20,500}}},			
		autoskill={19,{{1,1},{10,10},{31,10}}},
		skill_statetime={{{1,-1},{15,-1}}},		
    },
	wlmz_yyf_3_child1= --杨影枫-镇狱破天劲_子
    { 					
		buff_end_castskill={1767,{{1,1},{10,10}}},
		physics_potentialdamage_p={{{1,50},{20,50}}},
		skill_statetime={{{1,15*3},{15,15*3}}},
    },
	wlmz_yyf_3_child2= --杨影枫-镇狱破天劲_子
    { 
		attack_usebasedamage_p={{{1,500},{20,500}}},
    },
	wlmz_tj_1 =  --唐简普攻
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	wlmz_tj_2 = --唐简九宫飞星
    { 
		attack_usebasedamage_p={{{1,120},{20,120}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_tj_3 = --唐简穿心镖
    { 
		attack_usebasedamage_p={{{1,400},{20,400}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	wlmz_ggz_1 =  --鬼谷子普攻
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	wlmz_ggz_2 = --鬼谷子合纵连横
    { 
		attack_usebasedamage_p={{{1,600},{20,600}}},
		state_hurt_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},		
    },
	npc_100beiji = --100%被击中
    { 
		certainly_hit={},						
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_xianjing_2=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
    },
	npc_50life=
    { 
		autoskill={94,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_50life_child =
    { 
		recover_life_p={{{1,10},{30,10}},7},
		skill_statetime={{{1,43},{30,43}}},
    },
	npc_bswd =
    { 
		autoskill={95,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
	npc_qpzd =
    { 
		autoskill={7,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
    npc_qpfire =
    { 
		autoskill={14,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	npc_30_10 =  
    { 
		attack_usebasedamage_p={{{1,30},{30,320}}},
    },
	npc_jushikeng =  --巨石坑
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 	
    },
	npc_gunshi=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},
		state_knock_attack={{{1,100},{10,100}},7,20},
		state_npcknock_attack={{{1,100},{10,100}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
		skill_statetime={{{1,1},{30,1}}},		
    },
	npc_dushui=
    { 
        attack_usebasedamage_p={{{1,100},{29,380},{30,1000000}}},
		attack_metaldamage_v={
			[1]={{1,0},{29,0},{30,1000000}},
			[3]={{1,0},{29,0},{30,1000000}}
			},
		attack_wooddamage_v={
			[1]={{1,0},{29,0},{30,1000000}},
			[3]={{1,0},{29,0},{30,1000000}}
			},
		attack_waterdamage_v={
			[1]={{1,0},{29,0},{30,1000000}},
			[3]={{1,0},{29,0},{30,1000000}}
			},
		attack_firedamage_v={
			[1]={{1,0},{29,0},{30,1000000}},
			[3]={{1,0},{29,0},{30,1000000}}
			},
		attack_earthdamage_v={
			[1]={{1,0},{29,0},{30,1000000}},
			[3]={{1,0},{29,0},{30,1000000}}
			},
    },
	npc_200_30a_jitui=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={{{1,30},{10,100}},7,20},
		state_npcknock_attack={{{1,30},{10,100}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
    npc_200_30a_burt= 
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={{{1,30},{10,100}},9},
		state_hurt_attack={{{1,30},{10,100}},9},
    },
    npc_200_30a_zhican= 
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_zhican_attack={{{1,30},{10,100}},{{1,15*3},{30,15*3}}},		
    },
    npc_200_slowall30a= 
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_slowall_attack={{{1,30},{8,100}},{{1,15*3},{30,15*3}}},
    },
    npc_200_30a_confuse= --混乱
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_confuse_attack={{{1,30},{8,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
    npc_300a_30a_confuse= --混乱
    { 
		attack_usebasedamage_p={{{1,300},{30,2000}}},
		state_confuse_attack={{{1,30},{8,100}},{{1,15*3},{10,15*3},{11,15*3}}},
    },
	npc_100a_30_jitui=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_knock_attack={{{1,30},{10,30}},7,20},
		state_npcknock_attack={{{1,30},{10,30}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_200a_hurt30=
    { 
		attack_usebasedamage_p={{{1,200},{30,490}}},
		state_npchurt_attack={30,9},
		state_hurt_attack={30,9},
    },
	npc_300a_jidao75=
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
		state_knock_attack={75,35,30},
		state_npcknock_attack={75,35,30}, 
		spe_knock_param={26 , 26, 26},	
    },
	npc_250a_jitui50=
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_knock_attack={{{1,30},{10,100}},7,20},
		state_npcknock_attack={{{1,30},{10,100}},7,20}, 
		spe_knock_param={4 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
    npc_xuantianwuji02=									--玄天武机技能2效果
    { 
		attack_usebasedamage_p={{{1,100},{30,540}}},
		state_knock_attack={{{1,30},{10,100}},7,20},
		state_npcknock_attack={{{1,30},{10,100}},7,20}, 
		spe_knock_param={4 , 9, 9},
    },
	npc_suozu =
    {
		forbid_jump={1},
		skill_statetime={18*2.5},
    },
	npc_150_30a_hurt=
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={{{1,30},{10,100}},9},
		state_hurt_attack={{{1,30},{10,100}},9},
    },
	npc_150_30a_zhican=
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_zhican_attack={{{1,30},{10,100}},{{1,15*1},{30,15*1}}},
    }, 
	npc_150_30a_slowall=
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_slowall_attack={{{1,30},{10,100}},{{1,15*1},{30,15*1}}},
    },
	npc_150_30a_palsy=
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_palsy_attack={{{1,30},{10,100}},{{1,15*1},{30,15*1}}},
    },
	npc_150_30a_stun=
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_stun_attack={{{1,30},{10,100}},{{1,15*1},{30,15*1}}},
    },	
	npc_100a_30_fixed=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_fixed_attack={{{1,30},{10,30}},{{1,15*5},{30,15*5}}},
    }, 
	npc_200_30a_fixed=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_fixed_attack={{{1,30},{10,100}},{{1,15*3},{30,15*3}}},
    }, 
	npc_100a_30_jidao=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_knock_attack={{{1,30},{10,30}},35,30},
		state_npcknock_attack={{{1,30},{10,30}},35,30}, 
		spe_knock_param={26 , 26, 26},	
    },
	npc_200_30a_jidao=
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={{{1,30},{10,100}},35,30},
		state_npcknock_attack={{{1,30},{10,100}},35,30}, 
		spe_knock_param={26 , 26, 26},	
    },
	npc_100a_30_hurt=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_npchurt_attack={{{1,30},{10,30}},9},
		state_hurt_attack={{{1,30},{10,30}},9},
    },
	npc_100a_30_zhican=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_zhican_attack={{{1,30},{10,30}},{{1,15*1},{30,15*1}}},
    }, 
	npc_100a_30_slowall=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_slowall_attack={{{1,30},{10,30}},{{1,15*1},{30,15*1}}},
    },
	npc_100a_30_palsy=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_palsy_attack={{{1,30},{10,30}},{{1,15*1},{30,15*1}}},
    },
	npc_100a_30_stun=
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_stun_attack={{{1,30},{10,30}},{{1,15*1},{30,15*1}}},
    },	
	npc_500a_normal=
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
    },
	npc_qplr = --全屏拉人
    { 
		state_drag_attack={{{1,100},{15,100}},15,100},
		skill_drag_npclen={180},
    },
	npc_fix_igdrag=
    { 
		state_drag_ignore={1},
		locked_state ={--是否不能移动,使用技能,使用物品
			[1] = {{1,1},{10,1}},
			[2] = {{1,0},{10,0}},
			[3] = {{1,0},{10,0}},
			},
		skill_statetime={{{1,15*2},{10,15*2}}},
    }, 
    npc_400a_100_slowall= 
    { 
		attack_usebasedamage_p={{{1,400},{30,690},{40,1500}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	npc_200a_100_slowall=
    { 
		attack_usebasedamage_p={{{1,200},{30,490}}},
		state_slowall_attack={{{1,100},{10,100}},{{1,15*3},{30,15*3}}},
    },
	npc_yinshen = --npc隐身
    { 
		hide={15*60*60, 0},
		super_hide={},
		end_breakhide={},
		skill_statetime={-1},
    },
	npc_confuse=
    { 
		state_confuse_attack={{{1,100},{10,100},{11,100}},{{1,15*2},{5,15*5},{11,15*5}}},
    },	
	npc_jufeng=
    { 
		state_knock_attack={{{1,100},{10,100}},8,70},
		state_npcknock_attack={{{1,100},{10,100}},8,70}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_lazhican = --拉扯致残技能
    { 
		attack_usebasedamage_p={{{1,200},{30,490}}},
		state_drag_attack={{{1,100},{30,100}},12,60},
		skill_drag_npclen={120},
    },
	npc_lazhican_child = --拉扯致残技能_子
    { 
		state_zhican_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
   	npc_maxlifeack_xfz = --旋风斩（百分比掉血）
    { 
		dotdamage_maxlife_p={{{1,5},{30,30},{31,30}},15,50000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    npc_maxlifeack_shibao = --尸爆（百分比伤害）
    {
		autoskill={84,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    npc_jianhuixin  = --减会心
    {
		deadlystrike_v={{{1,-9999},{10,-99999}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
   	npc_maxlifeack_5_5 = --高伤普攻
    { 
		dotdamage_maxlife_p={{{1,5},{10,50}},15,50000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
}

FightSkill:AddMagicData(tb)