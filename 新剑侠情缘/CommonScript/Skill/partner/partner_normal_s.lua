
local tb    = {
	partner_yme_normal= --月眉儿-风花雪月-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_yme_bxxz= --月眉儿-冰心仙子
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		missile_hitcount={0,0,1},
    },
    partner_mzq_normal = --孟知秋-落叶掌-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 	
    partner_mzq_chym = --孟知秋-沧海月明
    { 
		userdesc_000={2899},	
		all_series_resist_v={{{1,150},{20,150}}},	
		skill_statetime={{{1,15*3},{10,15*3}}},		
    },
    partner_mzq_chym_child = --孟知秋-沧海月明_敌人
    { 
		attackrate_p={{{1,-30},{20,-30}}},
		skill_statetime={{{1,15*3},{10,15*3}}},
    },
	partner_gcg_normal= --高长恭-破天斩-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
    partner_gcg_blrz = --高长恭-白狼入阵
    {
		add_mult_proc_sate1={2647,{{1,5},{10,5}},84},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={{{1,-1},{10,-1}}},
		userdesc_000={2647},
    },
    partner_gcg_blrz_child = --高长恭-白狼入阵_子
    {
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		all_series_resist_v={{{1,40},{10,40}}},
		defense_v={{{1,60},{10,60}}},
		skill_statetime={{{1,15*10},{10,15*10}}},		
    },
	partner_zhebie_normal= --哲别-追风箭-普攻
    { 
		attack_usebasedamage_p={{{1,234},{20,234}}},
		missile_hitcount={0,0,3},
    },
	partner_zhebie_wjqf = --哲别-万箭齐发
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},		
    },
	partner_qly_normal= --秦良玉-云龙击-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_qly_fssy= --秦良玉-风霜碎影
    { 
		userdesc_000={2678},
    },
	partner_qly_fssy_child= --秦良玉-风霜碎影_子
    { 
		state_slowall_attack={{{1,20},{20,20}},{{1,15*1},{20,15*1}}},
    },
	partner_ycz_normal= --袁承志-混元功-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_ycz_jsjj= --袁承志-金蛇剑诀
    { 
		userdesc_000={2520},
    },
	partner_ycz_jsjj_child = --袁承志-金蛇剑诀_子
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},
		missile_hitcount={0,0,3},	
    },
	partner_aobai_normal= --鳌拜-挥砍-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_aobai_badao = --鳌拜-霸刀
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		state_npchurt_attack={100,10}, 
		state_hurt_attack={100,10}, 
		missile_hitcount={0,0,3},		
    },
	partner_hsz_normal= --韩世忠-霸虎刀法-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_hsz_hfbf= --韩世忠-黄沙步法
    { 
		autoskill={10,{{1,1},{10,10},{11,10}}},
		userdesc_000={2546},
		skill_statetime={{{1,-1},{30,-1}}},
    },
	partner_hsz_hfbf_child= --韩世忠-黄沙步法_子
    { 
		userdesc_101={50,15*10},
		attack_usebasedamage_p={{{1,187},{20,187}}},
		missile_hitcount={0,0,3},
    },
	partner_dhjg_normal= --定海金刚-投掷-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},	
		missile_hitcount={0,0,3},
    },
	partner_dhjg_js = --定海金刚-巨石
    { 
		userdesc_000={943},		
    },
	partner_dhjg_js_child = --定海金刚-巨石_子
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*1},{20,15*1}}},
		missile_hitcount={0,0,3},		
    },
	partner_jcph_normal= --金翅鹏皇-飞羽-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},	
		missile_hitcount={0,0,1},
    },
	partner_jcph_zhenchi = --金翅鹏皇-振翅
    { 
		dotdamage_wood={{{1,125},{20,125}},{{1,0},{30,0}},{{1,8},{30,8}}},
		state_float_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
		skill_statetime={{{1,48},{30,48}}},
    },
	partner_yjxh_normal= --银角犀皇-撞击-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},	
		missile_hitcount={0,0,1},
    },
    partner_yjxh_lx = --银角犀皇-灵犀
    { 
		lifemax_v={{{1,2000},{20,2000}}},
		recover_life_v={{{1,100},{10,100}},15*2},
		skill_statetime={{{1,15*2},{20,15*2}}},	
    },
    partner_zf_normal = --张风-驭雷术-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 	
	partner_zf_hfs= --张风-呼风术
    { 
		dotdamage_wood={{{1,187},{15,187}},{{1,0},{15,0}},{{1,15},{15,15}}},  --发挥基础攻击力，攻击点数，伤害间隔
		state_float_attack={{{1,100},{30,100},{31,100}},{{1,15*3},{30,15*3},{31,15*3}}},
		skill_statetime={{{1,15*3},{15,15*3}}},
    },
    partner_ngm_normal = --南宫灭-炎阳掌-普攻
    { 
		attack_usebasedamage_p={{{1,234},{20,234}}},
		missile_hitcount={0,0,3},
    }, 
	partner_ngm_lxjc = --南宫灭-龙象九重
    { 
		defense_v={{{1,-200},{20,-200}}},	
		skill_statetime={{{1,15*10},{20,15*10}}},
    },	
	partner_ngm_lxjc_child = --南宫灭-龙象九重_子
    { 
		defense_v={{{1,500},{20,500}}},	
		skill_statetime={{{1,15*10},{20,15*10}}},
    },	
    partner_fm_normal = --方勉-心剑-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_fm_hyxj = --方勉-幻音玄剑
    { 
		attack_usebasedamage_p={{{1,50},{20,50}}},
    }, 
	partner_ty_normal= --唐影-天罗地网-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
    partner_ty_xinyan = --唐影-心眼
    { 
	 	attackspeed_v={{{1,40},{20,40}}},
	 	attackrate_v={{{1,200},{20,200}}},
	 	deadlystrike_v={{{1,200},{20,200}}},
		skill_statetime={{{1,15*10},{20,15*10}}},
    },
	partner_qys_normal = --秋依水-风卷残雪-普攻
    { 
		userdesc_000={2864},		
    },
    partner_qys_normal_child = --秋依水-风卷残雪-普攻_子
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
	partner_qys_xyhc = --秋依水-雪映红尘
    { 
		recover_life_v={{{1,100},{10,100}},15*2},		
		resist_allseriesstate_rate_v={{{1,100},{20,100}}},		
		resist_allseriesstate_time_v={{{1,100},{20,100}}},	
		skill_statetime={{{1,15*2},{20,15*2}}},		
    },
    partner_txdz_normal = --天心道长-剥及而复-普攻
    { 
		attack_usebasedamage_p={{{1,234},{20,234}}},
		missile_hitcount={0,0,3},
    },
    partner_txdz_rjhy = --天心道长-人剑合一
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		missile_hitcount={0,0,3},
    }, 	
    partner_yrx_normal = --燕若雪-无影刺-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
	partner_yrx_yx = --燕若雪-影袭
    { 
	 	userdesc_000={956},
    },	
    partner_yrx_yx_child = --燕若雪-影袭_子
    { 
		attack_deadlystrike_v={{{1,8000},{20,8000}}},
		attack_usebasedamage_p={{{1,187},{20,187}}},
		state_palsy_attack={{{1,40},{20,40}},{{1,15*2},{20,15*2}}},
    }, 
	partner_yxl_normal= --杨熙烈-凌绝剑气-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_yxl_nyct= --杨熙烈-怒焰冲天
    { 
		userdesc_000={2859},
    },
	partner_yxl_nyct_child= --杨熙烈-怒焰冲天
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
	partner_sgfl_normal= --上官飞龙-升龙剑气-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_sgfl_yljy= --上官飞龙-游龙剑意
    { 
		magic_fixshield={{{1,1000},{20,1000}},{{1,15*5},{20,15*5}}},			--参数1：吸收伤害；参数2：时间帧
		autoskill={96,{{1,1},{10,10},{31,10}}},
		userdesc_000={2868},
		buff_end_castskill={2868,{{1,1},{10,10}}},
		skill_statetime={{{1,15*5},{15,15*5}}},		
    },
	partner_sgfl_yljy_child= --上官飞龙-游龙剑意_子
    { 
		state_stun_attack={{{1,100},{20,100}},{{1,15*2},{20,15*2}}},
		missile_hitcount={0,0,3},
    },
    partner_nlql_normal = --纳兰潜凛-无忧剑诀-普攻
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 	
	partner_nlql_ylcy = --纳兰潜凛-叶落穿影
    { 
	 	userdesc_000={2685},
    },	
	partner_nlql_ylcy_child = --纳兰潜凛-叶落穿影_子
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},	
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },	
    partner_cjhh_normal = --赤睛虎皇-爪击-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_cjhh_mp = --赤睛虎皇-猛扑
    { 
		userdesc_000={3214},
    }, 
    partner_cjhh_mp_child = --赤睛虎皇-猛扑_子
    { 
		attack_usebasedamage_p={{{1,312},{20,312}}},
		attack_deadlystrike_p={100},		--会心几率
		missile_hitcount={0,0,1},
    },
    partner_htxw_normal = --撼天熊王-掌击-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_htxw_jn = --撼天熊王-激怒
    { 
		autoskill={28,{{1,1},{10,10},{11,10}}},
		userdesc_000={3217},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    partner_htxw_jn_child = --撼天熊王-激怒_子
    { 
	 	attackspeed_v={{{1,50},{20,50}}},
	 	attackrate_v={{{1,500},{20,500}}},
		skill_statetime={{{1,15*15},{20,15*15}}},
    },  
    partner_zbeh_normal = --紫背鳄皇-撕咬-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_zbeh_dy = --紫背鳄皇-毒液
    { 
		autoskill={29,{{1,1},{10,10},{11,10}}},
		userdesc_000={3221},
		skill_statetime={{{1,-1},{30,-1}}},
    }, 
    partner_zbeh_dy_child = --紫背鳄皇-毒液_伤害
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
	partner_hmlj_normal= --黑面郎君-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_hmlj_yfsg= --黑面郎君-阴风蚀骨
    { 
		dotdamage_wood={{{1,90},{20,90}}, 0 ,15*0.5}, 				--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*2.5},{20,15*2.5}}},					--毒的持续时间
		userdesc_109={{{1,6},{20,6}}},								--描述用，显示毒的次数
		skill_dot_ext_type={1},										--增加受到的毒伤%的标记，能被五毒recdot_wood_p此属性放大
		missile_hitcount={0,0,3},
    }, 
    partner_hrw_normal = --何人我-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_hrw_klyh = --何人我-亢龙有悔
    { 
		attack_usebasedamage_p={{{1,160},{20,160}}},
		missile_hitcount={0,0,3},
    },
    partner_tc_normal = --唐仇-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_tc_bylh = --唐仇-暴雨梨花
    { 
		attack_usebasedamage_p={{{1,160},{20,160}}},
		missile_hitcount={0,0,3},
    },
    partner_blxh_normal = --冰鳞蜥皇-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_blxh_hbjc = --冰鳞蜥皇-寒冰尖刺
    { 
		userdesc_000={3907},
    },
    partner_blxh_hbjc_child = --冰鳞蜥皇-寒冰尖刺_子
    { 
		attack_usebasedamage_p={{{1,90},{20,90}}},
		missile_hitcount={0,0,3},
    },
	partner_ygxh_normal= --银钩蝎皇-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
	partner_ygxh_xhg= --银钩蝎皇-蝎皇蛊
    { 
		dotdamage_wood={{{1,90},{20,90}}, 0 ,15*1}, 				--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*6},{20,15*6}}},						--毒的持续时间
		userdesc_109={{{1,6},{20,6}}},								--描述用，显示毒的次数
		skill_dot_ext_type={1},										--增加受到的毒伤%的标记，能被五毒recdot_wood_p此属性放大
		userdesc_000={3912},
		missile_hitcount={0,0,3},
    }, 
	partner_ygxh_xhg_child = --银钩蝎皇-蝎皇蛊_子
    { 
		state_zhican_attack={{{1,30},{20,30}},{{1,15*1.5},{20,15*1.5}}},
		missile_hitcount={0,0,1},
    },
    partner_kzaw_normal = --狂鬃獒皇-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    }, 
    partner_kzaw_yhty = --狂鬃獒皇-狱火天焰
    { 
		userdesc_000={3915},
    },    
    partner_kzaw_yhty_child = --狂鬃獒皇-狱火天焰
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
    partner_hzy_normal = --黄真伊-普攻
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
    partner_hzy_qswy = --黄真伊-青山我意
    { 
		userdesc_000={3919},
    },    
    partner_hzy_qswy_child = --黄真伊-青山我意_子
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },
    partner_dyr_pg = --代言人-天山琴曲
    { 
		attack_usebasedamage_p={{{1,195},{20,195}}},
		missile_hitcount={0,0,3},
    },
    partner_dyr_fylb = --林更新-飞燕凌波
    { 
		attack_usebasedamage_p={{{1,330},{20,330}}},
		missile_hitcount={0,0,3},
    },
    partner_dyr_ypys = --颖宝宝-银瓶玉碎
    { 
		attack_usebasedamage_p={{{1,330},{20,330}}},
		missile_hitcount={0,0,3},
    },
}

FightSkill:AddMagicData(tb)