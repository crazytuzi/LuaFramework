
local tb    = {
	teamfb20_boss1_1 = --雷击
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss1_2 = --冰锁连环
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss1_3 = --暴风雪
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5},{31,15*5}}},
    },
	teamfb20_boss1_4= --闪电链
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss2_1 = --徐铁心普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss2_2 = --徐铁心重拳三连击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,10,20},	
		state_npcknock_attack={100,10,20},	
		spe_knock_param={10 , 4, 4},	
    }, 
	teamfb20_boss2_2_child = --徐铁心重拳三连击_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,30,30},		
		state_npcknock_attack={100,30,30},
		spe_knock_param={26 , 26, 26},				
    }, 
	teamfb20_boss2_3 = --徐铁心金刚坠
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },
	teamfb20_boss2_4_child1 = --旋风_子1
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		--state_npchurt_attack={100,9},
		--state_hurt_attack={100,9},
    },
	teamfb20_boss2_4_child2 = --旋风_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*7},{30,15*7}}},
    },
	teamfb20_boss3_1 = --卓非凡普攻
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss3_2 = --剑雨_伤害
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={60,30,30},		
		state_npcknock_attack={60,30,30},
		spe_knock_param={26 , 26, 26},				
    }, 
	teamfb20_boss3_3= --飞剑
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss3_4= --十字剑
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	teamfb20_boss3_5_child1= --鼓舞剑阵
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
    },
	teamfb20_boss3_5_child2= --鼓舞剑阵_buff
    { 
		physics_potentialdamage_p={{{1,10},{30,30}}},	
		skill_statetime={{{1,20},{30,20}}},		
    },
	teamfb20_boss3_5_child3 = --鼓舞剑阵_伤害
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_knock_attack={100,30,30},		
		state_npcknock_attack={100,30,30},
		spe_knock_param={26 , 26, 26},				
    }, 
	teamfb40_1 = --定时炸弹
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },
	teamfb60_paoche = --炮车
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
    teamfb120_guyanran_1 = --古嫣然普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    teamfb120_guyanran_2 = --古嫣然-阴风蚀骨
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },
	teamfb120_guyanran_3_ls = --古嫣然-召唤毒虫_灵蛇
    { 
		call_npc1={2190, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2190},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },	
	teamfb120_guyanran_3_ls_child = --古嫣然-召唤毒虫_灵蛇_子
    { 
	 	callnpc_life={2190,{{1,10},{30,10}}},			--NPCid，生命值%
	 	callnpc_damage={2190,{{1,50},{30,50}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*20},{30,15*20}}},		--持续时间需要跟召唤毒虫_灵蛇的时间一致
    },
	teamfb120_guyanran_3_bc = --古嫣然-召唤毒虫_碧蟾
    { 
		call_npc1={2191, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2191},
		skill_statetime={{{1,15*20},{30,15*20}}},	
    },	
	teamfb120_guyanran_3_bc_child = --古嫣然-召唤毒虫_碧蟾_子
    { 
	 	callnpc_life={2191,{{1,10},{30,10}}},			--NPCid，生命值%
	 	callnpc_damage={2191,{{1,50},{30,50}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*20},{30,15*20}}},		--持续时间需要跟召唤毒虫_碧蟾的时间一致
    },
	teamfb120_guyanran_3_cx = --古嫣然-召唤毒虫_赤蝎
    { 
		call_npc1={2192, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2192},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },	
	teamfb120_guyanran_3_cx_child = --古嫣然-召唤毒虫_赤蝎_子
    { 
	 	callnpc_life={2192,{{1,10},{30,10}}},			--NPCid，生命值%
	 	callnpc_damage={2192,{{1,50},{30,50}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*20},{30,15*20}}},		--持续时间需要跟召唤毒虫_赤蝎的时间一致
    },
	teamfb120_guyanran_3_fw = --古嫣然-召唤毒虫_风蜈
    { 
		call_npc1={2193, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2193},
		skill_statetime={{{1,15*20},{30,15*20}}},	
    },	
	teamfb120_guyanran_3_fw_child = --古嫣然-召唤毒虫_风蜈_子
    { 
	 	callnpc_life={2193,{{1,10},{30,10}}},			--NPCid，生命值%
	 	callnpc_damage={2193,{{1,50},{30,50}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*20},{30,15*20}}},		--持续时间需要跟召唤毒虫_风蜈的时间一致
    },
	teamfb120_guyanran_3_mz = --古嫣然-召唤毒虫_墨蛛
    { 
		call_npc1={2194, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2194},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },	
	teamfb120_guyanran_3_mz_child = --古嫣然-召唤毒虫_墨蛛_子
    { 
	 	callnpc_life={2194,{{1,10},{30,10}}},			--NPCid，生命值%
	 	callnpc_damage={2194,{{1,50},{30,50}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*20},{30,15*20}}},		--持续时间需要跟召唤毒虫_墨蛛的时间一致
    },
    teamfb120_guyanran_4 = --古嫣然-万蛊蚀心
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    }, 
}

FightSkill:AddMagicData(tb)