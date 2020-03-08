
local tb    = {
	partner_xyf_normal= --小殷方-御剑术-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_xyf_wjj= --小殷方-万剑诀
    { 
		userdesc_000={2592},	
    },
	partner_xyf_wjj_child= --小殷方-万剑诀_子
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_smy_normal= --苏墨芸-冰心剑诀-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_smy_clsd= --苏墨芸-沧浪三叠
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_xdc_normal= --萧动尘-梨花枪-普攻
    { 
		attack_usebasedamage_p={{{1,207},{20,207}}},
		missile_hitcount={0,0,3},
    },
	partner_xdc_hsyj= --萧动尘-横扫一击
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_bmhw_normal= --白眉猴王-投掷-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_bmhw_luoshi = --白眉猴王-落石
    { 
		userdesc_000={993},		
    },
	partner_bmhw_luoshi_child = --白眉猴王-落石
    { 
		attack_usebasedamage_p={{{1,110},{20,110}}},
		missile_hitcount={0,0,3},		
    },
	partner_ddlw_normal= --大地狼王-撕咬-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_ddlw_hj= --大地狼王-嚎叫
    { 
		add_mult_proc_sate1={2534,{{1,6},{10,6}},85},  --技能ID,叠加层数，自身为圆心格子半径
		userdesc_000={2534},			
		skill_statetime={{{1,15*8},{10,15*8}}},
    },
	partner_ddlw_hj_child= --大地狼王-嚎叫
    { 
		skill_mult_relation={2}, --对应的NPC类型，从skillsetting.ini上查看
		basic_damage_v={
			[1]={{1,20},{20,20}},
			[3]={{1,20},{20,20}}
			},
		skill_statetime={{{1,15*8},{10,15*8}}},
    },
	partner_hylw_normal= --寒玉鹿王-角击-普攻
    { 
		attack_usebasedamage_p={{{1,207},{20,207}}},
		missile_hitcount={0,0,3},
    },
	partner_hylw_xw= --寒玉鹿王-漩涡
    { 
		attack_usebasedamage_p={{{1,166},{20,166}}},
    },
	partner_hsy_normal= --胡神医-青莲剑法-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_hsy_zls = --胡神医-治疗术
	{ 
	 	userdesc_000={1000},
		missile_hitcount={0,0,1},
	},	
	partner_hsy_zls_child = --胡神医-治疗术_子
	{ 
	 	vitality_recover_life={{{1,60},{20,60}},15},
		skill_statetime={{{1,15*5},{30,15*5}}},
	},
	partner_qmb_normal= --秦沐白-毒爪-普攻
    { 
		attack_usebasedamage_p={{{1,207},{20,207}}},
		missile_hitcount={0,0,3},
    },
	partner_qmb_nf= --秦沐白-怒风
    { 
		dotdamage_wood={{{1,69},{20,69}},{{1,0},{30,0}},{{1,8},{30,8}}},
		state_float_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
		missile_hitcount={0,0,3},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
	partner_zzt_normal= --张仲天-扇里藏镖-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_zzt_qtbc= --张仲天-潜土冰刺
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_ld_normal= --路达-离火镖-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_ld_ycsy= --路达-杨穿三叶
    { 
		attack_usebasedamage_p={{{1,110},{20,110}}},
		missile_hitcount={0,0,3},
    },
	partner_ls_normal= --李三-弓术-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_ls_zj= --李三-重箭
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_lq_normal= --卢青-衡山剑法-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_lq_nyzt= --卢青-南岳支天
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_ye_normal= --莺儿-袖里箭-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_ye_sb= --莺儿-散镖
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
	partner_gw_normal= --顾武-挥砍-普攻
    { 
		attack_usebasedamage_p={{{1,173},{20,173}}},
		missile_hitcount={0,0,3},
    },
	partner_gw_byz= --顾武-半月斩
    { 
		attack_usebasedamage_p={{{1,276},{20,276}}},
		missile_hitcount={0,0,3},
    },
}

FightSkill:AddMagicData(tb)