
local tb	= {
	bd_pg1 = {--霸刀刀法--普攻1式--20级
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
		
		--reduce_cd_time_point1={4406,30*15,1},
		--allfactionskill_cd_point={-10*15,{{1,0},{2,1},{3,1}}},
		--hitfilter_buff={4410},--只能击中心剑状态敌人
		--hitfilter_buffsytle={4},--只能击中带有buff_attack,buff_ex的敌人
		--hitfilter_hp={0,50},--只能击中0%~50%血敌人
		--change_buf_lasttime={406,50*15},
	},
	bd_pg2 = {--霸刀刀法--普攻2式--20级
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
	bd_pg3 = {--霸刀刀法--普攻3式--20级
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
	bd_pg4 = {--霸刀刀法--普攻4式--20级,包含4和5
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,134*1.5}}},
		attack_metaldamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,134*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,134*1.5*2*1.1}}
			},
		state_hurt_attack={100/2,10},

		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
	},
	bd_xd = {--化血劫光--1级主动1--15级
		attack_usebasedamage_p={{{1,65},{15,155},{20,187}}},
		attack_metaldamage_v={
			[1]={{1,65*4*0.9},{15,155*4*0.9},{20,187*4*0.9}},
			[3]={{1,65*4*1.1},{15,155*4*1.1},{20,187*4*1.1}}
		},
		state_hurt_attack={30,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
		
		skill_point={200,100}, 		--参数1/100：叠加次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={8*15},
		
		userdesc_000={5006},
	},
	bd_xd_child = {--化血劫光_生命相关伤害-1级主动1--15级
		damage_maxlife_p={{{1,324},{15,774},{20,934}},1},
		state_hurt_attack={30,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
    },
	
	bd_book1={--化血劫光_秘籍_
		--初级.第二式触发单体,若单体击中则触发aoe
		addstartskill2={5006,5050,{{1,1},{20,20}}},
		
		--中级.释放时缩短撕裂cd
		addstartskill={{{1,0},{10,0},{11,5005},{20,5005}},{{1,0},{10,0},{11,5051},{20,5051}},{{1,0},{10,0},{11,11},{20,20}}},	
		
		--高级.加暴击率
		add_deadlystrike_p1={5005,{{1,0},{15,0},{16,7},{20,35}}},
		add_deadlystrike_p2={5006,{{1,0},{15,0},{16,7},{20,35}}},
		add_deadlystrike_p3={5050,{{1,0},{15,0},{16,7},{20,35}}},
		
		skill_statetime={-1},
		
		userdesc_000={5050,5051},
	},
	
	bd_book1_child1 = {--化血劫光_秘籍_对残血目标的伤害
		hitfilter_hp={0,33},--只能击中0%~33%血敌人
		attack_usebasedamage_p={{{1,50},{10,150},{20,150}}},
		attack_metaldamage_v={
			[1]={{1,50*2*0.9},{10,150*2*0.9},{20,150*2*0.9}},
			[3]={{1,50*2*1.1},{10,150*2*1.1},{20,150*2*1.1}}
			},
		missile_hitcount={3,0,0},
    },
	bd_book1_child2 = {--化血劫光_秘籍_减撕裂cd
		reduce_cd_time_point1={5011,{{1,0},{10,0},{11,0.4*15},{15,2*15},{20,2*15}},1},		--减少撕裂cd,对充能可减
    },
		
	bd_cf = {--挟山超海-4级主动2--15级
		skill_mintimepercast_v={{{1,19*15},{15,12*15},{20,12*15}}},
		
		userdesc_000={5010},
    },
	bd_cf_child1 = {--挟山超海_击退
		state_knock_attack={100,6,80},
		state_npcknock_attack={100,6,80},
		spe_knock_param={3 , 4, 9},			--停留时间，玩家动作ID，NPC动作ID
		skill_knock_len={1,250,0},			--是否击退到朝向垂线的投影点,击退距离,相对npc还是子弹
		
		missile_hitcount={3,0,0},
	},
	bd_cf_child2 = {--挟山超海_伤害
		attack_usebasedamage_p={{{1,390},{15,617},{20,699}}},
		attack_metaldamage_v={
			[1]={{1,390*2*0.9},{15,617*2*0.9},{20,699*2*0.9}},
			[3]={{1,390*2*1.1},{15,617*2*1.1},{20,699*2*1.1}}
			},
		missile_hitcount={3,0,0},
    },
	
	bd_book2={--挟山超海秘籍
		--初级.释放后提高自身会心伤害抗性
		addstartskill={5008,{{1,5052},{15,5052},{16,5053},{20,5053}},{{1,1},{20,20}}},	
		--autoskill={174,{{1,1},{10,10}}},
		
		--中级.减cd
		deccdtime={5008,{{1,0},{10,0},{11,0.6*15},{15,3*15},{20,3*15}}},
		
		--高级.属性都在初级的后几级里
		
		skill_statetime={-1},
		
		userdesc_000={{{1,5052},{15,5052},{16,5053},{20,5053}}},
	},
	
	bd_book2_child1 = {--挟山超海_秘籍1加会心伤害抗性
		--初级
		ignore_series_state={},		--免疫属性效果
		
		--高级
		weaken_deadlystrike_damage_p={{{1,0},{15,0},{16,9},{20,45}}},
		
		skill_statetime={{{1,2*15},{10,6*15},{20,6*15}}},
	},
	bd_sl = {--逆血截脉--15级
		missile_hitcount={6,0,0},
		
		skill_mintimepercast_v={25*15},
		
		userdesc_000={5013},
	},
	
	bd_sl_child1 = {--逆血截脉_持续子弹--15级
		ms_one_hit_count = {0,0,1},
	},
	bd_sl_child2 = {--逆血截脉_伤害--15级
		attack_usebasedamage_p={{{1,30},{15,65},{20,78}}},
		attack_metaldamage_v={
			[1]={{1,30*2*0.9},{15,65*2*0.9},{20,78*2*0.9}},
			[3]={{1,30*2*1.1},{15,65*2*1.1},{20,78*2*1.1}}
			},
		missile_hitcount={0,0,1},
		
		state_hurt_attack={{{1,10},{15,30},{20,30}},5},
	},
	
	bd_book3 = {--逆血截脉秘籍
		addstartskill={5013,5054,{{1,1},{10,10},{20,20}}},	--附带减抗和减速
		
		addms_life1={5012,{{1,0},{10,0},{11,0.4*15},{15,2*15},{20,3*15}}},		--增加主技能子弹存活时间
		
		addms_hittotal_c1={5013,{{1,0},{15,0},{16,1},{20,5}}},
		addms_hittotal_c2={5054,{{1,0},{15,0},{16,1},{20,5}}},
		addms_dmg_range1={{{1,0},{15,0},{15,5013},{20,5013}},{{1,0},{15,0},{16,4},{20,12}}},--撕裂伤害范围扩大,在秘籍之前只能打一个目标范围很大很容易打中的不是主目标
		addms_dmg_range2={{{1,0},{15,0},{15,5054},{20,5054}},{{1,0},{15,0},{16,4},{20,12}}},--撕裂减速减抗范围扩大,在秘籍之前只能打一个目标范围很大很容易打中的不是主目标
		
		skill_statetime={-1},
		
		userdesc_000={5054},
	},
	
	bd_book3_child1 = {--逆血截脉初级秘籍
		all_series_resist_p={{{1,-14},{10,-140},{20,-140}}},
		runspeed_v={{{1,-16},{10,-160},{20,-160}}},
		
		skill_statetime={2*15},
		
		missile_hitcount={0,0,1},
	},
	
	
	bd_skill_20 = {--铁索横江--10级
		lifemax_p={{{1,5},{10,45},{12,45*1.2}}},
		physics_potentialdamage_p={{{1,4},{10,40},{12,40*1.2}}},
		state_zhican_resistrate={{{1,15},{10,150},{11,165}}},
		skill_statetime={-1},
	},
	
	bd_kb = {--浴血蹈锋-30级主动4--15级
		ignore_abnor_state={},			--免疫负面
		ignore_series_state={},		--免疫属性
		physics_potentialdamage_p={{{1,225},{15,225},{20,300}}},
		lifemax_p={{{1,320},{15,320},{20,425}}},
		
		skill_statetime={90},
		
		make_npc_lose_lifeP={30},		--耗血
		
		skill_mintimepercast_v={{{1,45*15},{15,24*15},{20,24*15}}},
		
		force_ignore_spe_state={8388607},--可在特定负面下释放
		
		userdesc_000={5016},
    },
	bd_kb_child = {--浴血蹈锋_耗血减cd
		reduce_cd_time_point1={5005,8*15,1},			--减少血刀cd,对充能可减
    },
	
	bd_book4={--浴血蹈锋_秘籍
		addstartskill={5016,5055,{{1,1},{10,10},{20,20}}},
		
		lifemax_p={{{1,0},{10,0},{11,12},{15,60},{20,60}}},
		lifereplenish_p={{{1,0},{10,0},{11,6},{15,30},{20,30}}},
		
		--addstartskill2={{{1,0},{15,0},{16,5055},{20,5055}},{{1,0},{15,0},{16,5056},{20,5056}},{{1,0},{15,0},{16,16},{20,20}}},
		add_buffendskill1={{{1,0},{15,0},{16,5015},{20,5015}},{{1,0},{15,0},{16,5056},{20,5056}},{{1,0},{15,0},{16,16},{20,20}}},
		
		skill_statetime={-1},
		
		userdesc_000={5055,5056},
	},
	bd_book4_child1 = {--浴血蹈锋_秘籍_生命相关伤害-1级主动1--15级
		damage_maxlife_p={{{1,500},{10,2000},{20,2000}},1},--目标生命上限,目标生命上限视为不超过自身生命上限*p2/100

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
    },
	bd_book4_child3 = {--浴血蹈锋_秘籍_附加无敌
		invincible_b={1,1},	--第二个参数为1表示为低级无敌,可被无视无敌击中
		skill_statetime={{{1,0},{15,0},{16,0.6*15},{20,3*15}}},
    },
	
	bd_skill_40 = {--残阳映血_10
		lowhp_damage_att_p={{{1,3},{11,18}},0},
		--lowhp_damage_beatt_p={{{1,-3},{10,-30}},0},
		autoskill={152,{{1,1},{10,10},{11,11}}},
		
		skill_statetime={-1},
		
		userdesc_000={5057},
	},
	
	bd_skill_40_child = {--残阳映血_10_回血
		hitfilter_hp={0,33},			--只能击中0%~33%血
		dir_recover_life_pp={{{1,10},{10,80},{11,88}},1},--生命上限,自身数值
		
		missile_hitcount={0,0,1},		--只要打中一个就够了
	},
		
    bd_skill_50 = {--高级刀法_10
		add_skill_level={5001,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={5002,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={5003,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={5004,{{1,1},{10,10},{11,11}},0},
		
		skill_statetime={-1},
		
		userdesc_101={{{1,4},{10,40},{11,44}},{{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}}},--伤害加成描述
    },
	
	bd_skill_60 = {--避实就虚_10
		all_series_resist_p={{{1,35},{10,350}}},
		autoskill={172,{{1,1},{10,10},{11,11}}},--被击时叠加减抗
		
		skill_statetime={-1},
		
		userdesc_101={{{1,35},{10,350}}},
		userdesc_000={5027},
	},
	bd_skill_60_child = {--避实就虚_10
		all_series_resist_p={{{1,-10},{10,-100}}},
		
		superposemagic={3,3},
		
		skill_statetime={3*15},
	},
		
	bd_skill_70 = {--否极泰来--10级
		autoskill={170,{{1,1},{10,10},{11,11}}},--概率触发子buff
		skill_statetime={-1},

		userdesc_000={5030},
		userdesc_101={{{1,40},{10,90},{11,95}},30*15},--主buff触发概率和间隔描述
		userdesc_102={9*15,5},--免死时间,免死次数
		--userdesc_103={{{1,40},{10,80},{11,80}}},--概率免死触发概率描述
	},
	bd_skill_70_child1 = {--否极泰来_无敌x秒
		--invincible_b={1},
		mult_skill_state={5019,{{1,1},{10,10}},5}, 		--技能ID，等级，buff层数
		
		--skill_statetime={3*15},
	},
	bd_skill_70_child2 = {--否极泰来_概率免死
		autoskill={171,{{1,1},{10,10},{11,11}}},
		superposemagic={5,1},
		skill_statetime={9*15},
		
		userdesc_000={5030},
		--userdesc_101={{{1,40},{10,80},{11,80}}},--触发概率描述
	},
	bd_skill_70_child2c = {--否极泰来_概率免死的短时间无敌&回血
		dir_recover_life_pp={{{1,150},{10,300},{11,300}},1},--生命上限,自身数值
		mult_skill_state={5019,{{1,1},{10,10}},-1}, 		--技能ID，等级，buff层数
		invincible_b={1,1},		--弱无敌
		
		skill_statetime={5},
	},
	
	bd_skill_80 = {--乾元镇海诀
		physics_potentialdamage_p={{{1,10},{20,40},{24,40*1.2}}},
		lifemax_p={{{1,5},{20,100},{24,100*1.2}}},
		all_series_resist_p={{{1,2},{20,35},{24,35*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		state_hurt_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_zhican_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
	},
	
    bd_skill_90 = {--乘胜逐北_主技能检测目标血量
		userdesc_000={5033},			--增加队友光环的描述
		
		hitfilter_hp={0,33},			--只能击中0%~33%血敌人
		missile_hitcount={0,0,1},		--只要打中一个就够了
    },
    bd_skill_90_child = {--乘胜逐北自身buff
		deadlystrike_damage_p={{{1,4},{10,40},{12,50}}},--攻速跑速不成长,这俩属性正常高一点
		all_series_resist_p={{{1,16},{10,160},{12,200}}},
		--ignore_defense_vp={{{1,100},{10,100},{12,125}}},
		attackspeed_v={{{1,3},{10,30},{11,30}}},
		runspeed_v={{{1,5},{10,50},{11,50}}},
		skill_statetime={5*15},
    },
		
    bd_skill_100 = {--连环刀--10级
		autoskill={173,{{1,1},{10,10},{11,11}}},
		userdesc_000={5035,5036},
		skill_statetime={-1},
    },
    bd_skill_100_child1 = {--敌人攻击叠加降低
		physics_potentialdamage_p={{{1,-2},{10,-20},{20,-40}}},
		superposemagic={4,4},
		skill_statetime={4*15},
    },
    bd_skill_100_child2 = {--自身攻击叠加
		physics_potentialdamage_p={{{1,2},{10,20},{20,40}}},
		superposemagic={4,4},
		skill_statetime={4*15},
    },
	
	bd_nq = {--霸刀怒气-怒气
		attack_usebasedamage_p={{{1,300},{30,300}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	bd_nq_child1 = {--霸刀怒气_子
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	bd_nq_child2 = {--霸刀怒气_免疫
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
	},
}

FightSkill:AddMagicData(tb)