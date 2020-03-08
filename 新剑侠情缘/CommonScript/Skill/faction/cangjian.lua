
local tb	= {
	cj_pg1 = {--藏剑剑法--普攻1式--20级
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
	cj_pg2 = {--藏剑剑法--普攻2式--20级
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
	cj_pg3 = {--藏剑剑法--普攻3式--20级
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
	cj_pg4 = {--藏剑剑法--普攻4式--20级,包含4和5
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5/2},{20,90*1.5/2},{30,130*1.5/2},{31,134*1.5/2}}},
		attack_metaldamage_v={
			[1]={{1,60*1.5/2*2*0.9},{20,90*1.5/2*2*0.9},{30,130*1.5/2*2*0.9},{31,134*1.5/2*2*0.9}},
			[3]={{1,60*1.5/2*2*1.1},{20,90*1.5/2*2*1.1},{30,130*1.5/2*2*1.1},{31,134*1.5/2*2*1.1}}
			},
		state_hurt_attack={100/2,10},

		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
	},
	cj_pg5 = {--藏剑剑法--普攻5式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5/2},{20,90*1.5/2},{30,130*1.5/2},{31,134*1.5/2}}},
		attack_metaldamage_v={
			[1]={{1,60*1.5/2*2*0.9},{20,90*1.5/2*2*0.9},{30,130*1.5/2*2*0.9},{31,134*1.5/2*2*0.9}},
			[3]={{1,60*1.5/2*2*1.1},{20,90*1.5/2*2*1.1},{30,130*1.5/2*2*1.1},{31,134*1.5/2*2*1.1}}
			},
		state_hurt_attack={100/2,10},

		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},
		spe_knock_param1={1},
		
		missile_hitcount={3,0,0},
	},
	cj_dc = {--断潮--1级主动1--15级
		attack_usebasedamage_p={{{1,238},{15,347},{20,386}}},
		attack_metaldamage_v={
			[1]={{1,238*2*0.9},{15,347*2*0.9},{20,386*2*0.9}},
			[3]={{1,238*2*1.1},{15,347*2*1.1},{20,386*2*1.1}}
		},
		state_fixed_attack={0,0},  --秘籍需要用到
		state_hurt_attack={75,5},

		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},

		missile_hitcount={3,0,0},

		skill_point={
			{{1,200},{10,200},{11,300},{20,300}},
			100,
		},		--参数1/100：最大充能次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={{{1,10*15},{15,5*15},{20,5*15}}},
	},

	cj_book1={  --断潮秘籍
		add_deadlydmg_p1={4406,{{1,6},{10,60},{20,60}}},  			--增加会心伤害

		addstartskill={ --中级秘籍使之后的断潮伤害定身提高
			{{1,0},{10,0},{11,4407},{20,4407}},
			{{1,0},{10,0},{11,4439},{20,4439}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		autoskill={{{1,0},{15,0},{16,165},{20,165}},{{1,0},{10,0},{11,11},{20,20}}},	--高级秘籍概率刷新cd
		skill_statetime={-1},

		userdesc_000={4439},
		userdesc_101={{{1,0},{15,0},{16,8},{20,40}}},
	},
	cj_book1_child2={  --断潮中级秘籍
		add_usebasedmg_p1={4406,{{1,0},{10,0},{11,12},{15,60},{20,60}}},
		add_fixed_r={4406,{{1,5},{10,50},{20,50}}},		--增加造成定身的概率
		add_fixed_t={4406,1.5*15},						--增加造成定身的时间
		skill_statetime={2.5*15},
	},
	cj_book1_child3={  --断潮秘籍
		reduce_cd_time1={4406,{{1,0},{15,0},{16,5*15},{20,5*15}}},
	},

	cj_xj = {--心剑-10级主动3--15级
		physics_potentialdamage_p={{{1,7},{15,105},{20,140}}},
		deadlystrike_p={{{1,3},{15,45},{20,60}}},
		damage4npc_p={{{1,1},{15,20},{21,28}}},
		skill_statetime={25*15},
		skill_mintimepercast_v={{{1,29*15},{15,15*15},{20,15*15}}},
	},

	cj_book2={--心剑秘籍
		addstartskill={4410,4443,{{1,1},{10,10},{20,20}}},  --追加免控

		--中级秘籍的重置cd和结束回血都配在了初级秘籍的11级以后

		autoskill={{{1,0},{15,0},{16,164},{20,164}},{{1,0},{15,0},{16,16},{20,20}}},	--受击触发减少心剑cd
		skill_statetime={-1},

		userdesc_000={4449,4443,4456},
	},
	cj_book2_child1 = {--心剑_初级秘籍
		ignore_abnor_state={},		--免疫负面效果
		state_zhican_ignore={1},	 --免疫致残
		skill_statetime={{{1,0.5*15},{10,5*15},{20,5*15}}},

		reduce_cd_time1={4408,{{1,0},{10,0},{11,20*15},{20,20*15}}},
		buff_end_castskill={{{1,0},{10,0},{11,4449},{20,4449}},{{1,0},{10,0},{11,11},{20,20}}},
	},
	cj_book2_child2 = {--心剑_中级秘籍,回血
		dir_recover_life_pp={{{1,22},{10,227},{11,327}},1},		--生命上限万分比,自身数值
		skill_statetime={2},
	},
	cj_book2_child3 = {--心剑_高级秘籍
		reduce_cd_time1={4410,{{1,0},{15,0},{16,3},{20,15}}},	  --受击减少心剑cd1
	},

	cj_yqyy = {--玉泉鱼跃--4级主动2--15级
		userdesc_000={4409},
		skill_mintimepercast_v={{{1,14*15},{15,7*15},{20,7*15}}},
	},
	cj_yqyy_child = {--玉泉鱼跃_子--15级
		attack_usebasedamage_p={{{1,320},{15,491},{20,653}}},
		attack_metaldamage_v={
			[1]={{1,320*2*0.9},{15,491*2*0.9},{20,553*2*0.9}},
			[3]={{1,320*2*1.1},{15,491*2*1.1},{20,553*2*1.1}}
			},
		state_hurt_attack={{{1,25},{15,50},{20,50}},1*15},
		--state_fixed_attack={0,0},  --秘籍需要用到
		state_npcknock_attack={100,7,35},
		spe_knock_param={6 , 4, 9},
		spe_knock_param1={1},

		missile_hitcount={3,0,0},
	},
	cj_book3={  --玉泉鱼跃秘籍
		add_hitskill1={4409,4451,{{1,1},{10,10},{20,20}}},  --减速

		autoskill={{{1,0},{10,0},{11,134},{20,134}},{{1,0},{11,11},{20,20}}},	--一定几率额外击中一次

		add_steallife_p={4409,{{1,0},{10,0},{15,0},{16,600},{20,3000}}},		--技能ID，吸血万分比

		skill_statetime={-1},

		userdesc_000={4451},
		userdesc_101={{{1,0},{11,5},{20,50}}},
	},
	cj_book3_child1={   --初级秘籍降低跑速
		runspeed_v={{{1,-16},{10,-160},{20,-260}}},
		skill_statetime={4*15},
	},

	cj_jt = --惊涛-20级被动1--10级
	{
		physics_potentialdamage_p={{{1,5},{10,45},{12,54},{16,72},{18,86}}},
		attackspeed_v={{{1,3},{10,30},{11,33},{16,48},{17,48}}},
		runspeed_v={{{1,5},{10,50},{11,55},{16,80},{17,80}}},
		state_zhican_resistrate={{{1,15},{10,150},{11,165}}},
		skill_statetime={-1},
	},

	cj_fcyj = {--峰插云景--30级主动4--15级
		missile_hitcount={3,0,0},

		skill_mintimepercast_v={{{1,45*15},{15,40*15},{20,40*15}}},

		--峰插云景飞剑
		userdesc_000={4416},
	},
	cj_fcyj_child1 = {--峰插云景_内圈持续表现
		ms_one_hit_count={0,0,6},				--每次攻击最大数量
	},
	cj_fcyj_child2 = {--峰插云景_外圈剑阵,doHitskill
		ms_one_hit_count={0,0,6},				--每次攻击最大数量
	},
	cj_fcyj_child3 = {--峰插云景飞剑
		attack_usebasedamage_p={{{1,44},{15,101},{20,221}}},
		attack_metaldamage_v={
			[1]={{1,44*2*0.9},{15,101*2*0.9},{20,121*2*0.9}},
			[3]={{1,44*2*1.1},{15,101*2*1.1},{20,121*2*1.1}}
		},
		state_hurt_attack={50,7},
		missile_hitcount={1,0,0},
	},

	cj_book4={  --峰插云景秘籍
		add_hit_float1={4446},							--标记子弹能打空中目标
		addstartskill={4414,4446,{{1,1},{10,10},{20,20}}},  --附加初始伤害和禁轻功

		deccdtime={4413,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},

		add_hitskill1={4415,{{1,0},{15,0},{16,4462},{20,4462}},{{1,0},{15,0},{16,16},{20,20}}},	--高级秘籍飞剑附带减会心伤害

		skill_statetime={-1},
		userdesc_000={4446,4462},
	},
	cj_book4_child1 = {--峰插云景_秘籍,初始伤害和禁轻功
		attack_usebasedamage_p={{{1,80},{10,161},{20,161}}},
		attack_metaldamage_v={
			[1]={{1,80*2*0.9},{15,161*2*0.9},{20,161*2*0.9}},
			[3]={{1,80*2*1.1},{15,161*2*1.1},{20,161*2*1.1}}
		},
		state_nojump_attack={{{1,50},{10,100},{20,100}},4*15},
		missile_hitcount={3,0,0},
	},
    cj_book4_child3 = --峰插云景_高级秘籍减敌人造成的会心伤害
    {
		deadlystrike_damage_p={{{1,0},{15,0},{16,-6},{20,-30}}},
		superposemagic={3},						--叠加层数
		skill_statetime={{{1,0},{15,0},{16,5*15},{20,5*15}}},
    },

	cj_hggs = --鹤归孤山-40级被动2（光环）--10级
	{
		add_mult_proc_sate1={4418,{{1,6},{10,6},{11,6}},60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},
		userdesc_000={4419},							--描述用，对应cj_hggs_enemy
		userdesc_101={{{1,2},{10,20},{11,22}}},			--增加自身攻击力的描述，要与cj_hggs_self数值一致
	},
	cj_hggs_self = --鹤归孤山_自身--10级
	{
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		physics_potentialdamage_p={{{1,2},{10,20},{11,42}}},
		skill_statetime={{{1,15*10},{10,15*10},{11,15*10}}},
	},
	cj_hggs_enemy = {--鹤归孤山_敌人--10级
		physics_potentialdamage_p={{{1,-10},{10,-60},{11,-86}}},	--减少基础攻击力
		add_dottype_wood_p={1,{{1,-1},{10,-5},{11,-5}}},			--参数1：跟五毒skill_dot_ext_type定义的类型一样，参数2：减少毒伤的%
		skill_statetime={{{1,15*3},{10,15*3},{11,15*3}}},
	},

	cj_gjjf = {--高级剑法-50级被动3--10级
		add_skill_level={4401,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={4402,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={4403,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={4404,{{1,1},{10,10},{11,11}},0},
		userdesc_000={4421},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
	},
	cj_gjjf_child = {--高级剑法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-30级）--10级
		attack_usebasedamage_p={{{1,4},{10,40},{11,44}}},
		attack_metaldamage_v={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
			},
	},
	cj_ybsl = {--映波锁澜-60级被动4--10级
		autoskill={166,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},

		userdesc_000={4423},
	},
	cj_ybsl_child = {--映波锁澜_子1
		all_series_resist_p={{{1,150},{10,1500},{11,1850}}},
		ignore_abnor_state={},		--免疫负面效果
		state_zhican_ignore={1},		--免疫致残
		skill_statetime={{{1,0.3*15},{10,1.2*15},{11,1.2*15}}},
	},

	cj_yqs = {--云栖松-70级被动5--10级
		autoskill={132,{{1,1},{10,10},{11,11}}},
		userdesc_000={4425,4426},
		userdesc_101={{{1,40},{10,90},{11,95}}},			--描述用，实际触发几率请查看autoskill.tab中的云栖松
		userdesc_102={{{1,15*39},{10,15*30},{11,15*30}}},	--描述用，实际触发间隔请查看autoskill.tab中的云栖松
		skill_statetime={-1},
	},
	cj_yqs_child1  = {--云栖松_子1
		attack_usebasedamage_p={{{1,100},{10,200},{11,220}}},
		attack_metaldamage_v={
			[1]={{1,100*2*0.9},{10,200*2*0.9},{11,220*2*0.9}},
			[3]={{1,100*2*1.1},{10,200*2*1.1},{11,220*2*1.1}}
		},
		attack_steallife_p={200},
		missile_hitcount={3,0,0},
	},
	cj_yqs_child2 = {--云栖松_子2
		invincible_b={1},
	 	recover_life_p={{{1,1},{10,5},{12,6}},30},
		skill_statetime={5},
	},

	cj_flws = {--风来吴山-80级被动6--20级
		physics_potentialdamage_p={{{1,10},{20,55},{24,55*1.2}}},
		lifemax_p={{{1,4},{20,75},{24,75*1.2}}},
		all_series_resist_p={{{1,4},{20,40},{24,40*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		state_hurt_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_zhican_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
	},

	cj_hltc = {--黄龙吐翠-90级被动7--10级
		autoskill={133,{{1,1},{10,10},{11,11}}},
		skill_statetime={-1},

		userdesc_000={4429},
		userdesc_101={{{1,6},{10,15},{11,15}}},			--触发几率的描述，实际间隔在auto.tab中修改
		--userdesc_102={{{1,15*5},{10,15*5},{11,15*5}}},		--触发间隔的描述，实际间隔在auto.tab中修改
	},
	cj_hltc_child = {--黄龙吐翠_子
		attack_usebasedamage_p={{{1,50},{10,200},{11,220}}},
		attack_metaldamage_v={
			[1]={{1,50*2*0.9},{10,200*2*0.9},{11,220*2*0.9}},
			[3]={{1,50*2*1.1},{10,200*2*1.1},{11,220*2*1.1}}
			},
		missile_hitcount={3,0,0},
	},

	cj_nq = {--藏剑怒气-怒气
		attack_usebasedamage_p={{{1,300},{30,300}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	cj_nq_child1 = {--藏剑怒气_子
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	cj_nq_child2 = {--藏剑怒气_免疫
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
	},
}

FightSkill:AddMagicData(tb)