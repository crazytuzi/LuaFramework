
local tb    = {
    tw_xyj = {--普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_hurt_attack={40,4},
		
		state_npcknock_attack={100,7,25},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    tw_jlj = {--普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_hurt_attack={55,4},

		state_npcknock_attack={100,7,45},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },

    tw_xlj = {--普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_metaldamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
			},
		state_hurt_attack={75,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},

    },
    tw_ptj = {--普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_metaldamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
			},
		state_hurt_attack={100,10},

		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
    },
	
	tw_ymcz = {--野蛮冲撞--1级主动1--15级
		skill_mintimepercast_v={7*15},
		
		userdesc_000={207},
    },
    tw_ymcz_child = {--野蛮冲撞_子--15级
		attack_usebasedamage_p={{{1,305},{15,467},{20,525}}},
		attack_metaldamage_v={
			[1]={{1,305*2*0.9},{15,467*2*0.9},{20,525*2*0.9}},
			[3]={{1,305*2*1.1},{15,467*2*1.1},{20,525*2*1.1}}
			},
		state_fixed_attack={100,{{1,11},{15,25},{20,30}}},
		state_hurt_attack={100,{{1,15*0.5},{15,15*1},{20,15*1.5}}},
		
		missile_hitcount={3,0,0},
    },
	
	tw_book1 = { --野蛮冲撞秘籍
		add_hitskill1={207,217,{{1,1},{10,10},{20,20}}},					--野蛮冲撞后提高基础会心
		
		add_usebasedmg_p1={207,{{1,0},{10,0},{11,11},{15,55},{20,55}}},		--增加野蛮冲撞攻击力
		
		add_steallife_p={207,{{1,0},{15,0},{16,1000},{20,5000}}},  			--增加吸血%
		
		skill_statetime={-1},
		
		userdesc_000={217},
	},
    tw_book1_child1  = {--野蛮冲撞_秘籍提高会心
		--attackspeed_v={{{1,20},{10,50},{15,60},{20,80}}},
		deadlystrike_p={{{1,9},{10,90},{20,90}}},
		--deadlystrike_v={{{1,50},{10,150},{15,200},{20,200}}},
		skill_statetime={10*15},
    },
	
    tw_xzbf = {--血战八方--4级主动2--15级
		userdesc_000={211},
		skill_mintimepercast_v={{{1,35*15},{15,25*15},{16,25*15},{21,25*15}}},
    },
    tw_xzbf_child1 = {--血战八方_子1--15级
		attack_usebasedamage_p={{{1,224},{15,291},{20,315}}},
		attack_metaldamage_v={
			[1]={{1,224*2*0.9},{15,291*2*0.9},{20,315*2*0.9}},
			[3]={{1,224*2*1.1},{15,291*2*1.1},{20,315*2*1.1}}
		},
		state_hurt_attack={0,0},	--秘籍支持
		state_npcknock_attack={100,7,30},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    tw_xzbf_child2 = {--血战八方_子2--15级
		ignore_series_state={},
		ignore_abnor_state={},
		ignore_skillstate1={4451},	--玉泉鱼跃减速
		--ignore_skillstate2={4458},	--平湖断月减速
		--ignore_skillstate3={4432},	--
		skill_statetime={7*15},
    },

	tw_book2 = { --血战八方秘籍
		add_usebasedmg_p1={211,{{1,3},{10,24},{15,48},{20,48}}},	--增加攻击力,初始伤害调低了,受伤一开始也算进去了,这里给的是10级数值+初始额外降低的值
		
		add_hurt_r={212,{{1,0},{10,0},{11,8},{15,40},{20,40}}}, --增加受伤几率
		add_hurt_t={212,{{1,0},{10,0},{11,5},{15,5},{20,5}}},  	--增加受伤时间
		
		addstartskill={212,{{1,0},{15,0},{16,3446},{20,3446}},{{1,0},{15,0},{16,16},{20,20}}},		--附加过程减伤
		
		skill_statetime={-1},
		
		userdesc_000={3446},
	},
    tw_book2_child3 = {--高级血战八方_子
		runspeed_v={{{1,0},{15,0},{16,25},{20,25}}},									--增加移动速度
		remote_dmg_p={{{1,0},{15,0},{16,-5},{20,-50}}},
		skill_statetime={5.5*15},
    },
	
	tw_dmxy = {--金钟罩-10级主动3--15级
		all_series_resist_p={{{1,90},{15,405},{20,540}}},
		--recover_life_v={{{1,100},{15,500},{16,526},{21,700}},15*5},
		all_series_resist_v={{{1,50},{15,225},{20,300}}},
		resist_allseriesstate_rate_v={{{1,35},{15,150},{20,200}}},
		skill_statetime={15*15},
		
		skill_mintimepercast_v={30*15},
    },
	
	tw_book3 = { --金钟罩秘籍
		addstartskill={213,254,{{1,1},{10,10},{20,20}}},		--附加回血
		
		deccdtime={213,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},
		add_state_time1={213,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},  	--增加金钟罩持续时间
		
		addstartskill2={254,{{1,0},{15,0},{16,3450},{20,3450}},{{1,0},{15,0},{16,16},{20,20}}},		--提高金钟罩效果
		
		skill_statetime={-1},
		
		userdesc_000={254,3450},
	},
    tw_book3_child1 = {--金钟罩初始回血
		dir_recover_life_pp={{{1,76},{10,760},{11,760}},1},		--生命上限万分比,自身数值
		skill_statetime={1},
    },
    tw_book3_child3  = {--高级金钟罩_子
		all_series_resist_p={{{1,0},{15,0},{16,30},{20,150}}},
		lifereplenish_p={{{1,0},{15,0},{16,4},{20,20}}},
		skill_statetime={{{1,0},{15,0},{16,16*15},{20,20*15}}},
    },
	
    tw_twzy = {--天王战意-20级被动1--10级
		physics_potentialdamage_p={{{1,15},{10,35},{12,42}}},
		lifemax_p={{{1,35},{10,55},{12,66}}},
		state_zhican_resistrate={{{1,35},{10,150},{11,165}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    tw_bwnh = {--霸王怒吼--30级主动4--15级
		attack_usebasedamage_p={{{1,528},{15,770},{20,856}}},
		attack_metaldamage_v={
			[1]={{1,528*2*0.9},{15,770*2*0.9},{20,856*2*0.9}},
			[3]={{1,528*2*1.1},{15,770*2*1.1},{20,856*2*1.1}}
		},
		state_hurt_attack={{{1,50},{15,100},{16,100},{21,100}},{{1,15*0.5},{15,15*2},{16,15*2},{21,15*2}}},
		state_npcknock_attack={100,7,80},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={6,0,0},
		
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
    },
	
	tw_book4 = { --霸王怒吼_秘籍
		add_hitskill1={208,221,{{1,1},{10,10},{20,20}}},
		
		--add_hurt_r={208,{{1,0},{15,0},{16,5},{20,20}}},  						--增加受伤几率
		add_hurt_t={208,{{1,0},{10,0},{11,15*0.3},{15,15*1.5},{20,15*1.5}}},  	--增加受伤时间
		add_usebasedmg_p1={208,{{1,0},{10,0},{11,8},{20,85}}},					--增加霸王怒吼攻击力,分散到10级内
		
		addstartskill={206,{{1,0},{15,0},{16,3448},{20,3448}},{{1,0},{15,0},{16,16},{20,20}}},				--野蛮冲撞缩短霸王cd
		
		skill_statetime={-1},
		
		userdesc_000={221,3448},
	},
    tw_book4_child1 = {--初级霸王怒吼
		melee_dmg_p={{{1,-1},{10,-4},{20,-4}}},
		remote_dmg_p={{{1,-1},{10,-4},{20,-4}}},
		superposemagic={6},
		skill_statetime={{{1,5.5*15},{10,10*15},{20,10*15}}},
    },
	tw_book4_child3 = {--高级霸王怒吼
		reduce_cd_time1={208,{{1,0},{15,0},{16,0.4*15},{20,2*15}}},
    },
	
    tw_yjdq = {--一骑当千-40级被动2--10级
		add_mult_proc_sate1={225,{{1,6},{10,6},{11,6}},60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
		userdesc_000={225},
    },
    tw_yjdq_child = {--一骑当千_子--10级
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		all_series_resist_p={{{1,20},{10,60},{11,64}}},
		skill_statetime={{{1,15*10},{10,15*10},{11,15*10}}},
    },
	
    tw_gjcf = {--高级锤法-50级被动3--10级
		add_skill_level={201,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={202,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={203,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={204,{{1,1},{10,10},{11,11}},0},
		skill_statetime={-1},
		
		userdesc_000={230},
    },
    tw_gjcf_child = {--高级锤法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_metaldamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
		},
    },
    tw_jlpt = {--惊雷破天-60级被动4--10级
		autoskill={22,{{1,1},{10,10},{11,11}}},
		userdesc_000={241},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    tw_jlpt_child = {--惊雷破天_子
		physics_potentialdamage_p={{{1,3},{10,30},{11,33}}},
		superposemagic={6},				--叠加层数
		skill_statetime={6.5*15},
    },
	
    tw_pfcz = {--破釜沉舟-70级被动5--10级
		autoskill={21,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},
		
		userdesc_000={219},
		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的破釜沉舟
		userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--描述用，实际触发间隔请查看autoskill.tab中的破釜沉舟
    },
    tw_pfcz_child  = {--破釜沉舟_子--10级
		change_buf_lasttime={241,6.5*15},
		invincible_b={1,1},
	 	dir_recover_life_pp={{{1,200},{10,1800},{11,1800}},1},		--生命上限万分比,自身数值
		--recover_life_p={{{1,1},{10,3},{11,3}},15},
		skill_statetime={{{1,15*2},{10,15*6},{11,15*6}}},
    },
	
    tw_twbs = {--天王本生-80级被动6--20级
		physics_potentialdamage_p={{{1,10},{20,30},{24,30*1.2}}},
		lifemax_p={{{1,10},{20,100},{24,100*1.2}}},
		all_series_resist_p={{{1,3},{20,55},{24,55*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		state_hurt_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_zhican_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },

	tw_qgbh = {--气盖八荒-90级被动7--10级
		autoskill={128,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},

		lifecurmax_p={{{1,1},{10,5},{20,10}}},
		userdesc_000={247},
		userdesc_101={{{1,20},{10,50},{11,50}}},				--触发几率的描述，实际间隔在auto.tab中修改
	},
	tw_qgbh_child = {--气盖八荒_子
		damage_maxlife_p={{{1,250},{10,1000},{11,1100}},1}, 
		missile_hitcount={3,0,0},
	},
	
    tw_ryshs = {--日月山河碎-怒气
		userdesc_000={0},
    },
    tw_ryshs_child1 = {--日月山河碎_子1
		attack_usebasedamage_p={{{1,1000},{30,500}}},
		attack_metaldamage_v={
			[1]={{1,100*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,100*1.1},{30,2000*1.1},{31,2000*1.1}}
		},
    },
	tw_ryshs_child2 = {--日月山河碎_子2
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
    },
}

FightSkill:AddMagicData(tb)