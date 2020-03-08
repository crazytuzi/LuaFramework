
local tb    = { 
    ls_normal = --李斯普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    ls_s1 = --李斯焚书坑儒
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},		
		state_drag_attack={{{1,50},{30,50}},4,60},		
		skill_drag_npclen={20},
    }, 
    ls_s2 = --李斯吞噬毒珠
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    }, 
    ls_s3 = --权倾天下_击退_子
    { 
		state_knock_attack={100,15,70},				--几率，时间，速度
		state_npcknock_attack={100,15,70},			--几率，时间，速度 
		spe_knock_param={3 , 4, 9},					--停留时间，玩家动作ID，NPC动作ID
    }, 
	ls_s4 = --权倾天下-召唤2蜘蛛
    { 
		call_npc1={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		--remove_call_npc={1881},
		skill_statetime={{{1,15*30},{30,15*30}}},
    },	
	ls_s4_child = --权倾天下-召唤2蜘蛛_子
    { 
	 	callnpc_life={1881,{{1,0},{10,0},{30,0}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1881,{{1,0},{10,0},{30,0}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*30},{30,15*30}}},				--持续时间需要跟ls_s4的时间一致
    },
	ls_s4_5count = --权倾天下-召唤5蜘蛛
    { 
		call_npc1={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc4={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc5={1881, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		--remove_call_npc={1881},
		skill_statetime={{{1,15*30},{30,15*30}}},
    },	
	ls_s4_5count_child = --权倾天下-召唤5蜘蛛_子
    { 
	 	callnpc_life={1881,{{1,0},{10,0},{30,0}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1881,{{1,0},{10,0},{30,0}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*30},{30,15*30}}},				--持续时间需要跟ls_s4的时间一致
    },
    ls_s5 = --权倾天下-死亡给BUFF
    {
		autoskill={15,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
	ls_s5_child1 = --权倾天下-死亡给BUFF_免疫
    { 
		autoskill={16,{{1,1},{30,30},{31,30}}},
		attack_usebasedamage_p={{{1,10},{30,10}}},		
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
	ls_s5_child2 = --权倾天下-死亡给BUFF_友方免疫
    { 
		state_knock_ignore={1},									--免疫NPC击退状态
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	ls_s6 = --召唤赤蝎
    { 
		call_npc1={1882, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1882, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		--remove_call_npc={1882},
		skill_statetime={{{1,15*120},{30,15*120}}},
    },	
	ls_s6_child = --召唤赤蝎_子
    { 
	 	callnpc_life={1882,{{1,3},{10,3},{30,3}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1882,{{1,0},{10,0},{30,0}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*120},{30,15*120}}},				--持续时间需要跟ls_s4的时间一致
    },
	ls_s6_die = --召唤赤蝎-死亡清除
    { 
		autoskill={18,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },	
	ls_s6_die_child = --召唤赤蝎-死亡清除
    { 
		remove_call_npc={1882},
		skill_statetime={{{1,3},{30,3}}},
    },
    ls_s7 = --赤蝎之毒_子1
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_slowrun_attack={50,15*2},
    }, 
    ls_s8 = --暗毒血雾_子3
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={100,35,0},			--概率，持续时间，速度
		state_npcknock_attack={100,35,0},
		spe_knock_param={35 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    }, 
    bq_normal = --白起普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    bq_s1 = --大卸八块
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    bq_s2 = --潜伏
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
    bq_s2_child = --潜伏_降临伤害
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
	bq_s3 = --嗜血之意
    { 
		physical_damage_v={								--增加攻击力点数
			[1]={{1,500},{30,790}},
			[3]={{1,500},{30,790}}
			},
		attackspeed_v={{{1,40},{30,70}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    bq_s4 = --坑杀
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_knock_attack={100,3,100},		
		state_npcknock_attack={100,3,100},	
		spe_knock_param={0 , 9, 9},
    },
    bq_s4_child = --坑杀_控制
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
		state_slowrun_attack={100,15*2},
    },
	bq_s5 = --唤醒
    { 
		call_npc1={1880, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1880, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={1880, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc4={1880, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc5={1880, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		--remove_call_npc={1880},
		skill_statetime={{{1,15*120},{30,15*120}}},
    },	
	bq_s5_child = --唤醒_子
    { 
	 	callnpc_life={1880,{{1,1},{10,1}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1880,{{1,0},{10,0}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*120},{30,15*120}}},		--持续时间需要跟bq_s5的时间一致
    },
	bq_s5_die = --唤醒-死亡清除
    { 
		autoskill={17,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },	
	bq_s5_die_child = --唤醒-死亡清除
    { 
		remove_call_npc={1880},
		skill_statetime={{{1,3},{30,3}}},
    },
	bq_s6 = --乱影迷神
    { 
		call_npc1={1883, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1883, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={1883},
		skill_statetime={{{1,15*30},{30,15*30}}},
    },	
	bq_s6_child = --乱影迷神_子
    { 
		call_masterlife={1883,{{1,100},{10,100}}},			--NPCid,召唤NPC的血量为召唤者当前血量的%
	 	callnpc_damage={1883,{{1,0},{10,0}}},				--NPCid,攻击力%
		skill_statetime={{{1,15*30},{30,15*30}}},			--持续时间需要跟bq_s6的时间一致
    },
    qsh_normal = --秦始皇普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    qsh_s1 = --秦始皇突出重围
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}}, 
    },
    qsh_s1_child1 = --秦始皇突出重围_子1		--持续的间隔伤害
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
		state_knock_attack={100,35,30},					--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},					--停留时间，角色动作ID，NPC动作ID	
    },
    qsh_s1_child2 = --秦始皇突出重围_击退
    { 
		state_knock_attack={100,5,70},				--几率，时间，速度
		state_npcknock_attack={100,5,70},			--几率，时间，速度 
		spe_knock_param={3 , 4, 9},					--停留时间，玩家动作ID，NPC动作ID
    },
	qsh_s2 = --召唤李斯							--释放技能后就消失
    { 
		call_npc1={1885, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={1885},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },	
	qsh_s2_child = --召唤李斯_子
    { 
	 	callnpc_life={1885,{{1,100},{10,100}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1885,{{1,100},{10,100}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*3},{30,15*3}}},				--持续时间需要跟bq_s5的时间一致
    },
	qsh_s3 = --召唤白起							--释放技能后就消失
    { 
		call_npc1={1884, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={1884},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },	
	qsh_s3_child = --召唤白起_子
    { 
	 	callnpc_life={1884,{{1,100},{10,100}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1884,{{1,100},{10,100}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*3},{30,15*3}}},				--持续时间需要跟bq_s5的时间一致
    },
	qsh_s4 = --护驾
	{ 
		call_npc1={1894, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={1894, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={1894, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={1894},
		skill_statetime={{{1,15*5},{30,15*5}}},
    },	
	qsh_s4_child = --护驾_子
    { 
	 	callnpc_life={1894,{{1,100},{10,100}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={1894,{{1,100},{10,100}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*5},{30,15*5}}},			--持续时间需要跟bq_s5的时间一致
    },
    qsh_s5 = --秦始皇旋剑
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}}, 
    },
    qsh_s6 = --秦始皇秒杀
    { 
		attack_usebasedamage_p={{{1,100000},{30,100000}}}, 
		attack_earthdamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_wooddamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_waterdamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_firedamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_metaldamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		missile_hitcount={{{1,1},{30,1}}},  
    },
    xtwj_normal = --玄天武机普攻
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}}, 
    },
    xtwj_s1=  --玄天武机噬天火
    { 
		attack_usebasedamage_p={{{1,150},{30,390}}},
    },
    xtwj_s2 = --变小
    { 
		physics_potentialdamage_p={{{1,1},{30,1}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },	
    xtwj_s3 = --火焰喷发_子
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_knock_attack={100,20,30},			--概率，持续时间，速度
		state_npcknock_attack={100,20,30},
		spe_knock_param={11 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	 
    },
    xtwj_s4 = --追踪火弹
    { 
		--attack_usebasedamage_p={{{1,200},{30,200}}}, 
		missile_hitcount={{{1,1},{20,1}}}, 
    },
    xtwj_s4_child = --追踪火弹_子
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}}, 
    },
	buff_forqsh= --长生不老
    { 
		--invincible_b={1},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
	buff_stay10second= --站立10秒_无敌
    { 
		invincible_b={1},
		skill_statetime={{{1,15*12},{30,15*12}}},
    },
}

FightSkill:AddMagicData(tb)