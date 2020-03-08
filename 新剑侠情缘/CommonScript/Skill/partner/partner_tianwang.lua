
local tb    = {
    a_partner_tw_xyj = --行云诀--普攻1式
    { 
		attack_usebasedamage_p={{{1,65},{20,85}}},
		missile_hitcount={0,0,1},
    }, 
    a_partner_tw_jlj = --惊雷诀--普攻2式
    { 
		attack_usebasedamage_p={{{1,65},{20,85}}},
		missile_hitcount={0,0,1},
    }, 
    a_partner_tw_xlj = --降龙诀--普攻3式
    { 
		attack_usebasedamage_p={{{1,65},{20,85}}},
		missile_hitcount={0,0,1},
    }, 	
    a_partner_tw_ptj = --破天诀--普攻4式
    { 
		attack_usebasedamage_p={{{1,65},{20,85}}},
		missile_hitcount={0,0,1},
    },  
    a_partner_tw_jzz = --金钟罩
    { 
        recover_life_v={{{1,200},{20,200}},15*5},
        all_series_resist_v={{{1,150},{20,150}}},
        resist_allseriesstate_rate_v={{{1,100},{20,100}}},
        skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},
    },
    partner_tw_twzy = --天王战意
    {
		physics_potentialdamage_p={{{1,8},{30,8}}},
		lifemax_p={{{1,8},{30,8}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    s_partner_tw_pg1 = --S级回风落雁--普攻1式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_tw_pg2 = --S级回风落雁--普攻2式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_tw_pg3 = --S级回风落雁--普攻3式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 	
    s_partner_tw_pg4 = --S级回风落雁--普攻4式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    },  
	s_partner_tw_dhc = --S级断魂刺
    { 
		userdesc_000={1116},	
    },
    s_partner_tw_dhc_child = --S级断魂刺_子
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		state_fixed_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
		state_npchurt_attack={100,10}, 
		state_hurt_attack={100,10}, 
		missile_hitcount={0,0,3},
    },
}

FightSkill:AddMagicData(tb)