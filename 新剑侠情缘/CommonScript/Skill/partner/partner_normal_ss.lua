
local tb    = {
	partner_dgj_normal= --独孤剑-衡山有雪-普攻
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},	
		missile_hitcount={0,0,3},
    },
	partner_dgj_mjh = --独孤剑-满江红
    { 
	 	userdesc_000={2673},
    },
	partner_dgj_mjh_child = --独孤剑-满江红_子
    { 
		attack_usebasedamage_p={{{1,139},{20,139}}},
	 	userdesc_101={{{1,20},{20,20}}},				--描述用，与partner_dgj_mjh_buff中的全抗一致
		missile_hitcount={0,0,3},	
    },
	partner_dgj_mjh_buff = --独孤剑-满江红_buff
    { 
		all_series_resist_v={{{1,20},{20,20}}},
		superposemagic={{{1,10},{10,10}}},				--叠加层数		
		skill_statetime={{{1,15*10},{15,15*10}}},
    },
	partner_ngfy_normal= --南宫飞云-雪一刀-普攻
    { 
		attack_usebasedamage_p={{{1,218},{20,218}}},	
		missile_hitcount={0,0,3},
    },
	partner_ngfy_hfhdj = --南宫飞云-花飞蝴蝶剑
    { 
		userdesc_000={2852},		
    },
	partner_ngfy_hfhdj_child = --南宫飞云-花飞蝴蝶剑
    { 
		attack_usebasedamage_p={{{1,97},{20,97}}},	
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
		missile_hitcount={0,0,3}, 			
    },
	partner_yyf_normal= --杨影枫-绝情断意剑-普攻
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},	
		missile_hitcount={0,0,3},
    },
	partner_yyf_zyptj= --杨影枫-镇狱破天劲
    { 
		defense_v={{{1,600},{20,600}}},			
		autoskill={9,{{1,1},{10,10},{31,10}}},
		userdesc_000={2872},
		userdesc_101={{{1,15*10},{20,15*10}}},			--描述用，要跟当前技能skill_statetime一样
		skill_statetime={{{1,15*10},{15,15*10}}},		
    },
	partner_yyf_zyptj_child1= --杨影枫-镇狱破天劲_子
    { 
		physics_potentialdamage_p={{{1,20},{10,20},{11,20}}},
		deadlystrike_v={{{1,20},{10,20},{11,20}}},
		superposemagic={{{1,5},{10,5}}},						--叠加层数						
		buff_end_castskill={2889,{{1,1},{10,10}}},
		userdesc_103={{{1,139},{20,139}}},						--假的魔法属性描述，实际看 partner_yyf_zyptj_child2 的攻击力，要一致
		userdesc_102={{{1,15*10},{20,15*10}}},					--描述用，要跟当前技能skill_statetime一样
		skill_statetime={{{1,15*10},{15,15*10}}},
    },
	partner_yyf_zyptj_child2= --杨影枫-镇狱破天劲_子
    { 
		attack_usebasedamage_p={{{1,139},{20,139}}},	
		missile_hitcount={0,0,3},
    },
	partner_yf_normal= --岳飞--普攻
    { 
		attack_usebasedamage_p={{{1,218},{20,218}}},
		state_stun_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},		
		missile_hitcount={0,0,3},
    },
	partner_yf_zgbr = --岳飞-忠贯白日
    { 
		autoskill={11,{{1,1},{20,20}}},
		magicshield={{{1,15*100},{20,15*100}},{{1,15*15},{15,15*15}}},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={{{1,15*15},{20,15*15}}},
		userdesc_000={1773},	
    },
	partner_yf_zgbr_child = --岳飞-忠贯白日_子
    { 
		attack_usebasedamage_p={{{1,97},{20,97}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*1},{15,15*1}}},
		missile_hitcount={0,0,1},
    },
	partner_yj_normal= --虞姬-普攻
    { 
		attack_usebasedamage_p={{{1,218},{20,218}}},
		skill_randskill1={{{1,50},{20,50}},1774,{{1,1},{20,20}}},				--概率，技能ID，技能等级
		skill_randskill2={{{1,50},{20,50}},1775,{{1,1},{20,20}}},	
		skill_randskill3={{{1,50},{20,50}},1776,{{1,1},{20,20}}},	
		skill_randskill4={{{1,50},{20,50}},1777,{{1,1},{20,20}}},	
		skill_randskill5={{{1,50},{20,50}},1778,{{1,1},{20,20}}},			
		missile_hitcount={0,0,3},
    },
	partner_yj_normal_child1 = --虞姬-普攻_子1   
    { 
		state_fixed_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},
    },
	partner_yj_normal_child2 = --虞姬-普攻_子2   
    { 
		state_slowall_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},
    },
    partner_yj_normal_child3 = --虞姬-普攻_子3   
    { 
		state_palsy_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},
    },
    partner_yj_normal_child4 = --虞姬-普攻_子4   
    { 
		state_zhican_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},
    },
    partner_yj_normal_child5 = --虞姬-普攻_子5  
    { 
		state_stun_attack={{{1,50},{20,50}},{{1,15*1},{15,15*1}}},
    },
    partner_yj_jb = --虞姬-诀别
    { 
		autoskill={12,{{1,1},{20,20}}},
		skill_statetime={{{1,15*120},{20,15*120}}},
		userdesc_000={2858},	
		userdesc_101={{{1,15*10},{15,15*10}}},				--假描述，需要与partner_yj_jb_child1持续时间的参数一致
		userdesc_102={{{1,100},{20,100}},15},					--假描述，需要与partner_yj_jb_child2回复生命的参数一致
    },
	partner_yj_jb_child1= --虞姬-诀别_子1
    { 
		physics_potentialdamage_p={{{1,50},{20,50}}},
		missile_hitcount={0,0,1},
		skill_statetime={{{1,15*120},{15,15*120}}},
    },
	partner_yj_jb_child2= --虞姬-诀别_子2
    { 
		vitality_recover_life={{{1,100},{20,100}},15},
		missile_hitcount={0,0,1},
		skill_statetime={{{1,15*10},{20,15*10}}},
    },
	partner_jk_normal= --荆轲-荆轲刺
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},	
		missile_hitcount={0,0,3},
    },
    partner_jk_ayc = --荆轲-暗影刺
    { 
		keephide={},
		runspeed_v={{{1,100},{20,100}}},
		hide={{{1,15*15},{20,15*15}},1},				--参数1时间，参数2：队友1，同阵营2
		autoskill={13,{{1,1},{20,20}}},	
		userdesc_000={1781},			
		userdesc_104={{{1,15*15},{20,15*15}}},	
		skill_statetime={{{1,15*15},{20,15*15}}},
    }, 
    partner_jk_ayc_child = --荆轲-暗影刺_破隐普攻加成buff
    { 
		ignore_defense_v={{{1,1000},{20,1000}}},
		attackspeed_v={{{1,100},{20,100}}},
		deadlystrike_v={{{1,10000},{20,10000}}},
		link_skill_buff={},				--连招内保持当前加成BUFF的魔法属性
		addaction_event1={1779,1782},		--技能1779被1782替换
		addaction_event2={1784,1783},		--技能1784被1783替换
		skill_statetime={{{1,15*4},{20,15*4}}},
    },
    partner_jk_ayc_pg1 = --荆轲-暗影刺_攻击1
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},
		missile_hitcount={0,0,3},
    }, 
    partner_jk_ayc_pg2 = --荆轲-暗影刺_攻击2
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},
		missile_hitcount={0,0,3},
    }, 
	partner_lyb_normal= --李元霸-普攻
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},
		state_hurt_attack={{{1,40},{20,40}},{{1,4},{20,4}}},
		state_npchurt_attack={40,4},	
		missile_hitcount={0,0,3},
    },
	partner_lyb_sbdl= --李元霸-山崩地裂
    { 
		attack_usebasedamage_p={{{1,360},{20,360}}},
		state_hurt_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		state_npchurt_attack={100,15*2},
		missile_hitcount={0,0,3},
    },
	partner_zy_normal= --赵云-普攻
    { 
		attack_usebasedamage_p={{{1,240},{20,240}}},
		state_zhican_attack={{{1,40},{20,40}},{{1,4},{20,4}}},
		missile_hitcount={0,0,3},
    },
	partner_zy_qtsp= --赵云-七探蛇盘
    { 
		userdesc_000={3206},
    },
	partner_zy_qtsp_child= --赵云-七探蛇盘_子1
    { 
		attack_usebasedamage_p={{{1,170},{20,170}}},
		missile_hitcount={0,0,3},
    },
	partner_lg_normal= --李广-普攻
    { 
		attack_usebasedamage_p={{{1,218},{20,218}}},
		state_knock_attack={40,6,30},
		state_npcknock_attack={40,6,30},
		spe_knock_param={4 , 4, 9},
		missile_hitcount={0,0,1},
    },
	partner_lg_ssbh= --李广-射石搏虎
    { 
		attack_usebasedamage_p={{{1,340},{20,340}}},
		state_knock_attack={40,12,30},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 9},
		state_palsy_attack={{{1,100},{20,100}},{{1,15*3},{20,15*3}}},
		attack_deadlystrike_p={100},		--会心几率
		missile_hitcount={0,0,1},
    },
	partner_tj_normal= --唐简-普攻
    { 
		attack_usebasedamage_p={{{1,220},{20,220}}},
		missile_hitcount={0,0,1},
    },
    partner_tj_jgfx = --唐简-九宫飞星
    { 
		userdesc_000={3279},
    },	
    partner_tj_jgfx_child = --唐简-九宫飞星_子
    { 
		attack_usebasedamage_p={{{1,55},{15,55},{16,55}}},
		state_zhican_attack={{{1,100},{15,100},{16,100}},{{1,15*1},{15,15*1},{16,15*1}}},
		missile_hitcount={{{1,1},{15,1},{16,1}}},
    },
}

FightSkill:AddMagicData(tb)