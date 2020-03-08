
local tb    = { 
    npc_20boss1_1= --鳌拜-锤击
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_20boss1_2= --鳌拜-蛮横霸道
    { 
		userdesc_000={0},
    },    
	npc_20boss1_2_child= --鳌拜-蛮横霸道_子
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_knock_attack={100,8,45},		--概率，时间，速度
    },	
	npc_20boss1_3= --鳌拜-神力
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },	
	npc_20boss1_4= --鳌拜-钢之铠甲
    { 
		meleedamagereturn_p={{{1,50},{30,100}}},
		rangedamagereturn_p={{{1,50},{30,100}}},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },
    npc_20boss1_5 = --鳌拜-万象天引
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_drag_attack={{{1,100},{30,100}},8,90},
		skill_drag_npclen={100},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    npc_20boss1_5_child = --鳌拜-万象天引_子
    { 
		--state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
		state_drag_attack={{{1,100},{30,100}},3,30},
    },
    npc_20boss2_1= --袁承志-剑击
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},			
    },
    npc_20boss2_2 = --袁承志-金蛇擒鹤拳
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_drag_attack={{{1,100},{30,100}},8,90},
		skill_drag_npclen={100},
		state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
    },
    npc_20boss2_2_child = --袁承志-金蛇擒鹤拳_子
    { 
		--state_stun_attack={{{1,100},{30,100}},{{1,15*2},{30,15*2}}},
		state_drag_attack={{{1,100},{30,100}},3,30},
    },	
    npc_20boss2_3= --袁承志-狂剑诀_子2
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},			
    },
    npc_20boss2_4= --袁承志-金蛇剑法
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20boss2_5 = --袁承志-神行百变_子1
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
		state_npchurt_attack={100,9},
		state_hurt_attack={100,9},	
    },
    npc_20boss3_1 = --哲别-箭术
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_20boss3_2 = --哲别-箭无虚发
    { 
		userdesc_000={0},
		missile_hitcount={{{1,1},{30,1}}},
    },    
	npc_20boss3_2_child = --哲别-箭无虚发_子
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    },
    npc_20boss3_3 = --哲别-连环箭
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
    },
    npc_20boss3_4 = --哲别-铁骑突袭
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_knock_attack={100,5,20},
    },    
	npc_20boss3_5 = --哲别-万箭齐发_子
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
	npc_20boss3_6 = --哲别-焚星落羽_子3
    { 
		attack_usebasedamage_p={{{1,500},{30,500}}},
		state_palsy_attack={{{1,100},{30,100},{31,100}},{{1,15*5},{30,15*5}}},
    },
	npc_20boss4_1= --高长恭-枪法
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
	npc_20boss4_2= --高长恭-遣散
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },	
	npc_20boss4_3= --高长恭-横扫千军
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_20boss4_4= --高长恭-长枪贯日
    { 
		userdesc_000={0},
    },    
	npc_20boss4_4_child= --高长恭-长枪贯日_子
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
	npc_20boss4_5= --高长恭-圣盾护体
    { 
		invincible_b={1},
		skill_statetime={{{1,15*10},{30,15*10}}},
    },	
    npc_count_resist = --根据敌人数量叠加抗性
    {
		add_mult_proc_sate1={1066,{{1,100},{10,100}},100},  --技能ID,叠加层数，自身为圆心半径
		skill_statetime={{{1,-1},{10,-1}}},
    },
    npc_count_resist_child = --根据敌人数量叠加抗性_子
    {
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看MultMagicRelation
		all_series_resist_v={{{1,10},{10,100}}},
		skill_statetime={{{1,15*10},{10,15*10}}},		
    },
    npc_count_resist2 = --根据敌人数量叠加抵消伤害
    {
        add_mult_proc_sate1={3968,{{1,100},{10,100}},100},  --技能ID,叠加层数，自身为圆心半径
        skill_statetime={{{1,-1},{10,-1}}},
    },
    npc_count_resist2_child = --根据敌人数量叠加抵消伤害_子
    {
        skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看MultMagicRelation
        reduce_final_damage_p={{{1,10},{10,100}}},
        skill_statetime={{{1,15*10},{10,15*10}}},       
    },
	npc_60boss1_1= --荆轲-普攻
    { 
		attack_usebasedamage_p={{{1,200},{30,490}}},
    },	
    npc_60boss1_2 = --荆轲-暗影刺
    { 
		keephide={},
		runspeed_v={{{1,100},{20,100}}},
		hide={{{1,15*3},{20,15*3}},1},				--参数1时间，参数2：队友1，同阵营2	
		ignore_defense_v={{{1,1000},{20,1000}}},
		attackspeed_v={{{1,100},{20,100}}},
		deadlystrike_v={{{1,10000},{20,10000}}},
		physics_potentialdamage_p={{{1,100},{10,100}}},		
		skill_statetime={{{1,15*8},{20,15*8}}},
    }, 
	npc_60boss1_3= --荆轲-背刺
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },	
    npc_60boss1_4 = --血祭
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},		
		state_drag_attack={{{1,80},{30,80}},8,30},		
		skill_drag_npclen={0},
		state_npchurt_attack={100,10}, 
    }, 
	npc_60boss2_1= --虞姬-随意曲
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },	
	npc_60boss2_2= --虞姬-琴殇
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
		state_knock_attack={100,2,45},		--概率，时间，速度
    },	
	npc_60boss2_3= --虞姬-满城花雨
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
    },
    npc_60boss2_4= --虞姬-魂牵梦萦曲
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},	
		state_sleep_attack={{{1,100},{10,100}},{{1,15*2},{10,15*2},{11,15*2}}},		
    },	
	npc_60boss3_1= --岳飞-岳家枪
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
	npc_60boss3_2= --岳飞-忠贯白日
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
    },
	npc_60boss3_3= --岳飞-猛虎咆哮
    { 
		attack_usebasedamage_p={{{1,400},{30,690}}},
		state_stun_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    npc_60boss3_4 = --岳飞-精忠报国
    { 
		runspeed_v={{{1,100},{20,100}}},
		ignore_defense_v={{{1,1000},{20,1000}}},
		attackspeed_v={{{1,100},{20,100}}},
		deadlystrike_v={{{1,10000},{20,10000}}},
		physics_potentialdamage_p={{{1,100},{10,100}}},		
		skill_statetime={{{1,15*8},{20,15*8}}},
    }, 
	npc_80boss1_1= --李元霸-普攻
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
	npc_80boss1_2= --李元霸-山崩地裂
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
    },
    npc_80boss1_3 = --李元霸-十二擒龙手
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
		state_drag_attack={{{1,100},{15,100},{16,100}},8,70},
		skill_drag_npclen={140},
    },
    npc_80boss1_4 = --李元霸-苍穹一击
    { 
		attack_usebasedamage_p={{{1,700},{30,990}}},
    },
	npc_80boss2_1= --赵云-普攻
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
	npc_80boss2_2= --赵云-七探蛇盘
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
    },
    npc_80boss2_3 = --赵云-铁血龙胆
    { 
		attack_usebasedamage_p={{{1,600},{30,890}}},
		state_knock_attack={100,10,80},
		state_npcknock_attack={100,10,80}, 
		spe_knock_param={6 , 4, 4},	
    },
    npc_80boss2_4 = --赵云-九雷链
    { 
		attack_usebasedamage_p={{{1,500},{30,790}}},
    },
	npc_80boss3_1= --李广-普攻
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
	npc_80boss3_2= --李广-射石搏虎
    { 
		attack_usebasedamage_p={{{1,700},{30,990}}},
    },
    npc_80boss3_3 = --李广-流星箭
    { 
		attack_usebasedamage_p={{{1,400},{30,690}}},
		state_palsy_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
    npc_80boss3_4 = --李广-聚能箭
    { 
		attack_usebasedamage_p={{{1,300},{30,590}}},
    },
    npc_110boss1_1= --项羽-普攻
    { 
        attack_usebasedamage_p={{{1,500},{30,790}}},
    },
    npc_110boss1_2= --项羽-烈焰斩
    { 
        attack_usebasedamage_p={{{1,700},{30,990}}},
        state_palsy_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
    npc_110boss1_3 = --项羽-炎爆
    { 
        attack_usebasedamage_p={{{1,800},{30,1090}}},
    },
    npc_110boss1_4 = --项羽-千军万马
    { 
        attack_usebasedamage_p={{{1,300},{30,590}}},
        state_knock_attack={100,5,70},              --几率，时间，速度
        state_npcknock_attack={100,5,70},           --几率，时间，速度 
        spe_knock_param={3 , 4, 9},                 --停留时间，玩家动作ID，NPC动作ID
    },
    npc_110boss1_5 = --项羽-鸿门摆宴
    { 
        attack_usebasedamage_p={{{1,600},{30,890}}},
        state_drag_attack={{{1,100},{30,100}},8,70},
        skill_drag_npclen={60},
        state_palsy_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
    cross_svr_xy_1  = --项羽-无敌
    {
        invincible_b={1},
        skill_statetime={{{1,15*60*10},{30,15*60*10}}},
    },
    cross_svr_xy_2=  --加攻击
    { 
        physics_potentialdamage_p={{{1,100},{20,200}}},
        skill_statetime={{{1,15*60*3},{20,15*60*3}}},
    },
    cross_svr_xy_3 = --召唤虞姬                         --释放技能后就消失
    { 
        call_npc1={2497, -1, 5},                --NPCid, NPC等级（-1为跟玩家一样），NPC五行
        remove_call_npc={1885},
        skill_statetime={{{1,15*3},{30,15*3}}},
    },  
    cross_svr_xy_3_child = --召唤虞姬_子
    { 
        callnpc_life={2497,{{1,33},{10,33}}},             --NPCid，召唤NPC血量为召唤者生命上限值的%
        callnpc_damage={2497,{{1,100},{10,100}}},         --NPCid，召唤NPC攻击力为召唤者攻击力上限值的%
        skill_statetime={{{1,15*3},{30,15*3}}},           --持续时间需要跟cross_svr_xy_3的时间一致
    },
    cross_svr_xy_4  = --百分比回血
    {
        recover_life_p={{{1,10},{10,10},{11,10}},3},
        skill_statetime={{{1,15*1},{10,15*1}}},
    },
    cross_svr_xy_5 = --项羽-地爆天星
    { 
        attack_usebasedamage_p={{{1,2000},{20,2000}}},
        attack_earthdamage_v={
            [1]={{1,1000000},{30,1000000}},
            [3]={{1,1000000},{30,1000000}}
            },
        attack_wooddamage_v={
            [1]={{1,1000000},{30,1000000}},
            [3]={{1,1000000},{30,1000000}}
            },
        attack_waterdamage_v={
            [1]={{1,1000000},{30,1000000}},
            [3]={{1,1000000},{30,1000000}}
            },
        attack_firedamage_v={
            [1]={{1,1000000},{30,1000000}},
            [3]={{1,1000000},{30,1000000}}
            },
        state_npchurt_attack={100,9},
        state_hurt_attack={100,9},      
    },  

    dm_s1 = --达摩_吞噬火球
    { 
		attack_usebasedamage_p={{{1,100000},{30,100000}}}, 
		attack_earthdamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_wooddamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_waterdamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_firedamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
		attack_metaldamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
    }, 
    dm_s2 = --达摩_达摩杵-击退
    { 
		attack_usebasedamage_p={{{1,1000},{30,1000}}}, 
		state_knock_attack={100,15,70},				--几率，时间，速度
		state_npcknock_attack={100,15,70},			--几率，时间，速度 
		spe_knock_param={3 , 4, 9},					--停留时间，玩家动作ID，NPC动作ID
    }, 
}

FightSkill:AddMagicData(tb)