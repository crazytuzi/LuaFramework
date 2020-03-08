
local tb    = {
    xy_qf1 = {--逍遥枪法-普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={40,4},
		state_npcknock_attack={100,7,50},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    xy_qf2 = {--逍遥枪法-普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={60,4},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    xy_qf3 = {--逍遥枪法-普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_wooddamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_zhican_attack={80,6},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    xy_qf3_jt = {--逍遥枪法-普攻3式击退用--20级
		attack_attackrate_v={100},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
    },
    xy_qf4 = {--逍遥枪法-普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_wooddamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
			},
		state_zhican_attack={80,6},
		spe_knock_param1={1},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
    xy_bhgr = {--白虹贯日-1级主动--10级
		userdesc_000={511},
		skill_mintimepercast_v={{{1,15*15},{15,12*15},{16,12*15},{21,12*15}}},
    },
    xy_bhgr_child1 = {--白虹贯日_子1--10级
		attack_usebasedamage_p={{{1,379},{15,704},{20,1220}}},
		attack_wooddamage_v={
			[1]={{1,379*2*0.9},{15,704*2*0.9},{20,1220*2*0.9}},
			[3]={{1,379*2*1.1},{15,704*2*1.1},{20,1220*2*1.1}}
		},
		state_zhican_attack={{{1,25},{15,50},{16,50},{21,50}},2.5*15},
		state_fixed_attack={0,0},  --秘籍需要用到
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},
		
		missile_hitcount={3,0,0},
    },

    xy_book1 = {--白虹贯日秘籍
		add_zhican_r={511,{{1,3},{10,25},{20,25}}},		--增加白虹贯日造成致残的几率
		add_fixed_r={511,{{1,5},{10,50},{20,50}}},		--增加造成定身的概率
		add_fixed_t={511,2.5*15},						--增加造成定身的时间

		add_usebasedmg_p1={511,{{1,0},{10,0},{11,23},{15,115},{20,115}}},	--增加白虹贯日攻击力

		add_deadlydmg_p1={709,{{1,0},{15,0},{16,12},{20,60}}},				--增加会心伤害

		skill_statetime={-1},
    },

    xy_qtsp = {--七探蛇盘-4级主动2--10级
		userdesc_000={508},
		skill_mintimepercast_v={{{1,30*15},{15,25*15},{16,25*15},{21,25*15}}},
    },
    xy_qtsp_child1 = {--七探蛇盘_子--10级
		attack_usebasedamage_p={{{1,286/2},{15,764/2},{20,934/2}}},
		attack_wooddamage_v={
			[1]={{1,286/2*2*0.9},{15,764/2*2*0.9},{20,934/2*2*0.9}},
			[3]={{1,286/2*2*1.1},{15,764/2*2*1.1},{20,934/2*2*1.1}}
		},
		state_npchurt_attack={100,6},
		
		missile_hitcount={3,0,0},
    },
	xy_qtsp_child2 = {--七探蛇盘_子4(免疫)--10级
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		invincible_b={1},			--无敌
		skill_statetime={{{1,15*5},{15,15*5},{16,15*5},{21,15*5}}},
    },

    xy_book2 = {--七探蛇盘秘籍
		add_hitskill1={508,518,{{1,1},{10,10},{20,20}}},
		add_melee_float={507}, 							--动作技能能选中空中目标
		add_hit_float1={508},							--标记子弹能打空中目标
		add_hit_float2={518},							--标记子弹能打空中目标

		deccdtime={507,{{1,0},{10,0},{11,1.4*15},{15,7*15},{20,7*15}}},		--cd降低

		skill_statetime={-1},

		userdesc_000={518},
    },
    xy_book2_child1 = {--七探蛇盘秘籍_子
		attack_usebasedamage_p={{{1,30},{10,85},{20,125}}},
		attack_wooddamage_v={
			[1]={{1,30*2*0.9},{10,85*2*0.9},{20,125*2*0.9}},
			[3]={{1,30*2*1.1},{10,85*2*1.1},{20,125*2*1.1}}
		},
		state_dragfloat_attack={100,7,50},		--击落空中目标：概率，时间，速度

		resist_allseriesstate_rate_v={{{1,0},{15,0},{16,-30},{20,-150}}},
		resist_allspecialstate_rate_v={{{1,0},{15,0},{16,-30},{20,-150}}},
		skill_statetime={{{1,0},{15,0},{16,15*15},{20,15*15}}},
		
		missile_hitcount={0,0,1},
    },

	xy_dzxy = {--斗转星移-10级主动3--15级
		attack_usebasedamage_p={{{1,245},{15,322},{20,550}}},
		attack_wooddamage_v={
			[1]={{1,245*2*0.9},{15,322*2*0.9},{20,550*2*0.9}},
			[3]={{1,245*2*1.1},{15,322*2*1.1},{20,550*2*1.1}}
		},
		state_zhican_attack={{{1,100},{15,100},{16,100},{21,100}},{{1,15*1.5},{15,15*1.5},{16,15*1.5},{21,15*1.5}}},

		missile_hitcount={3,0,0},
		
		skill_mintimepercast_v={{{1,15*15},{15,10*15},{16,10*15},{21,10*15}}},
    },
	xy_dzxy_child = {--斗转星移_子--15级
		state_drag_attack={{{1,100},{15,100},{16,100},{21,100}},8,70},
		skill_drag_npclen={70},
		missile_hitcount={3,0,0},
    },

    xy_book3 = {--高级斗转星移
		add_steallife_p={506,{{1,500},{10,5000},{20,9000}}},				--技能ID，吸血万分比

		add_usebasedmg_p1={506,{{1,0},{10,0},{11,6},{15,27},{20,85}}},			--增加斗转星移攻击力
		add_zhican_t={506,{{1,0},{10,0},{11,0.3*15},{15,1.5*15},{20,1.5*15}}},				--增加斗转星移造成致残的时间

		deccdtime={506,{{1,0},{15,0},{16,1*15},{20,5*15}}},

		skill_statetime={-1},
    },

    xy_xwxg = {--小无相功-20级被动1--10级
		--physics_potentialdamage_p={{{1,3},{10,25},{12,30}}},
		deadlystrike_p={{{1,8},{10,75},{12,75*1.2},{16,75*1.6},{17,232}}},
		attackspeed_v={{{1,3},{10,30},{11,33},{16,48},{17,68}}},
		runspeed_v={{{1,10},{10,50},{11,55},{16,80},{17,80}}},
		state_stun_resistrate={{{1,15},{10,150},{11,165}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },

    xy_fjcy = {--风卷残云-30级主动4--15级
		dotdamage_wood={
			[1] = {{1,40},{15,119},{20,146}},		--基础攻击力
			[2] = {{1,40*2},{15,119*2},{21,146*2}},	--点数伤害
			[3] = {{1,5},{15,5},{16,5},{21,5}}				--伤害间隔
		},
		skill_statetime={{{1,15*3},{15,15*3},{16,15*3},{21,15*3}}},
		missile_hitcount={3,0,0},

		skill_mintimepercast_v={{{1,45*15},{15,35*15},{20,35*15}}},
		
		userdesc_000={512},
    },
    xy_fjcy_child = {--风卷残云子-浮空
		state_float_attack={{{1,100},{15,100},{16,100},{21,100}},{{1,15*3},{15,15*3},{16,15*3},{21,15*3}}},
		missile_hitcount={0,0,3},
    },
	
    xy_book4 = {--高级风卷残云
		add_hitskill1={513,520,{{1,1},{10,10},{20,20}}},
		add_hit_float1={520},											--标记子弹能打空中目标
		
		deccdtime={513,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},
		
		add_dotdamage_wood={513,{{1,0},{15,0},{16,5},{20,27}},0},			--增加风卷残云的攻击力
		
		skill_statetime={-1},
		
		userdesc_000={520},
    },
    xy_book4_child1 = {--高级风卷残云_子1
		state_zhican_attack={100,{{1,2*15},{10,5.5*15},{20,5.5*15}}},
		all_series_resist_p={{{1,-24},{10,-240},{20,-240}}},
		skill_statetime={10*15},
    },

    xy_sygy = {--三元归一-40级被动2--10级
		autoskill={51,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},
		
		userdesc_000={523},
    },
    xy_sygy_child1 = {--三元归一_子1--10级_523
		autoskill={52,{{1,1},{10,10},{11,11}}},
		physics_potentialdamage_p={{{1,10},{10,20},{11,42}}},
		superposemagic={{{1,3},{10,15},{11,15}}},
		skill_statetime={4*15},
    },
    xy_sygy_child2 = {--三元归一_子2--闪避三元归一,此buff不会重复获取_524,考虑结束后清除三元归一,
		ignore_dmgskill_id={10000,523},
		--buff_end_castskill={525,{{1,1},{10,10}}},
		skill_statetime={4.1*15},
    },
    xy_sygy_child3 = {--三元归一_子3--清除三元归一_525,暂时不用
		mult_skill_state={523,{{1,1},{10,10}},-20}, 		--技能ID，等级，buff层数
    },

    xy_gjqf = {--高级枪法-50级被动3--10级
		add_skill_level={501,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={502,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={503,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={504,{{1,1},{10,10},{11,11}},0},
		--deadlystrike_v={{{1,10},{10,100},{11,110}}},
		userdesc_000={533},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    xy_gjqf_child = {--高级枪法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_wooddamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
		},
    },
    xy_lbwb = {--凌波微步-60级被动4--10级
		ignoreattackontime={{{1,30*15},{10,12*15},{11,11.5*15},{15,8.5*15},{20,6.75*15},{25,5.7*15}},1.5*15},
		skill_statetime={-1},
    },
    xy_xyyf = {--逍遥御风-70级被动5--10级
		autoskill={53,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},
		
		userdesc_000={542},
    },
    xy_xyyf_child  = {--逍遥御风_子--10级
		deadlystrike_p={{{1,5},{10,50},{11,55}}},
		defense_p={{{1,20},{10,200},{11,220}}},
		runspeed_v={{{1,10},{10,50},{11,55}}},
		ignore_abnor_state={},
		ignore_series_state={},
		superposemagic={5},
		
		skill_statetime={3*15},
    },
    xy_wwdz = {--唯我独尊-80级被动6--20级
		physics_potentialdamage_p={{{1,3},{20,45},{24,65*1.2}}},
		lifemax_p={{{1,5},{20,85},{24,95*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,3},{20,45},{24,45*1.2}}},
		state_zhican_attackrate={{{1,10},{20,200},{24,400*1.2}}},
		state_stun_resisttime={{{1,10},{20,200},{24,400*1.2}}},
		skill_statetime={-1},
    },
    xy_90_bsqf = {--悲酥清风-90级被动7--10级
		add_mult_proc_sate1={562,{{1,6},{10,6},{11,6}},60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
		userdesc_000={562},
    },
    xy_90_bsqf_child = {--悲酥清风_子--10级
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		all_series_resist_p={{{1,30},{10,60},{11,70},{12,60*1.2},{14,80*1.4}}},
		physics_potentialdamage_p={{{1,10},{10,25},{11,27},{12,25*1.2},{14,35*1.4}}},
		skill_statetime={{{1,15*8},{10,15*8},{11,15*8}}},
    },
    xy_hyxyy = {--寰宇逍遥游-怒气
		attack_usebasedamage_p={{{1,600},{30,600}}},
		attack_wooddamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,4000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,4000*1.1}}
			},
    },
	xy_hyxyy_child1 = {--寰宇逍遥游_子
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
    xy_hyxyy_child2 = {--寰宇逍遥游_伤害
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
		attack_wooddamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,4000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,4000*1.1}}
			},
    },
}

FightSkill:AddMagicData(tb)