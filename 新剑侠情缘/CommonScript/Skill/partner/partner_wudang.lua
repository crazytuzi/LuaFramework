
local tb    = {
    a_partner_wd_pg1 = --A级-李天目-剥及而复-普攻
    { 
		attack_usebasedamage_p={{{1,188},{20,188}}},
		missile_hitcount={0,0,3},
    }, 
	a_partner_wd_zwww = --A级坐忘无我
    { 
		magicshield={{{1,3*100},{20,3*100}},{{1,15*20},{15,20*20}}},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={{{1,15*20},{15,20*20}}},		
    },     
    s_partner_wd_pg1 = --S级武当剑法1--普攻1式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_wd_pg2 = --S级武当剑法2--普攻2式
    { 
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_wd_pg3 = --S级武当剑法3--普攻3式
    {  
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    }, 
    s_partner_wd_pg4 = --S级武当剑法4--普攻4式
    {  
		attack_usebasedamage_p={{{1,130},{20,130}}},
		missile_hitcount={0,0,3},
    },  
    s_partner_wd_tdwj = --s级天地无极
    { 
		attack_usebasedamage_p={{{1,187},{20,187}}},
		state_stun_attack={{{1,100},{15,100}},{{1,15*1},{15,15*1}}},
		missile_hitcount={0,0,3},
    },   	
}

FightSkill:AddMagicData(tb)