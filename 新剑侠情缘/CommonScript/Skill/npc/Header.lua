
local tb    = { 
    npc_20Header1_1= --大地狼王-撕咬
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },   
	npc_20Header1_2= --大地狼王-潜土突刺
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },	
	npc_20Header1_3= --大地狼王-地裂
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	
    },	
	npc_20Header1_4= --大地狼王-瞬身撕咬_子1
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
    },
    npc_20Header2_1= --寒玉鹿王-角击
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20Header2_2 = --寒玉鹿王-漩涡
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_drag_attack={{{1,100},{30,100}},8,40},
		skill_drag_npclen={20},
    },
    npc_20Header2_3 = --寒玉鹿王-寒冰冲顶
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },	
    npc_20Header3_1= --奔焰豹王-爪击
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20Header3_2= --奔焰豹王-烈焰奔袭_子
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},
		state_burn_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5},{31,15*5}}},
    },
    npc_20Header3_3= --奔焰豹王-天火烈爪
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20Header4_1 = --九尾狐王-甩尾
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20Header4_2 = --九尾狐王-风刃舞
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20Header4_3 = --九尾狐王-影风斩
    { 
		attack_usebasedamage_p={{{1,120},{20,200}}},
		state_knock_attack={100,35,30},
		state_npcknock_attack={100,35,30}, 
		spe_knock_param={26 , 26, 26},	 
    },    
	npc_20Header4_4 = --九尾狐王-龙卷呼啸
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
		state_float_attack={{{1,100},{30,100},{31,100}},{{1,15*3},{30,15*3},{31,15*3}}},		
    },	
    npc_80Header1_1 = --虎皇-爪击
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_80Header1_2 = --虎皇-猛扑
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_80Header1_3 = --虎皇-魔火炼狱
    { 
		attack_usebasedamage_p={{{1,700},{30,700}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    npc_80Header2_1 = --熊皇-掌击
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_80Header2_2 = --熊皇-激怒
    { 
		attackspeed_v={{{1,50},{30,50}}},
		deccdtime={3353,{{1,15*1.5},{30,15*1.5}}},		
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
    npc_80Header2_3 = --熊皇-至尊咆哮
    { 
		attack_usebasedamage_p={{{1,800},{30,800}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_80Header3_1 = --鳄皇-撕咬
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    npc_80Header3_2 = --鳄皇-毒液
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
    },
    npc_80Header3_3 = --鳄皇-毒雾
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
		state_zhican_attack={100,15*2},
    },
    npc_100Header1_1 = --冰鳞蜥皇-寒星
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_100Header1_2 = --冰鳞蜥皇-寒冰尖刺
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_freeze_attack={{{1,40},{30,40}},{{1,15*3},{30,15*3}}},	
    },
    npc_100Header1_3 = --冰鳞蜥皇-水泡
    { 
		attack_usebasedamage_p={{{1,700},{30,700}}},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*2},{15,15*2},{16,15*2}}},
    },
    npc_100Header2_1 = --银钩蝎皇-毒针
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_100Header2_2 = --银钩蝎皇-花叶飞舞
    { 
		attack_usebasedamage_p={{{1,800},{30,800}}},
		state_zhican_attack={100,15*3},	
    },
    npc_100Header2_3 = --银钩蝎皇-蝎皇蛊
    { 
		dotdamage_wood={{{1,300},{30,300}}, 0 ,15*0.5}, 			--毒伤：发挥基础攻击力，毒攻点数，伤害间隔
		skill_statetime={{{1,15*3.5},{30,15*3.5}}},					--毒的持续时间
		skill_dot_ext_type={1},										--增加受到的毒伤%的标记，能被五毒recdot_wood_p此属性放大
    },
    npc_100Header3_1 = --狂鬃獒皇-猛力撕咬
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_100Header3_2 = --狂鬃獒皇-狱火天焰
    { 
		attack_usebasedamage_p={{{1,600},{30,600}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    npc_100Header3_3 = --狂鬃獒皇-火焰落弹
    { 
		attack_usebasedamage_p={{{1,800},{30,800}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
	npc_header = --野外首领防御随人数上升
    { 
		resist_allseriesstate_time_v={{{1,300},{2,300},{30,3000}}},		--抗属性时间
		resist_allspecialstate_time_v={{{1,300},{2,300},{30,3000}}},	--抗负面时间
		state_npchurt_ignore={1},										--免疫NPC受伤状态
		state_npcknock_ignore={1},										--免疫NPC击退状态
		state_stun_ignore={1},											--免疫眩晕状态
		state_zhican_ignore={1},										--免疫致残状态
		state_slowall_ignore={1},										--免疫迟缓状态
		state_palsy_ignore={1},											--免疫麻痹状态
		state_float_ignore={1},											--免疫浮空状态		
		damage4npc_p={{{1,-25},{2,-67},{3,-100},{30,-100}}},			--减少对同伴的攻击伤害,正数为1+p,负数为:1/(1-p),-100为1/2

		add_mult_proc_sate1={83,{{1,25},{10,25},{11,25}},60},  			--叠加伤害抵消：技能ID,叠加层数，自身为圆心格子半径		

		skill_statetime={{{1,-1},{30,-1}}},
    },
    npc_header_child = --野外首领防御随人数上升_抵消伤害
    {
		skill_mult_relation={1}, 	--对应的NPC类型，从skillsetting.ini上查看
		reduce_final_damage_p={{{1,2},{10,11},{11,12}}},
		skill_statetime={{{1,15*10},{10,15*10},{11,15*10}}},
    },
}

FightSkill:AddMagicData(tb)