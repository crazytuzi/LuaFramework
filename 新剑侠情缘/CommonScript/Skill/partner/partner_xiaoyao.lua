
local tb    = {
    a_partner_xy_qf1 = --普攻1式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_xy_qf2 = --普攻2式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_xy_qf3 = --普攻3式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_xy_qf4 = --普攻4式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },   
    a_partner_xy_bhgr = --白虹贯日
    { 
		userdesc_000={1233},
    },
    a_partner_xy_bhgr_child = --白虹贯日_子
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},
		missile_hitcount={0,0,3},
    },
    s_partner_xy_qf1 = --普攻1式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_xy_qf2 = --普攻2式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_xy_qf3 = --普攻3式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_xy_qf4 = --普攻4式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    },   
    s_partner_xy_qtsp = --S级同伴-七探蛇盘
    { 
		userdesc_000={1239},
    },
    s_partner_xy_qtsp_child = --S级同伴-七探蛇盘_子
    { 
		attack_usebasedamage_p={{{1,187},{20,187}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
		missile_hitcount={0,0,3},
    },
}

FightSkill:AddMagicData(tb)