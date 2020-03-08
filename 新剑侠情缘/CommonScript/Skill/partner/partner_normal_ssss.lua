
local tb    = { 
	partner_zsf_normal= --张三丰普攻
    { 
		attack_usebasedamage_p={{{1,540},{20,540}}},
		missile_hitcount={0,0,3},
    },
    partner_zsf_cywjg = --张三丰-纯阳无极功
    { 
		physics_potentialdamage_p={{{1,30},{30,30}}},
		steallife_p={{{1,5},{30,5}}},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },

	partner_dm_normal= --达摩普攻
    { 
		attack_usebasedamage_p={{{1,180},{20,180}}},
		missile_hitcount={0,0,3},
    },
	partner_dm_hjxc= --达摩-火尽薪传
    { 
		attack_usebasedamage_p={{{1,140},{20,140}}},
		state_palsy_attack={100,10},
		missile_hitcount={0,0,1},
    },
}

FightSkill:AddMagicData(tb)