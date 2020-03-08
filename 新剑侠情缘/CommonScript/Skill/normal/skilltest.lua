
local tb    = {
	test_hitcount={--测试用目标数
		ms_one_hit_count={0,0,10},
	},
	test_dmg={	--测试用伤害技能
		attack_usebasedamage_p={100},
	},
	
	
	test_bufflayer={	--测试用伤害技能,4159
		--reduce_autoskill_cd={64,30*15},
		--autoskill_percent={162,85},
		autoskill_percast={61,30*15},
		buff_addition={5218,2,10},
		add_force_ignore_spe_state={4010,7077403},

		physics_potentialdamage_p={{{1,3},{15,45},{20,60}}},
		attackspeed_v={{{1,1},{15,15},{20,15}}},
		
		superposemagic={4,{{1,1},{2,2}}},				--buff最大叠加层数,当前层数(不要设置),属性叠加层数
		
		skill_statetime={30*15,{{1,0},{2,1},{3,2},{4,2}},45*15},	--持续时间,时间叠加模式,
	},
	
}

FightSkill:AddMagicData(tb)