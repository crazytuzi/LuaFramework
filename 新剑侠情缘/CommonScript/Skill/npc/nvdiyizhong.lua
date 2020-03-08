
local tb    = { 
    wzt_normal = --武则天普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    wzt_s1 = --武则天-极度冰冷
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},		
		state_freeze_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    }, 
	wzt_s2 = --唤醒卫兵
    { 
		call_npc1={2531, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={2531, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={2531, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc4={2531, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc5={2531, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2531},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },	
	wzt_s2_child = --唤醒卫兵_子
    { 
	 	callnpc_life={2531,{{1,1},{10,1}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={2531,{{1,0},{10,0}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*60},{30,15*60}}},		--持续时间需要跟bq_s5的时间一致
    },
}

FightSkill:AddMagicData(tb)