----------------------------------------------------
-- 此文件由数据工具生成
-- 章节副本配置数据--day_goals_second_data.xml
--------------------------------------

Config = Config or {} 
Config.DayGoalsSecondData = Config.DayGoalsSecondData or {}

-- -------------------constant_start-------------------
Config.DayGoalsSecondData.data_constant_length = 3
Config.DayGoalsSecondData.data_constant = {
	["over_time"] = {label='over_time', val=7, desc="结束时间"},
	["task_total"] = {label='task_total', val=88, desc="全目标总任务数量"},
	["rule_desc"] = {label='rule_desc', val=1, desc="1.全民探索根据天数开放，玩家完成任务后，可在第七天开始领取终极大奖；\n2.全民探索内的任务均从活动开启时计算；\n3.活动7天后（即第8天0点）关闭，奖励只可领取一次，领取后继续完成任务不可补充领取奖励;(福利领取、半价折扣不计算在内)"}
}
-- -------------------constant_end---------------------


-- -------------------welfarecollection_start-------------------
Config.DayGoalsSecondData.data_welfarecollection_length = 7
Config.DayGoalsSecondData.data_welfarecollection = {
	[7] = {{goal_id=80000, day=7, desc="登陆1次", condition={{'login',7}}, show_icon="", award1={{2,20}}},
		{goal_id=80004, day=7, desc="等级达到45级", condition={{'evt_levup',45}}, show_icon="", award1={{2,20},{1,35000}}}
	},
	[6] = {{goal_id=70000, day=6, desc="登陆1次", condition={{'login',6}}, show_icon="", award1={{2,20}}},
		{goal_id=70004, day=6, desc="等级达到44级", condition={{'evt_levup',44}}, show_icon="", award1={{2,20},{1,30000}}}
	},
	[5] = {{goal_id=60000, day=5, desc="登陆1次", condition={{'login',5}}, show_icon="", award1={{2,20}}},
		{goal_id=60004, day=5, desc="等级达到43级", condition={{'evt_levup',43}}, show_icon="", award1={{2,20},{1,25000}}}
	},
	[4] = {{goal_id=50000, day=4, desc="登陆1次", condition={{'login',4}}, show_icon="", award1={{2,20}}},
		{goal_id=50004, day=4, desc="等级达到42级", condition={{'evt_levup',42}}, show_icon="", award1={{2,20},{1,20000}}}
	},
	[3] = {{goal_id=40000, day=3, desc="登陆1次", condition={{'login',3}}, show_icon="", award1={{2,20}}},
		{goal_id=40004, day=3, desc="等级达到41级", condition={{'evt_levup',41}}, show_icon="", award1={{2,20},{1,18000}}}
	},
	[2] = {{goal_id=30000, day=2, desc="登陆1次", condition={{'login',2}}, show_icon="", award1={{2,20}}},
		{goal_id=30004, day=2, desc="等级达到40级", condition={{'evt_levup',40}}, show_icon="", award1={{2,20},{1,15000}}}
	},
	[1] = {{goal_id=20000, day=1, desc="登陆1次", condition={{'login',1}}, show_icon="", award1={{2,20}}},
		{goal_id=20004, day=1, desc="等级达到39级", condition={{'evt_levup',39}}, show_icon="", award1={{2,20},{1,10000}}}
	},
}
-- -------------------welfarecollection_end---------------------


-- -------------------growthtarget_start-------------------
Config.DayGoalsSecondData.data_growthtarget_length = 7
Config.DayGoalsSecondData.data_growthtarget = {
	[7] = {{goal_id=18010, day=7, target_type=1, type_name="神格消耗", desc="神格消耗5000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=5000,param={}}}, show_icon="shenge", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=18020, day=7, target_type=1, type_name="神格消耗", desc="神格消耗10000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=10000,param={}}}, show_icon="shenge", award1={{2,20},{10,2000}}, lev=1},
		{goal_id=18030, day=7, target_type=1, type_name="神格消耗", desc="神格消耗15000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=15000,param={}}}, show_icon="shenge", award1={{2,20},{10,5000}}, lev=1},
		{goal_id=18040, day=7, target_type=1, type_name="神格消耗", desc="神格消耗20000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=20000,param={}}}, show_icon="shenge", award1={{2,20},{10201,1}}, lev=1},
		{goal_id=18050, day=7, target_type=1, type_name="神格消耗", desc="神格消耗25000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=25000,param={}}}, show_icon="shenge", award1={{2,20},{10201,1}}, lev=1},
		{goal_id=18060, day=7, target_type=1, type_name="神格消耗", desc="神格消耗30000点", progress={{cli_label="evt_loss_hero_soul",target=0,target_val=30000,param={}}}, show_icon="shenge", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=18070, day=7, target_type=2, type_name="钻石消耗", desc="消耗1000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=1000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=18080, day=7, target_type=2, type_name="钻石消耗", desc="消耗2000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=2000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=18090, day=7, target_type=2, type_name="钻石消耗", desc="消耗4000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=4000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=18100, day=7, target_type=2, type_name="钻石消耗", desc="消耗8000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=8000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=18110, day=7, target_type=2, type_name="钻石消耗", desc="消耗12000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=12000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=18120, day=7, target_type=2, type_name="钻石消耗", desc="消耗15000钻", progress={{cli_label="evt_loss_gold_day_goals2",target=0,target_val=15000,param={}}}, show_icon="shenmi", award1={{2,20},{10,1000}}, lev=17}
	},
	[6] = {{goal_id=17010, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到150000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',150000}}}}, show_icon="buzhen", award1={{30111,2},{2,20}}, lev=26},
		{goal_id=17020, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到170000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',170000}}}}, show_icon="buzhen", award1={{30111,2},{2,20}}, lev=26},
		{goal_id=17030, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到200000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',200000}}}}, show_icon="buzhen", award1={{30111,2},{2,20}}, lev=26},
		{goal_id=17040, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到230000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',230000}}}}, show_icon="buzhen", award1={{10200,1},{2,20}}, lev=26},
		{goal_id=17050, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到250000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',250000}}}}, show_icon="buzhen", award1={{10200,1},{2,20}}, lev=26},
		{goal_id=17060, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到280000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',280000}}}}, show_icon="buzhen", award1={{10210,1},{2,20}}, lev=26},
		{goal_id=17070, day=6, target_type=1, type_name="战力提升", desc="布阵战力达到300000", progress={{cli_label="evt_power",target=3,target_val=1,param={{'power',300000}}}}, show_icon="buzhen", award1={{30110,3},{2,20}}, lev=26},
		{goal_id=17080, day=6, target_type=2, type_name="实力提升", desc="高级召唤10次", progress={{cli_label="evt_partner_summon",target=0,target_val=10,param={{'type',2}}}}, show_icon="summon", award1={{2,20},{10,1000}}, lev=25},
		{goal_id=17100, day=6, target_type=2, type_name="实力提升", desc="高级召唤30次", progress={{cli_label="evt_partner_summon",target=0,target_val=30,param={{'type',2}}}}, show_icon="summon", award1={{2,20},{10,1000}}, lev=25},
		{goal_id=17120, day=6, target_type=2, type_name="实力提升", desc="高级召唤60次", progress={{cli_label="evt_partner_summon",target=0,target_val=60,param={{'type',2}}}}, show_icon="summon", award1={{2,30},{10,1500}}, lev=25},
		{goal_id=17130, day=6, target_type=2, type_name="实力提升", desc="高级召唤90次", progress={{cli_label="evt_partner_summon",target=0,target_val=90,param={{'type',2}}}}, show_icon="summon", award1={{2,50},{10,3000}}, lev=25},
		{goal_id=17140, day=6, target_type=2, type_name="实力提升", desc="神器高级铸造5次", progress={{cli_label="evt_artifact_summon",target=0,target_val=5,param={{'type',2}}}}, show_icon="shenqi_zhuzao", award1={{2,20},{1,30000}}, lev=28},
		{goal_id=17150, day=6, target_type=2, type_name="实力提升", desc="神器高级铸造10次", progress={{cli_label="evt_artifact_summon",target=0,target_val=10,param={{'type',2}}}}, show_icon="shenqi_zhuzao", award1={{2,20},{1,50000}}, lev=28},
		{goal_id=17160, day=6, target_type=2, type_name="实力提升", desc="神器高级铸造20次", progress={{cli_label="evt_artifact_summon",target=0,target_val=20,param={{'type',2}}}}, show_icon="shenqi_zhuzao", award1={{2,20},{10207,1}}, lev=28},
		{goal_id=17170, day=6, target_type=2, type_name="实力提升", desc="神器高级铸造30次", progress={{cli_label="evt_artifact_summon",target=0,target_val=30,param={{'type',2}}}}, show_icon="shenqi_zhuzao", award1={{2,20},{10207,1}}, lev=28}
	},
	[5] = {{goal_id=16010, day=5, target_type=1, type_name="副本通关", desc="通关冒险难度巨龙", progress={{cli_label="evt_dungeon_pass",target=6,target_val=1,param={{'difficulty',3}}}}, show_icon="dragon", award1={{2,10},{10,1000}}, lev=28},
		{goal_id=16020, day=5, target_type=1, type_name="副本通关", desc="通关困难难度巨龙", progress={{cli_label="evt_dungeon_pass",target=6,target_val=1,param={{'difficulty',4}}}}, show_icon="dragon", award1={{2,20},{10,1000}}, lev=28},
		{goal_id=16030, day=5, target_type=1, type_name="副本通关", desc="通关王者难度巨龙", progress={{cli_label="evt_dungeon_pass",target=6,target_val=1,param={{'difficulty',5}}}}, show_icon="dragon", award1={{2,20},{10,1500}}, lev=28},
		{goal_id=16040, day=5, target_type=1, type_name="副本通关", desc="通关冒险难度凤凰", progress={{cli_label="evt_dungeon_pass",target=5,target_val=1,param={{'difficulty',3}}}}, show_icon="titan", award1={{2,30},{10,1500}}, lev=28},
		{goal_id=16050, day=5, target_type=1, type_name="副本通关", desc="通关困难难度凤凰", progress={{cli_label="evt_dungeon_pass",target=5,target_val=1,param={{'difficulty',4}}}}, show_icon="titan", award1={{2,20},{10,1000}}, lev=28},
		{goal_id=16060, day=5, target_type=1, type_name="副本通关", desc="通关王者难度凤凰", progress={{cli_label="evt_dungeon_pass",target=5,target_val=1,param={{'difficulty',5}}}}, show_icon="titan", award1={{2,50},{10,5000}}, lev=28},
		{goal_id=16070, day=5, target_type=2, type_name="竞技挑战", desc="参加12次天梯对决", progress={{cli_label="evt_sky_ladder_fight",target=0,target_val=12,param={}}}, show_icon="tianti", award1={{2,20},{10,5000}}, lev=28},
		{goal_id=16071, day=5, target_type=2, type_name="竞技挑战", desc="参加24次天梯对决", progress={{cli_label="evt_sky_ladder_fight",target=0,target_val=24,param={}}}, show_icon="tianti", award1={{2,20},{10,5000}}, lev=28},
		{goal_id=16080, day=5, target_type=2, type_name="竞技挑战", desc="参加3次众神战场", progress={{cli_label="evt_zs_war_fight",target=0,target_val=3,param={}}}, show_icon="zhongshen", award1={{2,20},{10,5000}}, lev=28},
		{goal_id=16081, day=5, target_type=2, type_name="竞技挑战", desc="参加5次众神战场", progress={{cli_label="evt_zs_war_fight",target=0,target_val=5,param={}}}, show_icon="zhongshen", award1={{2,20},{10,5000}}, lev=28}
	},
	[4] = {{goal_id=15010, day=4, target_type=1, type_name="诸神小怪", desc="击败大陆野怪20次", progress={{cli_label="evt_combat_start",target=0,target_val=20,param={{'world_unit_type',3}}}}, show_icon="zhuxiao", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15020, day=4, target_type=1, type_name="诸神小怪", desc="击败大陆野怪40次", progress={{cli_label="evt_combat_start",target=0,target_val=40,param={{'world_unit_type',3}}}}, show_icon="zhuxiao", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15030, day=4, target_type=1, type_name="诸神小怪", desc="击败大陆野怪60次", progress={{cli_label="evt_combat_start",target=0,target_val=60,param={{'world_unit_type',3}}}}, show_icon="zhuxiao", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15040, day=4, target_type=1, type_name="诸神小怪", desc="击败大陆野怪80次", progress={{cli_label="evt_combat_start",target=0,target_val=80,param={{'world_unit_type',3}}}}, show_icon="zhuxiao", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15050, day=4, target_type=1, type_name="诸神小怪", desc="击败大陆野怪100次", progress={{cli_label="evt_combat_start",target=0,target_val=100,param={{'world_unit_type',3}}}}, show_icon="zhuxiao", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15060, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss1次", progress={{cli_label="evt_combat_start",target=0,target_val=1,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15070, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss3次", progress={{cli_label="evt_combat_start",target=0,target_val=3,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15080, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss6次", progress={{cli_label="evt_combat_start",target=0,target_val=6,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=17},
		{goal_id=15090, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss9次", progress={{cli_label="evt_combat_start",target=0,target_val=9,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=18},
		{goal_id=15100, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss15次", progress={{cli_label="evt_combat_start",target=0,target_val=15,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=18},
		{goal_id=15110, day=4, target_type=2, type_name="诸神boss", desc="击败大陆boss25次", progress={{cli_label="evt_combat_start",target=0,target_val=25,param={{'world_unit_type',4}}}}, show_icon="zhuboss", award1={{2,20},{10,1000}}, lev=18}
	},
	[3] = {{goal_id=14010, day=3, target_type=1, type_name="装备培养", desc="装备洗练5次", progress={{cli_label="evt_eqm_wash",target=0,target_val=5,param={}}}, show_icon="partner_jinjie", award1={{2,20},{10214,5}}, lev=1},
		{goal_id=14030, day=3, target_type=1, type_name="装备培养", desc="装备洗练10次", progress={{cli_label="evt_eqm_wash",target=0,target_val=10,param={}}}, show_icon="partner_jinjie", award1={{2,20},{10214,5}}, lev=1},
		{goal_id=14040, day=3, target_type=1, type_name="装备培养", desc="装备洗练20次", progress={{cli_label="evt_eqm_wash",target=0,target_val=20,param={}}}, show_icon="partner_jinjie", award1={{2,20},{10214,10}}, lev=1},
		{goal_id=14050, day=3, target_type=1, type_name="装备培养", desc="装备洗练30次", progress={{cli_label="evt_eqm_wash",target=0,target_val=30,param={}}}, show_icon="partner_jinjie", award1={{2,50},{10214,10}}, lev=1},
		{goal_id=14061, day=3, target_type=1, type_name="装备培养", desc="装备精炼1次", progress={{cli_label="evt_eqm_refine",target=0,target_val=1,param={}}}, show_icon="partner_zb", award1={{2,20},{10200,1}}, lev=28},
		{goal_id=14062, day=3, target_type=1, type_name="装备培养", desc="装备精炼3次", progress={{cli_label="evt_eqm_refine",target=0,target_val=3,param={}}}, show_icon="partner_zb", award1={{2,20},{10200,1}}, lev=28},
		{goal_id=14065, day=3, target_type=1, type_name="英雄培养", desc="制作1次光环", progress={{cli_label="evt_halo_compose",target=0,target_val=1,param={}}}, show_icon="yjs_halo", award1={{15002,4},{15010,2}}, lev=28},
		{goal_id=14066, day=3, target_type=1, type_name="英雄培养", desc="光环精炼2次", progress={{cli_label="evt_halo_refine",target=0,target_val=2,param={}}}, show_icon="partner_jinjie", award1={{15002,2},{15010,1}}, lev=28},
		{goal_id=14070, day=3, target_type=2, type_name="异界裂缝", desc="通关异界裂缝3次", progress={{cli_label="evt_farplane_fight",target=0,target_val=3,param={}}}, show_icon="yijie", award1={{2,20},{10,1000}}, lev=22},
		{goal_id=14080, day=3, target_type=2, type_name="异界裂缝", desc="通关异界裂缝6次", progress={{cli_label="evt_farplane_fight",target=0,target_val=6,param={}}}, show_icon="yijie", award1={{2,20},{10,1000}}, lev=22},
		{goal_id=14090, day=3, target_type=2, type_name="异界裂缝", desc="通关异界裂缝9次", progress={{cli_label="evt_farplane_fight",target=0,target_val=9,param={}}}, show_icon="yijie", award1={{2,40},{10,1000}}, lev=22},
		{goal_id=14100, day=3, target_type=2, type_name="异界裂缝", desc="通关异界裂缝12次", progress={{cli_label="evt_farplane_fight",target=0,target_val=12,param={}}}, show_icon="yijie", award1={{2,40},{10,1000}}, lev=22}
	},
	[2] = {{goal_id=13010, day=2, target_type=1, type_name="英雄阶级", desc="1个英雄达到紫色+3", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'quality',9}}}}, show_icon="partner_jinjie", award1={{30111,2},{10,1000}}, lev=1},
		{goal_id=13020, day=2, target_type=1, type_name="英雄阶级", desc="3个英雄达到紫色+3", progress={{cli_label="evt_partner",target=0,target_val=3,param={{'quality',9}}}}, show_icon="partner_jinjie", award1={{30111,3},{10,1000}}, lev=1},
		{goal_id=13030, day=2, target_type=1, type_name="英雄阶级", desc="5个英雄达到紫色+3", progress={{cli_label="evt_partner",target=0,target_val=3,param={{'quality',9}}}}, show_icon="partner_jinjie", award1={{30110,2},{10,1000}}, lev=1},
		{goal_id=13040, day=2, target_type=1, type_name="英雄阶级", desc="1个英雄达到橙色", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'quality',10}}}}, show_icon="partner_jinjie", award1={{30110,3},{10,2000}}, lev=1},
		{goal_id=13050, day=2, target_type=1, type_name="英雄阶级", desc="3个英雄达到橙色", progress={{cli_label="evt_partner",target=0,target_val=3,param={{'quality',10}}}}, show_icon="partner_jinjie", award1={{30110,3},{10,2000}}, lev=1},
		{goal_id=13060, day=2, target_type=1, type_name="英雄阶级", desc="5个英雄达到橙色", progress={{cli_label="evt_partner",target=0,target_val=5,param={{'quality',10}}}}, show_icon="partner_jinjie", award1={{2,20},{10302,5}}, lev=16},
		{goal_id=13070, day=2, target_type=2, type_name="英雄培养", desc="拥有5个3星", progress={{cli_label="evt_partner",target=0,target_val=5,param={{'star',3}}}}, show_icon="partner_xingji", award1={{2,20},{10302,5}}, lev=16},
		{goal_id=13080, day=2, target_type=2, type_name="英雄培养", desc="拥有1个4星", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'star',4}}}}, show_icon="partner_xingji", award1={{2,20},{10302,5}}, lev=16},
		{goal_id=13090, day=2, target_type=2, type_name="英雄培养", desc="拥有2个4星", progress={{cli_label="evt_partner",target=0,target_val=2,param={{'star',4}}}}, show_icon="partner_xingji", award1={{2,20},{10200,1}}, lev=16},
		{goal_id=13100, day=2, target_type=2, type_name="英雄培养", desc="拥有3个4星", progress={{cli_label="evt_partner",target=0,target_val=3,param={{'star',4}}}}, show_icon="partner_xingji", award1={{2,30},{10200,2}}, lev=16},
		{goal_id=13110, day=2, target_type=2, type_name="英雄培养", desc="拥有1个5星", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'star',5}}}}, show_icon="partner_xingji", award1={{2,50},{10200,5}}, lev=16},
		{goal_id=13120, day=2, target_type=2, type_name="英雄培养", desc="拥有1个6星", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'star',6}}}}, show_icon="partner_xingji", award1={{2,100},{10201,1}}, lev=16},
		{goal_id=13130, day=2, target_type=2, type_name="英雄培养", desc="1个英雄达到觉醒+1", progress={{cli_label="evt_partner",target=0,target_val=1,param={{'awaken',1}}}}, show_icon="partner_juexing", award1={{2,20},{15000,5}}, lev=28},
		{goal_id=13140, day=2, target_type=2, type_name="英雄培养", desc="3个英雄达到觉醒+1", progress={{cli_label="evt_partner",target=0,target_val=3,param={{'awaken',1}}}}, show_icon="partner_juexing", award1={{2,20},{15000,10}}, lev=28},
		{goal_id=13180, day=2, target_type=2, type_name="英雄培养", desc="英雄神器强化5次", progress={{cli_label="evt_artifact_enhance",target=0,target_val=5,param={}}}, show_icon="shenqi", award1={{2,20},{15041,1}}, lev=28},
		{goal_id=13181, day=2, target_type=2, type_name="英雄培养", desc="英雄神器强化10次", progress={{cli_label="evt_artifact_enhance",target=0,target_val=10,param={}}}, show_icon="shenqi", award1={{2,20},{15041,1}}, lev=28}
	},
	[1] = {{goal_id=11010, day=1, target_type=1, type_name="剧情副本", desc="通关第七章北裂境平原", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',10708}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11020, day=1, target_type=1, type_name="剧情副本", desc="通关第八章落日森林", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',10808}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11030, day=1, target_type=1, type_name="剧情副本", desc="通关第九章叹息山脉", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',10908}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11040, day=1, target_type=1, type_name="剧情副本", desc="通关第十章冰冠冰川", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',11008}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11050, day=1, target_type=1, type_name="剧情副本", desc="通关第十一章萨隆米亚神庙", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',11108}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11060, day=1, target_type=1, type_name="剧情副本", desc="通关第十二章特洛伊群岛", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',11208}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11070, day=1, target_type=2, type_name="地下城副本", desc="通关第七章龙鸣之地", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',20705}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11080, day=1, target_type=2, type_name="地下城副本", desc="通关第八章地下陵墓", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',20805}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11090, day=1, target_type=2, type_name="地下城副本", desc="通关第九章炼狱熔炉", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',20905}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11100, day=1, target_type=2, type_name="地下城副本", desc="通关第十章烈焰峡谷", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',21005}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11110, day=1, target_type=2, type_name="地下城副本", desc="通关第十一章幽冥神庙", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',21105}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1},
		{goal_id=11120, day=1, target_type=2, type_name="地下城副本", desc="通关第十二章地心熔岩", progress={{cli_label="evt_dungeon_pass",target=3,target_val=1,param={{'chapter',21205}}}}, show_icon="juqing", award1={{2,20},{10,1000}}, lev=1}
	},
}
-- -------------------growthtarget_end---------------------


-- -------------------halfdiscount_start-------------------
Config.DayGoalsSecondData.data_halfdiscount_length = 7
Config.DayGoalsSecondData.data_halfdiscount = {
	[1] = {day=1, award1={{10212,1},{10211,1},{10401,1}}, award1_name="符石礼包", price1=1800, price2=900, icon="action_gift_4"},
	[2] = {day=2, award1={{15000,100}}, award1_name="觉醒礼包", price1=1000, price2=500, icon="action_gift_12"},
	[3] = {day=3, award1={{10214,30},{80005,1}}, award1_name="洗练精炼礼包", price1=1200, price2=600, icon="action_gift_14"},
	[4] = {day=4, award1={{10466,1},{15010,2},{15002,4}}, award1_name="光环礼包", price1=2000, price2=1000, icon="action_gift_13"},
	[5] = {day=5, award1={{10207,10}}, award1_name="神器铸造礼包", price1=1500, price2=750, icon="action_gift_11"},
	[6] = {day=6, award1={{10464,1},{15042,10}}, award1_name="随机三星神器礼包", price1=3200, price2=1600, icon="action_gift_10"},
	[7] = {day=7, award1={{13,4800}}, award1_name="神格积分礼包", price1=2400, price2=1200, icon="action_gift_15"}
}
-- -------------------halfdiscount_end---------------------


-- -------------------all_target_start-------------------
Config.DayGoalsSecondData.data_all_target_length = 1
Config.DayGoalsSecondData.data_all_target = {
	[88] = {id=88, award={{20084,80}}}
}
-- -------------------all_target_end---------------------
