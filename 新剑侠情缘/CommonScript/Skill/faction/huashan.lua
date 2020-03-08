
local tb    = {
	hs_pg1 = {--华山剑法-普攻1式--20级
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
	hs_pg2 = {--华山剑法-普攻2式--20级
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
	hs_pg3 = {--华山剑法-普攻3式--20级
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
	hs_pg4 = {--华山剑法-普攻4式--20级
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,90*1.5},{30,130*1.5},{31,184*1.5}}},
		attack_wooddamage_v={
			[1]={{1,60*1.5*2*0.9},{20,90*1.5*2*0.9},{30,130*1.5*2*0.9},{31,184*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,90*1.5*2*1.1},{30,130*1.5*2*1.1},{31,184*1.5*2*1.1}}
			},
		state_zhican_attack={80,6},
		spe_knock_param1={1},
		state_npcknock_attack={100,14,30},
		spe_knock_param={11 , 4, 26},

		missile_hitcount={3,0,0},
	},

	hs_xscl = {--萧史乘龙
		skill_mintimepercast_v={0},				--无cd
		check_buff_superpose={5218,3},			--3点剑意才能使用

		userdesc_000={5207},				--萧史乘龙伤害,剑意获得间隔
		userdesc_101={2*15},				--萧史乘龙伤害,剑意获得间隔
	},
	hs_xscl_child1 = {--萧史乘龙_伤害
		attack_usebasedamage_p={{{1,268},{15,359},{20,492}}},
		attack_wooddamage_v={
			[1]={{1,268*2*0.9},{15,359*2*0.9},{20,492*2*0.9}},
			[3]={{1,268*2*1.1},{15,359*2*1.1},{20,492*2*1.1}}
		},
		state_zhican_attack={{{1,50},{15,80},{20,80}},{{1,1*15},{15,1.5*15},{20,2*15},{21,2*15}}},

		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={3,0,0},
	},
	hs_xscl_cost = {--萧史乘龙_扣除剑意
		mult_skill_state={5218,1,-3}, 		--扣除3点剑意
		skill_statetime={1},
	},
	hs_xscl_bd = {--萧史乘龙_自动获得剑意
		autoskill={136,{{1,1},{15,15}}},
		skill_statetime={-1},
	},
	hs_xscl_bd_child1 = {--萧史乘龙_剑意
		physics_potentialdamage_p={0},
		superposemagic={10},				--叠加层数
		skill_statetime={60*15},
	},

	hs_book1 = {--萧史乘龙秘籍_20级
		--增加会心
		add_deadlystrike_p1={5207,{{1,2},{10,25},{20,25}}},

		--冲刺后获得免控buff
		addstartskill={
			{{1,0},{10,0},{11,5207},{20,5207}},
			{{1,0},{10,0},{11,5249},{20,5249}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		--增加攻击力
		add_usebasedmg_p1={5207,{{1,0},{15,0},{16,6},{20,33}}},

		skill_statetime={-1},

		userdesc_000={5249},
	},
	hs_book1_child2 = {--萧史乘龙秘籍_免控
		ignore_abnor_state={},			--免疫负面
		ignore_series_state={},		--免疫致残

		skill_statetime={{{1,0},{10,0},{11,0.4*15},{15,2*15},{20,2*15}}},
	},

	hs_tsdx = {--天绅倒悬_15级
		attack_usebasedamage_p={{{1,187},{15,349},{20,407}}},
		attack_wooddamage_v={
			[1]={{1,187*2*0.9},{15,349*2*0.9},{20,407*2*0.9}},
			[3]={{1,187*2*1.1},{15,349*2*1.1},{20,407*2*1.1}}
		},

		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={3,0,0},

		skill_mintimepercast_v={{{1,16*15},{15,8*15},{20,8*15}}},

		userdesc_000={5210},
	},
	hs_tsdx_child1 = {--天绅倒悬_debuff_15级
		physics_potentialdamage_p={{{1,-75},{15,-150},{20,-200}}},

		skill_statetime={4*15},
	},

	hs_book2 = {--天绅倒悬秘籍_20级
		--结束时造成致缠和延长目标技能cd
		add_buffendskill1={{{1,5210},{20,5210}},{{1,5250},{20,5250}},{{1,1},{20,20}}},

		--增加天绅倒悬的吸血
		add_steallife_p={5209,{{1,0},{10,0},{11,1000},{15,5000},{20,5000}}},

		--驱散,效果在初级里的高等级效果
		skill_statetime={-1},

		userdesc_000={5250},
	},
	hs_book2_child1 = {--天绅倒悬_结束效果
		state_zhican_attack={{{1,50},{10,100},{20,100}},{{1,2*15},{10,2*15},{20,2*15}}},

		--高级秘籍
		rand_ignoreskill={{{1,0},{15,0},{16,30},{20,100}},{{1,0},{15,0},{16,1},{20,2}},1},		--概率，数量，类型（skillsetting下定义类型）
	},

	hs_cyyqj = {--朝阳一气剑_15级
		attack_usebasedamage_p={{{1,184},{15,382},{20,553}}},
		attack_wooddamage_v={
			[1]={{1,184*2*0.9},{15,382*2*0.9},{20,553*2*0.9}},
			[3]={{1,184*2*1.1},{15,382*2*1.1},{20,553*2*1.1}}
		},
		state_zhican_attack={{{1,20},{15,60},{20,80}},2*15},
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={2,0,0},

		skill_mintimepercast_v={15*15},

		userdesc_000={5214},
	},
	hs_cyyqj_charge = {--朝阳一气剑_15级_获得剑意
		mult_skill_state={5218,1,3}, 		--获得3点剑意
		skill_statetime={1},
	},

	hs_charge1 = {--通用_获得1剑意
		mult_skill_state={5218,1,1}, 		--获得3点剑意
		skill_statetime={1},
	},
	hs_book3 = {--朝阳一气剑_20级
		--提高伤害,造成减速
		add_usebasedmg_p1={5212,{{1,5},{10,50},{20,50}}},
		add_hitskill_pos1={5212,5251,{{1,1},{20,20}}},

		--自身获得buff
		addstartskill={
			{{1,0},{10,0},{11,5214},{20,5214}},
			{{1,0},{10,0},{11,5252},{20,5252}},
			{{1,0},{10,0},{11,11},{20,20}}
		},

		--受击时几率刷新cd
		autoskill={
			{{1,0},{15,0},{16,140},{20,140}},
			{{1,0},{15,0},{16,11},{20,20}}
		},

		--驱散,效果在初级里的高等级效果
		skill_statetime={-1},

		userdesc_000={5251,5252},
		userdesc_101={{{1,0},{15,0},{16,4},{20,20}}},	--触发几率描述
	},
	hs_book3_child1 = {--朝阳一气剑.减速
		runspeed_p={{{1,-4},{10,-40},{11,-40}}},
		skill_statetime={6*15},
	},
	hs_book3_child2 = {--会伤加成
		deadlystrike_damage_p={{{1,0},{10,0},{11,12},{15,60},{20,70}}},
		skill_statetime={6*15},
	},
	hs_book3_child3 = {--清cd
		reduce_cd_time_point1={5212,15*15,1},		--刷新天绅倒悬cd
	},

	hs_byj = {--抱元劲-20级被动1--10级
		--physics_potentialdamage_p={{{1,3},{10,25},{12,30}}},
		deadlystrike_p={{{1,8},{10,75},{12,75*1.2}}},
		attackspeed_v={{{1,3},{10,30},{11,30}}},
		runspeed_v={{{1,10},{10,50},{11,50}}},
		state_stun_resistrate={{{1,15},{10,150},{11,165}}},
		skill_statetime={-1},
	},

	hs_fszx = {--风送紫霞
		skill_mintimepercast_v={5*15},
		check_buff_superpose={5218,5},			--5点剑意才能使用

		userdesc_000={5216},				--萧史乘龙伤害,剑意获得间隔
	},
	hs_fszx_cost = {--扣除剑意
		mult_skill_state={5218,1,-5}, 		--扣除5点剑意

		skill_statetime={1},
	},
	hs_fszx_detonate = {--引爆紫霞剑气
		hitfilter_buff={5234},								--有剑气才能击中,然后hitskill是范围伤害,从而每层爆一次伤害
		mult_skill_state={5234,1,-1}, 		--扣除1层剑气

		state_slowall_attack={0,1},	--挂一个伤害属性,autoskill才能走到击中触发

		skill_statetime={1},
	},
	hs_fszx_dmg = {--风送紫霞_伤害
		loselife_dmg_p={1},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,64},{15,113},{20,231}}},
		attack_wooddamage_v={
			[1]={{1,64*2*0.9},{15,113*2*0.9},{20,231*2*0.9}},
			[3]={{1,64*2*1.1},{15,113*2*1.1},{20,231*2*1.1}}
		},
		state_zhican_attack={{{1,5},{15,15},{20,20}},2*15},
		state_npcknock_attack={100,12,10},
		spe_knock_param={9 , 4, 26},

		missile_hitcount={3,0,0},
	},
	hs_fszx_bd = {--释放萧史乘龙自动叠加紫霞剑气
		addstartskill={5208,5234,1},
		skill_statetime={-1},
	},
	hs_fszx_zxjq = {--紫霞剑气
		physics_potentialdamage_p={0},
		superposemagic={10},				--叠加层数
		skill_statetime={60*15},
	},

	hs_book4 = {--风送紫霞秘籍
		--风送紫霞每引爆一层概率触发回复剑意
		autoskill={124,{{1,1},{10,10}}},

		--伤害加成
		add_usebasedmg_p1={5216,{{1,0},{10,0},{11,3},{15,18},{20,20}}},

		--每n秒自动叠加紫气
		autoskill2={
			{{1,0},{15,0},{16,125},{20,125}},
			{{1,0},{15,0},{16,16},{20,20}}
		},

		--驱散,效果在初级里的高等级效果
		skill_statetime={-1},

		userdesc_101={{{1,10},{10,100},{20,100}}},						--初级秘籍触发几率描述
		userdesc_102={{{1,60*15},{15,60*15},{16,15*15},{20,5*15}}},		--高级秘籍触发间隔描述
	},

	hs_sp = {--识破_10级
		add_deadlystrike_p1={5209,{{1,1},{10,10},{15,25}}},
		addstartskill={5209,5221,{{1,1},{15,15}}},
		skill_statetime={-1},

		userdesc_000={5221,5222},
	},
	hs_sp_child1 = {--识破_10级
		stealdmg_shield={1},		--护盾吸收伤害的%转换成生命回复
		certainly_hit={},			--必然被击中
		autoskill={138,{{1,1},{10,10}}},
		ignore_skillstate1={5379},	--免疫武当禁疗
		ignore_skillstate2={4542},	--免疫长歌禁疗
		ignore_skillstate2={4543},	--免疫长歌禁疗
		skill_statetime={{{1,0.2*15},{10,0.8*15},{11,0.8*15}}},

		userdesc_101={{{1,0.2*15},{10,0.8*15},{11,0.8*15}}},
		userdesc_102={{{1,10},{10,100},{11,110}},1},--生命上限,自身数值
	},
	hs_sp_child2 = {--识破_10级
		reduce_cd_time_point1={5209,{{1,1*15},{10,4*15},{11,4*15}},1},		--减少天绅倒悬cd
		mult_skill_state={5218,1,3}, --回复剑意
		dir_recover_life_pp={{{1,50},{10,500},{11,550}},1},				--生命上限,自身数值
		skill_statetime={1},
	},
	hs_sp_child3 = {--识破_10级_击中范围敌人,每击中一个目标给自己回血
		missile_hitcount={0,0,5},
	},
	hs_sp_child4 = {--识破_10级,击中每个人回血
		dir_recover_life_pp={{{1,10},{10,100},{11,110}},1},--生命上限,自身数值
		skill_statetime={1},
	},

	hs_gjjf = { --高级剑法
		add_skill_level={5201,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={5202,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={5203,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={5204,{{1,1},{10,10},{11,11}},0},

		skill_statetime={-1},

		userdesc_101={{{1,4},{10,40},{11,44}}},
		userdesc_102={
			[1]={{1,4*2*0.9},{10,40*2*0.9},{11,44*2*0.9}},
			[3]={{1,4*2*1.1},{10,40*2*1.1},{11,44*2*1.1}}
		},
	},

	hs_zxsg = { --紫霞神功,生命越低受伤越低,
		lowhp_damage_beatt_p={{{1,-4},{10,-40}},0},	--血越少受到伤害加成系数,加成系数基数
		steallife_resist_p={{{1,2},{10,20}}},
		skill_statetime={-1},
	},

	hs_ythg= {--云天弧光
		autoskill={137,{{1,1},{10,10}}},
		skill_statetime={-1},

		add_steallife_p={5226,10000},	--好像不能直接伤害吸血,需要用这个来加成

		userdesc_000={5226},
		userdesc_101={{{1,12},{10,50},{15,50}}},
	},
	hs_ythg_dmg = {--云天弧光_伤害
		attack_usebasedamage_p={{{1,30},{10,72},{15,208}}},
		attack_wooddamage_v={
			[1]={{1,30*2*0.9},{10,72*2*0.9},{15,208*2*0.9}},
			[3]={{1,30*2*1.1},{10,72*2*1.1},{15,208*2*1.1}}
		},

		missile_hitcount={2,0,0},
	},

	hs_hyg = {--混元功-80级被动6--20级
		physics_potentialdamage_p={{{1,3},{20,45},{24,55*1.2}}},
		lifemax_p={{{1,5},{20,85},{24,85*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,3},{20,45},{24,45*1.2}}},
		state_zhican_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_stun_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
	},
	hs_tgyy= {--天光云影_90被动_10级
		autoskill={139,{{1,1},{10,10}}},
		add_deadlystrike_p1={5226,{{1,2},{10,20}}},

		skill_statetime={-1},

		userdesc_000={5226},
		userdesc_101={{{1,4},{10,16},{11,24}}},	--触发几率描述
	},

	hs_nq = {--华山怒气-怒气
		attack_usebasedamage_p={{{1,300},{30,300}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	hs_nq_child1 = {--华山怒气_免疫
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
	},
	hs_nq_child2 = {--华山怒气_免疫
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
	},
}

FightSkill:AddMagicData(tb)