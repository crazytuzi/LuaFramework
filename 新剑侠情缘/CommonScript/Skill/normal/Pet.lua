
local tb    = {
    Pet_1=  --宠物1
    { 
		damage4npc_p={{{1,20},{2,40}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_2=  --宠物2
    { 
		enhance_exp_p={{{1,15},{2,15}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_2_2=  --宠物2_2
    { 
		enhance_exp_p={{{1,15},{2,15}}},
		enhance_exp_team_p={{{1,15},{2,15}}},
		userdesc_101={{{1,15},{2,15}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_3=  --宠物3
    { 
		exp_coin_contrib={0,{{1,5},{2,5}},0},  --增加银两
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_3_2=  --宠物3_2
    { 
		exp_coin_contrib={0,{{1,5},{2,5}},{{1,5},{2,5}}},  --增加银两、贡献
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_4=  --宠物4
    { 
        series_abate_v={{{1,75},{2,75}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_4_2=  --宠物4_2
    { 
        series_abate_v={{{1,75},{2,75}}},
        series_enhance_v={{{1,75},{2,75}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_5=  --宠物5
    { 
		all_series_resist_p={{{1,35},{2,35}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_5_2=  --宠物5_2
    { 
		all_series_resist_p={{{1,35},{2,35}}},
		lifereplenish_p={{{1,35},{2,35}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_6=  --宠物6
    { 
		lifemax_p={{{1,20},{2,20}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_6_2=  --宠物6_2
    { 
		lifemax_p={{{1,20},{2,20}}},
		meleedamagereturn_p={{{1,3},{2,3}}},
		rangedamagereturn_p={{{1,3},{2,3}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_7=  --宠物7
    { 
		resist_allseriesstate_rate_v={{{1,50},{2,50}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_7_2=  --宠物7_2
    { 
		resist_allseriesstate_rate_v={{{1,50},{2,50}}},
		runspeed_v={{{1,10},{2,10}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_8=  --宠物8
    { 
		ignore_all_resist_vp={{{1,35},{2,35}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_8_2=  --宠物8_2
    { 
		ignore_all_resist_vp={{{1,35},{2,35}}},
		steallife_p={{{1,3},{2,3}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_9=  --宠物9
    { 
        ignore_defense_vp={{{1,17},{2,17}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_9_2=  --宠物9_2
    { 
        ignore_defense_vp={{{1,17},{2,17}}},
        physics_potentialdamage_p={{{1,12},{2,12}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_10=  --宠物10
    { 
		deadlystrike_damage_p={{{1,10},{2,10}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_10_2=  --宠物10_2
    { 
		deadlystrike_damage_p={{{1,10},{2,10}}},
		deadlystrike_p={{{1,25},{2,25}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_11=  --宠物11
    { 
		attackspeed_v={{{1,10},{2,10}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
    Pet_11_2=  --宠物11_2
    { 
		attackspeed_v={{{1,10},{2,10}}},
		add_seriesstate_rate_v={{{1,50},{2,50}}},
		skill_statetime={{{1,15*60*60*24},{30,15*60*60*24}}},
    },
}

FightSkill:AddMagicData(tb)