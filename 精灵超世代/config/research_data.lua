----------------------------------------------------
-- 此文件由数据工具生成
-- 副本配置数据--research_data.xml
--------------------------------------

Config = Config or {} 
Config.ResearchData = Config.ResearchData or {}

-- -------------------research_start-------------------
Config.ResearchData.data_research_length = 10
Config.ResearchData.data_research = {
	[1] = {lv=1, limit_lv=0, limit_count=0, expend=0},
	[2] = {lv=2, limit_lv=1, limit_count=3, expend=200000},
	[3] = {lv=3, limit_lv=2, limit_count=4, expend=300000},
	[4] = {lv=4, limit_lv=3, limit_count=5, expend=400000},
	[5] = {lv=5, limit_lv=4, limit_count=6, expend=500000},
	[6] = {lv=6, limit_lv=5, limit_count=6, expend=600000},
	[7] = {lv=7, limit_lv=6, limit_count=6, expend=700000},
	[8] = {lv=8, limit_lv=7, limit_count=6, expend=800000},
	[9] = {lv=9, limit_lv=8, limit_count=6, expend=900000},
	[10] = {lv=10, limit_lv=9, limit_count=6, expend=1000000}
}
-- -------------------research_end---------------------


-- -------------------attrLev_start-------------------
Config.ResearchData.data_attrLev_length = 6
Config.ResearchData.data_attrLev = {
	[1] = {
		[1] = {id=1, lv=1, attr={{'atk_per',50}}, expend={{1,10000},{6,100}}, name="御火术", desc="所有英雄攻击额外加成5%"},
		[2] = {id=1, lv=2, attr={{'atk_per',80}}, expend={{1,25000},{6,200}}, name="烈火术", desc="所有英雄攻击额外加成8%"},
		[3] = {id=1, lv=3, attr={{'atk_per',110}}, expend={{1,50000},{6,300}}, name="焰火环", desc="所有英雄攻击额外加成11%"},
		[4] = {id=1, lv=4, attr={{'atk_per',140}}, expend={{1,75000},{6,400}}, name="炽炎波", desc="所有英雄攻击额外加成14%"},
		[5] = {id=1, lv=5, attr={{'atk_per',170}}, expend={{1,100000},{6,500}}, name="炙炎旋流", desc="所有英雄攻击额外加成17%"},
		[6] = {id=1, lv=6, attr={{'atk_per',200}}, expend={{1,150000},{6,600}}, name="火山熔岩", desc="所有英雄攻击额外加成20%"},
		[7] = {id=1, lv=7, attr={{'atk_per',230}}, expend={{1,600000},{6,700}}, name="烈日蚀晴", desc="所有英雄攻击额外加成23%"},
		[8] = {id=1, lv=8, attr={{'atk_per',260}}, expend={{1,400000},{6,800}}, name="地狱烈焰", desc="所有英雄攻击额外加成26%"},
		[9] = {id=1, lv=9, attr={{'atk_per',290}}, expend={{1,600000},{6,900}}, name="烈火熊熊", desc="所有英雄攻击额外加成29%"},
		[10] = {id=1, lv=10, attr={{'atk_per',320}}, expend={{1,800000},{6,1000}}, name="末日风暴", desc="所有英雄攻击额外加成32%"},
	},
	[2] = {
		[1] = {id=2, lv=1, attr={{'def_s_per',50}}, expend={{1,10000},{6,100}}, name="御水术", desc="所有英雄法术防御额外加成5%"},
		[2] = {id=2, lv=2, attr={{'def_s_per',80}}, expend={{1,25000},{6,200}}, name="水泡术", desc="所有英雄法术防御额外加成8%"},
		[3] = {id=2, lv=3, attr={{'def_s_per',110}}, expend={{1,50000},{6,300}}, name="流水盾", desc="所有英雄法术防御额外加成11%"},
		[4] = {id=2, lv=4, attr={{'def_s_per',140}}, expend={{1,75000},{6,400}}, name="寒冰墙", desc="所有英雄法术防御额外加成14%"},
		[5] = {id=2, lv=5, attr={{'def_s_per',170}}, expend={{1,100000},{6,500}}, name="冰霜护盾", desc="所有英雄法术防御额外加成17%"},
		[6] = {id=2, lv=6, attr={{'def_s_per',200}}, expend={{1,150000},{6,600}}, name="水纹护体", desc="所有英雄法术防御额外加成20%"},
		[7] = {id=2, lv=7, attr={{'def_s_per',230}}, expend={{1,600000},{6,700}}, name="瀑布冲击", desc="所有英雄法术防御额外加成23%"},
		[8] = {id=2, lv=8, attr={{'def_s_per',260}}, expend={{1,400000},{6,800}}, name="冰天雪地", desc="所有英雄法术防御额外加成26%"},
		[9] = {id=2, lv=9, attr={{'def_s_per',290}}, expend={{1,600000},{6,900}}, name="雪地冰雕", desc="所有英雄法术防御额外加成29%"},
		[10] = {id=2, lv=10, attr={{'def_s_per',320}}, expend={{1,800000},{6,1000}}, name="绝对零度", desc="所有英雄法术防御额外加成32%"},
	},
	[3] = {
		[1] = {id=3, lv=1, attr={{'def_p_per',50}}, expend={{1,10000},{6,100}}, name="御土术", desc="所有英雄物理防御额外加成5%"},
		[2] = {id=3, lv=2, attr={{'def_p_per',80}}, expend={{1,25000},{6,200}}, name="土墙术", desc="所有英雄物理防御额外加成8%"},
		[3] = {id=3, lv=3, attr={{'def_p_per',110}}, expend={{1,50000},{6,300}}, name="岩石盾", desc="所有英雄物理防御额外加成11%"},
		[4] = {id=3, lv=4, attr={{'def_p_per',140}}, expend={{1,75000},{6,400}}, name="流沙迷雾", desc="所有英雄物理防御额外加成14%"},
		[5] = {id=3, lv=5, attr={{'def_p_per',170}}, expend={{1,100000},{6,500}}, name="护体石肤", desc="所有英雄物理防御额外加成17%"},
		[6] = {id=3, lv=6, attr={{'def_p_per',200}}, expend={{1,150000},{6,600}}, name="火山熔岩", desc="所有英雄物理防御额外加成20%"},
		[7] = {id=3, lv=7, attr={{'def_p_per',230}}, expend={{1,600000},{6,700}}, name="元素守护", desc="所有英雄物理防御额外加成23%"},
		[8] = {id=3, lv=8, attr={{'def_p_per',260}}, expend={{1,400000},{6,800}}, name="石化森林", desc="所有英雄物理防御额外加成26%"},
		[9] = {id=3, lv=9, attr={{'def_p_per',290}}, expend={{1,600000},{6,900}}, name="绝对防御", desc="所有英雄物理防御额外加成29%"},
		[10] = {id=3, lv=10, attr={{'def_p_per',320}}, expend={{1,800000},{6,1000}}, name="叹息之墙", desc="所有英雄物理防御额外加成32%"},
	},
	[4] = {
		[1] = {id=4, lv=1, attr={{'hp_max_per',50}}, expend={{1,10000},{6,100}}, name="御木术", desc="所有英雄气血上限额外加成5%"},
		[2] = {id=4, lv=2, attr={{'hp_max_per',80}}, expend={{1,25000},{6,200}}, name="叶舞术", desc="所有英雄气血上限额外加成8%"},
		[3] = {id=4, lv=3, attr={{'hp_max_per',110}}, expend={{1,50000},{6,300}}, name="护林阵", desc="所有英雄气血上限额外加成11%"},
		[4] = {id=4, lv=4, attr={{'hp_max_per',140}}, expend={{1,75000},{6,400}}, name="护心花", desc="所有英雄气血上限额外加成14%"},
		[5] = {id=4, lv=5, attr={{'hp_max_per',170}}, expend={{1,100000},{6,500}}, name="藤蔓缠绕", desc="所有英雄气血上限额外加成17%"},
		[6] = {id=4, lv=6, attr={{'hp_max_per',200}}, expend={{1,150000},{6,600}}, name="落地生根", desc="所有英雄气血上限额外加成20%"},
		[7] = {id=4, lv=7, attr={{'hp_max_per',230}}, expend={{1,600000},{6,700}}, name="众生复苏", desc="所有英雄气血上限额外加成23%"},
		[8] = {id=4, lv=8, attr={{'hp_max_per',260}}, expend={{1,400000},{6,800}}, name="森林之歌", desc="所有英雄气血上限额外加成26%"},
		[9] = {id=4, lv=9, attr={{'hp_max_per',290}}, expend={{1,600000},{6,900}}, name="万木守护", desc="所有英雄气血上限额外加成29%"},
		[10] = {id=4, lv=10, attr={{'hp_max_per',320}}, expend={{1,800000},{6,1000}}, name="生生不息", desc="所有英雄气血上限额外加成32%"},
	},
	[5] = {
		[1] = {id=5, lv=1, attr={{'crit_ratio',50}}, expend={{1,10000},{6,100}}, name="御雷术", desc="所有英雄暴击伤害额外加成5%"},
		[2] = {id=5, lv=2, attr={{'crit_ratio',80}}, expend={{1,25000},{6,200}}, name="闪电箭", desc="所有英雄暴击伤害额外加成8%"},
		[3] = {id=5, lv=3, attr={{'crit_ratio',110}}, expend={{1,50000},{6,300}}, name="静电术", desc="所有英雄暴击伤害额外加成11%"},
		[4] = {id=5, lv=4, attr={{'crit_ratio',140}}, expend={{1,75000},{6,400}}, name="雷爆术", desc="所有英雄暴击伤害额外加成14%"},
		[5] = {id=5, lv=5, attr={{'crit_ratio',170}}, expend={{1,100000},{6,500}}, name="天雷闪", desc="所有英雄暴击伤害额外加成17%"},
		[6] = {id=5, lv=6, attr={{'crit_ratio',200}}, expend={{1,150000},{6,600}}, name="雷鸣爆弹", desc="所有英雄暴击伤害额外加成20%"},
		[7] = {id=5, lv=7, attr={{'crit_ratio',230}}, expend={{1,600000},{6,700}}, name="雷动九天", desc="所有英雄暴击伤害额外加成23%"},
		[8] = {id=5, lv=8, attr={{'crit_ratio',260}}, expend={{1,400000},{6,800}}, name="连锁闪电", desc="所有英雄暴击伤害额外加成26%"},
		[9] = {id=5, lv=9, attr={{'crit_ratio',290}}, expend={{1,600000},{6,900}}, name="闪电风暴", desc="所有英雄暴击伤害额外加成29%"},
		[10] = {id=5, lv=10, attr={{'crit_ratio',320}}, expend={{1,800000},{6,1000}}, name="天罚", desc="所有英雄暴击伤害额外加成32%"},
	},
	[6] = {
		[1] = {id=6, lv=1, attr={{'speed',5}}, expend={{1,10000},{6,100}}, name="御风术", desc="所有英雄速度额外增加5"},
		[2] = {id=6, lv=2, attr={{'speed',8}}, expend={{1,25000},{6,200}}, name="加速术", desc="所有英雄速度额外增加8"},
		[3] = {id=6, lv=3, attr={{'speed',11}}, expend={{1,50000},{6,300}}, name="飞行术", desc="所有英雄速度额外增加11"},
		[4] = {id=6, lv=4, attr={{'speed',14}}, expend={{1,75000},{6,400}}, name="风行步", desc="所有英雄速度额外增加14"},
		[5] = {id=6, lv=5, attr={{'speed',17}}, expend={{1,100000},{6,500}}, name="空气盾", desc="所有英雄速度额外增加17"},
		[6] = {id=6, lv=6, attr={{'speed',20}}, expend={{1,150000},{6,600}}, name="风卷残云", desc="所有英雄速度额外增加20"},
		[7] = {id=6, lv=7, attr={{'speed',23}}, expend={{1,600000},{6,700}}, name="随风飘动", desc="所有英雄速度额外增加23"},
		[8] = {id=6, lv=8, attr={{'speed',26}}, expend={{1,400000},{6,800}}, name="风之翔翼", desc="所有英雄速度额外增加26"},
		[9] = {id=6, lv=9, attr={{'speed',29}}, expend={{1,600000},{6,900}}, name="天风之舞", desc="所有英雄速度额外增加29"},
		[10] = {id=6, lv=10, attr={{'speed',32}}, expend={{1,800000},{6,1000}}, name="瞬间移动", desc="所有英雄速度额外增加32"},
	},
}
-- -------------------attrLev_end---------------------


-- -------------------const_start-------------------
Config.ResearchData.data_const_length = 5
Config.ResearchData.data_const = {
	["research_init"] = {key="research_init", val=1, desc="研究所初始等级"},
	["research_max"] = {key="research_max", val=10, desc="研究所最大等级"},
	["attr_init"] = {key="attr_init", val=0, desc="属性初始等级"},
	["attr_max"] = {key="attr_max", val=10, desc="属性最大等级"},
	["lv_up"] = {key="lv_up", val=10, desc="研究所开启等级"}
}
-- -------------------const_end---------------------
