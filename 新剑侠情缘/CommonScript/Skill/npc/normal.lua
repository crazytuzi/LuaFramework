
local tb    = {
	buff_recover=
    { 
		recover_life_p={{{1,5},{30,150}},15},
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	buff_recover2=
    { 
		recover_life_p={{{1,5},{30,5}},15},
		skill_statetime={{{1,15*5},{30,15*34}}},
    },
	buff_adddamage=
    { 
		physics_potentialdamage_p={{{1,30},{30,30},{50,2000}}},
		skill_statetime={{{1,15*5},{30,15*34},{50,15*50}}},
    },
	buff_series=
    { 
		all_series_resist_p={{{1,30},{30,30}}},
		skill_statetime={{{1,15*5},{30,15*34}}},
    },
	buff_runspeed=
    { 
		runspeed_p={{{1,50},{30,50}}},
		skill_statetime={{{1,15*5},{30,15*34}}},
    },
	buff_heal=
    { 
		recover_life_p={{{1,10},{30,10}},15},
		skill_statetime={{{1,15},{30,15}}},
    },
    showknock = --出场击退
    {  
		state_knock_attack={100,15,30},
		state_npcknock_attack={100,15,30}, 
		spe_knock_param={4 , 4, 4},	 		
    }, 
    npc_xx_chongfeng= --各系冲锋
    { 
		attack_usebasedamage_p={{{1,200},{30,200}}},
		state_knock_attack={{{1,30},{10,100}},35,30},
		state_npcknock_attack={{{1,30},{10,100}},35,30}, 
		spe_knock_param={26 , 26, 26},	 		--停留时间，角色动作ID，NPC动作ID
    },
    npc_xx_hengsao= --各系横扫
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_xx_fazhen= --各系移动法阵
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_xx_fanwei_1= --各系范围1次伤害
    { 
		attack_usebasedamage_p={{{1,100},{30,390}}},
    },
    npc_xx_fanwei_2= --各系范围2次伤害
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
    },
    npc_xx_shanxing= --各系扇形伤害
    { 
		attack_usebasedamage_p={{{1,50},{30,50}}},
    },
    npc_xx_fukong = --机关-龙卷风浮空
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
		state_float_attack={{{1,30},{8,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
    npc_fantan  = --光环_反弹
    {
		meleedamagereturn_p={{{1,100},{30,100}}},
		rangedamagereturn_p={{{1,100},{30,100}}},
    },
    npc_fanshe  = --光环_反射
    {
		meleedamagereturn_p={{{1,10},{10,100}}},
		rangedamagereturn_p={{{1,10},{10,100}}},
    },
    npc_jingji_buff  = --荆棘buff
    {
		meleedamagereturn_p={{{1,20},{9,100}}},
		rangedamagereturn_p={{{1,20},{9,100}}},
    },
    npc_zhongdu= --中毒光环
    { 
		attack_usebasedamage_p={{{1,30},{30,320}}},
    },
	npc_adddamage= --强力BUFF
    { 
		physics_potentialdamage_p={{{1,300},{30,300},{31,300}}},
		skill_statetime={{{1,15*5},{30,15*34}}},
    },
    npc_xj_huoyan= --各系扇形伤害
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    },
    npc_mustkill= --秒杀陷阱
    { 
        attack_usebasedamage_p = {10000},
		attack_metaldamage_v={
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
		attack_earthdamage_v={
			[1]={{1,1000000},{30,1000000}},
			[3]={{1,1000000},{30,1000000}}
			},
    },
    npc_wudi_bd  = --无敌-被动_子
    {
		invincible_b={1},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    npc_wudi  = --无敌
    {
		invincible_b={1},
		skill_statetime={{{1,15*5},{30,15*34},{31,15*34}}},
    },
    npc_shibao = --尸爆
    {
		autoskill={91,{{1,1},{30,30},{31,30}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    npc_shibao_child = --尸爆_子
    { 
		attack_usebasedamage_p={{{1,300},{30,880}}},
    },
	npc_runspeed=
    { 
		runspeed_v={{{1,100},{10,1100},{12,1100}}},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
    act_mingxia_pg = --守卫名侠普攻
    { 
		attack_usebasedamage_p={{{1,250},{20,250}}},
    }, 
}

FightSkill:AddMagicData(tb)