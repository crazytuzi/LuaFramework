
local tb    = {
    partner_ai_wenzhong = --同伴稳重AI配套技能
    {
		all_series_resist_p={{{1,30},{15,30}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	
	 partner_ai_lenjing = --同伴冷静AI配套技能
    {
		resist_allseriesstate_rate_v={{{1,150},{10,150}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	
	 partner_ai_jiaozha = --同伴狡诈AI配套技能
    {
		enhance_final_damage_p={{{1,5},{20,5}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	
	 partner_ai_guogan = --同伴果敢AI配套技能
    {
		all_series_resist_p={{{1,10},{15,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner_ai_zhongyi = --同伴重义AI配套技能
    {
		target_dmg_p={{{1,10},{15,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner_ai_jinshen = --同伴谨慎AI配套技能
    {
		lifereplenish_p={{{1,10},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner_ai_yonggan = --同伴勇猛AI配套技能
    {
		autoskill={98,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	 partner_ai_yonggan_child = --同伴勇敢AI配套技能
    {
		enhance_final_damage_p={{{1,45},{20,45}}},
		skill_statetime={{{1,15*11},{20,15*11}}},
    },
	partner_ai_buqu = --同伴不屈AI配套技能
    {
		autoskill={99,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	 partner_ai_buqu_child = --同伴不屈AI配套技能
    {
		all_series_resist_p={{{1,75},{20,75}}},
		skill_statetime={{{1,15*11},{20,15*11}}},
    },
	partner_ai_weiyan = --同伴威严AI配套技能
    {
		enhance_final_damage_p={{{1,-10},{20,-10}}},
		skill_statetime={{{1,15*3},{20,15*3}}},
    },
	partner_ai_huzhu = --同伴护主AI配套技能
    {
		autoskill={1,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	 partner_ai_huzhu_child = --同伴护主AI配套技能
    {
		enhance_final_damage_p={{{1,-10},{20,-10}}},
		skill_statetime={{{1,15*11},{20,15*11}}},
    },
	partner_ai_wenwan = --同伴温婉AI配套技能
    {
		weaken_deadlystrike_v={{{1,400},{20,400}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	partner_ai_shixue = --同伴嗜血AI配套技能
    {
		autoskill={8,{{1,1},{10,10}}},
		skill_statetime={{{1,-1},{20,-1}}},
    },
	 partner_ai_shixue_child = --同伴嗜血AI配套技能
    {
		enhance_final_damage_p={{{1,30},{20,30}}},
		skill_statetime={{{1,15*11},{20,15*11}}},
    },
}

FightSkill:AddMagicData(tb)