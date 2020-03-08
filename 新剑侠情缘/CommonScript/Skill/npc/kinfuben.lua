
local tb    = {
	kinfuben_1= --铜锤蛮士-重锤砸地
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
		state_stun_attack={{{1,100},{20,100}},{{1,15*3},{20,15*3}}},
    },
	kinfuben_2= --火炮-火炮
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID		
    },
	kinfuben_3= --蒙面杀手-无形蛊
    { 
		attack_usebasedamage_p={{{1,100},{20,100}}},
    },
	kinfuben_4= --反弹卫士
    {
		meleedamagereturn_p={{{1,100},{20,100}}},
		rangedamagereturn_p={{{1,100},{20,100}}},
    },
	kinfuben_6 = --点名炸弹
    { 
		dotdamage_maxlife_p={{{1,5},{20,100}},15,1000000},			--掉血% ，间隔时间 ， 最大伤害值
		skill_statetime={{{1,2},{30,2}}},
    },
	kinfuben_7= --反弹近战
    {
		meleedamagereturn_p={{{1,5},{20,100}}},
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
	kinfuben_8= --反弹远程
    {
		rangedamagereturn_p={{{1,5},{20,100}}},
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
	kinfuben_9= --五行反弹
    {
		meleedamagereturn_p={{{1,5},{20,100}}},
		rangedamagereturn_p={{{1,5},{20,100}}},
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
	kinfuben_10= --吸魂
    {
		enhance_final_damage_p={{{1,20},{50,1000}}},				--最终攻击放大%
		superposemagic={50},
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
	kinfuben_11= --吸魂
    {
		enhance_final_damage_p={{{1,1000},{50,1000}}},				--最终攻击放大%
		skill_statetime={{{1,15*2},{30,15*2}}},
    },
    kinfuben_12= --抵消伤害
    { 
		reduce_final_damage_p={{{1,6},{20,6}}},
		superposemagic={15},
		skill_statetime={{{1,15*10},{30,15*10}}},		
    },
}

FightSkill:AddMagicData(tb)