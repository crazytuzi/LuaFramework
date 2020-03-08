
local tb    = {
    tr_pg1 = {	--天忍刺杀术1--普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_firedamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_palsy_attack={30,4},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    tr_pg2 = {--天忍刺杀术2--普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_firedamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_palsy_attack={40,4},
		state_npcknock_attack={100,7,40},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    tr_pg3 = {--天忍刺杀术3--普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_firedamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_palsy_attack={60,6},
		state_npcknock_attack={100,7,45},
		spe_knock_param={6 , 4, 9},
		
		missile_hitcount={3,0,0},
    },
    tr_pg4 = {--天忍刺杀术4--普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_firedamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
		},
		state_palsy_attack={100,6},
		state_npcknock_attack={100,14,35},
		spe_knock_param={11 , 4, 26},
		
		missile_hitcount={3,0,0},
    },
    tr_myzt = {--魔焰在天-1级主动1--15级
		userdesc_000={707},
		keephide={},
		ms_hit_finish_vanish={},			--击中完后子弹就消失
		ms_vanish_remove_buff={706},		--子弹消失后，清掉BUFF
		ms_one_hit_count = {0,0,1},				--每次攻击最大数量
		missile_hitcount={0,0,6},
		skill_mintimepercast_v={{{1,25*15},{15,20*15},{16,20*15},{21,20*15}}},
    },
    tr_myzt_child2 = {--魔焰在天_子2--15级
		attack_usebasedamage_p={{{1,70},{15,156},{20,187}}},
		attack_firedamage_v={
			[1]={{1,70*2*0.9},{15,156*2*0.9},{20,187*2*0.9}},
			[3]={{1,70*2*1.1},{15,156*2*1.1},{20,187*2*1.1}}
		},
		state_npchurt_attack={100,10},
		state_burn_attack={{{1,10},{15,30},{16,32},{21,42}},5*15,10},  	--概率，持续时间，每次叠加百分比
		state_palsy_attack={0,0},										--配合中级秘籍的加成
		missile_hitcount={0,0,1},

		runspeed_p={{{1,-10},{15,-40},{16,-42},{21,-42}}},
		skill_statetime={5*15},
    },
	
	tr_book1 = {--魔焰在天秘籍
		add_palsy_r={707,{{1,4},{10,35},{20,35}}},			--增加麻痹几率
		add_palsy_t={707,1*15},								--增加麻痹时间	
		
		add_hitskill1={707,{{1,0},{10,0},{11,764},{20,764}},{{1,0},{10,0},{11,11},{15,15},{20,20}}},	--魔焰在天击中后提高自身攻击力,持续时间可叠加
		
		add_usebasedmg_p1={707,{{1,0},{15,0},{16,6},{20,31}}},			--增加魔焰在天攻击力%
		
		skill_statetime={-1},
		
		userdesc_000={764},
    },
    tr_book1_child2 = {--中级魔焰在天_子
		physics_potentialdamage_p={{{1,0},{10,0},{11,13},{15,85},{20,85}}},		
		skill_statetime={{{1,0},{10,0},{11,3*15},{15,3*15},{20,3*15}}},		--持续时间可叠加
    },
	
    tr_swhx = {--死亡回旋-4级主动2--10级
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,205},{15,386},{20,451}}},
		attack_firedamage_v={
			[1]={{1,205*2*0.9},{15,386*2*0.9},{20,451*2*0.9}},
			[3]={{1,205*2*1.1},{15,386*2*1.1},{20,451*2*1.1}}
		},
		state_npchurt_attack={100,15},
		state_palsy_attack={0,0},								--配合秘籍加成
		
		missile_hitcount={0,0,1},
		
		skill_point={100,100},		--参数1/100：最大充能次数，参数2/100：每次CD回复的次数
		
		skill_mintimepercast_v={{{1,20*15},{15,15*15},{16,15*15},{21,15*15}}},
    },

    tr_book2 = {--死亡回旋秘籍
		add_palsy_r={708,{{1,4},{10,40},{20,40}}},						--增加麻痹几率
		add_palsy_t={708,{{1,1.5*15},{10,1.5*15},{20,1.5*15}}},			--增加麻痹时间
		add_usebasedmg_p1={708,{{1,6},{10,65},{20,65}}},				--增加攻击力%
		
		add_skill_point1={708,{{1,0},{10,0},{11,100},{15,200},{20,200}}},		--增加最大充能次数，100=1次
		add_loselife_dmg_p={708,{{1,0},{10,0},{11,10},{15,50},{20,50}}},		--增加斩杀效果

		addstartskill={709,{{1,0},{15,0},{16,762},{20,762}},{{1,0},{15,0},{16,16},{20,20}}},				--重置魔焰七杀
		add_deadlydmg_p1={708,{{1,0},{15,0},{16,12},{20,60}}},  			--增加会心伤害
		add_deadlydmg_p2={5361,{{1,0},{15,0},{16,12},{20,60}}},  		--增加会心伤害

		skill_statetime={-1},
    },
	tr_book2_child2 = {--死亡回旋扣除魔焰七杀debuff层数
		mult_skill_state={743,{{1,10},{20,10}},{{1,0},{15,0},{16,-3},{20,-3}}}, 		--技能ID，等级，buff层数
	},

    tr_xyzy = {--血月之影-10级主动3--15级
		runspeed_v={{{1,50},{15,200},{20,200}}},
		attackspeed_v={{{1,10},{15,50},{20,50}}},
		physics_potentialdamage_p={{{1,10},{15,150},{20,200}}},
		--保证魔焰在天也能受到加成,StateReplaceRegular里设置血月加成和破隐加成不可并存
	
		keephide={},
		autoskill={71,{{1,1},{15,15},{16,16},{21,21}}},						--破隐触发
		
		hide=			{20*15,1},	--参数1时间，参数2：队友1，同阵营2
		skill_statetime={20*15},

		skill_mintimepercast_v={{{1,49*15},{15,35*15},{20,35*15}}},
		
		userdesc_101={{{1,4*15},{10,10*15},{15,10*15}}},
    },
    tr_xyzy_child1 = {--血月之影_破隐普攻替换buff--15级
		--link_skill_buff={},				--连招内保持当前加成BUFF的魔法属性,释放其他技能,连招中断,均会消失
		addaction_event1={701,714},		--技能701被714替换
		addaction_event2={702,715},		--技能702被715替换
		addaction_event3={703,716},		--技能703被716替换
		addaction_event4={704,717},		--技能704被717替换
		skill_statetime={4*15},
    },
    tr_xyzy_child2 = {--血月之影_破隐加成buff--15级
		runspeed_v={{{1,50},{15,200},{20,200}}},
		attackspeed_v={{{1,10},{15,50},{20,50}}},
		physics_potentialdamage_p={{{1,10},{15,150},{20,200}}},
		skill_statetime={{{1,4*15},{10,10*15},{15,10*15}}},
    },
	--相当于普攻1.5倍攻击,由于等级和普攻等级绑定了,所以攻击没做太大区别
    tr_xyzy_gongji1 = {--血月之影_攻击1--20级（与普攻等级走）
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_firedamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
		},
		state_palsy_attack={30,4},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
    },
    tr_xyzy_gongji2 = {--血月之影_攻击2--20级（与普攻等级走）
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_firedamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
		},
		state_palsy_attack={30,4},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
    },
    tr_xyzy_gongji3 = {--血月之影_攻击3--20级（与普攻等级走）
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_firedamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
		},
		state_palsy_attack={30,4},
		state_npcknock_attack={100,7,20},
		spe_knock_param={6 , 4, 9},
    },
    tr_xyzy_gongji4 = {--血月之影_攻击4--20级（与普攻等级走）
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*2.25},{20,90*2.25},{30,130*2.25},{31,134*2.25}}},
		attack_firedamage_v={
			[1]={{1,60*2.25*2*0.9},{20,90*2.25*2*0.9},{30,130*2.25*2*0.9},{31,134*2.25*2*0.9}},
			[3]={{1,60*2.25*2*1.1},{20,90*2.25*2*1.1},{30,130*2.25*2*1.1},{31,134*2.25*2*1.1}}
		},
		state_palsy_attack={100,6},
		state_npcknock_attack={100,14,35},
		spe_knock_param={11 , 4, 26},
    },

	tr_book3 = {--血月之影秘籍
		addstartskill={711,766,{{1,1},{10,10},{20,20}}},		--进入隐身免控和闪避
		addstartskill2={712,767,{{1,1},{10,10},{20,20}}},		--破隐爆发增加免控和闪避
		
		deccdtime={711,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},
		
		autoskill={72,{{1,0},{15,0},{16,16},{20,20}}},
		
		skill_statetime={-1},
		userdesc_000={767,744},
	},
	tr_book3_child1_1 = {--血月之影隐身中免控和闪避
		defense_p={{{1,80},{10,600},{20,600}}},
		ignore_abnor_state={},		--免疫负面效果
		state_hurt_ignore={1},		--免疫受伤
		skill_statetime={20*15},
	},
	tr_book3_child1_2 = {--血月之影破隐免控和闪避
		defense_p={{{1,80},{10,600},{20,600}}},
		ignore_abnor_state={},		--免疫负面效果
		state_hurt_ignore={1},		--免疫受伤
		skill_statetime={10*15},
	},
	tr_book3_child3 = {--血月之影破隐普攻追加目标百分比血量攻击
		damage_maxlife_p={{{1,0},{10,0},{16,2},{20,6}},150},
	},
	
    tr_hyfh = {--幻影飞狐-20级被动1--10级
		physics_potentialdamage_p={{{1,35},{10,75},{12,90}}},
		--deadlystrike_p={{{1,50},{10,100},{11,105}}},
		npc_ext_miss={{{1,40},{10,400},{11,440}}},			--增加对NPC闪避值
		state_hurt_resistrate={{{1,15},{10,150},{11,165}}},
		skill_statetime={-1},
    },
    tr_shlx = {--摄魂乱心-30级主动4--15级
		skill_mintimepercast_v={{{1,40*15},{15,35*15},{16,35*15},{21,35*15}}},
		
		userdesc_000={723},
    },
    tr_shlx_child = {--摄魂乱心_子--15级
		attack_usebasedamage_p={{{1,77},{15,165},{20,200}}},
		attack_firedamage_v={
			[1]={{1,77*2*0.9},{15,165*2*0.9},{20,200*2*0.9}},
			[3]={{1,77*2*1.1},{15,165*2*1.1},{20,200*2*1.1}}
		},
		state_confuse_attack={{{1,15},{15,30},{16,31},{21,36}},{{1,15*1.5},{15,15*1.5},{16,15*1.5},{21,15*1.5}}},
		state_drag_attack={{{1,30},{15,40},{16,40},{21,40}},8,30},
		skill_drag_npclen={0},
		state_npchurt_attack={100,10},
		--state_nojump_attack={{{1,60},{15,60},{16,60},{21,60}},{{1,15*1},{15,15*1},{16,15*1},{21,15*1}}},
		
		missile_hitcount={3,0,0},
    },
	
    tr_book4 = {--摄魂乱心秘籍
		add_hitskill1={723,769,{{1,1},{10,10},{20,20}}},				--命中后降低敌人基础闪避和效果抗性几率
		
		add_usebasedmg_p1={723,{{1,0},{10,0},{11,6},{15,32},{20,32}}},			--增加摄魂乱心攻击力%
		
		deccdtime={722,{{1,0},{15,0},{16,1.2*15},{20,6*15}}},	--cd降低
		
		skill_statetime={-1},
		
		userdesc_000={769},	
    },
    tr_book4_child1 = {--初级_摄魂乱心_
		defense_p={{{1,-15},{10,-150},{20,-150}}},
		resist_allseriesstate_rate_v	={{{1,-15},{10,-150},{20,-150}}},
		resist_allspecialstate_rate_v	={{{1,-15},{10,-150},{20,-150}}},
		skill_statetime={5*15},
    },
	
    tr_myqs = {--魔焰七杀-40级被动2--10级
		ignore_all_resist={100,{{1,4},{10,40},{11,42}}},
		autoskill={76,{{1,1},{10,10},{11,11}}},
		userdesc_101={{{1,-1},{10,-10},{11,-10}}, 4, 3*15},
		skill_statetime={-1},
    },
    tr_myqs_child1 = {--魔焰七杀-减少自身效果--10级
		ignore_all_resist={100,{{1,-1},{10,-10},{11,-10}}},
		superposemagic={4},
		skill_statetime={3*15},
    },

    tr_gjcss = {--高级刺杀术-50级被动3--10级
		add_skill_level={701,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={702,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={703,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={704,{{1,1},{10,10},{11,11}},0},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
		
		userdesc_000={729},
    },
    tr_gjcss_child = {--高级刺杀术_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_firedamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
		},
    },
	
    tr_psxk = {--破碎虚空-60级被动4--10级
		runspeed_v={{{1,3},{10,30},{11,33}}},
		autoskill={77,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},
		userdesc_000={746},
    },
    tr_psxk_child1 = {--破碎虚空_叠加闪避和负面几率抗性
		defense_p={{{1,4},{10,40},{11,44}}},
		resist_allspecialstate_rate_v={{{1,4},{10,40},{11,44}}},
		superposemagic={5},
		skill_statetime={5*15},
    },
    tr_shfx = {--圣火焚心-70级被动7--10级
		autoskill={73,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},
		
		userdesc_101={{{1,40},{10,90},{11,95}},{{1,15*39},{10,15*30},{11,15*30}}},		 --描述用，实际触发几率请查看autoskill.tab中的圣火焚心
		userdesc_000={737},
    },
	
    tr_tmjt = {--天魔解体-80级被动6--20级
		physics_potentialdamage_p={{{1,3},{20,50},{24,50*1.2}}},
		lifemax_p={{{1,4},{20,80},{24,80*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		defense_p={{{1,2},{20,25},{24,25*1.2}}},
		state_palsy_attackrate={{{1,35},{20,200},{24,200*1.2}}},
		state_hurt_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },
     tr_90_fhwj = {--飞鸿无迹
		autoskill={78,{{1,1},{10,10},{11,11}}},
		userdesc_000={771},
		userdesc_101={{{1,15*15},{10,6*15},{20,6*15}}},			--描述用，触发间隔时间，实际效果查看autoskill.tab中的飞鸿无迹
		skill_statetime={{{1,-1},{10,-1}}},
    },
    tr_90_fhwj_child = {--飞鸿无迹_子
		rand_ignoreskill={100,2,1},		--概率，数量，类型（skillsetting下定义类型）
		damage_maxlife_p={{{1,10},{10,10},{11,11}},150},
		missile_hitcount={0,0,1},
    },
    tr_qmyhs = {--千魔影幻杀-怒气
		attack_usebasedamage_p={{{1,1000},{10,800}}},
		attack_firedamage_v={
			[1]={{1,300*0.9},{10,200*0.9},{31,200*0.9}},
			[3]={{1,300*1.1},{10,200*1.1},{31,200*1.1}}
			},
    },
    tr_qmyhs_child = {--千魔影幻杀_子
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,30},{10,30}}},
    },
}

FightSkill:AddMagicData(tb)