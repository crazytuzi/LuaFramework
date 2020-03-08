
local tb    = {
    a_partner_em_pg1 = --A级峨眉剑术1
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_em_pg2 = --A级峨眉剑术2
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },	
    a_partner_em_pg3 = --A级峨眉剑术3
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
    a_partner_em_pg4 = --A级峨眉剑术4
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
    a_partner_em_jhnb = --A级江海凝波
    { 
		userdesc_000={1137},
    },
    a_partner_em_jhnb_child = --A级江海凝波_子
    { 
		attack_usebasedamage_p={{{1,120},{20,120}}},
		missile_hitcount={0,0,3},
    },	
	partner_em_jxtm = --剑心通明
	{ 
	--	attackspeed_v={{{1,10},{30,10}}},
		physics_potentialdamage_p={{{1,24},{30,40}}},
		lifemax_p={{{1,45},{30,60}}},
		skill_statetime={{{1,-1},{30,-1}}},
	},
    s_partner_em_pg1 = --S级峨眉剑术1
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_em_pg2 = --S级峨眉剑术2
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3},  
    },	
    s_partner_em_pg3 = --S级峨眉剑术3
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3},  
    },
    s_partner_em_pg4 = --S级峨眉剑术4
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3},  
    },
    s_partner_em_twbl = --S级天舞宝轮
    { 
		userdesc_000={1145},
		vitality_recover_life={{{1,100},{20,100}},15},
		skill_statetime={{{1,20},{20,20}}},
    },
    s_partner_em_twbl_child = --S级天舞宝轮_子
    { 
		attack_usebasedamage_p={{{1,50},{20,50}}},
		missile_hitcount={0,0,3}, 		
    },
}

FightSkill:AddMagicData(tb)