
local tb    = {
    wh_pg1 = --万花笔法1--20级
    {
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,85},{30,115},{31,118}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,85*2*0.9},{30,115*2*0.9},{31,118*2*0.9}},
			[3]={{1,60*2*1.1},{20,85*2*1.1},{30,115*2*1.1},{31,118*2*1.1}}
		},
		state_npchurt_attack={100,6},
		missile_hitcount={3,0,0},
    },
    wh_pg2 = --万花笔法2--20级
    {
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,85},{30,115},{31,118}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,85*2*0.9},{30,115*2*0.9},{31,118*2*0.9}},
			[3]={{1,60*2*1.1},{20,85*2*1.1},{30,115*2*1.1},{31,118*2*1.1}}
		},
		state_npchurt_attack={100,6},
		missile_hitcount={3,0,0},
    },
    wh_pg3 = --万花笔法3--20级
    {
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60},{20,85},{30,115},{31,118}}},
		attack_earthdamage_v={
			[1]={{1,60*2*0.9},{20,85*2*0.9},{30,115*2*0.9},{31,118*2*0.9}},
			[3]={{1,60*2*1.1},{20,85*2*1.1},{30,115*2*1.1},{31,118*2*1.1}}
		},
		state_npchurt_attack={100,6},
		missile_hitcount={3,0,0},
    },
    wh_pg4 = --万花笔法4--20级
    {
		attack_attackrate_v={100},
		attack_usebasedamage_p={{{1,60*1.5},{20,85*1.5},{30,115*1.5},{31,118*1.5}}},
		attack_earthdamage_v={
			[1]={{1,60*1.5*2*0.9},{20,85*1.5*2*0.9},{30,115*1.5*2*0.9},{31,118*1.5*2*0.9}},
			[3]={{1,60*1.5*2*1.1},{20,85*1.5*2*1.1},{30,115*1.5*2*1.1},{31,118*1.5*2*1.1}}
		},
		state_stun_attack={40,7},
		state_npchurt_attack={80,6},
		missile_hitcount={3,0,0},
    },

    wh_zydm = --执颖点墨-1级主动1--15级
    {
		attack_usebasedamage_p={{{1,257},{15,498},{20,584}}},
		attack_earthdamage_v={
			[1]={{1,257*2*0.9},{15,498*2*0.9},{20,584*2*0.9}},
			[3]={{1,257*2*1.1},{15,498*2*1.1},{20,584*2*1.1}}
		},
		state_stun_attack={0,0},                                    --秘籍用

		userdesc_000={5806,5819},

		missile_hitcount={3,0,0},

		skill_mintimepercast_v={15*10},
    },
    wh_zydm_child = --执颖点墨-1级主动1--15级
    {
		mult_skill_state={5806,{{1,1},{15,15}},3}, 					--技能ID，等级，buff层数
		missile_hitcount={3,0,0},
    },
	wh_zydm_child1 = --舞笔弄墨每层诅咒
	{
		--physics_potentialdamage_p={{{1,-3},{15,-45},{20,-60}}},
		superposemagic={5},				--最大叠加层数
		skill_statetime={15*15},
    },
	wh_zydm_child2 =  --舞笔弄墨-减少层数
	{
		mult_skill_state={5806,{{1,1},{15,15}},-1}, 		--技能ID，等级，buff层数
    },

    wh_book1 = --执颖点墨秘籍
    {
    	--初级秘籍
		add_hitskill1={5805,5856,{{1,1},{10,10},{20,20}}},		--击中后降低敌人全抗
		userdesc_101={8*15},    								--wh_book1_child1的时间描述

		--中级秘籍
		addstartskill={5805,{{1,0},{10,0},{11,5857},{20,5857}},{{1,0},{10,0},{11,11},{20,20}}},		--同时触发技能造成眩晕和定身

		--高级秘籍
		addstartskill2={5857,{{1,0},{15,0},{16,5876},{20,5876}},{{1,1},{10,10},{11,11}}},  				--增加会心伤害
		add_stun_r={5805,{{1,0},{15,0},{16,16},{20,80},{21,80}}},			--增加造成眩晕的概率
		add_stun_t={5805,{{1,0},{15,0},{16,0.2*15},{20,1*15},{21,1*15}}},	--增加造成眩晕的时间

		skill_statetime={-1},
		userdesc_000={5856,5858,5876},
	},
	wh_book1_child1 = --初级·执颖点墨.降低基础全抗
	{
		all_series_resist_p={{{1,-15},{10,-120},{20,-120}}},
		skill_statetime={8*15},
    },
	wh_book1_child2 = --中级·执颖点墨.造成定身与眩晕
	{
		ms_one_hit_count = {0,0,1},
	},
    wh_book1_child3 = --中级·执颖点墨.造成定身与眩晕
    {
		--state_stun_attack={{{1,0},{10,0},{11,30},{15,80},{20,80}},{{1,0},{10,0},{11,1*15},{15,1*15},{20,1*15}}},
		state_fixed_attack={{{1,0},{10,0},{11,30},{15,80},{20,80}},{{1,0},{10,0},{11,1*15},{15,1*15},{20,1*15}}},
		missile_hitcount={0,0,1},
    },
	wh_book1_child4 = --高级·执颖点墨.增加会心伤害
	{
		deadlystrike_damage_p={{{1,0},{15,0},{16,8},{20,40}}},
		skill_statetime={8*15},
    },

    wh_lcyz = --兰摧玉折-4级主动2--15级
    {
		attack_usebasedamage_p={{{1,217},{15,322},{20,460}}},
		attack_earthdamage_v={
			[1]={{1,217*2*0.9},{15,322*2*0.9},{20,460*2*0.9}},
			[3]={{1,217*2*1.1},{15,322*2*1.1},{20,460*2*1.1}}
		},
		skill_point={{{1,100},{7,100},{8,200},{14,200},{15,300},{21,300}},{{1,100},{15,100},{16,100},{21,100}}}, --参数1/100：叠加次数，参数2/100：每次CD回复的次数

		userdesc_101={{{1,217},{15,322},{20,460}}},    --wh_lcyz_child3的伤害描述
		userdesc_102={
			[1]={{1,217*2*0.9},{15,322*2*0.9},{20,460*2*0.9}},
			[3]={{1,217*2*1.1},{15,322*2*1.1},{20,460*2*1.1}}
		},

		missile_hitcount={6,0,0},

		skill_mintimepercast_v={15*5},
    },
	wh_lcyz_child1 = --兰摧玉折_引爆舞笔弄墨
	{
		hitfilter_buff={5806},				--有舞笔弄墨才能击中,然后hitskill是范围伤害,从而每层爆一次伤害
		mult_skill_state={5806,1,-1}, 		--扣除1层舞笔弄墨
		state_stun_attack={0,1},
	},
	wh_lcyz_child2 = --兰摧玉折_命中散射
	{
		missile_hitcount={6,0,0},
	},
	wh_lcyz_child3 = --兰摧玉折_舞笔弄墨伤害
	{
		attack_usebasedamage_p={{{1,217},{15,322},{20,360}}},
		attack_earthdamage_v={
			[1]={{1,217*2*0.9},{15,322*2*0.9},{20,360*2*0.9}},
			[3]={{1,217*2*1.1},{15,322*2*1.1},{20,360*2*1.1}}
		},

		missile_hitcount={6,0,0},
	},
    wh_book2 = --兰摧玉折秘籍
    {
    	--初级秘籍
		add_deadlystrike_p1={5808,{{1,5},{10,25},{20,25}}},  	--增加会心一击
		add_deadlydmg_p1={5808,{{1,10},{10,60},{20,60}}},  		--增加会心伤害

		--中级秘籍
		autoskill={{{1,0},{10,0},{11,126},{20,126}},{{1,0},{10,0},{11,11},{20,20}}},	--概率刷新cd
		userdesc_101={{{1,0},{10,0},{11,8},{15,40},{20,40}}},							--描述用，实际几率查看auto.tab

		--高级秘籍
		add_usebasedmg_p1={5808,{{1,0},{15,0},{16,5},{20,25}}},			--增加兰摧玉折威力
		add_usebasedmg_p2={5826,{{1,0},{15,0},{16,5},{20,25}}},			--增加舞笔弄墨威力

		skill_statetime={-1},
	},
	wh_book2_child= --兰摧玉折秘籍-清CD
	{
		reduce_cd_time1={5808,{{1,0},{10,0},{16,5*15},{20,5*15}}},
	},

	wh_mhrs = --墨虎如生-10级主动3--15级
	{
		attack_usebasedamage_p={{{1,202},{15,457},{20,650}}},
		attack_earthdamage_v={
			[1]={{1,202*2*0.9},{15,457*2*0.9},{20,650*2*0.9}},
			[3]={{1,202*2*1.1},{15,457*2*1.1},{20,650*2*1.1}}
		},
		state_stun_attack={40,15*1},
		mult_skill_state={5806,{{1,1},{15,15}},1}, 					--技能ID，等级，buff层数
		userdesc_000={5806,5811},
		missile_hitcount={1,1,1},
		skill_mintimepercast_v={15*15},
	},
	wh_mhrs_child = --墨虎如生-10级主动3--15级
	{
		mult_skill_state={5806,{{1,1},{15,15}},1}, 					--技能ID，等级，buff层数
		missile_hitcount={1,1,1},
	},

    wh_book3 = --墨虎如生秘籍
    {
		--初级.提高伤害，增加次数
		add_usebasedmg_p1={5810,{{1,8},{10,75},{20,75}}},
		add_usebasedmg_p2={5866,{{1,8},{10,75},{20,75}}},
		add_usebasedmg_p3={5867,{{1,8},{10,75},{20,75}}},
		addaction_event1={5810,{{1,5810},{4,5810},{5,5866},{9,5866},{10,5867},{20,5867}}},		--技能5810被5866与5867替换
		userdesc_101={{{1,0},{4,0},{5,1},{9,1},{10,2},{20,2}}},									--增加攻击次数的描述

		--中级.减少墨虎如生冷却时间
		deccdtime={5810,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},

		--高级.越打越疼
		addpowerwhencol1={5810,{{1,0},{15,0},{16,3},{20,15}},{{1,0},{15,0},{16,12},{20,60}}},				--技能ID，每次增加%，最大增加%
		addpowerwhencol2={5866,{{1,0},{15,0},{16,3},{20,15}},{{1,0},{15,0},{16,12},{20,60}}},				--技能ID，每次增加%，最大增加%
		addpowerwhencol3={5867,{{1,0},{15,0},{16,3},{20,15}},{{1,0},{15,0},{16,12},{20,60}}},				--技能ID，每次增加%，最大增加%

		skill_statetime={-1},
    },

	wh_whxf = --万花心法-20级被动1--10级
	{
		physics_potentialdamage_p={{{1,24},{10,70},{11,80}}},
		lifemax_p={{{1,45},{10,60},{11,62}}},
		state_slowall_resistrate={{{1,35},{10,150},{11,165}}},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},

		--add_setcallpos={5813},  --设置30级主动技能，召唤老虎在目标位置出现
	},

    wh_hhdj = --绘虎点睛-30级主动4--15级
    {
		attack_usebasedamage_p={{{1,139},{15,388},{20,577}}},
		attack_earthdamage_v={
			[1]={{1,139*2*0.9},{15,388*2*0.9},{20,577*2*0.9}},
			[3]={{1,139*2*1.1},{15,388*2*1.1},{20,577*2*1.1}}
		},
		userdesc_000={5814},
		missile_hitcount={6,0,0},
		skill_mintimepercast_v={15*25},
    },
	wh_hhdj_child1 = --绘虎点睛_子1--15级
	{
		call_npc1={3730, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={3730},
		skill_statetime={15*10},
    },
	wh_hhdj_child2 = --绘虎点睛_子2--15级
	{
	 	callnpc_life={3730,100},							--NPCid，生命值%
	 	callnpc_damage={3730,{{1,50},{15,113},{20,142}}},	--NPCid，攻击力%
		skill_statetime={15*10},							--持续时间需要跟wh_hhdj_child1的时间一致
    },
    wh_book4 = --绘虎点睛秘籍
    {
		--初级、高级.提高主角抗性、吸取生命
		buff_addition={5813,{{1,8},{15,8},{16,9},{20,9}},{{1,1},{20,20}}},
		userdesc_101={{{1,20},{10,200},{20,200}}},			--描述用，增加基础全抗
		userdesc_102={{{1,0},{15,0},{16,4},{20,20}}},		--描述用，增加生命吸取

		--中级.减少绘虎点睛冷却时间
		deccdtime={5812,{{1,0},{10,0},{11,1*15},{15,5*15},{20,5*15}}},

		skill_statetime={-1},
    },
    wh_book4_child = --绘虎点睛秘籍
    {
		--高级.提高主角防御
		buff_addition={5840,{{1,8},{15,8},{16,9},{20,9}},{{1,1},{20,20}}},

		skill_statetime={-1},
    },

    wh_mscg = --墨守成规-40级被动2--10级
    {
		state_freeze_ignore={1},

		autoskill={116,{{1,1},{10,10},{11,11}}},
		userdesc_101={{{1,15*15},{10,15*15},{11,15*15}}},				--假描述，墨守成规与护盾的持续时间
		userdesc_102={{{1,15*15},{10,15*15},{11,15*15}}},				--假描述，护盾的触发时间
		skill_statetime={-1},

		userdesc_000={5832},
    },
    wh_mscg_child1 = --墨守成规_叠加BUFF
    {
		autoskill={117,{{1,1},{10,10},{11,11}}},
		add_shield={5833,{{1,0.84*100},{10,7.8*100},{16,12.6*100}}},	--增加墨守成规_护盾
		superposemagic={5},							--最大叠加层数
		skill_statetime={15*15},
    },
	wh_mscg_child2 = --墨守成规_护盾
	{
		magicshield={
			[1] = {{1,0},{10,0},{11,0}},
			[2] = 15*15
		},			--参数1：倍数；参数2：时间帧。  吸收伤害 = 敏捷点数 * 参数1 / 100
		skill_statetime={15*15},
    },
	wh_mscg_child3 = --墨守成规_清除叠加BUFF
	{
		ignore_skillstate1={5832},		--清除叠加BUFF
		skill_statetime={1},
    },

    wh_gjbf = --高级笔法-50级被动3--10级
    {
		add_skill_level={5801,{{1,1},{10,10},{11,11}},0},
		add_skill_level2={5802,{{1,1},{10,10},{11,11}},0},
		add_skill_level3={5803,{{1,1},{10,10},{11,11}},0},
		add_skill_level4={5804,{{1,1},{10,10},{11,11}},0},
		userdesc_000={5836},
		--add_setcallpos={5840},  --设置60级被动技能，召唤大老虎在目标位置出现
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    wh_gjbf_child = --高级笔法_子（仅用作显示，无实际效果加成。实际效果查看普攻的21-31级）--10级
    {
		attack_usebasedamage_p={{{1,3},{10,30},{11,33}}},
		attack_earthdamage_v={
			[1]={{1,12*1},{10,120},{11,132}},
			[3]={{1,12*1},{10,120},{11,132}}
			},
    },

    wh_yhty = --与虎添翼-60级被动4--10级
    {
		addstartskill={5825,5838,{{1,1},{10,10},{11,11}}},
		userdesc_000={5838,5839,5841},
		userdesc_101={15*10},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    wh_yhty_child = --与虎添翼_子
    {
		--add_usebasedmg_p1={5801,{{1,5},{10,20},{11,22}}},			--增加普攻威力
		--add_usebasedmg_p2={5802,{{1,5},{10,20},{11,22}}},			--增加普攻威力
		--add_usebasedmg_p3={5803,{{1,5},{10,20},{11,22}}},			--增加普攻威力
		--add_usebasedmg_p4={5804,{{1,5},{10,20},{11,22}}},			--增加普攻威力
		superposemagic={5},				--最大叠加层数
		skill_statetime={30*15},
    },
    wh_yhty_callnpc = --与虎添翼
    {
		attack_usebasedamage_p={{{1,103},{15,555}}},
		attack_earthdamage_v={
			[1]={{1,103*2*0.9},{15,555*2*0.9}},
			[3]={{1,103*2*1.1},{15,555*2*1.1}}
		},
		check_buff_superpose={5838,5},			--5点buff才能使用

		userdesc_104={3748,{{1,50},{15,113},{20,142}}},
		userdesc_105={15*10},

		missile_hitcount={6,0,0},

		skill_mintimepercast_v={15*25},
    },
	wh_yhty_npcbuff1 = --与虎添翼_自身BUFF1
	{
		call_npc1={3748, -1, 5},				--NPCid, NPC等级（-1为跟玩家一样），NPC五行
		remove_call_npc={3748},
		skill_statetime={15*10},
    },
	wh_yhty_npcbuff2 = --与虎添翼_自身BUFF2
	{
	 	callnpc_life={3748,100},							--NPCid，生命值%
	 	callnpc_damage={3748,{{1,50},{15,113},{20,142}}},	--NPCid，攻击力%
		skill_statetime={15*10},								--持续时间需要跟wh_hhdj_child1的时间一致
    },
	wh_yhty_cost = --扣除与虎添翼层数
	{
		mult_skill_state={5838,1,-5}, 		--扣除与虎添翼层数
		skill_statetime={1},
	},

    wh_hxsl = --虎啸山林-70级被动5--10级
    {
		autoskill={118,{{1,1},{10,10},{11,11}}},
		userdesc_000={5847},
		userdesc_101={{{1,15*6},{10,15*6},{11,15*6}}},				--假描述，增加生命吸取时间，查看wh_hxsl_child3
		userdesc_102={{{1,40},{10,90},{11,95}}},					--假描述，触发概率，实际触发概率于aotuskill.tab中设置
		userdesc_103={{{1,15*30},{10,15*30},{11,15*30}}},			--假描述，触发间隔，实际触发概率于aotuskill.tab中设置 										--清除免疫控制时间，wh_hxsl_child4
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
    },
    wh_hxsl_child1 = --虎啸山林_满层墨守成规
    {
		missile_hitcount={0,0,1},
    },
    wh_hxsl_child2 = --虎啸山林_清除兰摧玉折CD
    {
		reduce_cd_time_point1={5808,{{1,15*5},{10,15*5}},1},		--清除兰摧玉折CD,对充能可减
		skill_statetime={1},
    },
    wh_hxsl_child3 = --虎啸山林_增加生命吸取
    {
		steallife_p={{{1,5},{10,50},{11,55}}},
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={15*6},
    },

    wh_qxjq = --清心静气-80级被动6--20级
    {
		physics_potentialdamage_p={{{1,2},{20,40},{24,40*1.2}}},
		lifemax_p={{{1,5},{20,95},{24,95*1.2}}},
		attackspeed_v={{{1,5},{20,20},{24,20*1.2}}},
		all_series_resist_p={{{1,2},{20,40},{24,40*1.2}}},
		state_stun_attackrate={{{1,10},{20,200},{24,200*1.2}}},
		state_slowall_resisttime={{{1,10},{20,200},{24,200*1.2}}},
		skill_statetime={-1},
    },

    wh_mrss = --墨染失色--90级被动7--10级
    {
		add_mult_proc_sate1={5851,{{1,4},{10,4},{11,4}},60},  --技能ID,叠加层数，自身为圆心格子半径
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
		userdesc_000={5851,5852},
    },
    wh_mrss_child1 = --墨染失色_攻击力加成
    {
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		physics_potentialdamage_p={{{1,10},{10,40},{11,44}}},
		skill_statetime={{{1,15*8},{10,15*8},{11,15*8}}},
    },
    wh_mrss_child2 = --墨染失色_回复效率减弱
    {
		lifereplenish_p={{{1,-20},{10,-60},{11,-64}}},
		skill_statetime={{{1,15*8},{10,15*8},{11,15*8}}},
    },

    wh_nq = {--万花怒气-怒气
		attack_usebasedamage_p={{{1,1000},{30,1000}}},
		attack_metaldamage_v={
			[1]={{1,2000*0.9},{30,2000*0.9},{31,2000*0.9}},
			[3]={{1,2000*1.1},{30,2000*1.1},{31,2000*1.1}}
			},
    },
	wh_nq_child = {--万花怒气_免疫
		ignore_series_state={},		--免疫属性效果
		ignore_abnor_state={},		--免疫负面效果
		skill_statetime={{{1,15*4},{30,15*4}}},
    },
}

FightSkill:AddMagicData(tb)