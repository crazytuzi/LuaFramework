
local tb    = {
	xmhj_buff_recover=  --buff_回复
    { 
		recover_life_p={{{1,4},{20,100}},15},
		skill_statetime={{{1,15*5},{20,15*5}}},
    },
	xmhj_buff_adddamage=  --buff_攻击
    { 
		physics_potentialdamage_p={{{1,100},{20,200}}},
		skill_statetime={{{1,15*60*3},{20,15*60*3}}},
    },
	xmhj_buff_series=  --buff_抗性
    { 
		all_series_resist_p={{{1,200},{20,300}}},
		skill_statetime={{{1,15*60*3},{30,15*60*3}}},
    },
	xmhj_buff_runspeed=  --buff_跑速
    { 
		runspeed_p={{{1,40},{20,100}}},
		skill_statetime={{{1,15*60*3},{30,15*60*3}}},
    },
	xmhj_buff_huixin=  --buff_会心
    { 
		deadlystrike_v={{{1,1500},{30,1500}}},
		deadlystrike_damage_p={{{1,30},{30,30}}},
		skill_statetime={{{1,15*60*3},{30,15*60*3}}},
    },
	xmhj_buff_wudi=  --buff_无敌
    { 
		invincible_b={1},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
	xmhj_jujin = --聚金_子
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_hurt_attack={50,15*2.5},	
		state_npchurt_attack={50,15*2.5},	
    },
	xmhj_jumu = --聚木_子
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_zhican_attack={50,15*2.5},	
    },
	xmhj_jushui = --聚水_子
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_slowall_attack={50,15*2.5},	
    },
	xmhj_juhuo = --聚火_子
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_confuse_attack={50,15*2.5},	
    },
	xmhj_jutu = --聚土_子
    { 
		attack_usebasedamage_p={{{1,250},{30,540}}},
		state_stun_attack={50,15*2.5},	
    },
	xmhj_gunshi = --滚石_子
    { 
		attack_usebasedamage_p={{{1,150},{30,440}}},
		state_knock_attack={{{1,100},{10,100}},7,20},
		state_npcknock_attack={{{1,100},{10,100}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
	xmhj_jlxj = --惊雷陷阱
    { 
		attack_usebasedamage_p={{{1,150},{30,440}}},
		state_stun_attack={100,15*1.5},	
    },
	xmhj_dgjg = --刀光机关_子
    { 
		attack_usebasedamage_p={{{1,150},{30,440}}},
		state_hurt_attack={100,15*1.5},	
		state_npchurt_attack={100,15*1.5},	
    },
	xmhj_dwjg = --毒雾机关
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_zhican_attack={100,15*1.5},	
    },
	xmhj_psjg = --喷水机关_子
    { 
		attack_usebasedamage_p={{{1,150},{30,440}}},
		state_slowall_attack={100,15*2.5},	
    },
	xmhj_jianzhanli=  --减战力、减回复效果
    { 
		fightpower_v1={{{1,-89100},{2,-431210},{100,-500000}}},
		lifereplenish_p={{{1,-30},{100,-30}}},			--减回复效果%
		steallife_p={{{1,-10},{100,-10}}},				--减吸血%
		skill_statetime={{{1,-1},{30,-1}}},
    },
	xmhj_bzjg= --爆炸机关
    { 
		attack_usebasedamage_p={{{1,150},{30,440}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
   	xmhj_duqi = --毒气
    { 
		dotdamage_maxlife_p={{{1,1},{100,100}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		lifereplenish_p={-100},
		skill_statetime={{{1,15*60*10},{30,15*60*10}}},
    },
   	xmhj_hukang = --忽抗
    { 
		ignore_all_resist={100,100},								--几率，忽抗%
		skill_statetime={{{1,-1},{30,-1}}},
    },
	xmhj_jd_buff_recover=  --buff_回复
    { 
		recover_life_p={{{1,2},{20,100}},15},
		skill_statetime={{{1,15*60},{20,15*60}}},
    },
	xmhj_jd_buff_miankong  = --buff_免控
    {
	 	ignore_series_state={},
	 	ignore_abnor_state={},
		skill_statetime={{{1,15*30},{20,15*30}}},
    },
	xmhj_jd_buff_runspeed=  --buff_跑速
    { 
		runspeed_v={{{1,10},{50,500},{51,500}}},
		skill_statetime={{{1,15*30},{30,15*30}}},
    },
    xmhj_jd_item_hide =   --道具_隐身
    { 
		hide={{{1,15*20},{20,15*39}},1},	--参数1时间，参数2：队友1，同阵营2
		skill_statetime={20*15},
    },
	xmhj_jd_item_recover=  --道具_回复
    { 
		recover_life_p={{{1,5},{20,24}},15},
		autoskill={175,1},
		skill_statetime={{{1,15*15},{20,15*15}}},

    },
	xmhj_jd_stoprecover = {--打断道具回血
		mult_skill_state={3198,1,-1}, 		--技能ID，等级，buff层数
		skill_statetime={{{1,2},{20,2}}},
	},
	xmhj_jd_bzjg= --爆炸机关
    { 
		make_npc_lose_lifeP={{{1,1},{50,50}}},  --扣除当前生命%
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
}

FightSkill:AddMagicData(tb)