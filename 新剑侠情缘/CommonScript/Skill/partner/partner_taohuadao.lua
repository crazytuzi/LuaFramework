
local tb    = {
    a_partner_th_pg1 = --A级桃花箭术1--普攻1式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_th_pg2 = --A级桃花箭术2--普攻2式
    { 
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_th_pg3 = --A级桃花箭术3--普攻3式
    {  
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    }, 
    a_partner_th_pg4 = --A级桃花箭术4--普攻4式
    {  
		attack_usebasedamage_p={{{1,125},{20,125}}},
		missile_hitcount={0,0,3},
    },     
    a_partner_th_fhlx = --A级飞火流星--5级主动2
    { 
		attack_usebasedamage_p={{{1,300},{20,300}}},
		missile_hitcount={0,0,3},
    },
    a_partner_th_fhlx_child = --A级飞火流星_效果
    { 
		userdesc_000={0},
    },
    partner_th_lfhx = --流风回雪--20级被动
    { 
		runspeed_v={{{1,10},{30,100}}},
		physics_potentialdamage_p={{{1,20},{30,50}}},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    s_partner_th_pg1 = --S级桃花箭术1--普攻1式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_th_pg2 = --S级桃花箭术2--普攻2式
    { 
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_th_pg3 = --S级桃花箭术3--普攻3式
    {  
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    }, 
    s_partner_th_pg4 = --S级桃花箭术4--普攻4式
    {  
		attack_usebasedamage_p={{{1,104},{20,104}}},
		missile_hitcount={0,0,3}, 
    },     
    s_partner_th_hfly = --S级桃花-火凤燎原
    { 
		runspeed_v={{{1,40},{20,40}}},
		attackspeed_v={{{1,50},{20,50}}},
		defense_v={{{1,100},{20,100}}},
		skill_statetime={{{1,15*10},{15,15*10}}},
    },
}

FightSkill:AddMagicData(tb)