
local tb    = { 
    jianta= --箭塔
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    }, 
	zc_buff_adddamage=
    { 
		physics_potentialdamage_p={{{1,200},{30,200}}},
		skill_statetime={{{1,15*90},{30,15*90}}},
    },
	zc_buff_recover=
    { 
		vitality_recover_life={{{1,20},{30,20}},15},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
	zc_buff_series=
    { 
		all_series_resist_p={{{1,300},{30,300}}},
		skill_statetime={{{1,15*90},{30,15*90}}},
    },  
	zc_buff_qiangli=
    { 
		all_series_resist_v={{{1,100},{30,300}}},
		lifemax_v={{{1,4000},{30,10000}}},
		resist_allseriesstate_rate_v={{{1,150},{10,500}}},	
		resist_allseriesstate_time_v={{{1,100},{10,200}}},	
		resist_allspecialstate_rate_v={{{1,150},{10,500}}},
		resist_allspecialstate_time_v={{{1,100},{10,200}}},
	--	physics_potentialdamage_p={{{1,10},{30,40}}},	--增加攻击力百分比			
		skill_statetime={{{1,15*60*10},{30,15*60*10}}},
    },
    moba_maxlife_atk = --炮塔
    { 
		dotdamage_maxlife_p={{{1,10},{30,39}},15,500000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },  	
	zc_debuff_player= 	--玩家打塔debuff
    { 
		special_dmg_p={{{1,-100},{2,-200}}},				--玩家对塔减少的攻击%,正数为1+p,负数为:1/(1-p),-100为1/2
		skill_statetime={{{1,15*3},{30,15*3}}},
    }, 	
	zc_npc_normal=  --战场小兵普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		missile_hitcount={{{1,1},{30,1}}},
    },
    zc_boss1 = --熊皇-掌击
    { 
		dotdamage_maxlife_p={{{1,10},{30,39}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    zc_boss2 = --熊皇-激怒
    { 
		attackspeed_v={{{1,50},{30,50}}},
		deccdtime={3757,{{1,15*1.5},{30,15*1.5}}},		
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
    zc_boss3 = --熊皇-至尊咆哮
    { 
		dotdamage_maxlife_p={{{1,30},{30,39}},15,2000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
	moba_buff_recover=  --buff_回复
    { 
		recover_life_p={{{1,5},{20,100}},15},
		skill_statetime={{{1,15*6},{20,15*6}}},
    },
	moba_buff_adddamage=  --buff_攻击
    { 
		physics_potentialdamage_p={{{1,100},{20,200}}},
		skill_statetime={{{1,15*60},{20,15*60}}},
    },
	moba_buff_series=  --buff_抗性
    { 
		all_series_resist_p={{{1,200},{20,300}}},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
	moba_buff_runspeed=  --buff_跑速
    { 
		runspeed_p={{{1,40},{20,100}}},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
	moba_buff_huixin=  --buff_会心
    { 
		deadlystrike_v={{{1,1500},{30,1500}}},
		deadlystrike_damage_p={{{1,30},{30,30}}},
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
	moba_buff_wudi=  --buff_无敌
    { 
		invincible_b={1},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
	robot_debuff=  --机器人debuff
    { 
		physics_potentialdamage_p={{{1,-200},{20,-200}}},
		all_series_resist_p={{{1,-100},{20,-200}}},
		attackspeed_v={{{1,-10},{20,-20}}},
		deadlystrike_damage_p={{{1,-50},{20,-50}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
}

FightSkill:AddMagicData(tb)