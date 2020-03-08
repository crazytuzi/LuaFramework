
local tb    = {
	public_juexue1={  --江湖绝学.风虎云龙
		deadlystrike_damage_p={{{1,4},{5,20},{10,35}}},
		autoskill={181,{{1,1},{10,10}}},
		
		skill_statetime={-1},
	},
	public_juexue1_child={  --增加会心免伤，减少会心伤害
		deadlystrike_damage_p={{{1,-4},{5,-20},{10,-35}}},
		weaken_deadlystrike_damage_p={{{1,4},{5,20},{10,35}}},
		
		skill_statetime={3*15},
	},

	public_juexue2={  --江湖绝学.挥袂生风
		autoskill={196,{{1,1},{10,10}}},
		return_resist_p={{{1,1},{3,5},{4,6},{6,8},{7,8},{8,9},{9,9},{10,10}}},
		userdesc_000={5389},		
		userdesc_101={{{1,30*15},{10,30*15}}},

		skill_statetime={-1},
	},
	public_juexue2_child1={  --叠加BUFF
		autoskill={197,{{1,1},{10,10}}},
		autoskill2={198,{{1,1},{10,10}}},
		
		skill_statetime={29*15},
	},
	public_juexue2_child2={  --近战BUFF
		runspeed_v={{{1,2},{5,10},{10,15}}},
		attackspeed_v={{{1,2},{5,10},{10,15}}},
		
		skill_statetime={8*15},
	},
	public_juexue2_child3={  --远程BUFF
		attackspeed_v={{{1,2},{5,10},{10,15}}},
		
		skill_statetime={8*15},
	},
	public_juexue2_child4={
		ignore_skillstate1={5388},	--清除层数
		
		skill_statetime={2},
	},
	
	tw_juexue1 = {	--金钟罩受击有概率解控并且回血
		add_autoskill1={213,182,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5358},
		userdesc_101={{{1,5},{10,50}}},
	},
    tw_juexue1_child1 = {--解控&回血
		ignore_series_state={},	
		ignore_abnor_state={},
		dir_recover_life_pp={{{1,50},{10,150}},1},		--生命上限万分比,自身数值
		
		skill_statetime={0.5*15},
    },
	tw_juexue2 = {	--血战八方击中目标后不断提升此技能伤害
		autoskill={189,{{1,1},{10,10}}},

		skill_statetime={-1},

		userdesc_000={5370},
	},
	tw_juexue2_child = { --增加攻击力
		add_usebasedmg_p1={211,{{1,6},{10,60}}},
		superposemagic={3},				--叠加层数

		skill_statetime={15*5},
	},
		
	em_juexue1 = {	--慈航普渡附带反弹
		buff_addition={306,1,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_101={{{1,7},{10,70}}},
	},
	em_juexue2 = {	--白露凝霜叠加攻击与远近程伤害抗性
		add_hitskill_pos1={308,5371,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5371},
	},
	em_juexue2_child={
		physics_potentialdamage_p={{{1,2},{10,20}}},
		remote_dmg_p={{{1,-1},{10,-3}}},
		melee_dmg_p={{{1,-1},{10,-3}}},
		superposemagic={5},				--叠加层数
		
		skill_statetime={8*15},
	},
	
	th_juexue1 = {	--火凤燎原后短时间内超高闪避
		add_hitskill1={406,5359,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5359},
	},
    th_juexue1_child1 = {--火凤后短时间超高闪避
		defense_p={3000},
		
		skill_statetime={{{1,0.5*15},{10,5*15}}},
    },
	th_juexue2 = {	--桃花箭术叠加攻击
		autoskill={190,{{1,1},{10,10}}},

		skill_statetime={-1},

		userdesc_000={5372},
	},
	th_juexue2_child={
		physics_potentialdamage_p={{{1,1},{10,10}}},
		defense_p={{{1,2},{10,14}}},		
		superposemagic={6},				--叠加层数
		
		skill_statetime={3*15},
	},
	
	xy_juexue1 = {	--白虹贯日概率不进cd
		autoskill={183,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_101={{{1,4},{10,40}}},
	},
	xy_juexue1_child1={
		reduce_cd_time1={510,60*15},
	},
	xy_juexue2 = {	--释放白虹贯日减少七探蛇盘CD
		autoskill={191,{{1,1},{10,10}}},

		skill_statetime={-1},

		userdesc_000={5373},
	},
	xy_juexue2_child={
		reduce_cd_time_point1={507,{{1,15*1},{10,15*5}}},
		skill_statetime={1},
	},
	
	wd_juexue1 = {	--武当.提高无我无剑的伤害
		add_usebasedmg_p1={609,{{1,11},{10,110}}},
		add_hitskill1={609,5379,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5379},
	},
	wd_juexue1_child1 = {	--武当.无我无剑附带禁疗
		forbid_recover={1},			--禁止回复生命
		
		skill_statetime={{{1,0.3*15},{10,3*15}},15*15},
	},
	
	wd_juexue2 = {	--武当.坐忘无我附带近远抗性%
		buff_addition={613,4,{{1,1},{10,10},{11,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5374},
		userdesc_101={{{1,3},{2,4},{4,4},{5,5},{7,5},{8,6},{10,6}}},
	},
	wd_juexue2_child = {	--近远程抗性%
		skill_mult_relation={1}, --对应的NPC类型，从skillsetting.ini上查看
		remote_dmg_p={{{1,-1},{2,-1},{3,-2},{4,-3},{5,-3},{6,-4},{7,-5},{8,-5},{9,-6},{10,-7},{11,-7}}},
		melee_dmg_p={{{1,-1},{2,-1},{3,-2},{4,-3},{5,-3},{6,-4},{7,-5},{8,-5},{9,-6},{10,-7},{11,-7}}},
		
		skill_statetime={15*3},
	},
	
	tr_juexue1 = {	--死亡回旋触发弹射攻击
		add_hitskill1={708,5361,{{1,1},{10,10}}},
		add_ignore_invin1={708,1},
		add_ignore_invin2={5361,1},
				
		skill_statetime={-1},
		
		userdesc_000={5361},
	},
	tr_juexue1_child1 = {
		--ms_powerwhencol={50,200},  		--参数1：每次增加伤害，参数2：增加上限
		loselife_dmg_p={51},				--伤害倍率=1 + 损失生命% * 参数 / 100
		attack_usebasedamage_p={{{1,51},{10,153}}},
		attack_firedamage_v={
			[1]={{1,51*2*0.9},{10,153*2*0.9}},
			[3]={{1,51*2*1.1},{10,153*2*1.1}}
		},
		state_npchurt_attack={100,15},
		state_palsy_attack={0,0},								--配合秘籍加成
		ms_one_hit_count={0,0,1},
    },
	tr_juexue2 = {	--血月之影附带持续恢复生命与减CD
		buff_addition={711,5,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5375,5376},
	},
	tr_juexue2_child1 = {  --减CD
		reduce_cd_time_point1={708,{{1,15*0.1},{10,15*1},{11,15*1}}},  	--死亡回旋
		reduce_cd_time_point2={705,{{1,15*0.1},{10,15*1},{11,15*1}}},  	--魔焰在天
		reduce_cd_time_point3={722,{{1,15*0.1},{10,15*1},{11,15*1}}},  	--摄魂乱心
		skill_statetime={1},
	},
	tr_juexue2_child2 = {  --50%血以下恢复生命
		hitfilter_hp={0,50},			--只能击中0%~50%血
		dir_recover_life_pp={{{1,100},{10,200},{11,210}},1},--生命上限,自身数值
		
		missile_hitcount={0,0,1},		--只要打中一个就够了
	},
	
	sl_juexue1 = {	--少林.大力金刚指叠加攻击
		add_hitskill_pos1={268,5362,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5362},
	},
	sl_juexue1_child1={
		physics_potentialdamage_p={{{1,3},{10,30}}},
		superposemagic={6},				--叠加层数
		
		skill_statetime={10*15},
	},
    sl_juexue2 = {--少林.罗汉阵击中目标回复生命
		add_hitskill_pos1={274,5386,{{1,1},{10,10}}},

		userdesc_000={5386},	

		skill_statetime={-1},
    },
    sl_juexue2_child = {--少林.罗汉阵击中目标回复生命
		dir_recover_life_pp={{{1,10},{10,50}},1},--生命上限,自身数值
		skill_statetime={1},		
    },
	
	cy_juexue1 = {	--召唤啵啵后提高自身???
		addstartskill={810,5363,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5363},
	},
	cy_juexue1_child1={
		dir_recover_life_pp={{{1,100},{10,1000}},1},--生命上限,自身数值
	},
	cy_juexue2 = {	--冰心雪莲.技能叠加提高翠烟御伞诀的伤害
		autoskill={193,{{1,1},{10,10}}},

		userdesc_000={5377},
		
		skill_statetime={-1},
	},
	cy_juexue2_child = { --技能叠加普攻伤害
		add_usebasedmg_p1={801,{{1,1},{10,10}}},
		add_usebasedmg_p2={802,{{1,1},{10,10}}},
		add_usebasedmg_p3={803,{{1,1},{10,10}}},
		add_usebasedmg_p4={804,{{1,1},{10,10}}},
		superposemagic={4},				--叠加层数		
		
		skill_statetime={15*4},
	},
	
	tm_juexue1 = {	--含沙射影有几率缩短技能cd
		autoskill={184,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5364},
		userdesc_101={{{1,1},{10,10}}},--触发几率
	},
	tm_juexue1_child1={
		reduce_cd_time_point1={4008,4*15,1},			--减少暴雨cd,对充能可减
		skill_statetime={1},
	},
	tm_juexue2 = {	--九宫飞星击中目标叠加会心伤害与会心几率
		add_hitskill_pos1={4013,5378,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5378},
	},
	tm_juexue2_child={ --叠加会心伤害与会心几率%
		deadlystrike_damage_p={{{1,1},{10,14}}},
		deadlystrike_p={{{1,1},{10,7}}},
		superposemagic={9},				--叠加层数	
		
		skill_statetime={15*15},
	},

	kl_juexue1 = {	--混沌剑阵cd
		deccdtime={4108,{{1,0.8*15},{10,8*15}}},
		skill_statetime={-1},
	},
	kl_juexue2 = {	--啸风三连击击中目标增加会心伤害与会心几率
		add_deadlystrike_p1={4109,{{1,3},{10,35}}}, 		--增加会心几率
		add_deadlydmg_p1={4109,{{1,6},{10,60}}},  			--增加会心伤害
		
		skill_statetime={-1},
	},
	
	gb_juexue1 = {	--亢龙有悔cd
		deccdtime={4206,{{1,0.6*15},{10,6*15}}},
		add_usebasedmg_p1={4206,{{1,4},{10,22}}},					--增加亢龙有悔攻击力
		skill_statetime={-1},
	},
	gb_juexue2 = {	--龙战于野附带火球与拉人效果
		addstartskill ={4215,5380,{{1,1},{10,10}}},

		skill_statetime={-1},
		
		userdesc_000={4216,4217},
	},
    gb_juexue2_child1 = --龙战于野_子3--15级
    {
		state_drag_attack={{{1,100},{10,100}},8,70},
		skill_drag_npclen={0},

		missile_hitcount={0,0,3},
    },
    gb_juexue2_child2 = --龙战于野_子4（单体）--15级
    {
		attack_usebasedamage_p={{{1,5},{10,50}}},
		attack_firedamage_v={
			[1]={{1,5*0.95*2},{10,50*0.95*2}},
			[3]={{1,5*1.05*2},{10,50*1.05*2}}
			},	
		missile_hitcount={0,0,1},
    },
	
	wudu_juexue1 = {	--五毒普攻击中叠加会伤
		autoskill={185,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5365},
	},
	wudu_juexue1_child1={
		deadlystrike_damage_p={{{1,1},{10,10}}},
		superposemagic={6},				--叠加层数
		
		skill_statetime={5*15},
	},
	wudu_juexue2 = {	--五毒普攻击中叠加会伤
		autoskill={194,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5381},
	},
	wudu_juexue2_child={
		reduce_cd_time_point1={4334,{{1,15*0.2},{10,15*2}}},  --减少迷心蛊cd
		reduce_cd_time_point2={4339,{{1,15*0.2},{10,15*2}}},  --减少万蛊蚀心cd		
		skill_statetime={1},
	},
	
	cj_juexue1 = {	--藏剑玉泉鱼跃提高会心免伤
		addstartskill ={4408,5366,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5366},
	},
	cj_juexue1_child1={
		deadlystrike_damage_p={{{1,4},{10,40}}},
		weaken_deadlystrike_damage_p={{{1,4},{10,40}}},
		
		skill_statetime={4*15},
	},
	cj_juexue2 = {	--藏剑映波锁澜叠加生命上限并回复生命
		addstartskill ={4423,5382,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5382,5387},
	},
	cj_juexue2_child1={  --叠加生命上限
		lifemax_p={{{1,10},{10,30}}},
		superposemagic={3},				--叠加层数
		
		skill_statetime={5*15},
	},
	cj_juexue2_child2={  --叠加生命上限
		dir_recover_life_pp={{{1,10},{10,100}},1},--生命上限,自身数值
	},	

	cg_juexue1 = {	--长歌.清音长啸和平沙雁落互相强化
		autoskill={186,{{1,1},{10,10}}},
		autoskill2={187,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5367,5368},
	},
	cg_juexue1_child1={	--强化清音长啸,由于清音长啸是hitskill,如果删除buff实际上吃不到加成,所以做的短时间内
		add_usebasedmg_p1={4511,{{1,6},{10,42}}},		--增加攻击力%
		
		skill_statetime={5*15},
	},
	cg_juexue1_child2={ --强化平沙雁落
		add_usebasedmg_p2={4506,{{1,11},{10,110}}},		--增加攻击力%
		
		skill_statetime={5*15},
	},
	cg_juexue2 = {	--长歌.云生结海提升吸血与会心几率
		buff_addition={4509,6,{{1,1},{10,10},{11,10}}},
		addms_dmg_range1={4510,{{1,30},{10,30}}},			--增加子弹范围格子，1格子=0.28米直径

		userdesc_101={{{1,1},{10,18}}},  		--描述用，吸血
		userdesc_102={{{1,20},{10,150}}},		--描述用，增加会心几率值	

		skill_statetime={-1},
	},
	
	ts_juexue1 = {	--天山.提高琴瑟和鸣的伤害
		add_usebasedmg_p1={4635,{{1,35},{10,100},{11,110}}},		--增加攻击力%
		skill_statetime={-1},
	},
	ts_juexue2 = {	--天山.梅花三弄减少银瓶玉碎、空山凝云、水龙吟冷却时间
		deccdtime={4608,{{1,0.5*15},{10,5*15}}},  		--银瓶玉碎

		userdesc_101={4611,{{1,0.5*15},{10,5*15}}},  	--描述用，空山凝云
		userdesc_102={4613,{{1,0.5*15},{10,5*15}}},		--描述用，水龙吟	

		skill_statetime={-1},
	},
	ts_juexue2_child1 = {	
		deccdtime={4611,{{1,0.5*15},{10,5*15}}},  --空山凝云
		skill_statetime={-1},
	},
	ts_juexue2_child2 = {	
		deccdtime={4613,{{1,0.5*15},{10,5*15}}},  --水龙吟
		skill_statetime={-1},
	},
	
	bd_juexue1 = {	--霸刀.浴血蹈锋效果结束回血
		autoskill={188,{{1,1},{10,10}}},
		skill_statetime={-1},
		
		userdesc_000={5369},
	},
	bd_juexue1_child1={ --浴血蹈锋效果结束回血
		dir_recover_life_pp={{{1,60},{10,600}},1},--生命上限,自身数值
	},
	bd_juexue2 = {	--霸刀.挟山超海提升全系抗性
		addstartskill2={5010,5385,{{1,1},{10,10}}},
		
		skill_statetime={-1},
		
		userdesc_000={5385},
	},
	bd_juexue2_child = {	--提升全系抗性
		all_series_resist_p={{{1,20},{10,200}}},
		
		skill_statetime={15*6},
	},
		
	hs_juexue1 = {	--风送紫霞追加斩杀效果
		add_loselife_dmg_p={5216,{{1,6},{10,60}}},
		skill_statetime={-1},
	},
	hs_juexue2 = {	--华山.提高萧史乘龙的伤害
		add_usebasedmg_p1={5207,{{1,6},{10,60}}},		--增加攻击力%
		skill_statetime={-1},
	},

	mj_juexue1={	--明教.降低敌人会心免伤与忽略基础闪避
		add_hitskill_pos1={5512,5560,{{1,1},{10,10}}},
		userdesc_000={5560},		
		skill_statetime={-1},
	},
	mj_juexue1_child={	--明教.降低会心免伤与忽略基础闪避
		weaken_deadlystrike_damage_p={{{1,-8},{10,-75},{11,-75}}},
		ignore_defense_vp={{{1,-16},{10,-150},{11,-150}}},

		skill_statetime={15*2},
	},
	mj_juexue2={	--绝学·不灭之光
		autoskill={195,{{1,1},{10,10},{11,11}}},
		userdesc_000={5562},
		skill_statetime={{{1,-1},{10,-1},{11,-1}}},
	},
	mj_juexue2_child={	--绝学·不灭之光.闪避后回血加攻速
		deadlystrike_p={{{1,3},{10,35},{11,35}}},				--闪避后增加基础会心
		dir_recover_life_pp={{{1,10},{10,100},{11,100}},1},		--生命上限万分比,自身数值
		
		superposemagic={{{1,4},{4,4},{5,4},{9,4},{10,4}}},			--叠加层数
		
		skill_statetime={15*10},									--攻速加成的持续时间
		
		userdesc_101={2*15},				--描述用，不灭之光的触发间隔，实际触发间隔请查看autoskill.tab中的绝学.明教.不灭之光
	},
	
	ds_juexue1 =  --段氏.一阳指.提高一阳指的伤害
	{	
		add_usebasedmg_p1={5606,{{1,11},{10,110}}},			--增加攻击力%
		add_hitskill1={5606,5673,{{1,1},{10,10}}},

		userdesc_000={5673},
		skill_statetime={-1},
	},
	ds_juexue1_child =  --段氏.一阳指.移除增益、气劲
	{	
		rand_ignoreskill={{{1,30},{10,100}},{{1,1},{5,1},{6,2},{10,2}},1},	--概率，数量，类型（skillsetting下定义类型）	
	},
	ds_juexue2 =  --段氏.五罗轻烟
	{
		addstartskill={5609,5675,{{1,1},{10,10}}},
		skill_statetime={-1},
		userdesc_000={5675},
	},
	ds_juexue2_child1 =  --段氏.五罗轻烟.普攻1距离越远伤害高
	{
		add_adddmgbydist={5601,{{1,16},{10,160}}},
		skill_statetime={5*15},
	},
	ds_juexue2_child2 =  --段氏.五罗轻烟.普攻2距离越远伤害高
	{
		add_adddmgbydist={5602,{{1,16},{10,160}}},
		skill_statetime={5*15},
	},
	ds_juexue2_child3 =  --段氏.五罗轻烟.普攻3距离越远伤害高
	{
		add_adddmgbydist={5603,{{1,16},{10,160}}},
		skill_statetime={5*15},
	},
	ds_juexue2_child4 =  --段氏.五罗轻烟.普攻4距离越远伤害高
	{
		add_adddmgbydist={5604,{{1,16},{10,160}}},
		skill_statetime={5*15},
	},

    wh_juexue1 = --万花.万花笔法
    {
		autoskill={127,{{1,1},{10,10}}},  											--普攻有几率减技能CD
		userdesc_101={{{1,8},{10,40}}},												--描述用，减CD几率
		userdesc_000={5873},
		skill_statetime={{{1,-1},{10,-1}}},
    },    
    wh_juexue1_child = --万花.万花笔法
    {
		reduce_cd_time_point1={5805,{{1,15*0.2},{10,15*0.2}}},
		reduce_cd_time_point2={5808,{{1,15*0.2},{10,15*0.2}}},
		reduce_cd_time_point3={5810,{{1,15*0.2},{10,15*0.2}}},
		reduce_cd_time_point4={5812,{{1,15*0.2},{10,15*0.2}}},
		skill_statetime={1},
    },
	wh_juexue2 =  --万花.墨守成规
	{
		addstartskill={5832,5875,{{1,1},{10,10}}},
		skill_statetime={-1},
		userdesc_000={5875},
	},
    wh_juexue2_child = --万花.墨守成规_子
    {
		melee_dmg_p={{{1,-1},{10,-5}}},
		remote_dmg_p={{{1,-1},{10,-5}}},
		userdesc_101={{{1,-10},{10,-50}}},
		superposemagic={{{1,5},{10,5},{11,5}}},				--叠加层数
		skill_statetime={12*15},
    },

	ym_juexue1 =  --杨门.枪,奇门盾
	{
		addstartskill={5420,5421,{{1,1},{10,10}}},
		skill_statetime={-1},
		userdesc_000={5421},
	},
    ym_juexue1_child = --杨门.枪,奇门盾造伤害与减敌方BUFF
    {
		attack_usebasedamage_p={{{1,10},{10,100}}},
		state_fixed_attack={{{1,6},{10,60}},{{1,1*15},{10,1*15}}},

		lifereplenish_p={{{1,-5},{10,-30}}},
		physics_potentialdamage_p={{{1,-10},{10,-60}}},

		missile_hitcount={6,0,0},

		skill_statetime={{{1,15*2},{10,15*2},{11,15*2}}},
    },
	ym_juexue2 =  --杨门.绝学·横枪跃马
	{
		autoskill={35,{{1,1},{10,10}}}, 
		userdesc_101={{{1,60},{10,60}}},		--几率
		userdesc_102={{{1,15*2},{10,15*2}}},	--间隔
		userdesc_000={5423},

		skill_statetime={-1},
	},
    ym_juexue2_child = {--杨门.绝学·横枪跃马.受击减枪技能CD		
		reduce_cd_time1={5469,{{1,1*15},{10,2*15}}},			--奔狼枪
		reduce_cd_time2={5471,{{1,1*15},{10,3*15}}},			--奇门盾
		reduce_cd_time3={5473,{{1,1*15},{10,2.5*15}}},			--横扫千军
		skill_statetime={1},
    },
}

FightSkill:AddMagicData(tb)