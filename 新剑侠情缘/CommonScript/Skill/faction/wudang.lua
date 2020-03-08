
local tb    = {
    wd_pg1 = {--武当剑法--普攻1式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_stun_attack={40,4},
		state_npchurt_attack={100,7},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },
    wd_pg2 = {--武当剑法--普攻2式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_stun_attack={40,4},
		state_npchurt_attack={100,7},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },

    wd_pg3 = {--武当剑法--普攻3式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,90},{30,130},{31,134}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,90*2*0.9},{30,130*2*0.9},{31,134*2*0.9}},
			[3]={{1,60*2*1.1},{20,90*2*1.1},{30,130*2*1.1},{31,134*2*1.1}}
		},
		state_stun_attack={40,4},
		state_npchurt_attack={100,7},
		spe_knock_param={6 , 4, 9},

		missile_hitcount={3,0,0},
    },
    wd_pg4 = {--武当剑法--普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_earthdamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
		},
		state_stun_attack={60,4},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},

		missile_hitcount={3,0,0},
    },
    wd_wwwj = {--无我无剑-1级主动1--10级
		damage_curlife_p={{{1,5},{20,15},{22,16}},150},
		attack_usebasedamage_p={{{1,78},{15,186},{20,225}}},
		attack_earthdamage_v={
			[1]={{1,130*2*0.9},{15,310*2*0.9},{20,375*2*0.9}},
			[3]={{1,130*2*1.1},{15,310*2*1.1},{20,375*2*1.1}}
		},
		state_stun_attack={{{1,20},{15,80},{20,80}},8},

		state_npcknock_attack={100,15,20},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={3,0,0},

		skill_point={{{1,100},{9,100},{10,200},{14,200},{15,300},{20,300}},100}, 		--参数1/100：叠加次数，参数2/100：每次CD回复的次数

		skill_mintimepercast_v={7*15},
    },

    wd_book1 = {--无我无剑秘籍
		--永久加会伤
		deadlystrike_damage_p={{{1,3},{10,30},{15,40},{20,40}}},

		--中级.释放后下一次普攻触发剑飞惊天
		addstartskill={
			{{1,0},{10,0},{11,609},{20,609}},
			{{1,0},{10,0},{11,650},{20,650}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		--高级减cd
		deccdtime={609,{{1,0},{15,0},{16,15*0.4},{20,15*2}}},

		skill_statetime={-1},

		userdesc_000={650},
    },
    wd_book1_child2 = {--中级无我无剑秘籍
		autoskill={62,{{1,0},{10,0},{11,11},{20,20}}},				--普攻触发一次剑飞

		skill_statetime={6*15},
    },
    wd_book1_child2c = {--中级无我无剑秘籍.触发后清除buff
		mult_skill_state={650,{{1,1},{15,15}},-1},			 		--技能ID，等级，buff层数
    },

    wd_tdwj = {--天地无极-4级主动2--15级_2次伤害
		attack_usebasedamage_p={{{1,147},{15,305},{20,362}}},
		attack_earthdamage_v={
			[1]={{1,147*2*0.9},{15,305*2*0.9},{20,362*2*0.9}},
			[3]={{1,147*2*1.1},{15,305*2*1.1},{20,362*2*1.1}}
		},
		state_stun_attack	={{{1,25},{15,50},{20,50}},8},
		state_fixed_attack={0,0},  --秘籍需要用到
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={3,0,0},

		skill_mintimepercast_v={12*15},
    },

    wd_book2 = {--高级_天地无极
		--第二式每一击触发群攻
		add_hitskill_pos1={616,627,{{1,1},{10,10},{20,20}}},

		--释放后获得buff
		addstartskill={
			{{1,0},{10,0},{11,615},{20,615}},
			{{1,0},{10,0},{11,655},{20,655}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		--增加天地无极和初级秘籍的会心几率
		add_deadlystrike_p1={615,{{1,0},{15,0},{16,4},{20,20}}},  			--增加会心几率
		add_deadlystrike_p2={616,{{1,0},{15,0},{16,4},{20,20}}},  			--增加会心几率
		add_deadlystrike_p3={627,{{1,0},{15,0},{16,4},{20,20}}},  			--增加会心几率
		add_fixed_r={616,{{1,0},{15,0},{16,10},{20,50}}},					--增加造成定身的概率
		add_fixed_t={616,2.5*15},											--增加造成定身的时间

		skill_statetime={-1},

		userdesc_000={627,655},
    },
    wd_book2_child1 = {--天地无极.初级触发自身范围群攻
		attack_usebasedamage_p={{{1,30},{10,65},{20,65}}},
		attack_earthdamage_v={
			[1]={{1,30*2*0.9},{10,65*2*0.9},{20,65*2*0.9}},
			[3]={{1,30*2*1.1},{10,65*2*1.1},{20,65*2*1.1}}
		},
		missile_hitcount={0,0,3},
    },
    wd_book2_child2 = {--天地无极,吸血和忽抗增加
		steallife_p={{{1,0},{10,0},{11,3},{15,15},{20,15}}},
		ignore_all_resist_vp={{{1,0},{10,0},{11,20},{15,100},{20,100}}},

		skill_statetime={5*15},
    },

	wd_zwww = {--坐忘无我-10级主动3--15级
		ignore_dmgskill={{{1,1000},{15,5000},{16,5000}},5},										--闪避诅咒
		magicshield={
			[1] = {{1,3*100},{15,30*100},{20,40*100}},
			[2] = 12*15
		},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100

		skill_statetime={12*15},

		skill_mintimepercast_v={{{1,30*15},{15,20*15},{20,20*15}}},
    },
    wd_book3 = {--高级坐忘无我
		add_autoskill1={613,63,{{1,1},{10,10},{20,20}}},		--盾持续时间内每2秒获得buff提高人剑反击伤害和吸血比例

		add_shield={613,{{1,0},{10,0},{11,2*100},{15,10*100},{20,10*100}}},			--增加坐忘无我防御

		addstartskill={					--开启护盾后短时间内清除自身诅咒并且免伤增加
			{{1,0},{15,0},{16,613},{20,613}},
			{{1,0},{15,0},{16,662},{20,662}},
			{{1,0},{15,0},{16,16},{20,20}}
		},

		skill_statetime={-1},
		userdesc_000={625,662},
    },
    wd_book3_child1 = {--初级坐忘无我
		add_usebasedmg_p1={606,{{1,12},{10,125},{20,125}}},		--增加剑飞惊天攻击力
		skill_statetime={5*15},
    },
    wd_book3_child3 = {--高级坐忘无我
		--rand_ignoreskill={{{1,0},{15,0},{16,50},{20,100}},{{1,0},{15,0},{16,1},{20,2}},5},		--概率，数量，类型（skillsetting下定义类型）
		melee_dmg_p		={{{1,0},{15,0},{16,-6},{20,-30}}},
		remote_dmg_p	={{{1,0},{15,0},{16,-6},{20,-30}}},

		skill_statetime={4*15},
    },

    wd_mzhy = {--迷踪幻影-20级被动1--10级
		physics_potentialdamage_p={{{1,20},{10,50},{11,55}}},
		all_series_resist_p={{{1,3},{10,55},{12,66}}},
		state_slowall_resistrate={{{1,15},{10,150},{11,165}}},
		runspeed_v={{{1,10},{10,50},{11,50}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },

	wd_rjhy = {--人剑合一-30级主动4--15级
		skill_mintimepercast_v={{{1,46*15},{15,30*15},{20,30*15}}},

		userdesc_000={612},		--冲刺伤害
		userdesc_101={{{1,5},{15,6},{20,7}}},		--反击触发几率描述
    },
	wd_rjhy_child = {--人剑合一伤害
		attack_usebasedamage_p={{{1,327},{15,361},{20,361}}},
		attack_earthdamage_v={
			[1]={{1,327*2*0.9},{15,361*2*0.9},{20,361*2*0.9}},
			[3]={{1,327*2*1.1},{15,361*2*1.1},{20,361*2*1.1}}
		},
		state_stun_attack={{{1,100},{15,100},{20,100}},2*15},
		missile_hitcount={3,0,0},
    },
	wd_rjhy_child2 = {--人剑合一.重置技能cd
		reduce_cd_time_point1={609,60*15,1},			--无我无剑
		reduce_cd_time_point2={615,60*15,1},			--天地无极
		reduce_cd_time_point3={613,60*15,1},			--坐忘无我
    },
    wd_rjhy_bd = {--人剑合一.被动反击
		autoskill={60,{{1,1},{10,10}}},

		skill_statetime={-1},
    },
	wd_rjhy_bd_child = {--人剑合一.触发的剑飞惊天
		attack_usebasedamage_p={{{1,10},{15,10},{20,10},{24,10}}},
		attack_earthdamage_v={
			[1]={{1,40*2*0.9},{15,100*2*0.9},{20,160*2*0.9},{24,192*2*0.9}},
			[3]={{1,40*2*1.1},{15,100*2*1.1},{20,160*2*1.1},{24,192*2*1.1}}
		},
		missile_hitcount={3,0,0},
    },

    wd_book4 = {--高级人剑合一
		--增加剑飞惊天攻击力
		addpowerwhencol={606,{{1,4},{10,40},{20,40}},{{1,8},{10,80},{20,80}}},				--技能ID，每次增加%，最大增加%

		--中级释放后加buff,攻击和攻速提高
		addstartskill={
			{{1,0},{10,0},{11,608},{20,608}},
			{{1,0},{10,0},{11,657},{20,657}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		--被动提高技能伤害
		style_skill_damage_p={7,{{1,0},{15,0},{16,3},{20,15}}},

		skill_statetime={-1},

		userdesc_000={657},
    },
    wd_book4_child2 = {--人剑合一中级
		physics_potentialdamage_p	={{{1,0},{10,0},{11,22},{15,110},{20,110}}},
		attackspeed_v				={{{1,0},{10,0},{11,10},{15,50},{20,50}}},
		skill_statetime={8*15},
    },

    wd_zwqj = {--真武七截-40级被动2（光环）--10级
		physics_potentialdamage_p={{{1,30},{10,70},{11,77}}},
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},

		userdesc_106={{{1,15},{10,30},{11,33}}},					--增加队友攻击力的描述
    },
    wd_zwqj_team = {--真武七截_队友--10级
		physics_potentialdamage_p={{{1,15},{10,30},{11,33}}},
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},
    },
    wd_gjjf = {--高级剑法-50级被动3--10级
		add_skill_level={601,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={602,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={603,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={604,{{1,1},{10,10},{11,11}},0},
		skill_statetime={-1},

		userdesc_000={620},
    },
    wd_gjjf_child = {--高级剑法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_earthdamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,40*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,40*2*1.1}}
		},
    },

    wd_tyzq = {--太一真气-60级被动4--10级
		autoskill={61,{{1,1},{10,10},{11,11}}},
		steallife_p={{{1,1},{10,10},{11,11}}},
		state_freeze_ignore={1},
		skill_statetime={-1},

		userdesc_000={618},
		userdesc_101={{{1,15*30},{10,15*20},{11,15*19}}}, 			--假的魔法属性，仅用作描述，此时间需对应autoskill表中的“触发间隔时间”
    },
    wd_tyzq_child = {--太一真气_子--10级
		ignore_series_state={},
		skill_statetime={{{1,15*3},{10,15*6},{11,15*6}}},
    },
    wd_xtxf = {--玄天心法-70级被动5--10级
		autoskill={64,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},

		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的玄天心法
		userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--描述用，实际触发几率请查看autoskill.tab中的玄天心法
    },
    wd_tjwy = {--太极无意-80级被动6--20级
		physics_potentialdamage_p={{{1,2},{20,35},{24,35*1.2}}},
		lifemax_p={{{1,4},{20,75},{24,75*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,2},{20,30},{24,30*1.2}}},
		defense_p={{{1,2},{20,30},{24,30*1.2}}},
		state_stun_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_slowall_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },
    wd_90_qxj = {--七星诀-90级被动7--10级
		autoskill={65,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},

		userdesc_000={666},
    },
    wd_90_qxj_child1 = {--七星诀_敌人
		deadlystrike_p={{{1,-5},{10,-50},{12,-65}}},
		runspeed_p={{{1,-3},{10,-25},{11,-25}}},
		skill_statetime={6*15},
    },
    wd_90_qxj_child2 = {--七星诀_自身
		deadlystrike_p={{{1,5},{10,50},{12,65}}},
		runspeed_p={{{1,3},{10,25},{11,25}}},
		skill_statetime={6*15},
    },

    wd_wjftj = {--万剑封天诀-怒气--10级
		attack_usebasedamage_p={{{1,1000},{30,800}}},
		attack_earthdamage_v={
			[1]={{1,300*0.9},{30,200*0.9},{31,200*0.9}},
			[3]={{1,300*1.1},{30,200*1.1},{31,200*1.1}}
			},
    },
    wd_wjftj_child = {--万剑封天诀_子
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,37},{30,37}}},
    },
}
--人剑合一反击伤害
tb.wd_rjhy.userdesc_102 = tb.wd_rjhy_bd_child.attack_usebasedamage_p
tb.wd_rjhy.userdesc_103 = tb.wd_rjhy_bd_child.attack_earthdamage_v

FightSkill:AddMagicData(tb)