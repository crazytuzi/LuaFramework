
local tb    = {
    empty=
    {
        userdesc_000={0},
    },
    emptyforbuff =
    {
        userdesc_000={0},
        lifemax_v = {1},
        skill_statetime={{{1,-1},{30,-1}}},        
    },
    test_recoverlife=
    {
	 	recover_life_v={{{1,1000},{30,1000},{31,1000}},15/2},
		skill_statetime={{{1,18*9},{30,18*9}}},
    },
    test1=
    { 
        attack_usebasedamage_p = {10000},
        dotdamage_holy = {10000, 10, 2},
        state_knock_attack={100, 6, 32},
        --autoskill={1, 1},
    },
    test2=
    { 
        attack_usebasedamage_p = {100},
        state_knock_attack={100, 11, 0},
    },
    test3=
    {
		physical_damage_v={
			[1]={{1,1000000},{30,50000000}},
			[3]={{1,1000000},{30,50000000}}
			},
		physics_potentialdamage_p={{{1,10000},{30,10000}}},		
		runspeed_v={{{1,300},{30,500}}},
		skill_statetime={{{1,15*60},{30,15*60}}},		
    },
    test4=
    { 
        attack_usebasedamage_p = {50},
        --state_knock_attack={100, 6, 32},
        --dotdamage_holy = {100, 10, 2},
        --autoskill={1, 1},
    },
    test_strong=
    {
		physics_potentialdamage_p={{{1,100},{30,3000},{50,5000}}},	
		lifemax_p={{{1,100},{30,3000},{50,5000}}},	
		skill_statetime={{{1,15*60},{30,15*60}}},		
    },
    test_mustkill=
    { 
        attack_usebasedamage_p = {10000},
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
    },
    test_npc=
    { 
        attack_usebasedamage_p = {100},
    },
    test_npc2=
    { 
        attack_usebasedamage_p = {100},
    },
    test_npc3=
    { 
        attack_usebasedamage_p = {100},
    },
    test_slowall= --迟缓
    { 
		state_slowall_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_fixed= --定身
    { 
		state_fixed_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_zhican= --致残
    { 
		state_zhican_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_palsy= --麻痹
    { 
		state_palsy_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_float= --浮空
    { 
		state_float_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_burn= --灼伤
    { 
		state_burn_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_silence= --沉默
    { 
		state_silence_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_confuse= --混乱
    { 
		state_confuse_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_weak= --虚弱
    { 
		state_weak_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_sleep= --睡眠
    { 
		state_sleep_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    test_stun= --眩晕
    { 
		state_stun_attack={{{1,100},{10,100},{11,100}},{{1,15*5},{10,15*5},{11,15*5}}},		
    },
    magictest= --测试魔法属性
    { 		
		vitality_v={1000},		
	--	dexterity_v={},		
	--	energy_v={},		
	--	strength_v={},		
    },	
    test_buff=
    {
		recover_life_v = {{{1,100},{30,100},{31,100}},75},		
		steallife_p={{{1,5},{30,5}}},		
		meleedamagereturn_p={{{1,5},{30,5}}},		
		rangedamagereturn_p={{{1,5},{30,5}}},		
		skill_statetime={{{1,15*60},{30,15*60}}},		
    },
    testmag1=
    { 
        playerdmg_npc_p={{{1,-10},{10,-50}}},
        skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
    testmag2=
    { 
        miss_alldmg_v={{{1,100},{30,3000}}},
        skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
    testmag3=
    { 
        steallife_resist_v={{{1,100},{30,3000}}},
        skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
    testmag4=
    { 
        steallife_resist_p={{{1,5},{20,100}}},
        skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
    testmag5=
    { 
        steallife_p={{{1,5},{20,100}}},
        skill_statetime={{{1,15*60*60*2},{30,15*60*60*2}}},
    },
}

FightSkill:AddMagicData(tb)