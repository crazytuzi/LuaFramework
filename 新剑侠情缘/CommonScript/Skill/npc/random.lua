
local tb    = { 
    npc_random_1= --光环_回血
    { 
	 	recover_life_p={{{1,1},{10,10},{100,100}},15},
		skill_statetime={{{1,15*3},{30,15*3}}},		
    },
    npc_random_2= --光环_加抗
    { 
        all_series_resist_p={{{1,20},{30,165}}},
		skill_statetime={{{1,15*3},{30,15*3}}},	
    },
    npc_random_3= --光环_攻速
    { 
		attackspeed_v={{{1,20},{20,120}}},		
		skill_statetime={{{1,15*3},{30,15*3}}},		
    },
    npc_random_4= --光环_伤害
    { 
		physics_potentialdamage_p={{{1,10},{30,300}}},	
		skill_statetime={{{1,15*3},{30,15*3}}},		
    },
    npc_random_5= --熊-地裂
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	npc_random_6 = --狂暴
    { 
		physics_potentialdamage_p={{{1,300},{30,300}}},	--增加攻击力百分比
		skill_statetime={{{1,15*5},{30,15*34}}},
    },
    npc_random_7 = --俯冲_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	npc_random_8 = --九星连环
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	npc_random_9_1 = --姬御天-普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	npc_random_9= --姬御天-连击
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},  
		state_knock_attack={100,10,20},
		state_npcknock_attack={100,10,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_10= --姬御天-地裂 
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_11= --排山倒海
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },
	npc_random_12= --双龙出海
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_knock_attack={100,8,40},
		state_npcknock_attack={100,8,40}, 
		spe_knock_param={3 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_13= --机关-击退
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,15,20},
		state_npcknock_attack={100,15,20},
		spe_knock_param={5 , 4, 4},			
    },	
	npc_random_14= --机关-冻结
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_freeze_attack={{{1,30},{8,100},{30,100}},{{1,15*3},{30,15*3}}},	
    },
    npc_random_15 = --机关-回复
    { 
		recover_life_p={{{1,1},{30,30},{31,30}},15},	
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	npc_random_16 = --机关-火焰
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},		
		state_palsy_attack={{{1,30},{8,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
    npc_random_17_1 = --天舞法阵
    { 
		vitality_recover_life={{{1,20*1},{30,20*5}},15},
		skill_statetime={{{1,20},{30,20}}},
    },
    npc_random_17_1_child = --天舞法阵_子
    { 
		attack_usebasedamage_p={{{1,50},{30,80}}},
		attack_waterdamage_v={
			[1]={{1,80*0.9},{30,200*0.9}},
			[3]={{1,80*1.1},{30,200*1.1}}
			},
		state_slowall_attack={{{1,70},{30,70}},{{1,15*3},{30,15*3}}},
    },
    npc_random_17_2 = --银针散射
    { 
		attack_usebasedamage_p={{{1,240},{20,280}}},
		state_zhican_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
		missile_hitcount={{{1,3},{30,3}}},
    },
	npc_random_17_3= --劈空掌
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	userdesc_1614= --薛银药-毒
    { 
		userdesc_000={1614},
    },
	npc_random_17_4 = --薛银药-毒
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_17_5 = --银针
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
    },
	npc_random_18= --机关-混乱
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_confuse_attack={{{1,30},{8,100},{30,100}},{{1,15*3},{30,15*3}}},
    },	
	npc_random_19_1 = --紫轩-花剑
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	 
    },
	npc_random_19_2 = --紫轩-落花
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	 
    },
	npc_random_19_3_child1 = --紫轩-燕舞_子1
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
	npc_random_19_3_child2 = --紫轩-燕舞_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
	npc_random_19_4 = --紫轩-花剑扇
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_19_5= --紫轩-魅惑
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_confuse_attack={100,15*4},		
    },	
	npc_random_20_1 = --慕容越普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	 
    },	
	npc_random_20_2 = --慕容越-五星连珠
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	npc_random_20_3 = --慕容越-雷灵破
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_knock_attack={100,32,30},
		state_npcknock_attack={100,32,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	npc_random_20_4 = --慕容越-九星连环
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },	
	npc_random_21_1 = --萧动尘-普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	npc_random_21_2 = --萧动尘-横扫
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	npc_random_21_3 = --萧动尘-惊雷
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
		state_stun_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	npc_random_21_4 = --萧动尘-冲锋
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	npc_random_22_1 = --苏墨芸-寒冰斩
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_22_2 = --苏墨芸-寒月弯刀
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_fixed_attack={{{1,100},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},	
    },
	npc_random_22_3 = --苏墨芸-玄冰无敌斩
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	npc_random_22_4= --苏墨芸-飞斩
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_23_1 = --公输羽-飞轮
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_23_2 = --公输羽-机关地刺
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_23_3 = --公输羽-夺魂链
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_drag_attack={{{1,100},{30,100}},12,60},
		skill_drag_npclen={120},
    },
	npc_random_23_3_child = --公输羽-夺魂链_子
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
	npc_random_23_4 = --公输羽-矩形机关地刺
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_fixed_attack={{{1,100},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},	
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_23_5 = --公输羽-自爆鸟
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_24_1 = --沐紫衣-针散
    { 
		attack_usebasedamage_p={{{1,400},{20,400}}},
		state_confuse_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*2},{31,15*2}}},
    },
    npc_random_24_2 = --沐紫衣-弹射球
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
    npc_random_24_3 = --沐紫衣-沉默之球
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_silence_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5},{31,15*5}}},
    },
	npc_random_24_4 = --沐紫衣-呼啦剑圈
    { 
		attack_usebasedamage_p={{{1,150},{20,150}}},
    },
	npc_random_25_1= --叶无心-旋扇
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_25_2= --叶无心-九宫飞星
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},  
		state_knock_attack={100,12,20},
		state_npcknock_attack={100,12,20}, 
		spe_knock_param={6 , 4, 4},	 		
    },
    npc_random_25_3= --叶无心-狂暴
    { 
		attackspeed_v={{{1,20},{30,20}}},	
		physics_potentialdamage_p={{{1,100},{30,100}}},	
		skill_statetime={{{1,15*15},{30,15*15}}},		
    },
    npc_random_25_4 = --叶无心-火焰掌
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_palsy_attack={{{1,10},{30,10}},{{1,15*2},{30,15*2}}},
    },
	npc_random_25_5= --叶无心-寒冰掌
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*2},{30,15*2},{31,15*2}}},		
    },
	npc_random_25_6= --叶无心-毒镖
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_26_1= --霹雳火-火球术
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_26_2= --霹雳火-炸弹
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	npc_random_26_3= --霹雳火-连环炸弹
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	npc_random_26_4 = --霹雳火-火墙
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},	
		state_palsy_attack={{{1,10},{30,10}},{{1,15*1},{30,15*1}}},
    },
	npc_random_26_5 = --霹雳火-飞火
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_27_1= --月眉儿-冰锥
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_27_2= --月眉儿-光晕
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
    npc_random_27_3 = --月眉儿-弹射球
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_slowall_attack={{{1,100},{20,100}},{{1,15*2},{30,15*2}}},
    },
	npc_random_27_4 = --月眉儿-暴风雪
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*2},{30,15*2},{31,15*2}}},
    },
	npc_random_28_1= --蔷薇-星月
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_28_2= --蔷薇-双星月
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_28_3= --蔷薇-连环星月
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_28_4= --蔷薇-狂怒
    { 
		physics_potentialdamage_p={{{1,100},{30,100}}},	--增加攻击力百分比
		attackspeed_v={{{1,30},{30,30}}},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
	npc_random_29_1= --杨瑛普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_29_2= --杨瑛-无敌斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_29_3 = --杨瑛-太乙生风
    { 
		dotdamage_wood={{{1,100},{20,100}},{{1,0},{30,0}},{{1,8},{30,8}}},
		state_float_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
	npc_random_29_4= --杨瑛-扇形半月
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,20},
		state_npcknock_attack={100,10,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_30_1= --雪块
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*2},{30,15*2},{31,15*2}}},		
    },
	npc_random_31_1= --上官飞龙-剑魄
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_31_2 = --上官飞龙-定时炸弹
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },
	npc_random_31_3 = --上官飞龙-飞斩
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_31_4 = --上官飞龙-重旋
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	npc_random_31_5 = --上官飞龙-重旋散剑
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	npc_random_31_6 = --上官飞龙普攻
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
    npc_random_32_1 = --天王镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_32_2 = --天王镜像-野蛮冲撞_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_32_3 = --天王镜像-霸王怒吼
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_32_4_child1 = --天王镜像-血战八方_子1
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_random_32_4_child2 = --天王镜像-血战八方_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*7},{30,15*7}}},
    },
    npc_random_33_1 = --峨眉镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_33_2 = --峨眉镜像-江海凝波_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_33_3 = --峨眉镜像-白露凝霜_子
    { 
		attack_usebasedamage_p={{{1,350},{30,350}}},
    },
    npc_random_33_4 = --峨眉镜像-天舞宝轮_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_34_1 = --桃花镜像普攻
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    }, 
    npc_random_34_2 = --桃花镜像-飞火流星
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
    },	
    npc_random_34_3 = --桃花镜像-九曜连珠
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_random_34_4 = --桃花镜像-穿云破月
    { 
		attack_usebasedamage_p={{{1,700},{30,700}}},
    },
    npc_random_35_1 = --逍遥镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_35_2 = --逍遥镜像-白虹贯日_子1
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_35_3 = --逍遥镜像-七探蛇盘_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_35_4 = --逍遥镜像-斗转星移
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_35_4_child = --逍遥镜像-斗转星移_子
    { 
		--state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
    npc_random_35_5 = --逍遥镜像-风卷残云
    { 
		dotdamage_wood={{{1,300},{30,300}},{{1,0},{30,0}},{{1,5},{30,5}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    },
    npc_random_36= --致命光环-火
    { 
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
    },
    npc_random_37 = --抗性光环-火
    { 
		fire_resist_p={{{1,10000},{30,10000}}},  --万分比，10000 = 100%
    },
	npc_random_38_1 = --藏剑
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
		state_float_attack={{{1,50},{30,50}},{{1,15*2},{30,15*2}}},
		skill_statetime={{{1,15*2},{30,15*2}}},	
    },
	npc_random_38_2 = --含锋
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_zhican_attack={{{1,50},{30,50},{31,50}},{{1,15*1.5},{30,15*1.5},{31,15*1.5}}},
    },
	npc_random_38_3 = --碎金
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_39_1 = --落叶步
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
	npc_random_39_2 = --焚心
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_confuse_attack={50,15*1.5},	
    },
	npc_random_39_3 = --暴风剑
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
	npc_random_40_1 = --唤风
    { 
		autoskill={92,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*20},{30,15*20}}},	
    },
	npc_random_40_1_child = --唤风_子
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
    },
	npc_random_40_2 = --风护
    { 
		autoskill={93,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*20},{30,15*20}}},	
    },
	npc_random_40_2_child = --风护_子
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
    },
	npc_random_40_3 = --烈风
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={50,10,50},
		state_npcknock_attack={50,10,50},
		spe_knock_param={5 , 4, 4},		
    },
	npc_random_40_4 = --风卷
    { 
		attack_usebasedamage_p={{{1,240},{30,300}}},
		state_drag_attack={{{1,100},{30,100}},8,70},
		skill_drag_npclen={70},
    },
	npc_random_40_4_child = --风卷_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_40_5 = --烈风
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={50,10,50},
		state_npcknock_attack={50,10,50},
		spe_knock_param={5 , 4, 4},	
		missile_hitcount={{{1,1},{30,1}}}, 		
    },
	npc_random_41_1 = --啸风三击
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_41_2 = --寒冰掌
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_slowall_attack={50,15*3},
    },
	npc_random_41_3 = --冰踪无影
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
	npc_random_41_4 = --冰聚
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_random_42_1 = --烈火
    { 
		attack_usebasedamage_p={{{1,350},{30,350}}},
		state_slowrun_attack={50,15*5},
    },
	npc_random_42_2 = --焚城
    { 
		attack_usebasedamage_p={{{1,350},{30,350}}},
		state_confuse_attack={30,15*1},	
    },
	npc_random_42_3 = --虚空
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_drag_attack={{{1,100},{30,100}},8,40},
		skill_drag_npclen={20},
    },
    npc_random_42_4 = --不灭
    { 
	 	recover_life_p={{{1,1},{10,10},{11,10}},15},
		skill_statetime={{{1,20},{30,20}}},
    },
	npc_random_43_1 = --严寒
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    },
	npc_random_43_2 = --雪舞
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_slowrun_attack={50,15*1},		
    },
	npc_random_43_2_child = --雪舞_子1
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	npc_random_43_3 = --御冰_伤害1
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_zhican_attack={{{1,50},{30,50}},{{1,15*2},{30,15*2}}},
    },
	npc_random_43_3_child = --御冰_伤害2
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
	npc_random_43_4 = --吹雪
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_freeze_attack={{{1,30},{30,30}},{{1,15*1.5},{30,15*1.5}}},
    },
    npc_random_44_1 = --武当心魔普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_44_2 = --武当心魔-剑飞惊天
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_44_3 = --武当心魔-人剑合一
    { 
		attack_usebasedamage_p={{{1,450},{30,450}}},
    },
    npc_random_44_4 = --武当心魔-天地无极
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_45_1 = --天忍心魔普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_45_2 = --天忍心魔-魔焰在天
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
    npc_random_45_3 = --天忍心魔-死亡回旋
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_random_45_4 = --天忍心魔-摄魂乱心
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_46_1 = --少林心魔普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_46_2 = --少林心魔-降龙棍
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
    },
    npc_random_46_3 = --少林心魔-大力金刚指
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_46_4 = --少林心魔-十二擒龙手
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_drag_attack={{{1,100},{15,100}},8,70},
		skill_drag_npclen={90},
    },
    npc_random_47_1 = --翠烟心魔普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_47_2 = --翠烟心魔-璇玑罗舞_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_47_3 = --翠烟心魔-雨打梨花_子
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
    },
    npc_random_47_4 = --翠烟心魔-冰踪无影
    { 
		attack_usebasedamage_p={{{1,450},{30,450}}},
    }, 
    npc_random_48_1 = --唐门镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_48_2 = --唐门镜像-缠身刺_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_48_3 = --唐门镜像-暴雨梨花
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_random_48_4_child = --唐门镜像-九宫飞星_子
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
    },  
    npc_random_49_1 = --昆仑镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_49_2 = --昆仑镜像-仙人指路_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_49_3 = --昆仑镜像-混沌剑阵_子
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_random_49_4 = --昆仑镜像-啸风三连击
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },  
    npc_random_49_5 = --昆仑镜像-雷动九天
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_50_1 = --旋风陷阱
    { 
		autoskill={20,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*2},{30,15*2}}},
    },   
	npc_random_50_1_child = --旋风陷阱_子
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},30,1000000},	
		state_knock_attack={100,7,50},
		state_npcknock_attack={100,7,50},
		spe_knock_param={3 , 4, 9},	
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_random_51_1 = --火焰陷阱-造混乱
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},30,1000000},	
		state_confuse_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
		skill_statetime={{{1,1},{30,1}}},
    },
    npc_random_52_1 = --无敌光环
    { 
		autoskill={85,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,15*3},{30,15*3}}},
    }, 
    npc_random_52_1_child  = --无敌光环_子
    {
		invincible_b={1},
		skill_statetime={{{1,15*1},{30,15*1}}},
    },
    npc_random_53_1 = --黄暮云普攻
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    }, 
    npc_random_53_2 = --黄暮云-飞火流星
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_knock_attack={40,12,30},
		state_npcknock_attack={100,12,30},
		spe_knock_param={9 , 4, 9},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },	
    npc_random_53_3 = --黄暮云-九曜连珠
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_palsy_attack={{{1,50},{30,50}},{{1,15*1.5},{30,15*1.5}}},
    },
    npc_random_53_4 = --黄暮云-穿云破月
    { 
		attack_usebasedamage_p={{{1,700},{30,700}}},
    },
    npc_random_54_1 = --道一真人普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_54_2 = --道一真人-剑飞惊天
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },
    npc_random_54_3 = --道一真人-人剑合一
    { 
		attack_usebasedamage_p={{{1,450},{30,450}}},
    },
    npc_random_54_4 = --道一真人-天地无极
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_stun_attack={{{1,30},{30,30}},{{1,15*1},{30,15*1}}},
    },
    npc_random_55_1 = --端木睿普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_55_2 = --端木睿-魔焰在天
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_burn_attack={{{1,30},{30,30}},{{1,15*5},{30,15*5}},10},  	--概率，持续时间，叠加百分比
		runspeed_p={{{1,-20},{30,-20}}},
		skill_statetime={{{1,15*5},{30,15*5}}},	
    },
    npc_random_55_3 = --端木睿-死亡回旋
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_random_55_4 = --端木睿-摄魂乱心
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_confuse_attack={{{1,15},{30,30}},{{1,15*1.5},{30,15*1.5}}},		
		state_drag_attack={{{1,50},{30,50}},8,30},		
		skill_drag_npclen={0},
    },
    npc_random_56_1 = --尹含烟普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_56_2 = --尹含烟-璇玑罗舞_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_56_3 = --尹含烟-雨打梨花_子
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_slowall_attack={{{1,70},{30,70}},{{1,15*1},{30,15*1}}},
    },
    npc_random_56_4 = --尹含烟-冰踪无影
    { 
		attack_usebasedamage_p={{{1,450},{30,450}}},
		state_freeze_attack={{{1,90},{30,90}},{{1,15*1},{30,15*2}}},
    }, 
	npc_random_56_5 = --尹含烟-召唤啵啵
    { 
		call_npc1={2114, -1, 3},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc2={2114, -1, 3},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		call_npc3={2114, -1, 3},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2114},
		skill_statetime={{{1,15*50},{30,15*50}}},
    },	
	npc_random_56_5_child = --召唤啵啵_子--15级
    { 
	 	callnpc_life={2114,{{1,5},{30,5}}},					--NPCid，生命值%
	 	callnpc_damage={2114,{{1,30},{30,30}}},				--NPCid，攻击力%
		skill_statetime={{{1,15*50},{30,15*50}}},			--持续时间需要跟cy_zh的时间一致
    },
    npc_random_56_6 = --啵啵-普攻
    { 
		attack_usebasedamage_p={150},
		missile_hitcount={{{1,4},{15,4},{16,4}}},  
    },
    npc_random_56_7 = --啵啵-冲
    { 
		attack_usebasedamage_p={200},
		state_slowall_attack={100,15*2},
    },
    npc_random_57_1 = --璇玑子昆仑剑法
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_57_2 = --璇玑子-仙人指路
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    },
    npc_random_57_3 = --璇玑子-混沌剑阵
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
    npc_random_57_4 = --璇玑子-啸风三连击
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_stun_attack={{{1,40},{30,40}},{{1,15*2},{30,15*2}}},
		state_knock_attack={100,7,50},
		state_npcknock_attack={100,7,50},	
		spe_knock_param={6 , 4, 9},
    },
    npc_random_57_5 = --璇玑子-雷动九天
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,60},{30,60}},{{1,15*1.5},{30,15*1.5}}},
    },
	npc_random_58_1 = --六合独尊
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},30,1000000},	
		state_knock_attack={100,9,50},
		state_npcknock_attack={100,9,50},
		spe_knock_param={3 , 4, 9},	
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_random_59_1 = --大刀光
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},30,1000000},	
		state_knock_attack={100,7,100},
		state_npcknock_attack={100,7,100},
		spe_knock_param={5 , 4, 9},	
		skill_statetime={{{1,1},{30,1}}},
    },
    npc_random_60_1 = --丐帮镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_60_2 = --丐帮镜像-亢龙有悔
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_random_60_3 = --丐帮镜像-困龙功
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
    npc_random_60_4 = --丐帮镜像-龙战于野
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },  
    npc_random_61_1 = --五毒镜像普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
    npc_random_61_2 = --五毒镜像-阴风蚀骨
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_random_61_3 = --五毒镜像召唤毒虫
    { 
		skill_randskill1={{{1,20},{10,20}},3631,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill2={{{1,20},{10,20}},3633,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill3={{{1,20},{10,20}},3635,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill4={{{1,20},{10,20}},3637,{{1,1},{10,10}}},	--权值，技能ID，等级
		skill_randskill5={{{1,20},{10,20}},3639,{{1,1},{10,10}}},	--权值，技能ID，等级	
		skill_statetime={{{1,2},{15,2},{16,2}}},	
    },
	npc_random_61_3_ls = --召唤毒虫_灵蛇
    { 
		call_npc1={2190, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2190},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	npc_random_61_3_ls_child = --召唤毒虫_灵蛇_子
    { 
	 	callnpc_life={2190,{{1,100},{30,100}}},			--NPCid，生命值%
	 	callnpc_damage={2190,{{1,30},{30,30}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},		--持续时间需要跟召唤毒虫_灵蛇的时间一致
    },
	npc_random_61_3_bc = --召唤毒虫_碧蟾
    { 
		call_npc1={2191, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2191},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	npc_random_61_3_bc_child = --召唤毒虫_碧蟾_子
    { 
	 	callnpc_life={2191,{{1,100},{30,100}}},			--NPCid，生命值%
	 	callnpc_damage={2191,{{1,30},{30,30}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},		--持续时间需要跟召唤毒虫_碧蟾的时间一致
    },
	npc_random_61_3_cx = --召唤毒虫_赤蝎
    { 
		call_npc1={2192, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2192},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},
    },	
	npc_random_61_3_cx_child = --召唤毒虫_赤蝎_子
    { 
	 	callnpc_life={2192,{{1,100},{30,100}}},			--NPCid，生命值%
	 	callnpc_damage={2192,{{1,30},{30,30}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},		--持续时间需要跟召唤毒虫_赤蝎的时间一致
    },
	npc_random_61_3_fw = --召唤毒虫_风蜈
    { 
		call_npc1={2193, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2193},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},	
    },	
	npc_random_61_3_fw_child = --召唤毒虫_风蜈_子
    { 
	 	callnpc_life={2193,{{1,100},{30,100}}},			--NPCid，生命值%
	 	callnpc_damage={2193,{{1,30},{30,30}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},		--持续时间需要跟召唤毒虫_风蜈的时间一致
    },
	npc_random_61_3_mz = --召唤毒虫_墨蛛
    { 
		call_npc1={2194, -1, 2},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={2194},
		skill_statetime={{{1,15*15},{15,15*15},{16,15*15}}},
    },	
	npc_random_61_3_mz_child = --召唤毒虫_墨蛛_子
    { 
	 	callnpc_life={2194,{{1,100},{30,100}}},			--NPCid，生命值%
	 	callnpc_damage={2194,{{1,30},{30,30}}},			--NPCid，攻击力%
		skill_statetime={{{1,15*15},{15,15*15}}},		--持续时间需要跟召唤毒虫_墨蛛的时间一致
    },
    npc_random_61_4 = --五毒镜像-万蛊蚀心
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_62_1 = --藏剑镜像-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_62_2 = --藏剑镜像-九溪弥烟
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    },
	npc_random_62_3 = --藏剑镜像-平湖断月
    { 
		userdesc_000={4409},
    },
	npc_random_62_3_child = --藏剑镜像-平湖断月_子
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
	npc_random_62_4 = --藏剑镜像-峰插云景
    { 
		userdesc_000={4414,4415},
    },
	npc_random_62_4_child = --藏剑镜像-峰插云景_内圈伤害
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
	npc_random_63_1 = --长歌镜像-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_63_2 = --长歌镜像-平沙雁落
    { 
		userdesc_000={4507},
    },
	npc_random_63_2_child = --长歌镜像-平沙雁落_子
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    },
	npc_random_63_3 = --长歌镜像-清音长啸
	{ 
		attack_usebasedamage_p={{{1,200},{30,200}}},
	},
	npc_random_63_3_child1 = --长歌镜像-清音长啸_子1
	{ 
		attack_usebasedamage_p={{{1,200},{30,200}}},
	},
	npc_random_63_3_child2 = --长歌镜像-清音长啸_子2
	{ 
		attack_usebasedamage_p={{{1,200},{30,200}}},
	},
	npc_random_63_3_child3 = --长歌镜像-清音长啸_子3
	{ 
		attack_usebasedamage_p={{{1,200},{30,200}}},
	},
	npc_random_63_3_child4 = --长歌镜像-清音长啸_子4
	{ 
		attack_usebasedamage_p={{{1,200},{30,200}}},
	},
	npc_random_63_4 = --长歌镜像-江逐月天
    { 
		userdesc_000={4519,4520},
    },
	npc_random_63_4_child = --长歌镜像-江逐月天_子
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
	npc_random_64_1 = --天山镜像-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_64_2 = --天山镜像-飞燕凌波
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_64_3 = --天山镜像-银瓶玉碎
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_64_4 = --天山镜像-水龙吟
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    }, 
	npc_random_65_1 = --霸刀镜像-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_65_2 = --霸刀镜像-血刀
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_65_3 = --霸刀镜像-冲锋
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_65_4 = --霸刀镜像-撕裂
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    }, 
	npc_random_66_1 = --华山镜像-华山剑法
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_66_2 = --华山镜像-萧史乘龙_伤害
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_66_3 = --华山镜像-天绅倒悬
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_66_4 = --华山镜像-朝阳一气剑
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_66_5 = --华山镜像-风送紫霞.剑气伤害
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    }, 
	npc_random_67_1 = --明教镜像-明教御环诀
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_67_2 = --明教镜像-焚山噬川
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_67_3 = --明教镜像-电光石火
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_67_4 = --明教镜像-毁天灭地
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    }, 
	npc_random_68_1 = --段氏镜像-段氏扇诀
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_68_2 = --段氏镜像-一阳指
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_68_3 = --段氏镜像-五罗轻烟
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_68_4 = --段氏镜像-六脉神剑
    { 
		attack_usebasedamage_p={{{1,120},{30,120}}},
    }, 
	npc_random_68_5 = --段氏镜像-水龙狱
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_69_1 = --万花镜像-万花笔法
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_69_2 = --万花镜像-执颖点墨
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_69_3 = --万花镜像-兰摧玉折
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_69_4 = --万花镜像-墨虎如生
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    }, 
	npc_random_70_1 = --杨门镜像-杨门箭法
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    }, 
	npc_random_70_2 = --杨门镜像-落箭
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
	npc_random_70_3 = --杨门镜像-横扫千军
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
    },
	npc_control_fire_dotlife_10=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},	
		state_confuse_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_wood_dotlife_30=
    { 
		dotdamage_maxlife_p={{{1,30},{13,100}},31,1000000},
		state_zhican_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_water_dotlife_30=
    { 
		dotdamage_maxlife_p={{{1,30},{13,100}},31,1000000},	
		state_slowall_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_fire_dotlife_30=
    { 
		dotdamage_maxlife_p={{{1,30},{13,100}},31,1000000},	
		state_confuse_attack={{{1,30},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_earth_dotlife_30=
    { 
		dotdamage_maxlife_p={{{1,30},{13,100}},31,1000000},
		state_knock_attack={{{1,30},{10,100}},7,20},
		state_npcknock_attack={{{1,30},{10,100}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_dotlife_10_5 = --百分比掉血10%+5%
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},		
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_dotlife_30_5 = --百分比掉血30%+5%
    { 
		dotdamage_maxlife_p={{{1,30},{13,100}},31,1000000},		
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_maxlifeack_1 = --通用百分比掉血（1~29%）
    { 
		dotdamage_maxlife_p={{{1,1},{30,29},{31,30}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    npc_maxlifeack_2 = --通用百分比掉血（30~59%）
    { 
		dotdamage_maxlife_p={{{1,30},{30,59},{31,60}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    npc_maxlifeack_3 = --通用百分比掉血（60~89%）
    { 
		dotdamage_maxlife_p={{{1,60},{30,89},{31,90}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    npc_maxlifeack_4 = --通用百分比掉血（秒杀）
    { 
		dotdamage_maxlife_p={{{1,100},{30,100},{31,100}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
	npc_sfgyq=  --三分归元气
    { 
		state_knock_attack={{{1,100},{10,100}},26,150},
		state_npcknock_attack={{{1,100},{10,100}},26,150}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
    },
    npc_maxlifeack_jdz = --浸毒掌
    { 
		dotdamage_maxlife_p={{{1,45},{30,45}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    npc_maxlifeack_ldfz = --雷电法阵
    { 
		dotdamage_maxlife_p={{{1,5},{100,104}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
    random_target = --仇恨对象标识
    { 
		runspeed_v={{{1,-1},{30,-1}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	npc_control_gold_dotlife_10_5=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},
		state_knock_attack={30,35,30},			--概率，持续时间，速度
		state_npcknock_attack={30,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_wood_dotlife_10_5=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},
		state_zhican_attack={{{1,30},{10,30},{11,30}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_water_dotlife_10_5=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},
		state_slowall_attack={{{1,30},{10,30},{11,30}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_fire_dotlife_10_5=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},	
		state_confuse_attack={{{1,30},{10,30},{11,30}},{{1,15*3},{10,15*3},{11,15*3}}},
		skill_statetime={{{1,1},{30,1}}},
    },
	npc_control_earth_dotlife_10_5=
    { 
		dotdamage_maxlife_p={{{1,10},{19,100}},31,1000000},
		state_knock_attack={{{1,30},{10,30}},7,20},
		state_npcknock_attack={{{1,30},{10,30}},7,20}, 
		spe_knock_param={0 , 9, 9},	 		--停留时间，角色动作ID，NPC动作ID
		skill_statetime={{{1,1},{30,1}}},
    },
}

FightSkill:AddMagicData(tb)