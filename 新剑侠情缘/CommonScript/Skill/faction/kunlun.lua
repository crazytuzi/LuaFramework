
local tb    = {
    kl_pg1 = {--昆仑剑法--普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,120},{31,123}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,120*2*0.9},{31,123*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,120*2*1.1},{31,123*2*1.1}}
		},
		state_stun_attack={30,4},
		state_npcknock_attack={100,7,50},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },
    kl_pg2 = {--昆仑剑法--普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,120},{31,123}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,120*2*0.9},{31,123*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,120*2*1.1},{31,123*2*1.1}}
		},
		state_stun_attack={30,4},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },

    kl_pg3 = {--昆仑剑法--普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,120},{31,123}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,120*2*0.9},{31,123*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,120*2*1.1},{31,123*2*1.1}}
		},
		state_stun_attack={70,6},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },
    kl_pg4 = {--昆仑剑法--普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,120*1.5},{31,123*1.5}}},
		attack_earthdamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,120*1.5*2*0.9},{31,123*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,120*1.5*2*1.1},{31,123*1.5*2*1.1}}
		},
		state_stun_attack={100,10},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},

		missile_hitcount={3,0,0},
    },

    kl_xrzl = {--仙人指路-1级主动1--15级
		userdesc_000={4107},
		skill_mintimepercast_v={{{1,10*15},{15,4*15},{16,4*15},{21,4*15}}},
		skill_point={
			{{1,100},{10,100},{11,200},{14,200},{15,300},{20,300}},
			100,
		},		--参数1/100：最大充能次数，参数2/100：每次CD回复的次数
    },
    kl_xrzl_child = {--仙人指路_子
		attack_usebasedamage_p={{{1,327},{15,372},{20,588}}},
		attack_earthdamage_v={
			[1]={{1,327*2*0.9},{15,372*2*0.9},{20,588*2*0.9}},
			[3]={{1,327*2*1.1},{15,372*2*1.1},{20,588*2*1.1}}
		},
		state_stun_attack={{{1,4},{15,60},{20,80}},{{1,1*15},{15,1*15},{20,1*15}}},
		state_fixed_attack={{{1,4},{15,60},{20,80}},{{1,1*15},{20,2.5*15}}},
		state_npcknock_attack={100,15,20},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
	
    kl_book1 = {--仙人指路秘籍
		add_hitskill1={4107,4134,{{1,1},{10,10},{20,20}}},						--击中后增加攻速和造成眩晕时间

		add_usebasedmg_p1={4107,{{1,0},{15,0},{11,3},{15,16},{20,32}}},			--增加仙人指路攻击力
		addstartskill={4107,{{1,0},{10,0},{11,4140},{20,4140}},{{1,0},{10,0},{11,11},{15,15},{20,20}}},		--释放仙人指路后增加免疫buff

		addstartskill2={4106,{{1,0},{15,0},{16,4146},{20,4146}},{{1,0},{15,0},{16,16},{20,20}}},				--释放仙人指路后缩短啸风三连击cd

		skill_statetime={-1},

		userdesc_000={4134,4146},
    },
    kl_book1_child1 = {--仙人指路秘籍_增加会心和造成眩晕时间
		deadlystrike_p={{{1,7},{10,70},{20,70}}},
		state_stun_attacktime={{{1,30},{10,300},{20,300}}},
		skill_statetime={8*15},
    },
    kl_book1_child2 = {--仙人指路秘籍_
		ignore_abnor_state={},		--免疫负面效果
		state_slowall_ignore={1},	--免疫迟缓
		skill_statetime={2*15},
    },
    kl_book1_child3 = {--仙人指路秘籍_缩短啸风三连击cd
		reduce_cd_time1={4110,{{1,0},{15,0},{16,0.4*15},{20,2*15}}},
    },
	
	kl_xfsl = {--啸风三连-10级主动3--15级
		userdesc_000={4109},
		missile_hitcount={0,0,1},
		skill_mintimepercast_v={{{1,24*15},{15,16*15},{20,16*15}}},
    },
	kl_xfsl_child = {--啸风三连-10级主动3--15级
		attack_usebasedamage_p={{{1,107},{15,169},{20,392}}},
		attack_earthdamage_v={
			[1]={{1,107*2*0.9},{15,169*2*0.9},{20,392*2*0.9}},
			[3]={{1,107*2*1.1},{15,169*2*1.1},{20,392*2*1.1}}
		},
		state_stun_attack={{{1,25},{15,50},{20,60}},{{1,1*15},{15,2*15},{20,2*15}}},
		--state_knock_attack={100,7,50},

		--state_npcknock_attack={100,7,50},
		--spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
		skill_mintimepercast_v={{{1,24*15},{15,16*15},{20,16*15}}},
    },

	kl_book2 = {--啸风三连击秘籍
		addstartskill={4109,4154,{{1,1},{10,10},{20,20}}},					--主技能的单体跟踪旋风增加拉回
		add_steallife_p={4109,{{1,500},{10,5000},{20,5000}}},				--技能ID，吸血万分比

		add_usebasedmg_p1={4109,{{1,0},{10,0},{11,5},{15,22},{20,45}}},		--增加啸风三连击攻击力

		add_hitskill2={4109,{{1,0},{15,0},{16,4155},{20,4155}},{{1,0},{15,0},{16,16},{20,20}}},			--伤害附加减效果
		skill_statetime={-1},
		userdesc_000={4154,4155},
	},
	kl_book2_child1 = {--啸风三连击.初级拉回
		state_drag_attack={{{1,7},{10,70},{20,70}},8,90},
		skill_drag_npclen={90},
	},
	kl_book2_child3 = {--啸风三连击.高级降低敌人效果抗性
		defense_p={{{1,0},{15,0},{16,-10},{20,-50}}},
		resist_allseriesstate_rate_v={{{1,0},{15,0},{16,-30},{20,-150}}},
		resist_allspecialstate_rate_v={{{1,0},{15,0},{16,-30},{20,-150}}},
		skill_statetime={6*15},
	},

    kl_hdjz = {--混沌剑阵-4级主动2--15级
		attack_usebasedamage_p={{{1,17},{15,48},{20,59}}},
		attack_earthdamage_v={
			[1]={{1,17*2*0.9},{15,48*2*0.9},{20,59*2*0.9}},
			[3]={{1,17*2*1.1},{15,48*2*1.1},{20,59*2*1.1}}
		},
		state_npchurt_attack={100,6},
		ms_one_hit_count={6,0,0},				--每次攻击最大数量
		--missile_hitcount={0,0,6},
		skill_mintimepercast_v={20*15},
    },

	kl_book3 = {--混沌剑阵秘籍
		addms_life1={4108,{{1,0.2*15},{10,2*15},{20,2*15}}},  			--增加混沌子弹存活时间

		add_hitskill1={4108,{{1,0},{10,0},{11,4143},{20,4143}},{{1,0},{10,0},{11,11},{20,20}}},		--击中后降低敌人全抗
		
		addstartskill={4108,{{1,0},{15,0},{16,4150},{20,4150}},{{1,0},{15,0},{16,16},{20,20}}},		--释放混沌剑阵后降低受到的远程伤害
		
		skill_statetime={-1},
		userdesc_000={4143,4150},
	},
    kl_book3_child2 = {--混沌剑阵中级秘籍
		all_series_resist_p={{{1,0},{10,0},{11,-40},{15,-200},{20,-200}}},
		skill_statetime={4*15},
    },
    kl_book3_child3 = {--混沌剑阵高级秘籍
		remote_dmg_p={{{1,0},{15,0},{16,-6},{20,-30}}},
		skill_statetime={{{1,8.2*15},{10,10*15},{20,10*15}}},
    },

	kl_zxcg = {--醉仙错骨-20级被动1--10级
		physics_potentialdamage_p={{{1,5},{10,45},{12,54},{16,72},{18,94}}},
		attackspeed_v={{{1,3},{10,30},{11,33},{16,48},{17,48}}},
		runspeed_v={{{1,10},{10,50},{11,55},{16,80},{17,80}}},
		state_slowall_resistrate={{{1,35},{10,150},{11,165}}},
		skill_statetime={-1},
    },

	kl_ldjt = {--雷动九天-30级主动4--15级
		--userdesc_000={4113},
		ms_powerwhencol={50,200},  		--参数1：每次增加伤害，参数2：增加上限
		attack_usebasedamage_p={{{1,88},{15,257},{20,518}}},
		attack_earthdamage_v={
			[1]={{1,88*2*0.9},{15,257*2*0.9},{20,518*2*0.9}},
			[3]={{1,88*2*1.1},{15,257*2*1.1},{20,518*2*1.1}}
		},
		state_stun_attack={{{1,100},{15,100},{20,100}},{{1,1.5*15},{15,2*15},{20,2.5*15}}},
		ms_one_hit_count={0,0,1},
		skill_mintimepercast_v={{{1,45*15},{15,40*15},{20,40*15}}},
    },
	
	kl_book4={--雷动九天秘籍
		add_usebasedmg_p1={4112,{{1,6},{10,60},{15,121},{20,221}}},					--增加雷动九天1攻击力
		
		deccdtime={4112,{{1,0},{10,0},{11,1.4*15},{15,7*15},{20,7*15}}},		--减雷动九天的CD
		
		addstartskill={4114,{{1,0},{15,0},{16,4156},{20,4156}},{{1,0},{15,0},{16,16},{20,20}}},				--雷动九天击中目标后使自身免疫五行
		skill_statetime={-1},
		
		userdesc_000={4156},
	},
	kl_book4_child3={--雷动九天高级秘籍免控
		reduce_cd_time1={4106,{{1,0},{15,0},{16,0.6*15},{20,3*15}}},
		reduce_cd_time2={4110,{{1,0},{15,0},{16,0.6*15},{20,3*15}}},
		ignore_series_state={},		--免疫属性效果
		skill_statetime={{{1,0},{15,0},{16,3*15},{16,3*15}}},
	},

    kl_yfx = {--御风行-40级被动1--10级
		autoskill={162,{{1,1},{10,10}}},
		autoskill2={163,{{1,1},{10,10}}},
		skill_statetime={-1},

		userdesc_000={4121},
		userdesc_101={15,15*15},
    },
    kl_yfx_child = {--御风行-40级被动1--10级
		magicshield={{{1,0.5*100},{10,5*100}},4*15},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={4*15},
    },
    kl_gjjf = {--高级剑法-50级被动3--10级
		add_skill_level={4101,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={4102,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={4103,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={4104,{{1,1},{10,10},{11,11}},0},
		state_stun_attacktime={{{1,10},{10,100},{11,110}}},
		userdesc_000={4117},
		skill_statetime={-1},
    },
    kl_gjjf_child = {--高级剑法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,3},{10,30},{11,33}}},
		attack_earthdamage_v={
			[1]={{1,3*2*0.9},{10,30*2*0.9},{11,33*2*0.9}},
			[3]={{1,3*2*1.1},{10,30*2*1.1},{11,33*2*1.1}}
		},
    },
    kl_hyqk = {--混元乾坤-60级被动4--10级
		autoskill={67,{{1,1},{10,10},{11,11}}},
		userdesc_000={4119,4120},
		skill_statetime={-1},
    },
    kl_hyqk_child1 = {--混元乾坤_提高自身吸血
		steallife_p={{{1,1},{10,7},{20,34}}},
		superposemagic={3},				--叠加层数
		skill_statetime={3*15},
    },
    kl_hyqk_child2 = {--混元乾坤_降低敌人生命回复效率
		lifereplenish_p={{{1,-3},{10,-30},{11,-43}}},
		runspeed_p={{{1,-1},{10,-10},{11,-11}}},
		superposemagic={3},				--叠加层数
		skill_statetime={3*15},
    },
    kl_yqsq = {--一气三清-70级被动5--10级
		autoskill={68,{{1,1},{10,10},{11,11}}},
		userdesc_000={4131},
		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的御雷诀
		userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--描述用，实际触发间隔请查看autoskill.tab中的御雷诀
		skill_statetime={-1},
    },
    kl_yqsq_child = {--一气三清_子
		ignore_skillstate1={4121},							--由于盾会保留当前有的盾或自身盾的较大者,导致御风行盾将保命盾继承下去,所以这里免疫掉
		magicshield={{{1,3*100},{10,30*100}},6*15},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		superposemagic={10},
		skill_statetime={6*15},
    },
    kl_sakl = {--霜傲昆仑-80级被动6--20级
		physics_potentialdamage_p={{{1,2},{20,40},{24,40*1.2}}},
		lifemax_p={{{1,5},{20,95},{24,95*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,2},{20,40},{24,40*1.2}}},
		state_stun_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_slowall_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },
    kl_tqdz = {--天清地浊-90级被动7--10级
		attackspeed_v={{{1,5},{10,50},{11,50}}},
		physics_potentialdamage_p={{{1,5},{10,50},{11,60}}},

		add_mult_proc_sate1={4153,5,60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={-1},

		userdesc_000={4153},
		userdesc_101={{{1,5},{10,50},{11,50}},{{1,5},{10,50},{11,60}}},
    },
    kl_tqdz_child = {--天清地浊_子--10级
		skill_mult_relation={1}, 									--对应的NPC类型，从skillsetting.ini上查看

		attackspeed_v={{{1,-1},{10,-10},{11,-10}}},
		physics_potentialdamage_p={{{1,-1},{10,-10},{11,-12}}},
		
		all_series_resist_p={{{1,3},{10,35},{12,35*1.2}}},
		defense_p={{{1,2},{10,20},{11,22}}},

		skill_statetime={10*15},
    },

    kl_kxzwf = {--昆虚坠无锋_伤害
		attack_usebasedamage_p={{{1,800},{30,800}}},
		attack_wooddamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,4000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,4000*1.1}}
			},
    },
    kl_kxzwf_child = {--昆虚坠无锋_免疫
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,40},{30,40}}},
    },
}

FightSkill:AddMagicData(tb)