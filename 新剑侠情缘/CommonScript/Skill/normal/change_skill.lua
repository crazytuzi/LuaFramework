
local tb    = {
	change_wolf_skill3 = --狂暴噬血
    { 
		physical_damage_v={								--增加攻击力点数
			[1]={{1,100},{30,1000}},
			[3]={{1,100},{30,1000}}
			},
		physics_potentialdamage_p={{{1,40},{30,70}}},	--增加攻击力百分比
		attackspeed_v={{{1,40},{30,70}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	change_wolf_skill4 = 
    {
		physics_potentialdamage_p={{{1,15},{30,30}}},
		lifemax_p={{{1,35},{30,50}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
	change_nuche_skill2= --弩车落弩_子1
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},	
    },	
	change_nuche_skill3= --弩车连弩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,6,20},
		state_npcknock_attack={100,6,20},
		spe_knock_param={5 , 4, 4},			
    },	
}

FightSkill:AddMagicData(tb)