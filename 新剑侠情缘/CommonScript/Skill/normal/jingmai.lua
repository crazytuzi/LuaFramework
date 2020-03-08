
local tb    = {
    jm_renmai = --任脉技能
    { 
		autoskill={103,{{1,1},{20,20}}},
		userdesc_101={{{1,30},{20,50}}},		--描述用，实际触发几率请查看autoskill.tab中的任脉技能
		userdesc_102={{{1,15*10},{20,15*5}}},	--描述用，实际触发间隔请查看autoskill.tab中的任脉技能
		userdesc_000={4802},	
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_renmai_child = --任脉技能
    { 
		attack_usebasedamage_p={{{1,200},{20,500}}},
		missile_hitcount={0,0,6},
    },
    jm_dumai = --督脉技能
    { 
		autoskill={104,{{1,1},{20,20}}},
		userdesc_101={{{1,5},{20,15}}},			--描述用，实际触发几率请查看autoskill.tab中的督脉技能
		userdesc_102={{{1,15*15},{20,15*10}}},	--描述用，实际触发间隔请查看autoskill.tab中的督脉技能
		userdesc_000={4805},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_dumai_child = --督脉技能
    { 
		attack_usebasedamage_p={{{1,50},{20,260}}},
		state_confuse_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		missile_hitcount={0,0,1},
    },
	
	jm_chongmai = --冲脉技能,覆盖率5~10%
    { 
		autoskill={105,{{1,1},{20,20}}},
		userdesc_101={{{1,25},{20,25}}},			--描述用，实际触发几率请查看autoskill.tab中的冲脉技能
		userdesc_102={{{1,15*38},{20,15*18}}},	--描述用，实际触发间隔请查看autoskill.tab中的冲脉技能
		userdesc_000={4808},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_chongmai_child = --冲脉技能_buff
    { 
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*1.1},{20,15*3}}},
    },
	
	jm_yangqiaomai = --阳跷脉,击杀敌人回血
    { 
		autoskill={106,{{1,1},{20,20}}},
		--userdesc_101={{{1,25},{20,25}}},			--描述用，实际触发几率请查看autoskill.tab中的冲脉技能
		userdesc_102={{{1,15*45},{20,15*30}}},		--描述用，实际触发间隔请查看autoskill.tab中的冲脉技能
		userdesc_000={4810},
		skill_statetime={-1},
    },
    jm_yangqiaomai_child = --击杀敌人回血
    { 
		dir_recover_life_pp={{{1,500},{20,1500}},1},--生命上限,自身数值
    },

	jm_yinqiaomai = --阴跷脉技能
    { 
		autoskill={107,{{1,1},{20,20}}},
		userdesc_102={{{1,15*38},{20,15*20}}},		--描述用，实际触发间隔请查看autoskill.tab中的冲脉技能
		userdesc_000={4812},
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_yinqiaomai_child = --阴跷脉技能_buff
    { 
		lifereplenish_p={{{1,-15},{20,-110}}},
		skill_statetime={{{1,15*3},{20,15*10}}},
    },

 	jm_yangweimai = --阳维脉技能
    { 
		autoskill={108,{{1,1},{20,20}}},
		userdesc_000={4814},
		userdesc_101={{{1,15*5},{20,15*5}}},		--描述用，持续时间
		userdesc_102={{{1,15*10},{20,15*10}}},		--描述用，实际触发间隔请查看autoskill.tab中的阳维脉技能
		skill_statetime={{{1,-1},{20,-1}}},
    },
    jm_yangweimai_child = --阳维脉技能_buff
    { 
		ignore_all_resist_vp={{{1,10},{20,80}}},  	--忽略基础抗性
		skill_statetime={{{1,15*5},{20,15*5}}},
    },
}

FightSkill:AddMagicData(tb)