
local tb    = {
    ym_g_pg1 = {--弓普攻1式--20级
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
    ym_g_pg2 = {--弓普攻2式--20级
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
    ym_g_pg3 = {--弓普攻3式--20级
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
    ym_g_pg4 = {--弓普攻4式--20级
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

    ym_q_pg1 = {--枪普攻1式--20级
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
    ym_q_pg2 = {--枪普攻2式--20级
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
    ym_q_pg3 = {--枪普攻3式--20级
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
    ym_q_pg4 = {--枪普攻4式--20级
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

	ym_lgjy = {--弓,流光绝影-1级主动1--15级
		skill_mintimepercast_v={10*15},
		
		userdesc_000={5461},
    },
    ym_lgjy_child = {--弓_流光绝影_子--15级
		damage_curlife_p={1,150},
		attack_usebasedamage_p={{{1,139},{15,236},{20,271}}},
		attack_metaldamage_v={
			[1]={{1,139*2*0.9},{15,236*2*0.9},{20,271*2*0.9}},
			[3]={{1,139*2*1.1},{15,236*2*1.1},{20,271*2*1.1}}
		},
		state_hurt_attack={{{1,50},{15,100},{16,100},{21,100}},{{1,15*1.5},{15,15*1.5},{16,15*1.5},{21,15*1.5}}},	
		state_npcknock_attack={100,7,60},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },
	
	ym_blq = {--枪,奔狼枪--1级主动1--15级
		skill_mintimepercast_v={10*15},
		
		userdesc_000={5470},
    },
    ym_blq_child = {--枪_奔狼枪_子--15级
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,319},{15,494},{20,556}}},
		attack_metaldamage_v={
			[1]={{1,319*2*0.9},{15,494*2*0.9},{20,556*2*0.9}},
			[3]={{1,319*2*1.1},{15,494*2*1.1},{20,556*2*1.1}}
			},
		state_hurt_attack={100,{{1,15*0.5},{15,15*1},{20,15*1.5}}},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={4,0,0},
    },
	
	ym_book1 = { --流光绝影、奔狼枪秘籍
		--初级秘籍
		add_hurt_r={5461,{{1,2},{10,20},{15,20},{20,20}}},  					--增加受伤几率
		add_hurt_t={5461,{{1,15*0.1},{10,15*1},{15,15*1},{20,15*1}}},  			--增加受伤时间
		add_usebasedmg_p1={5461,{{1,5},{10,45},{15,45},{20,45}}},				--增加流光绝影攻击力

		--中级秘籍
		add_usebasedmg_p2={5470,{{1,0},{10,0},{11,10},{15,50},{20,50}}},		--增加奔狼枪攻击力
		autoskill={157,{{1,0},{10,0},{11,11},{15,15},{20,20}}},					--触发不计算CD
		userdesc_101={{{1,0},{10,0},{11,6},{15,30},{20,30}}},					--描述用触发不计算CD

		--高级秘籍
		add_deadlydmg_p1={5461,{{1,0},{15,0},{16,8},{20,40}}},					--增加流光绝影的会心伤害
		add_deadlydmg_p2={5470,{{1,0},{15,0},{16,8},{20,40}}},					--增加奔狼枪的会心伤害
		add_hitskill1={5461,5396,{{1,0},{15,0},{16,16},{20,20}}},				--增加流光绝影的减速效果,ym_book1_high_child
		add_hitskill2={5470,5396,{{1,0},{15,0},{16,16},{20,20}}},				--增加奔狼枪的减速效果,ym_book1_high_child

		skill_statetime={-1},

		userdesc_000={5396},	
	},
	ym_book1_mid_child={  --流光绝影、奔狼枪秘籍
		reduce_cd_time1={5469,{{1,0},{10,0},{11,10*15},{16,10*15},{20,10*15}}},
	},
	ym_book1_high_child={  --流光绝影、奔狼枪秘籍
		runspeed_v={{{1,-10},{10,-100},{20,-100}}},
		skill_statetime={4*15},
	},
	
    ym_xfj = {--弓,啸风诀-4级主动3--15级
		attackspeed_v={{{1,10},{15,40},{16,42},{21,52}}},
		runspeed_v={{{1,50},{15,120},{16,122},{21,130}}},

		add_seriesstate_rate_v={{{1,30},{15,180},{16,192},{21,252}}},
		add_seriesstate_time_v={{{1,30},{15,180},{16,192},{21,252}}},
		--add_allspecialstate_rate_v={{{1,30},{15,180},{16,192},{21,252}}},
		--add_allspecialstate_time_v={{{1,30},{15,180},{16,192},{21,252}}},

		skill_statetime={10*15},

		skill_mintimepercast_v={25*15},
    },
	
	ym_qmd = {--枪,奇门盾-4级主动3--15级
		all_series_resist_p={{{1,50},{15,380},{20,505}}},
		resist_allseriesstate_rate_v={{{1,20},{15,140},{20,190}}},
		remote_dmg_p={{{1,-5},{15,-20},{20,-27}}},

		skill_statetime={10*15},
		
		skill_mintimepercast_v={25*15},
    },
    ym_qmd_child = --枪,奇门盾_圈内队友BUFF
    {
		all_series_resist_p={{{1,25},{15,190},{20,250}}},
		resist_allseriesstate_rate_v={{{1,10},{15,70},{20,95}}},
		remote_dmg_p={{{1,-1},{15,-10},{20,-14}}},

		skill_statetime={{{1,15*1},{10,15*1},{11,15*1}}},
    },
	
	ym_book2 = { --啸风诀、奇门盾秘籍
		--初级秘籍
		autoskill={34,{{1,1},{10,10},{11,11},{20,20}}}, 		--触发初级·啸风诀/奇门盾增加忽略会心与会心免伤,ym_book2_low_child
		userdesc_104={15*5},		

		--中级秘籍
		autoskill2={158,{{1,0},{10,0},{11,11},{20,20}}}, 				--触发自身濒死
		addstartskill={{{1,0},{10,0},{11,5494},{20,5494}},{{1,0},{10,0},{11,5402},{20,5402}},{{1,0},{10,0},{11,11},{20,20}}},		--触发队友濒死,ym_book2_mid_team1
 		userdesc_102={{{1,0},{10,0},{11,50},{15,90},{20,90}}},			--触发濒死的几率描述   	
 		userdesc_103={{{1,0},{10,0},{11,15*0.5},{15,15*2},{20,15*2}}},	--无敌的持续时间描述  

		--高级秘籍
		addstartskill2={{{1,0},{15,0},{16,5402},{20,5402}},{{1,0},{15,0},{16,5404},{20,5404}},{{1,0},{15,0},{16,16},{20,20}}},		--高级·啸风诀/奇门盾伤害&嘲讽,ym_book2_high_child1

		skill_statetime={-1},

		userdesc_000={5400,5404,5418},
	},
    ym_book2_low_child = {--初级秘籍：啸风诀/奇门盾
		ignore_deadlystrike_vp={{{1,20},{10,185},{20,185}}},
		weaken_deadlystrike_damage_p={{{1,10},{10,55},{20,55}}},
		skill_statetime={15*5},
    },
	ym_book2_mid_self= {--中级·啸风诀/奇门盾自身无敌
		invincible_b={1,1},		--弱无敌	
		skill_statetime={{{1,0},{10,0},{11,15*0.5},{15,15*2},{20,15*2}}},
	},
    ym_book2_mid_team1 = {--中级秘籍：啸风诀/奇门盾
		autoskill={159,{{1,0},{10,0},{11,11},{20,20}}}, 
		userdesc_101={1},							--仅用作触发技能用		
		skill_statetime={15*1},
    },
	ym_book2_mid_team2 = {--中级·啸风诀/奇门盾队友无敌
		invincible_b={1,1},		--弱无敌
		skill_statetime={{{1,0},{10,0},{11,15*0.5},{15,15*2},{20,15*2}}},
	},
    ym_book2_high_child1 = {--高级·啸风诀/奇门盾伤害&嘲讽
		state_forceatk_attack={{{1,0},{15,0},{16,100},{20,100}},{{1,0},{15,0},{16,15*2.5},{20,15*2.5}}},
		attack_usebasedamage_p={{{1,0},{15,0},{16,100},{20,270}}},
		attack_metaldamage_v={
			[1]={{1,0},{15,0},{16,100*2*0.9},{20,270*2*0.9}},
			[3]={{1,0},{15,0},{16,100*2*1.1},{20,270*2*1.1}}
			},
		missile_hitcount={4,0,0},
    },
	ym_book2_high_child2 = {--高级·奇门盾回复一次
		dir_recover_life_pp={{{1,0},{15,0},{16,30},{20,150}},1},		--生命上限,自身数值
	},

    ym_sjjs = {--弓,碎金箭术--10级主动4--15级
		damage_curlife_p={1,150},
		attack_usebasedamage_p={{{1,268},{15,577},{20,688}}},
		attack_metaldamage_v={
			[1]={{1,268*2*0.9},{15,577*2*0.9},{20,688*2*0.9}},
			[3]={{1,268*2*1.1},{15,577*2*1.1},{20,688*2*1.1}}
		},
		state_fixed_attack={{{1,50},{15,100},{16,100},{21,100}},{{1,15*0.5},{15,15*2},{16,15*2},{21,15*2}}},
		state_npcknock_attack={100,7,0},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
		
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
    },
	
    ym_hsqj = {--枪,横扫千军--10级主动4--15级
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,285},{15,621},{20,741}}},
		attack_metaldamage_v={
			[1]={{1,285*2*0.9},{15,621*2*0.9},{20,741*2*0.9}},
			[3]={{1,285*2*1.1},{15,621*2*1.1},{20,741*2*1.1}}
		},
		state_hurt_attack={100,{{1,15*0.5},{15,15*1},{20,15*1.5}}},
		state_npcknock_attack={100,7,80},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={6,0,0},
		
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
    },

	ym_book3 = { --碎金箭术、横扫千军秘籍
		--初级秘籍
		add_fixed_r={5462,{{1,2},{10,20},{20,20}}},  							--增加定身几率
		add_fixed_t={5462,{{1,15*0.3},{10,15*1.5},{20,15*1.5}}},  				--增加定身时间
		add_usebasedmg_p1={5462,{{1,8},{10,88},{20,88}}},						--增加碎金箭术攻击力,ym_sjjs

		--中级秘籍
		add_deadlydmg_p1={5473,{{1,0},{10,0},{11,6},{15,30},{20,30}}},			--增加横扫千军的会心伤害,ym_hsqj
		add_usebasedmg_p2={5473,{{1,0},{10,0},{11,10},{15,50},{20,50}}},		--增加横扫千军攻击力,ym_hsqj

		--高级秘籍
		add_hitskill1={5409,{{1,0},{15,0},{16,5408},{20,5408}},{{1,0},{15,0},{16,16},{20,20}}},

		skill_statetime={-1},

		userdesc_000={5408,5473},
	},
	--@_@
    ym_book3_child1 = {--高级横扫千军_减少自身技能cd		
		--reduce_cd_time1={5460,{{1,0},{15,0},{16,0.6*15},{20,3*15}}},			--流光绝影
		reduce_cd_time2={5462,{{1,0},{15,0},{16,0.6*15},{20,3*15}}},			--碎金箭术
		--reduce_cd_time3={5463,{{1,0},{15,0},{16,0.6*15},{20,3*15}}},			--啸风诀
		skill_statetime={1},
    },
    ym_book3_child2 = {--高级·横扫千军_触发减CD用
		missile_hitcount={0,0,6},
    },
	
    ym_txxf = {--铁血心法-20级被动1--10级
		physics_potentialdamage_p={{{1,15},{10,35},{12,42}}},
		lifemax_p={{{1,20},{10,36},{12,44}}},
		state_zhican_resistrate={{{1,35},{10,150},{11,165}}},
		runspeed_v={{{1,3},{10,30},{11,33},{16,48},{17,48}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },

    ym_changeweapon = --切换武器
    {
		skill_mintimepercast_v={{{1,5*15},{15,5*15},{20,5*15}}},
    },

    ym_q_qlgy = --枪,枪联弓映=碎金箭术
    {
    	all_series_resist_p={{{1,50},{15,280},{20,380}}},
		reduce_final_damage_p={{{1,1},{15,7.5},{20,10}}},
		add_seriesstate_rate_v={{{1,20},{15,144},{16,154},{21,204}}},
		add_seriesstate_time_v={{{1,20},{15,144},{16,154},{21,204}}},
		userdesc_000={5480},
		skill_statetime={-1},
    },
    ym_g_qlgy = --弓,枪联弓映=碎金箭术
    {
		add_seriesstate_rate_v={{{1,20},{15,144},{16,154},{21,204}}},
		add_seriesstate_time_v={{{1,20},{15,144},{16,154},{21,204}}},
		--add_allspecialstate_rate_v={{{1,20},{15,144},{16,154},{21,204}}},
		--add_allspecialstate_time_v={{{1,20},{15,144},{16,154},{21,204}}},

		skill_statetime={-1},
    },

	ym_book4 = { --枪联弓映秘籍
		--初级秘籍
		autoskill={160,{{1,1},{10,10},{20,20}}},  		--攻击命中时触发,ym_book4_low_child1
		autoskill2={161,{{1,1},{10,10},{20,20}}},		--攻击命中时触发,ym_book4_low_child2

		--中级秘籍
		add_hitskill1={5461,{{1,0},{10,0},{11,5415},{20,5415}},{{1,0},{10,0},{11,11},{20,20}}},			--减少近战抗性
		add_hitskill2={5462,{{1,0},{10,0},{11,5415},{20,5415}},{{1,0},{10,0},{11,11},{20,20}}},			--减少近战抗性
		add_hitskill_pos1={5470,{{1,0},{10,0},{11,5416},{20,5416}},{{1,0},{10,0},{11,11},{20,20}}},		--减少远程抗性
		add_hitskill_pos2={5473,{{1,0},{10,0},{11,5416},{20,5416}},{{1,0},{10,0},{11,11},{20,20}}},		--减少远程抗性

		--高级秘籍
		lifemax_p={{{1,0},{15,0},{16,12},{20,60}}},
		lifereplenish_p={{{1,0},{15,0},{16,6},{20,30}}},
		autoskill3={33,{{1,0},{15,0},{16,16},{20,20}}}, 			--触发高级·枪联弓映.换武器回血,ym_book4_high_child

		userdesc_101={{{1,15*6},{10,15*6},{20,15*6}}},				--时间描述,ym_book4_low_child1
		userdesc_102={{{1,15*10},{10,15*10},{20,15*10}}},			--时间描述,ym_book4_mid_child1
		userdesc_103={{{1,15*10},{10,15*10},{20,15*10}}},			--autoskill触发间隔,回血效果,ym_book4_high_child

		skill_statetime={-1},
		userdesc_000={5413,5415,5417},
	},
	ym_book4_low_child1 = {--初级·枪联弓映.提升弓普攻伤害
		--add_usebasedmg_p1={5456,{{1,12},{10,120},{20,120}}},				--提升弓普攻1攻击力
		add_usebasedmg_p2={5457,{{1,12},{10,120},{20,120}}},				--提升弓普攻2攻击力
		add_usebasedmg_p3={5458,{{1,12},{10,120},{20,120}}},				--提升弓普攻3攻击力
		add_usebasedmg_p4={5459,{{1,12},{10,120},{20,120}}},				--提升弓普攻4攻击力
		skill_statetime={15*6},
    },
	ym_book4_low_child2 = {--初级·枪联弓映.提升枪普攻伤害
		add_usebasedmg_p1={5465,{{1,12},{10,120},{20,120}}},				--提升弓普攻1攻击力
		add_usebasedmg_p2={5466,{{1,12},{10,120},{20,120}}},				--提升弓普攻2攻击力
		add_usebasedmg_p3={5467,{{1,12},{10,120},{20,120}}},				--提升弓普攻3攻击力
		add_usebasedmg_p4={5468,{{1,12},{10,120},{20,120}}},				--提升弓普攻4攻击力
		skill_statetime={15*6},
    },
    ym_book4_mid_child1 = {--中级·枪联弓映.减目标近程抗性
		melee_dmg_p={{{1,0},{10,0},{11,3},{15,15},{20,15}}},
		superposemagic={{{1,3},{10,3},{11,3}}},				--叠加层数
		skill_statetime={10*15},
    },
    ym_book4_mid_child2 = {--中级·枪联弓映.减目标远程抗性
		remote_dmg_p={{{1,0},{10,0},{11,3},{15,15},{20,15}}},
		superposemagic={{{1,3},{10,3},{11,3}}},				--叠加层数
		skill_statetime={10*15},
    },
	ym_book4_high_child = {--初级·枪联弓映.换武器回血
		dir_recover_life_pp={{{1,0},{15,0},{16,8},{20,88}},1},--生命上限,自身数值
	},
	
    ym_wfbd = {--万夫不当-40级被动2--10级
		add_damage_curlife_p={5461,{{1,5},{10,18},{12,21}},150},				--流光绝影：目标当前生命百分比越高伤害越高
		add_loselife_dmg_p={5470,{{1,5},{10,18},{12,21}}},						--奔狼枪：目标当前生命百分比越低伤害越高
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    ym_wfbd_child = {--万夫不当_子--10级
		add_damage_curlife_p={5462,{{1,5},{10,18},{12,21}},150},				--碎金箭术：目标当前生命越高伤害越高
		add_loselife_dmg_p={5473,{{1,5},{10,18},{12,21}}},						--横扫千军：目标当前生命越低伤害越高
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
	
    ym_pgjj = {--普攻进阶-50级被动3--10级
		--add_skill_level={5456,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={5457,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={5458,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={5459,{{1,1},{10,10},{11,11}},0},
		skill_statetime={-1},
		
		userdesc_000={5485},
    },
    ym_pgjj_child1 = {--普攻进阶-50级被动3--10级
		add_skill_level={5465,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={5466,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={5467,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={5468,{{1,1},{10,10},{11,11}},0},
		skill_statetime={-1},
    },
    ym_pgjj_child2 = {--普攻进阶_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_metaldamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
		},
    },
    ym_hfzr = {--后发制人-60级被动4--10级
		buff_addition={5471,10,{{1,1},{20,20}}},				--奇门盾中加入autoskill，触发后发制人_高抗
    	add_buffendskill1={5487,5488,{{1,1},{10,10},{20,20}}},	--高抗后清除控制
		userdesc_000={5487},									--后发制人_高抗
		userdesc_105={{{1,15*4},{15,15*4},{20,15*4}}},			--后发制人_清除控制,skill_statetime

    	addstartskill={5472,5494,{{1,1},{10,10},{20,20}}},		--后发制人_队友
		userdesc_101={{{1,80},{10,80},{11,80}}},				--描述用，实际触发几率请查看autoskill.tab中的后发制人.队友
		userdesc_102={{{1,100},{10,600},{15,900},{16,950}}},	--后发制人_队友高抗,ym_hfzr_team2,all_series_resist_p
		userdesc_103={{{1,15*4},{15,15*4},{20,15*4}}},			--后发制人_队友高抗,ym_hfzr_team2,skill_statetime
		userdesc_104={{{1,15*10},{10,15*10},{11,15*10}}},		--描述用，实际触发间隔请查看autoskill.tab中的后发制人.队友

		skill_statetime={-1},
    },
    ym_hfzr_self1 = {--后发制人_高抗
    	all_series_resist_p={{{1,200},{10,1200},{15,1800},{16,1900}}},
		skill_statetime={15*4},
    },
    ym_hfzr_self2 = {--后发制人_清除控制
		ignore_series_state={},			--免疫属性
		ignore_abnor_state={},			--免疫负面
		skill_statetime={{{1,15*4},{10,15*4},{11,15*4}}},
    },
    ym_hfzr_team1 = {--后发制人_队友
		autoskill={156,{{1,1},{10,10},{11,11}}}, 
		userdesc_101={1},							--仅用作触发技能用		
		skill_statetime={15*1},
    },
    ym_hfzr_team2 = {--后发制人_队友高抗
		all_series_resist_p={{{1,100},{10,600},{15,900},{16,950}}}, 
		buff_end_castskill={5496,{{1,1},{10,10}}},
		skill_statetime={15*4},
    },
    ym_hfzr_team3 = {--后发制人_队友高抗debuff
		ignore_skillstate1={5495},
		skill_statetime={15*10},
    },

	ym_pjyh = {--否极阳回--10级
		autoskill={153,{{1,1},{10,10},{11,11}}},    --触发奇门盾
		autoskill2={154,{{1,1},{10,10},{11,11}}}, 	--触发无敌

		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的否极阳回
		userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--描述用，实际触发间隔请查看autoskill.tab中的否极阳回
		userdesc_000={5490},		
		skill_statetime={-1},
	},
	ym_pjyh_child = {--否极阳回_无敌
		invincible_b={1,1},		--弱无敌	
		skill_statetime={{{1,15*1},{10,15*3},{11,15*3}}},
	},
	
    ym_ymbs = {--杨门本生=杨门军法-80级被动6--20级
		physics_potentialdamage_p={{{1,10},{20,30},{24,30*1.2}}},
		lifemax_p={{{1,10},{20,100},{24,100*1.2}}},
		all_series_resist_p={{{1,3},{20,55},{24,55*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		state_hurt_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_zhican_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },

    ym_ljfz_gong= {--两极反转-90级被动7--10级
		attackspeed_v={{{1,5},{10,50},{11,50}}},
		physics_potentialdamage_p={{{1,5},{10,50},{11,60}}},

		add_mult_proc_sate1={5493,5,60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={-1},

		userdesc_000={5493,5498},
		userdesc_101={{{1,5},{10,50},{11,50}},{{1,5},{10,50},{11,60}}},
    },
    ym_ljfz_gong_child = {--两极反转_子--10级
		skill_mult_relation={1}, 									--对应的NPC类型，从skillsetting.ini上查看

		attackspeed_v={{{1,-1},{10,-10},{11,-10}}},
		physics_potentialdamage_p={{{1,-1},{10,-10},{11,-12}}},
		ignore_skillstate1={5498},

		skill_statetime={3*15},
    },
    ym_ljfz_qiang= {--两极反转_持枪--10级
		attackspeed_v={{{1,5},{10,50},{11,50}}},
		physics_potentialdamage_p={{{1,5},{10,50},{11,60}}},
		
		add_mult_proc_sate2={5498,5,60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={-1},
    },
    ym_ljfz_qiang_child = {--两极反转_持枪BUFF--10级
		skill_mult_relation={1}, 									--对应的NPC类型，从skillsetting.ini上查看

		attackspeed_v={{{1,-1},{10,-10},{11,-10}}},
		physics_potentialdamage_p={{{1,-1},{10,-10},{11,-12}}},
		
		all_series_resist_p={{{1,10},{10,30},{12,34}}},
		steallife_p={{{1,1},{10,5},{12,6}}},
		ignore_skillstate1={5493},

		skill_statetime={3*15},
    },
	
    ym_nq = {--碧月飞星击-怒气
		userdesc_000={0},
    },
    ym_nq_child1 = {--碧月飞星击_子1
		attack_usebasedamage_p={{{1,1000},{30,500}}},
		attack_metaldamage_v={
			[1]={{1,100*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,100*1.1},{30,2000*1.1},{31,2000*1.1}}
		},
    },
	ym_nq_child2 = {--碧月飞星击_子2
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
    },


    ym_nq_kamo = {--日月山河碎-第四个技能
		attack_usebasedamage_p={{{1,285},{15,621},{20,741}}},
		attack_metaldamage_v={
			[1]={{1,285*2*0.9},{15,621*2*0.9},{20,741*2*0.9}},
			[3]={{1,285*2*1.1},{15,621*2*1.1},{20,741*2*1.1}}
		},
		missile_hitcount={6,0,0},
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
		--userdesc_000={5474},
    },
    ym_nq_child1_kamo = {--日月山河碎_子1
		attack_usebasedamage_p={{{1,194},{15,594},{20,656}}},
		attack_metaldamage_v={
			[1]={{1,194*2*0.9},{15,594*2*0.9},{20,656*2*0.9}},
			[3]={{1,194*2*1.1},{15,594*2*1.1},{20,656*2*1.1}}
			},
		missile_hitcount={10,0,0},
    },
	ym_nq_child2_kamo = {--日月山河碎_子2
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
    },
	

    ym_hsqj = {--枪,横扫千军--10级主动4--15级
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,285},{15,621},{20,741}}},
		attack_metaldamage_v={
			[1]={{1,285*2*0.9},{15,621*2*0.9},{20,741*2*0.9}},
			[3]={{1,285*2*1.1},{15,621*2*1.1},{20,741*2*1.1}}
		},
		state_hurt_attack={100,{{1,15*0.5},{15,15*1},{20,15*1.5}}},
		state_npcknock_attack={100,7,80},
		spe_knock_param={6 , 4, 9},
		missile_hitcount={6,0,0},
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
    },
	
	ym_blq = {--枪,奔狼枪--1级主动1--15级
		skill_mintimepercast_v={10*15},
		
		userdesc_000={5470},
    },
    ym_blq_child = {--枪_奔狼枪_子--15级
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,319},{15,494},{20,556}}},
		attack_metaldamage_v={
			[1]={{1,319*2*0.9},{15,494*2*0.9},{20,556*2*0.9}},
			[3]={{1,319*2*1.1},{15,494*2*1.1},{20,556*2*1.1}}
			},
		state_hurt_attack={100,{{1,15*0.5},{15,15*1},{20,15*1.5}}},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={4,0,0},
    },
	--------------------- By SuMiao 3596242830 ---------------------------
	--------------------- By SuMiao 3596242830 ---------------------------
}

FightSkill:AddMagicData(tb)