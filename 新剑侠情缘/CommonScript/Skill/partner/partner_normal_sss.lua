
local tb    = { 
	partner_qsh_normal= --秦始皇普攻
    { 
		attack_usebasedamage_p={{{1,360},{20,360}}},
		missile_hitcount={0,0,3},
    },
	partner_qsh_hj = --护驾
    { 
		userdesc_000={3228},
    },	
	partner_qsh_hj_child1 = --护驾_子1
    { 
		call_npc1={2166, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={2166, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={2166, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2166},
		skill_statetime={{{1,15*5},{30,15*5}}},
    },	
	partner_qsh_hj_child2 = --护驾_子2
    { 
	 	callnpc_life={2166,{{1,100},{10,100}}},				--NPCid，召唤NPC血量为召唤者生命上限值的%
	 	callnpc_damage={2166,{{1,100},{10,100}}},			--NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
		skill_statetime={{{1,15*5},{30,15*5}}},	
    },
    partner_qsh_hjgj_child1 = --护驾攻击_子1
    { 
		attack_usebasedamage_p={{{1,180},{30,180}}},
		missile_hitcount={0,0,3},
    },
    partner_qsh_hjgj_child3 = --护驾攻击_降临伤害
    { 
		attack_usebasedamage_p={{{1,180},{30,180}}},
		missile_hitcount={0,0,3},
    },
	partner_wyhl_normal= --完颜洪烈普攻
    { 
		dotdamage_wood={{{1,120},{30,120}},{{1,0},{30,0}},{{1,1},{30,1}}},
		skill_statetime={{{1,3},{30,3}}},
		missile_hitcount={0,0,3},
    },
    partner_wyhl_jn = --风卷尘沙
    { 
		attack_usebasedamage_p={{{1,180},{30,180}}},
		dotdamage_wood={{{1,180},{30,180}},{{1,0},{30,0}},{{1,1},{30,1}}},
		skill_statetime={{{1,5},{30,5}}},		
		missile_hitcount={0,0,3},
    },
    partner_xy_normal= --项羽普攻
    { 
		attack_usebasedamage_p={{{1,400},{20,400}}},
		missile_hitcount={0,0,3},
    },
    partner_xy_hmby = --项羽-鸿门摆宴
    { 
        attack_usebasedamage_p={{{1,1200},{30,1200}}},
        state_drag_attack={{{1,100},{30,100}},8,70},
        skill_drag_npclen={60},
        state_palsy_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    partner_wzt_normal= --武则天普攻
    { 
		attack_usebasedamage_p={{{1,360},{20,360}}},
		missile_hitcount={0,0,3},
    },
    partner_wzt_ndzl = --武则天-女帝之力
    { 
		userdesc_000={3922},
		autoskill={102,{{1,1},{30,30}}},
		physics_potentialdamage_p={{{1,50},{30,50}}},
		all_series_resist_p={{{1,100},{30,100}}},
		attackspeed_v={{{1,30},{30,30}}},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
    partner_wzt_ndzl_child= --武则-女帝之力_冰冻
    { 
		state_freeze_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		userdesc_101={{{1,30},{30,30}}},			--描述用，触发冰冻反击几率，实际几率于autoskill.tab表中填写
		userdesc_102={{{1,15*5},{30,15*5}}},		--描述用，触发间隔，实际时间于autoskill.tab表中填写
		missile_hitcount={0,0,1},
    },
    partner_ggz_normal= --鬼谷子普攻
    { 
		attack_usebasedamage_p={{{1,360},{20,360}}},
		missile_hitcount={0,0,3},
    },
    partner_ggz_hzlh= --鬼谷子-合纵连横
    { 
		attack_usebasedamage_p={{{1,400},{20,400}}},
		missile_hitcount={0,0,5},

		reduce_final_damage_p={{{1,-6},{20,-6}}},
		skill_statetime={{{1,15*10},{30,15*10}}},		

    },
}

FightSkill:AddMagicData(tb)