
local tb    = {
	dxz_rxq =  --扔雪球
    { 
		attack_holydamage_v={
			[1]={{1,1000},{30,1000}},
			[3]={{1,1000},{30,1000}}
			},
		skill_point={{{1,100},{2,200},{3,300},{4,300}},{{1,100},{4,100}}}, --参数1/100：叠加次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={{{1,5},{4,5}}},
    },
	dxz_rxq_kouchu = {--扣除一层
		mult_skill_state={3594,{{1,1},{10,10}},{{1,-1},{10,-1}}}, 		--技能ID，等级，buff层数
    },
	dxz_hbj =  --环冰诀
    { 
		attack_holydamage_v={
			[1]={{1,1000},{30,1000}},
			[3]={{1,1000},{30,1000}}
			},
		ms_vanish_remove_buff = {3398},
    },
	dxz_rxq2 =  --无限扔雪球
    { 
		attack_holydamage_v={
			[1]={{1,1000},{30,1000}},
			[3]={{1,1000},{30,1000}}
			},
    },
	dxz_xjz =  --雪金针
    { 
		attack_holydamage_v={
			[1]={{1,3},{30,3}},
			[3]={{1,3},{30,3}}
			},
    },
	dxz_cxr =  --绻雪缠
    { 
		attack_holydamage_v={
			[1]={{1,500},{30,500}},
			[3]={{1,500},{30,500}}
			},
		state_fixed_attack={{{1,500},{30,100}},{{1,15*4},{30,15*3}}},
		ms_vanish_remove_buff = {4740},
    },
	dxz_rxb =  --柔雪绊
    { 
		attack_holydamage_v={
			[1]={{1,500},{30,500}},
			[3]={{1,500},{30,500}}
			},
		state_freeze_attack={{{1,500},{30,100}},{{1,15*5},{30,15*4}}},
		ms_vanish_remove_buff = {4741},
    },
	dxz_mhx =  --迷魂雪
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
		state_confuse_attack={{{1,100},{30,100}},{{1,15*1.5},{30,15*1.5}}},
    },
	dxz_dxj =  --堆雪击
    { 
		attack_holydamage_v={
			[1]={{1,500},{30,500}},
			[3]={{1,500},{30,500}}
			},
		state_stun_attack={{{1,500},{30,100}},{{1,15*4},{30,15*3}}},
		ms_vanish_remove_buff = {4742},
    },
	dxz_txwx =  --天仙舞雪
    { 
		attack_holydamage_v={
			[1]={{1,500},{30,500}},
			[3]={{1,500},{30,500}}
			},
		state_slowall_attack={{{1,500},{30,100}},{{1,15*3},{30,15*2}}},
		ms_vanish_remove_buff = {4737},
    },
	dxz_tbj =  --踏冰诀
    { 
		runspeed_v={{{1,10},{5,50},{6,50}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css =  --乘霜式
    { 
		addms_speed1={3359,{{1,50},{20,50}}},
		addms_speed2={3593,{{1,50},{20,50}}},
		--addms_speed3={3361,{{1,60},{20,60}}},
		addms_life1={3359,{{1,-3},{20,-3}}},
		addms_life2={3593,{{1,-3},{20,-3}}},
		--addms_life3={3361,{{1,-7},{20,-7}}},
		ms_vanish_remove_buff = {3398},
		skill_mintimepercast_v={{{1,30*15},{20,30*15}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css_child1 =  --乘霜式_子1
    { 
		--addms_speed1={3362,{{1,60},{20,60}}},
		--addms_speed2={3363,{{1,60},{20,60}}},
		--addms_speed3={3364,{{1,60},{20,60}}},
		--addms_life1={3362,{{1,-7},{20,-7}}},
		--addms_life2={3363,{{1,-7},{20,-7}}},
		--addms_life3={3364,{{1,-7},{20,-7}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	dxz_css_child2 =  --乘霜式_子2
    { 
		--addms_speed1={3365,{{1,40},{20,40}}},
		--addms_life1={3365,{{1,-7},{20,-7}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    dxz_xyw = --雪影舞
    { 
		ignore_series_state={},	
		ignore_abnor_state={},	
		skill_statetime={{{1,15*20},{10,15*20}}},
    },
	dxz_jby =  --坚冰御
    { 
		invincible_b={1},
		skill_mintimepercast_v={{{1,15*10},{4,15*10}}},
		skill_statetime={{{1,15*5},{2,15*10},{3,15*10}}},
    },
	dxz_xj_jin =  --陷阱（金）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,4},{30,4}},
			[3]={{1,4},{30,4}}
			},
    },
	dxz_xj_mu =  --陷阱（木）_子
    { 
		attack_holydamage_v={
			[1]={{1,2},{30,2}},
			[3]={{1,2},{30,2}}
			},
    },
	dxz_xj_shui =  --陷阱（水）_子
    { 
		attack_holydamage_v={
			[1]={{1,3},{30,3}},
			[3]={{1,3},{30,3}}
			},
		state_slowall_attack={{{1,100},{30,100}},{{1,15*3},{30,15*3}}},
    },
	dxz_xj_huo =  --陷阱（火）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,5},{30,5}},
			[3]={{1,5},{30,5}}
			},
    },
	dxz_xj_tu =  --陷阱（土）_伤害
    { 
		attack_holydamage_v={
			[1]={{1,4},{30,4}},
			[3]={{1,4},{30,4}}
			},
		state_stun_attack={{{1,100},{30,100}},{{1,15*1},{30,15*1}}},
    }, 
    dxz_nsbz = --年兽冰阵   概率，技能ID，技能等级
    { 
		skill_randskill1={{{1,50},{10,50}},3389,{{1,1},{10,10}}},	
		skill_randskill2={{{1,50},{10,50}},3390,{{1,1},{10,10}}},	
		skill_randskill3={{{1,50},{10,50}},3391,{{1,1},{10,10}}},	
		skill_randskill4={{{1,50},{10,50}},3392,{{1,1},{10,10}}},	
		skill_randskill5={{{1,50},{10,50}},3393,{{1,1},{10,10}}},	
    }, 
    dxz_nsbz_child1 = --年兽冰阵_定身
    { 
		state_fixed_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child2 = --年兽冰阵_冰冻
    { 
		state_freeze_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child3 = --年兽冰阵_混乱
    { 
		state_confuse_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child4 = --年兽冰阵_眩晕
    { 
		state_stun_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },
    dxz_nsbz_child5 = --年兽冰阵_迟缓
    { 
		state_slowall_attack={{{1,100},{30,100}},{{1,15*4},{30,15*4}}},
    },  
	dxz_change_xzboy=  --变身雪仗小男孩
    { 
		shapeshift={2126,2},								--参数1：npcid，参数2：与角色本身属性无关
		deadlystrike_v={{{1,-100000},{30,-100000}}},	
		lifemax_v={{{1,1000},{30,1000}}},		
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_xzgirl=  --变身雪仗小女孩
    { 
		shapeshift={2127,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,1000},{30,1000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
    dxz_change_boy=  --变身打雪仗男孩
    { 
		shapeshift={2128,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,1000},{30,1000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_girl=  --变身打雪仗女孩
    { 
		shapeshift={2129,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,1000},{30,1000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_smboy=  --变身火娃
    { 
		shapeshift={3719,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,100000},{30,100000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_smgirl=  --变身水娃
    { 
		shapeshift={3706,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,1000},{30,1000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
    dxz_change_xwjj=  --玄武机甲
    { 
		shapeshift={3718,2},
		deadlystrike_v={{{1,-100000},{30,-100000}}},
		lifemax_v={{{1,1000000},{30,1000000}}},
		skill_statetime={{{1,15*200},{30,15*200}}},
    },
	dxz_change_snowman=  --变身雪人隐藏本体
    { 
		--shapeshift={2134},								--参数1：npcid
		deadlystrike_v={{{1,1},{30,1}}},					--随便给的一个魔法属性，保证此脚本生效
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	dxz_addrxq=  --增加雪球
    { 
		add_skill_level={3359,{{1,1},{10,10}}, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		superposemagic={{{1,3},{3,3}}},				--叠加层数		
		skill_statetime={{{1,15*3000},{30,15*200}}},
    },
	dxz_addskill=  --增加变身技能
    { 
		add_skill_level={{{1, 3371},{2, 3367},{3, 3591},{4, 3593}}, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*5},{30,15*200}}},	
    },
	dxz_addsqs=  --增加水球
    { 
		add_skill_level={4734,{{1,1},{10,10}}, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		superposemagic={{{1,3},{3,3}}},				--叠加层数		
		skill_statetime={{{1,15*3000},{30,15*3000}}},
    },
	dxz_addskill01=  --增加变身技能
    { 
		add_skill_level={3365, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*5},{30,15*200}}},	
    },
    dxz_addskill02=  --增加变身技能
    { 
		add_skill_level={3361, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*5},{30,15*200}}},	
    },
    dxz_addskill03=  --增加变身技能
    { 
		add_skill_level={3362, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*5},{30,15*200}}},	
    },
    dxz_addskill04=  --增加变身技能
    { 
		add_skill_level={3364, 1, 1},  --每个等级对应不同的技能ID，添加的等级，是否添加技能
		skill_statetime={{{1,15*5},{30,15*200}}},	
    },
	act_nianshou_yanhua1 =  --烟花技能1
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_yanhua2 =  --烟花技能2
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_yanhua3 =  --烟花技能3
    { 
		attack_holydamage_v={
			[1]={{1,9500},{30,9500}},
			[3]={{1,10500},{30,10500}}
			},
    },
	act_nianshou_chongzhuang =  --年兽冲撞
    { 
		--attack_holydamage_v={
		--	[1]={{1,3000},{30,3000}},
		--	[3]={{1,3000},{30,3000}}
		--	},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    },
	act_nianshou_paoxiao =  --年兽咆哮
    { 
		--attack_holydamage_v={
		--	[1]={{1,3000},{30,3000}},
		--	[3]={{1,3000},{30,3000}}
		--	},
		state_knock_attack={100,35,30},			--概率，持续时间，速度
		state_npcknock_attack={100,35,30},
		spe_knock_param={26 , 26, 26},			--停留时间，角色动作ID，NPC动作ID	
    },
	act_nianshou_bianyang =  --年兽变羊
    { 
		state_confuse_attack={{{1,100},{30,100}},{{1,15*5},{30,15*5}}},	
    },
	act_nianshou_bianyang_child =   --年兽变羊_子
    { 
		shapeshift={2174},								--npcid
		skill_statetime={{{1,15*5},{30,15*5}}},
    },
	act_nianshou_kangxing =   --年兽抗性
    { 
		metal_resist_p={9999},
		wood_resist_p={9999},
		water_resist_p={9999},
		fire_resist_p={9999},
		earth_resist_p={9999},
		skill_statetime={{{1,-1},{30,-1}}},
    },
    act_daiyanren  = --无敌新颖
    {
		invincible_b={1,1},
		skill_statetime={{{1,15*180},{10,15*180},{11,15*180}}},
    },
	act_atk=  --运营_伤害放大
    { 
		enhance_final_damage_p={{{1,100},{5,500}}},
		skill_statetime={{{1,15*900},{30,15*900}}},
    },
	act_life=  --运营_基础血量
    { 
		lifemax_p={{{1,100},{30,3000},{31,3000}}},
		skill_statetime={{{1,15*900},{30,15*900}}},
    },
    act_maxlife = --运营_当前血量
    {
		lifecurmax_p={{{1,200},{5,1000}}},
		skill_statetime={{{1,15*900},{30,15*900}}},
    },
    lovertask = --情缘任务_心灵之护
    { 
		defuse_damage={{{1,500000},{10,500000}},100},
		skill_statetime={{{1,15*5},{10,15*5}}},
    },
	kin_dinner=  --家族聚餐
    { 
		call_script={},
		skill_statetime={{{1,15*15},{30,15*15}}},
    },
    yiji_defuse = --伤害抵挡
    { 
		defuse_damage={{{1,100000},{10,100000}},30},
		skill_statetime={{{1,15*5},{10,15*5}}},
    },
	foolsday_change_pig= 	--变身猪（愚人节活动）
    { 
		shapeshift={3461},								--npcid
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
	foolsday_change_pig1= 	--变身猪（愚人节活动）
    { 
		lifemax_p={{{1,1},{30,1}}},
		skill_statetime={{{1,15*20},{30,15*20}}},
    },
    dxz_hqs =  --火球术
    { 
		attack_holydamage_v={
			[1]={{1,500},{30,500}},
			[3]={{1,500},{30,500}}
			},
    },
    dxz_sqs =  --水球术
    { 
		attack_holydamage_v={
			[1]={{1,100},{30,100}},
			[3]={{1,100},{30,100}}
			},
		skill_point={{{1,100},{2,200},{3,300},{4,300}},{{1,100},{4,100}}}, --参数1/100：叠加次数，参数2/100：每次CD回复的次数
		skill_mintimepercast_v={{{1,5},{4,5}}},
    },
    dxz_sqs_kouchu = {--扣除一层
		mult_skill_state={4736,{{1,1},{10,10}},{{1,-1},{10,-1}}}, 		--技能ID，等级，buff层数
    },
    dxz_hbz =  --寒冰掌
    { 
		attack_holydamage_v={
			[1]={{1,20000},{30,20000}},
			[3]={{1,20000},{30,20000}}
			},
    },

	lmzz_buff_recover=  --复苏
    { 
		recover_life_p={{{1,5},{96,100},{100,100}},15},
		skill_statetime={{{1,15*5},{100,15*5}}},
    },
    lmzz_buff_hide =   --潜行
    { 
		hide={{{1,15*10},{10,15*19}},1},	--参数1时间，参数2：队友1，同阵营2
		skill_statetime={{{1,15*10},{10,15*19}}},
    },
	lmzz_buff_runspeed=  --疾行
    { 
		runspeed_v={{{1,10},{50,500},{51,500}}},
		skill_statetime={{{1,15*30},{30,15*30}}},
    },
	lmzz_buff_wudi=  --无敌
    { 
		invincible_b={1},
		skill_statetime={{{1,15*5},{10,15*14}}},
    },

	cbzd_recover=  --回血_可叠加
    { 
		recover_life_p={{{1,1},{10,10}},15},
		superposemagic={10},							--最大叠加层数
		skill_statetime={{{1,15*1},{20,15*1}}},
    },
	cbzd_enhance_damage=  --伤害放大_可叠加
    { 
		enhance_final_damage_p={{{1,1},{10,10}}},
		superposemagic={10},							--最大叠加层数
		skill_statetime={{{1,15*60},{20,15*60}}},
    },
	cbzd_reduce_damage=  --伤害抵消_可叠加
    { 
		reduce_final_damage_p={{{1,1},{10,10}}},
		superposemagic={10},							--最大叠加层数
		skill_statetime={{{1,15*60},{30,15*60}}},
    },
    tjmz_character=
    { 
    metal_resist_v={{{1,0},{2,-870},{3,0},{4,870},{5,0}}},
	wood_resist_v={{{1,870},{2,0},{3,0},{4,0},{5,-870}}},
	water_resist_v={{{1,0},{2,0},{3,0},{4,-870},{5,870}}},
	fire_resist_v={{{1,-870},{2,0},{3,870},{4,0},{5,0}}},
	earth_resist_v={{{1,0},{2,870},{3,-870},{4,0},{5,0}}},
    }, 
    tjmz_lbwb = {--凌波微步-天机迷阵
		ignoreattackontime={{{1,30*15},{10,12*15}},1.5*15},
		skill_statetime={-1},
	},
	tjmz_txwg = --天下无狗-天机迷阵
    {
		enhance_final_damage_p={{{1,20},{2,10},{3,-5},{4,-10}}},
		lifecurmax_p={{{1,20},{2,10},{3,-5},{4,-10}}},
		skill_statetime={-1},
    },
    tjmz_wanhua_1 = --万花笔法
    { 
		attack_usebasedamage_p={{{1,100},{30,100}}},
    }, 
	tjmz_wanhua_2 = --执颖点墨
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    }, 
	tjmz_wanhua_3 = --兰摧玉折
    { 
		attack_usebasedamage_p={{{1,300},{30,300}}},
    },
    tjmz_wanhua_4 = --墨虎如生
    { 
		attack_usebasedamage_p={{{1,400},{30,400}}},
    }, 
    tjmz_debuff_1 = --破甲，受击时减少回复效率
    {
		autoskill={36,{{1,1},{10,10}}}, 
		skill_statetime={-1},
    },
    tjmz_debuff_1_child = --蚀甲，受击时减少回复效率
    {
		lifereplenish_p={{{1,-10},{10,-19},{11,-20}}},
		skill_statetime={{{1,15*4},{10,15*4}}},
    },
}

FightSkill:AddMagicData(tb)