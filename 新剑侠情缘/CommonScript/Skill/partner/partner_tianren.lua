
local tb    = {
    a_partner_tr_pg1 = --普攻1式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_tr_pg2 = --普攻2式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    a_partner_tr_pg3 = --普攻3式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    a_partner_tr_pg4 = --普攻4式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_tr_shlx = --摄魂乱心
    { 
		userdesc_000={2830},	
    }, 	
    a_partner_tr_shlx_child = --摄魂乱心_子
    { 
		attack_usebasedamage_p={{{1,200},{20,200}}},
		state_confuse_attack={{{1,30},{20,30}},{{1,15*1.5},{15,15*1.5}}},		
		state_drag_attack={{{1,30},{20,30}},8,30},		
		skill_drag_npclen={0},
		state_npchurt_attack={100,10}, 
    }, 
    s_partner_tr_pg1 = --普攻1式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,1},
    }, 
    s_partner_tr_pg2 = --普攻2式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    s_partner_tr_pg3 = --普攻3式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    s_partner_tr_pg4 = --普攻4式
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_tr_xyzy = --血月之影
    { 
		keephide={},
		runspeed_v={{{1,100},{15,200}}},
		hide={{{1,15*15},{15,15*20}},1},				--参数1时间，参数2：队友1，同阵营2
		autoskill={75,{{1,1},{15,15}}},	
		userdesc_000={2820},			
		userdesc_104={{{1,15*15},{15,15*20}}},		
		skill_statetime={{{1,15*15},{15,15*20}}},
    }, 
    s_partner_tr_xyzy_child1 = --血月之影_破隐普攻加成buff
    { 
		ignore_defense_v={{{1,1000},{20,1000}}},
		attackspeed_v={{{1,100},{20,100}}},
		deadlystrike_v={{{1,10000},{20,10000}}},
		--physics_potentialdamage_p={{{1,100},{15,300}}},
		link_skill_buff={},				--连招内保持当前加成BUFF的魔法属性
		addaction_event1={2815,2821},		--技能2815被2821替换
		addaction_event2={2816,2822},		--技能2816被2822替换
		addaction_event3={2817,2823},		--技能2817被2823替换
		addaction_event4={2818,2824},		--技能2818被2824替换
		skill_statetime={{{1,15*5},{15,15*5}}},
    },
    s_partner_tr_xyzy_pg1 = --血月之影_攻击1
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_tr_xyzy_pg2 = --血月之影_攻击2
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    s_partner_tr_xyzy_pg3 = --血月之影_攻击3
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    }, 	
    s_partner_tr_xyzy_pg4 = --血月之影_攻击4
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		missile_hitcount={0,0,3},
    },
}

FightSkill:AddMagicData(tb)