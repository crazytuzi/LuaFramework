
local tb    = {
    ts_pg1 = {--天山琴曲1--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,80},{30,110},{31,113}}},
		attack_waterdamage_v={
			[1]={{1,60*2*0.90},{20,80*2*0.90},{30,110*2*0.90},{31,113*2*0.90}},
			[3]={{1,60*2*1.10},{20,80*2*1.10},{30,110*2*1.10},{31,113*2*1.10}}
			},
		state_npchurt_attack={100,6},
		missile_hitcount={3,0,0},
    },
    ts_pg2 = {--天山琴曲2--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,80},{30,110},{31,113}}},
		attack_waterdamage_v={
			[1]={{1,60*2*0.90},{20,80*2*0.90},{30,110*2*0.90},{31,113*2*0.90}},
			[3]={{1,60*2*1.10},{20,80*2*1.10},{30,110*2*1.10},{31,113*2*1.10}}
			},
		state_npchurt_attack={100,6},
		--state_slowall_attack={{{1,30},{20,30},{30,30}},{{1,15*1.5},{20,15*1.5},{30,15*1.5}}},
		missile_hitcount={3,0,0},
    },
    ts_pg3 = {--天山琴曲3--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,80},{30,110},{31,113}}},
		attack_waterdamage_v={
			[1]={{1,60*2*0.90},{20,80*2*0.90},{30,110*2*0.90},{31,113*2*0.90}},
			[3]={{1,60*2*1.10},{20,80*2*1.10},{30,110*2*1.10},{31,113*2*1.10}}
			},
		--state_hurt_attack={50,5,0},
		--state_slowall_attack={{{1,50},{20,50},{30,50}},{{1,15*1.5},{20,15*1.5},{30,15*1.5}}},
		state_npchurt_attack={100,6},
		missile_hitcount={3,0,0},
    },
    ts_pg4 = {--天山琴曲4--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*0.5},{20,80*0.5},{30,110*0.5},{31,113*0.5}}},
		attack_waterdamage_v={
			[1]={{1,60*1*0.90},{20,80*1*0.90},{30,110*1*0.90},{31,113*1*0.90}},
			[3]={{1,60*1*1.10},{20,80*1*1.10},{30,110*1*1.10},{31,113*1*1.10}}
			},
		state_slowall_attack={{{1,80/3},{20,80/3},{30,80/3},{31,80/3}},{{1,15*1.5},{20,15*1.5},{30,15*1.5},{31,15*1.5}}},
		state_npchurt_attack={80,6},
		missile_hitcount={3,0,0},
    },
    ts_fylb = {--飞燕凌波-1级主动1--15级
		loselife_dmg_p={100},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,153},{15,243},{20,399}}},
		attack_waterdamage_v={
			[1]={{1,153*2*0.9},{15,243*2*0.9},{20,399*2*0.9}},
			[3]={{1,153*2*1.1},{15,243*2*1.1},{20,399*2*1.1}}
		},
		state_slowall_attack={{{1,9},{15,65},{20,85}},2*15},
		missile_hitcount={3,0,0},

		skill_point={
			{{1,200},{10,200},{11,300},{20,300}},
			100,
		},		--参数1/100：最大充能次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={12*15},
	},

	ts_book1 = {	--飞燕凌波秘籍
		autoskill={145,{{1,1},{20,20}}},		--释放普攻触发减cd

		add_usebasedmg_p1={4606,{{1,0},{10,0},{11,7},{15,32},{20,75}}},

		addstartskill={4607,{{1,0},{15,0},{16,4650},{20,4650}},{{1,0},{15,0},{16,16},{20,20}}},	--释放飞燕凌波特效时,叠加会心
		userdesc_000={4649,4650},
		skill_statetime={-1},
	},

	ts_book1_child1 = {	--飞燕凌波秘籍_减少cd
		reduce_cd_time1={4606,{{1,3},{10,15},{15,18},{16,18},{20,18}}},			--减飞燕凌波CD
	},

	ts_book1_child3 = {	--飞燕凌波秘籍_叠加会心
		deadlystrike_p={{{1,0},{15,0},{16,3},{20,15}}},
		superposemagic={5},				--最大叠加层数,0为不限制
		skill_statetime={15*15},
	},

    ts_ypys = {--银瓶玉碎-4级主动2--15级
		attack_usebasedamage_p={{{1,234},{15,512},{20,855}}},
		attack_waterdamage_v={
			[1]={{1,234*2*0.9},{15,512*2*0.9},{20,855*2*0.9}},
			[3]={{1,234*2*1.1},{15,512*2*1.1},{20,855*2*1.1}}
		},
		--state_slowall_attack={{{1,5},{15,75},{16,80},{20,100}},15*2.5},
		missile_hitcount={3,0,0},

		skill_mintimepercast_v={20*15},

		userdesc_000={4609,4610},
    },

	ts_ypys_child1 = {--银瓶玉碎_加诅咒层数,分开避免第一次攻击就扣层数
		mult_skill_state={4610,{{1,1},{15,15}},5}, 		--技能ID，等级，buff层数
	},

	ts_ypys_child2 = {--银屏玉碎_每层诅咒
		physics_potentialdamage_p={{{1,-3},{15,-45},{20,-90}}},
		autoskill={146,{{1,1},{10,10},{11,11}}},
		superposemagic={5},				--最大叠加层数
		skill_statetime={15*15},
    },

	ts_ypys_child3 =  {--银屏玉碎_诅咒-减少层数
		mult_skill_state={4610,{{1,1},{15,15}},-1}, 		--技能ID，等级，buff层数
    },

	ts_book2 = {--银瓶玉碎_秘籍
		add_igdefense_p1={4608,{{1,2},{2,5},{10,25},{11,25}}},		--忽略闪避

		add_usebasedmg_p1={4608,{{1,0},{10,0},{11,20},{15,98},{20,118}}},	--增加银瓶玉碎主技能伤害
		add_hitskill1={4609,{{1,0},{10,0},{11,4651},{20,4651}},{{1,0},{10,0},{11,11},{20,20}}},	--银瓶玉碎诅咒追加造成冰冻

		addstartskill={4651,{{1,0},{15,0},{16,4652},{20,4652}},{{1,0},{15,0},{16,16},{20,20}}},	--银瓶玉碎冰冻追加目标受到会心伤害增加
		userdesc_000={4651,4652},
		skill_statetime={-1},
	},

	ts_book2_child2 = {--银瓶玉碎冰冻
		state_freeze_attack={{{1,0},{10,0},{11,8},{15,40},{20,50}},15*2},
	},

	ts_book2_child3 = {--银瓶玉碎+受到会心伤害
		weaken_deadlystrike_damage_p={{{1,0},{15,0},{16,-10},{20,-50}}},
		skill_statetime={10*15},
	},

	ts_ksny = {--空山凝云-10级主动3--15级
		mult_skill_state={4632,{{1,1},{15,15}},4}, 		--技能ID，等级，buff层数
		userdesc_000={4632},

		skill_mintimepercast_v={20*15},
    },

	ts_ksny_child1 = {--空山凝云_子
		physics_potentialdamage_p={{{1,3},{15,45},{20,60}}},
		attackspeed_v={{{1,1},{15,15},{20,15}}},
		autoskill={147,{{1,1},{15,15}}},						--受击扣除层数
		superposemagic={4},				--叠加层数
		skill_statetime={20*15},
    },

	ts_ksny_child2 = {--空山凝云-减少层数
		mult_skill_state={4632,{{1,1},{15,15}},{{1,-1},{15,-1},{16,-1}}}, 		--技能ID，等级，buff层数
    },
	ts_ksny_empty = {--空山凝云-对目标效果
		attack_usebasedamage_p={0},
		state_slowall_attack={0,0},
    },

	ts_book3 = {--空山凝云秘籍
		addstartskill={4611,4654,{{1,1},{20,20}}},  		--附加回血

		add_usebasedmg_p1={4615,{{1,0},{10,0},{11,28},{15,140},{20,285}}},		--增加空子弹的伤害
		add_slowall_r={4615,{{1,0},{10,0},{11,10},{20,100}}},					--增加空子弹的迟缓几率
		add_slowall_t={4615,2*15},											--增加空子弹的迟缓时间

		addstartskill2={4633,{{1,0},{15,0},{16,4655},{20,4655}},{{1,0},{15,0},{16,16},{20,20}}},  	--附加免控加成

		userdesc_000={4654,4655},
		skill_statetime={-1},
	},

	ts_book3_child1 = {--空山凝云初级秘籍回血
		dir_recover_life_pp={{{1,60},{10,600},{11,600}},1},		--生命上限万分比,自身数值
		skill_statetime={1},
	},

	ts_book3_child3 = {--空山凝云高级秘籍免控
		ignore_abnor_state={},		--免疫负面效果
		state_palsy_ignore={1},		--免疫麻痹
		skill_statetime={{{1,0},{15,0},{16,15*0.5},{20,15*2.5}}},
	},

    ts_stry = {--双弹如一-20级被动1--10级
		physics_potentialdamage_p={{{1,3},{10,30},{16,48},{18,57}}},
		attackspeed_v={{{1,3},{10,30},{16,48},{17,48}}},
		state_palsy_resistrate={{{1,15},{10,150}}},
		skill_statetime={-1},
    },
    ts_sly = {--水龙吟-30级主动4--15级
		rand_ignoreskill={{{1,6},{15,100},{20,100}},3,4},		--概率，数量，类型（skillsetting下定义类型）

		skill_mintimepercast_v={35*15},

		userdesc_000={4621},
    },

    ts_sly_child = {--水龙吟_子--15级
		attack_usebasedamage_p={{{1,174},{15,367},{20,676}}},
		attack_waterdamage_v={
			[1]={{1,174*2*0.9},{15,367*2*0.9},{20,676*2*0.9}},
			[3]={{1,174*2*1.1},{15,367*2*1.1},{20,676*2*1.1}}
		},
		state_slowall_attack={{{1,6},{15,100},{20,100}},15*4.5},
		missile_hitcount={0,0,3},
    },

	ts_book4 = {--水龙吟秘籍
		add_hitskill1={4613,4656,{{1,1},{10,10},{20,20}}},  		--附加概率闪避增益

		add_usebasedmg_p1={4621,{{1,0},{10,0},{11,14},{15,69},{20,69*2}}},	--增加伤害

		deccdtime={4613,{{1,0},{15,0},{16,15*1.6},{20,15*8}}},			--减少水龙吟CD时间
		skill_statetime={-1},

		userdesc_000={4656},
	},

	ts_book4_child1 = {--水龙吟_初级秘籍
		ignore_dmgskill={{{1,600},{10,6000},{11,6000}},4},
		skill_statetime={15*15},
	},

    ts_fqwt = {--凤栖梧桐-40级被动2（增益）--10级
		autoskill={148,{{1,1},{10,10}}},
		autoskill2={150,{{1,1},{10,10}}},	--每隔2秒掉层数

		skill_statetime={-1},

		userdesc_101={5*15},	--触发间隔显示
		userdesc_000={4620,4628},
    },
    ts_fqwt_self = {--凤栖梧桐_叠加buff--10级
		physics_potentialdamage_p={{{1,1},{10,10}}},
		superposemagic={10},				--叠加层数
		skill_statetime={12*15},
    },
    ts_fqwt_self1 = {--凤栖梧桐_回血
		dir_recover_life_pp={{{1,6},{10,60},{11,76}},1},--生命上限,自身数值
		skill_statetime={1},
    },
    ts_fqwt_self2 = {--凤栖梧桐_自动掉层
		mult_skill_state={4620,{{1,1},{10,10}},-1}, 		--技能ID，等级，buff层数
    },

    ts_cyj = {--吹云劲-50级被动3--10级
		add_skill_level={4601,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={4602,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={4603,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={4604,{{1,1},{10,10},{11,11}},0},
		userdesc_000={4623},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    ts_cyj_child = {--吹云劲_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-31级）--10级
		attack_usebasedamage_p={{{1,3},{10,30},{11,33}}},
		attack_waterdamage_v={
			[1]={{1,3*2*0.9},{10,30*2*0.9},{11,33*2*0.9}},
			[3]={{1,3*2*1.1},{10,30*2*1.1},{11,33*2*1.1}}
		},
    },
    ts_smth = {--水幕天华-60级被动4--10级
		ignore_defense_p={{{1,2},{10,20}}},					--测试忽略基础闪避百分比
		weaken_deadlystrike_damage_p={{{1,3},{10,30}}},
		userdesc_101={{{1,1.5},{2,3},{10,15},{12,18}}},		--队友光环显示效果
		skill_statetime={3*15},
    },
    ts_smth_team = {--水幕天华_队友--10级
		weaken_deadlystrike_damage_p={{{1,1.5},{2,3},{10,15},{12,20}}},
		skill_statetime={3*15},
    },
    ts_nsh = {--逆水寒-70级被动5--10级
		autoskill={151,{{1,1},{10,10},{11,11}}},
		userdesc_000={4627},
		userdesc_101={{{1,40},{10,90},{11,95}}},			--假描述，触发概率，实际触发概率于aotuskill.tab中设置
		userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--假描述，触发间隔，实际触发概率于aotuskill.tab中设置
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    ts_nsh_child = {--逆水寒_子--10级
		steallife_p={{{1,5},{10,50}}},
		all_series_resist_p={{{1,30},{10,300}}},
		ignore_series_state={},								--免疫属性效果
		ignore_abnor_state={},								--免疫负面效果
		skill_statetime={{{1,15*6},{10,15*6},{11,15*6}}},
    },
    ts_jdqx = {--剑胆琴心-80级被动6--20级
		physics_potentialdamage_p={{{1,3},{20,30},{24,50*1.2}}},
		lifemax_p={{{1,5},{20,100},{24,100*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,3},{20,55},{24,55*1.2}}},
		state_slowall_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_palsy_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },
    ts_qshm = {--琴瑟和鸣-90级被动7--10级
		autoskill={149,{{1,1},{10,10},{11,11}}},
		userdesc_101={{{1,5},{10,50},{11,50}}},			--假描述，触发概率，实际触发概率于aotuskill.tab中设置
		--userdesc_102={{{1,15*30},{10,15*30},{11,15*30}}},	--假描述，触发间隔，实际触发概率于aotuskill.tab中设置
		userdesc_000={4635,4636},
		skill_statetime={{{1,-1},{10,-1}}},
    },
    ts_qshm_child = {--琴瑟和鸣_子,无成长,触发几率成长
		attack_usebasedamage_p={0},
		state_slowall_attack={{{1,50},{10,50},{11,75}},15*1},
		missile_hitcount={0,0,1},
    },
	ts_qshm_child2 = {--琴瑟和鸣_子
		dir_recover_life_pp={{{1,200},{10,200},{11,220}},1},--生命上限,自身数值
    },

    ts_nq = {--天山-怒气
		attack_usebasedamage_p={{{1,1000},{10,1000}}},
		attack_waterdamage_v={
			[1]={{1,300*0.9},{10,200*0.9},{31,200*0.9}},
			[3]={{1,300*1.1},{10,200*1.1},{31,200*1.1}}
			},
    },
    ts_nq_child1 = {--天山-怒气_子1
		attack_usebasedamage_p={{{1,1000},{10,1000}}},
		attack_waterdamage_v={
			[1]={{1,1000*0.9},{10,2000*0.9},{31,2000*0.9}},
			[3]={{1,1000*1.1},{10,2000*1.1},{31,2000*1.1}}
			},
    },
    ts_nq_child2 = {--天山-怒气_子
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,40},{10,40}}},
    },
}

FightSkill:AddMagicData(tb)