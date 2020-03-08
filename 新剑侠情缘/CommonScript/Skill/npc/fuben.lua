
local tb    = {
	room1_1= --骷髅-刀光
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room1_2= --骷髅-绞杀
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room1_3= --骷髅-扇形_横扫
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,15,20},
		state_npcknock_attack={100,15,20},
		spe_knock_param={5 , 4, 4},			--停留时间，角色动作ID，NPC动作ID
    },	
	room1_4= --骷髅-冲击波
    { 
		dotdamage_fire={{{1,50},{30,50}}, 0,{{1,2},{30,2}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
		state_knock_attack={100,13,40},
		state_npcknock_attack={100,13,40},
		spe_knock_param={5 , 4, 4},
		skill_statetime={{{1,12},{30,12}}},
    },
	room2_1= --姬御天-掌击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,8,40},
		state_npcknock_attack={100,8,40},
		spe_knock_param={3 , 4, 4},			--停留时间，角色动作ID，NPC动作ID
    },
	room2_2= --姬御天-连击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},  
		state_knock_attack={100,10,20},
		state_npcknock_attack={100,10,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room2_3= --姬御天-地裂 
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room3_1= --青翼蝠王-风浪
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,8,40},
		state_npcknock_attack={100,8,40}, 
		spe_knock_param={3 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room3_2= --青翼蝠王-龙卷风
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_float_attack={{{1,100},{30,100},{31,100}},{{1,15*3},{30,15*3},{31,15*3}}},
    },
	room3_3= --青翼蝠王-雷动九天
    { 
		attack_usebasedamage_p={{{1,200},{30,1200}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
	room4_1= --龙战天-豪火球连弹
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},  
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room4_2_1= --龙战天-乾坤大挪移_吸
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_drag_attack={{{1,100},{30,100}},12,5}, 
		skill_drag_npclen={50},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    room4_2_2 = --龙战天-乾坤大挪移_弹
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,10,60},
		state_npcknock_attack={100,10,60}, 
		spe_knock_param={6 , 4, 4},	 		
    },    
	room4_3 = --龙战天-火陨
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room5_1 = --七煞使-冲锋
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	room5_2 = --七煞使-飞刃
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,12,50},
		state_npcknock_attack={100,8,50}, 
		spe_knock_param={8 , 4, 4},	 		
    },
	room5_3 = --七煞使-七煞地裂
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room6_1 = --萧动尘-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	room6_2 = --萧动尘-横扫
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	room6_3 = --萧动尘-惊雷
    { 
		attack_usebasedamage_p={{{1,350},{30,350}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
		state_stun_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	room6_4 = --萧动尘-冲锋
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	room7_1 = --慕容越-五星连珠
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
    },
	room7_2 = --慕容越-雷灵破
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,32,30},
		state_npcknock_attack={100,32,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	room8_1 = --金刚坠
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },
	room8_2_1 = --重拳三连击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,10,20},	
		state_npcknock_attack={100,10,20},	
		spe_knock_param={5 , 4, 4},	
    }, 
	room8_2_1_child = --重拳三连击_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,30,30},			--概率，持续时间，速度
		state_npcknock_attack={100,30,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    }, 
	room8_2_3 = --重拳3
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,12,25},
		state_npcknock_attack={100,12,25},
		spe_knock_param={9 , 4, 26},
    }, 
	room9_1 = --狂奔突袭
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room9_2 = --狂暴噬血
    { 
		physical_damage_v={								--增加攻击力点数
			[1]={{1,100},{30,1000}},
			[3]={{1,100},{30,1000}}
			},
		physics_potentialdamage_p={{{1,40},{30,70}}},	--增加攻击力百分比
		attackspeed_v={{{1,40},{30,70}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	room10_1 = --机关地刺
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room10_2 = --夺魂链
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_drag_attack={{{1,100},{30,100}},12,60},
		skill_drag_npclen={120},
    },
	room10_2_child = --夺魂链_子
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
	room11_1 = --雷击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room11_2 = --冰锁连环
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room11_3 = --暴风雪
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5},{31,15*5}}},
    },
	room12_1 = --星月
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room12_2 = --连环星月
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room13_1 = --烈焰枪
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
		state_burn_attack={{{1,100},{30,100},{31,100}},{{1,15*10},{30,15*5},{31,15*5}}},
    },
	room13_2 = --火墙
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},		
		state_burn_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5},{31,15*5}}},
    },
	room14_1 = --半月斩
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},	
    },
	room14_2= --剑裂 
    { 
		attack_usebasedamage_p={{{1,100},{2,100},{3,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 		
    },
	room14_3_child1 = --旋风斩_子1
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
	--	state_stun_attack={{{1,35},{30,35}},{{1,15*0.5},{30,15*0.5}}},
	--	state_npchurt_attack={100,9},
	--	state_hurt_attack={100,9},
    },
	room14_3_child2 = --旋风斩_子2
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*7},{30,15*7}}},
    },
	room15_1= --旋扇
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_knock_attack={100,15,20},
		state_npcknock_attack={100,15,20},
		spe_knock_param={5 , 4, 4},			
    },	
	room15_2 = --扇形镖
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room15_3 = --毒雾
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	 
    },
	room16_1= --强盗刀光重击
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room16_2 = --强盗旋风斩_子1
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
    },
	room16_3 = --连月斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room17_1= --锤子重击
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_knock_attack={100,15,20},
		state_npcknock_attack={100,15,20},
		spe_knock_param={5 , 4, 4},			--停留时间，角色动作ID，NPC动作ID
    },	
	room17_2= --重锤裂地
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room18_1 = --火焰半月斩
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room18_2 = --连续烈焰半月斩
    { 
		attack_usebasedamage_p={{{1,150},{30,150}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room18_3 = --多重豪火球
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room18_4 = --火墙
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},		
		state_burn_attack={{{1,100},{30,100},{31,100}},{{1,15*3},{30,15*3},{31,15*3}}},
    },
	room19_1 = --寒冰斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room19_2 = --寒月弯刀
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_fixed_attack={{{1,100},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},	
    },
	room19_3 = --玄冰无敌斩
    { 
		attack_usebasedamage_p={{{1,80},{30,80}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	room19_4= --飞斩
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},  
		state_knock_attack={100,10,70},
		state_npcknock_attack={100,10,70}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room19_5 = --苏墨芸冲刺_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room20_1 = --钉拳三连击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,10,20},	
		state_npcknock_attack={100,10,20},	
		spe_knock_param={5 , 4, 4},	
    }, 
	room20_1_child = --钉拳三连击_子
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room20_2= --横扫-右至左
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room20_3= --狼牙地刺
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room21_1 = --红缨枪
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		state_fixed_attack={{{1,100},{10,100},{11,100}},{{1,15*3},{10,15*3},{11,15*3}}},	
    },
	room21_2= --红缨风
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_float_attack={{{1,100},{30,100},{31,100}},{{1,15*2.5},{30,15*2.5},{31,15*2.5}}},
    },
	room21_3= --狂热
    { 
		physics_potentialdamage_p={{{1,100},{30,300}}},
		attackspeed_v={{{1,20},{30,20}}},
		skill_statetime={{{1,15*8},{30,15*8}}},
    },
	room22_1= --寒冰箭
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_freeze_attack={{{1,100},{30,100},{31,100}},{{1,15*2},{30,15*2},{31,15*2}}},
    },
	room22_2= --火球术
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
	room22_3= --寒冰箭扫射
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room22_4= --火球术扫射
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room23_1= --金色半月斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room23_2= --连环金色半月斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room23_3= --枫林卫刀光重击
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	room23_4= --金色击退斩
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},  
		state_knock_attack={100,10,20},
		state_npcknock_attack={100,10,20}, 
		spe_knock_param={6 , 4, 4},	 		--停留时间，角色动作ID，NPC动作ID
    },
	room24_1= --雷击
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room24_2= --雷神之怒
    { 
		attack_usebasedamage_p={{{1,250},{2,300}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
	room24_3= --狂雷
    { 
		attack_usebasedamage_p={{{1,250},{2,100},{3,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room25_1= --纳兰潜凛-挥剑
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room25_2= --纳兰潜凛-重剑破尘
    { 
		attack_usebasedamage_p={{{1,350},{30,590}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    },
	room25_3= --纳兰潜凛-剑魄
    { 
		attack_usebasedamage_p={{{1,350},{30,590}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room25_4= --纳兰潜凛-旋剑破土
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room25_5= --纳兰潜凛-旋剑破土
    { 
		attack_usebasedamage_p={{{1,250},{30,250}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
	room26_1_child1 = --旋风斩_子1
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
}

FightSkill:AddMagicData(tb)