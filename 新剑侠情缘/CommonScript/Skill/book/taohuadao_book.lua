
local tb    = {
    book_th_fybh = --飞火流星
    {  
		add_hitskill1={407,418,{{1,1},{10,10}}},
		userdesc_000={418},
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_fybh_child = --飞火流星_子
    { 
		rand_ignoreskill={{{1,50},{10,100}},1,1},		--概率，数量，类型（skillsetting下定义类型）
		state_burn_attack={{{1,30},{10,100}},{{1,15*3},{10,15*6}},30},
		missile_hitcount={0,0,1}, 
    },
    book_th_jctq = --火凤燎原
    { 
		addstartskill={406,414,{{1,1},{10,10}}},
		userdesc_000={414},
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_jctq_child = --火凤燎原_子
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*2},{10,15*10}}},
    },
    book_th_yxqx = --穿云破月
    { 
		add_hitskill1={438,424,{{1,1},{10,10}}},
		userdesc_000={424},
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_th_yxqx_child = --穿云破月_子
    { 
		attack_usebasedamage_p={{{1,60},{10,100}}},
		attack_firedamage_v={
			[1]={{1,100*1},{10,350*1}},
			[3]={{1,100*1},{10,350*1}}
		},
    },
    book_th_new = --九耀连珠
    {
		add_igdefense_p1={411,{{1,50},{10,200}}},  							--增加忽闪%
		userdesc_101={411,{{1,20},{10,200}}},  								--描述用：增加忽闪%
		add_deadlystrike_v1={411,{{1,50},{10,200}}},  						--增加会心一击
		userdesc_102={411,{{1,50},{10,200}}},   							--描述用：增加会心一击	
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_th_mid_new = --中级九耀连珠
    {
		add_igdefense_p1={411,{{1,50},{10,200},{15,260}}},  				--增加忽闪%
		userdesc_101={411,{{1,50},{10,200},{15,260}}},  					--描述用：增加忽闪%
		add_deadlystrike_v1={411,{{1,20},{10,200},{15,300}}},  				--增加会心一击
		userdesc_102={411,{{1,20},{10,200},{15,300}}},   					--描述用：增加会心一击	
		add_usebasedmg_p1={411,{{1,0},{10,0},{11,2},{15,10}}},				--增加九曜连珠攻击力
		userdesc_103={411,{{1,0},{10,0},{11,2},{15,10}}},					--描述用：增加九曜连珠攻击力			
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_th_mid_fybh = --中级飞火流星
    {  
		add_hitskill1={407,449,{{1,1},{10,10},{20,20}}},
		add_usebasedmg_p1={407,{{1,0},{10,0},{11,5},{15,30}}},				--增加飞火流星攻击力
		userdesc_101={407,{{1,0},{10,0},{11,5},{15,30}}},					--描述用：增加飞火流星攻击力		
		userdesc_000={449},
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_mid_fybh_child = --中级飞火流星_子
    { 
		rand_ignoreskill={{{1,50},{10,100},{20,100}},1,1},		--概率，数量，类型（skillsetting下定义类型）
		state_burn_attack={{{1,30},{10,100},{20,100}},{{1,15*3},{10,15*6},{20,15*6}},30},
		missile_hitcount={0,0,1}, 
    },
    book_th_mid_jctq = --中级火凤燎原
    { 
		addstartskill={406,451,{{1,1},{10,10},{20,20}}},
		userdesc_000={451},
		add_state_time1={406,{{1,0},{10,0},{11,15*1},{15,15*5}}},  			--增加火凤燎原持续时间
		userdesc_101={406,{{1,0},{10,0},{11,15*1},{15,15*5}}},  			--描述用：增加火凤燎原持续时间
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_mid_jctq_child = --中级火凤燎原_子
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*2},{10,15*10},{15,15*15}}},
    },
    book_th_mid_yxqx = --中级穿云破月
    { 
		add_hitskill1={438,453,{{1,1},{10,10},{20,20}}},
		userdesc_000={453},
		deccdtime={412,{{1,0},{10,0},{11,15*1},{15,15*5}}},										--减穿云破月CD时间
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_th_mid_yxqx_child = --中级穿云破月_子
    { 
		attack_usebasedamage_p={{{1,60},{10,100},{15,130}}},
		attack_firedamage_v={
			[1]={{1,100*1},{10,350*1},{15,700*1}},
			[3]={{1,100*1},{10,350*1},{15,700*1}}
			},
    },
    book_th_high_jylz = --高级九耀连珠
    {
		add_igdefense_p1={411,{{1,50},{10,200},{15,260},{20,300}}},  				--增加忽闪%
		add_deadlystrike_v1={411,{{1,20},{10,200},{15,300},{20,400}}},  			--增加会心一击
		add_usebasedmg_p1={411,{{1,0},{10,0},{11,2},{15,10},{20,13}}},				--增加九曜连珠攻击力
		add_palsy_r={411,{{1,0},{15,0},{16,5},{20,20}}},							--增加麻痹几率			
		skill_statetime={{{1,-1},{10,-1}}},
    },
    book_th_high_fybh = --高级飞火流星
    {  
		add_hitskill1={407,457,{{1,1},{10,10},{20,20}}},
		add_usebasedmg_p1={407,{{1,0},{10,0},{11,5},{15,30},{20,40}}},				--增加飞火流星攻击力
		add_igdefense_v1={407,{{1,0},{15,0},{16,50},{20,300}}},							--增加忽闪点数
		add_deadlystrike_v1={407,{{1,0},{15,0},{16,40},{20,200}}},						--增加会心点数		
		userdesc_000={457},
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_high_fybh_child = --高级飞火流星_子
    { 
		rand_ignoreskill={{{1,50},{10,100},{20,100}},1,1},		--概率，数量，类型（skillsetting下定义类型）
		state_burn_attack={{{1,30},{10,100},{20,100}},{{1,15*3},{10,15*6},{20,15*6}},30},
		missile_hitcount={0,0,1}, 
    },
    book_th_high_jctq = --高级火凤燎原
    { 
		addstartskill={406,459,{{1,1},{10,10},{20,20}}},
		userdesc_000={459},
		add_state_time1={406,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*6}}},  			--增加火凤燎原持续时间
		skill_statetime={{{1,-1},{10,-1}}},		
    },
    book_th_high_jctq_child = --高级火凤燎原_子
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		defense_v={{{1,0},{15,0},{16,50},{20,300}}},									--增加闪避点数
		skill_statetime={{{1,15*2},{10,15*10},{15,15*15},{20,15*16}}},
    },
    book_th_high_yxqx = --高级穿云破月
    { 
		add_hitskill1={438,461,{{1,1},{10,10},{20,20}}},
		userdesc_000={461},
		deccdtime={412,{{1,0},{10,0},{11,15*1},{15,15*5},{20,15*6}}},					--减穿云破月CD时间
		add_usebasedmg_p1={438,{{1,0},{15,0},{16,5},{20,25}}},							--增加穿云破月攻击力
		skill_statetime={{{1,-1},{10,-1}}},	
    },
    book_th_high_yxqx_child = --高级穿云破月_子
    { 
		attack_usebasedamage_p={{{1,60},{10,100},{15,130},{20,150}}},
		attack_firedamage_v={
			[1]={{1,100*1},{10,350*1},{15,700*1},{20,900*1}},
			[3]={{1,100*1},{10,350*1},{15,700*1},{20,900*1}}
			},
    },
}

FightSkill:AddMagicData(tb)