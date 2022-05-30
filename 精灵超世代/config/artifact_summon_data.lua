----------------------------------------------------
-- 此文件由数据工具生成
-- 神器铸造配置数据--artifact_summon_data.xml
--------------------------------------

Config = Config or {} 
Config.ArtifactSummonData = Config.ArtifactSummonData or {}

-- -------------------summon_const_start-------------------
Config.ArtifactSummonData.data_summon_const_length = 8
Config.ArtifactSummonData.data_summon_const = {
	["c_interval"] = {code="c_interval", val=86400, type="普通召唤免费次数间隔/s"},
	["s_interval"] = {code="s_interval", val=172800, type="高级召唤免费间隔/s"},
	["common_s"] = {code="common_s", val=50000, type="普通召唤金币消耗"},
	["common_ten_s"] = {code="common_ten_s", val=500000, type="普通召唤十连金币消耗"},
	["senior_s"] = {code="senior_s", val=150, type="高级召唤钻石消耗"},
	["senior_ten_s"] = {code="senior_ten_s", val=1350, type="高级钻石十连价格"},
	["senior_red"] = {code="senior_red", val=150, type="高级召唤红钻消耗"},
	["senior_red_times"] = {code="senior_red_times", val=5, type="高级召唤每日红钻次数"}
}
-- -------------------summon_const_end---------------------


-- -------------------normal_data_start-------------------
Config.ArtifactSummonData.data_normal_data_length = 1
Config.ArtifactSummonData.data_normal_data = {
	[2] = {
		[27201] = {rare_type=2, id=101, artifact_id=27201, name="王者之剑碎片", limit_lev=1},
		[27202] = {rare_type=2, id=101, artifact_id=27202, name="奥义法典碎片", limit_lev=1},
		[27203] = {rare_type=2, id=101, artifact_id=27203, name="统御头盔碎片", limit_lev=1},
		[27204] = {rare_type=2, id=101, artifact_id=27204, name="千年积木碎片", limit_lev=1},
		[27101] = {rare_type=2, id=102, artifact_id=27101, name="大地之铠碎片", limit_lev=1},
		[27102] = {rare_type=2, id=102, artifact_id=27102, name="雷霆之盾碎片", limit_lev=1},
		[27103] = {rare_type=2, id=102, artifact_id=27103, name="埃阿斯之盾碎片", limit_lev=1},
		[27104] = {rare_type=2, id=102, artifact_id=27104, name="纯净月尘碎片", limit_lev=1},
		[27105] = {rare_type=2, id=102, artifact_id=27105, name="烈焰之锤碎片", limit_lev=1},
		[27106] = {rare_type=2, id=102, artifact_id=27106, name="荼毒之鞭碎片", limit_lev=1},
		[27107] = {rare_type=2, id=102, artifact_id=27107, name="涤罪利刃碎片", limit_lev=1},
		[27108] = {rare_type=2, id=102, artifact_id=27108, name="斩裂剑提尔锋碎片", limit_lev=1},
		[27109] = {rare_type=2, id=102, artifact_id=27109, name="精灵神弓碎片", limit_lev=1},
		[27110] = {rare_type=2, id=102, artifact_id=27110, name="暮光之戒碎片", limit_lev=1},
		[27111] = {rare_type=2, id=102, artifact_id=27111, name="翡翠额环碎片", limit_lev=1},
		[27112] = {rare_type=2, id=102, artifact_id=27112, name="神圣之翼碎片", limit_lev=1},
		[27001] = {rare_type=2, id=103, artifact_id=27001, name="命运之枪碎片", limit_lev=1},
		[27002] = {rare_type=2, id=103, artifact_id=27002, name="智慧之冠碎片", limit_lev=1},
		[27003] = {rare_type=2, id=103, artifact_id=27003, name="死神权杖碎片", limit_lev=1},
		[27004] = {rare_type=2, id=103, artifact_id=27004, name="群星之怒碎片", limit_lev=1},
		[27005] = {rare_type=2, id=103, artifact_id=27005, name="寒冰吊坠碎片", limit_lev=1},
		[27006] = {rare_type=2, id=103, artifact_id=27006, name="昆古尼尔碎片", limit_lev=1},
		[27007] = {rare_type=2, id=103, artifact_id=27007, name="诸神黄昏碎片", limit_lev=1},
		[27008] = {rare_type=2, id=103, artifact_id=27008, name="海神三叉戟碎片", limit_lev=1},
		[15040] = {rare_type=2, id=104, artifact_id=15040, name="炼神石", limit_lev=1},
		[15041] = {rare_type=2, id=105, artifact_id=15041, name="中阶炼神石", limit_lev=1},
		[15042] = {rare_type=2, id=106, artifact_id=15042, name="高阶炼神石", limit_lev=1},
		[15050] = {rare_type=2, id=107, artifact_id=15050, name="突破石", limit_lev=1},
	},
}
-- -------------------normal_data_end---------------------


-- -------------------senior_data_start-------------------
Config.ArtifactSummonData.data_senior_data_length = 1
Config.ArtifactSummonData.data_senior_data = {
	[2] = {
		[27101] = {rare_type=2, id=201, artifact_id=27101, name="大地之铠碎片", limit_lev=1},
		[27102] = {rare_type=2, id=201, artifact_id=27102, name="雷霆之盾碎片", limit_lev=1},
		[27103] = {rare_type=2, id=201, artifact_id=27103, name="埃阿斯之盾碎片", limit_lev=1},
		[27104] = {rare_type=2, id=201, artifact_id=27104, name="纯净月尘碎片", limit_lev=1},
		[27105] = {rare_type=2, id=201, artifact_id=27105, name="烈焰之锤碎片", limit_lev=1},
		[27106] = {rare_type=2, id=201, artifact_id=27106, name="荼毒之鞭碎片", limit_lev=1},
		[27107] = {rare_type=2, id=201, artifact_id=27107, name="涤罪利刃碎片", limit_lev=1},
		[27108] = {rare_type=2, id=201, artifact_id=27108, name="斩裂剑提尔锋碎片", limit_lev=1},
		[27109] = {rare_type=2, id=201, artifact_id=27109, name="精灵神弓碎片", limit_lev=1},
		[27110] = {rare_type=2, id=201, artifact_id=27110, name="暮光之戒碎片", limit_lev=1},
		[27111] = {rare_type=2, id=201, artifact_id=27111, name="翡翠额环碎片", limit_lev=1},
		[27112] = {rare_type=2, id=201, artifact_id=27112, name="神圣之翼碎片", limit_lev=1},
		[27001] = {rare_type=2, id=202, artifact_id=27001, name="命运之枪碎片", limit_lev=1},
		[27002] = {rare_type=2, id=202, artifact_id=27002, name="智慧之冠碎片", limit_lev=1},
		[27003] = {rare_type=2, id=202, artifact_id=27003, name="死神权杖碎片", limit_lev=1},
		[27004] = {rare_type=2, id=202, artifact_id=27004, name="群星之怒碎片", limit_lev=1},
		[27005] = {rare_type=2, id=202, artifact_id=27005, name="寒冰吊坠碎片", limit_lev=1},
		[27006] = {rare_type=2, id=202, artifact_id=27006, name="昆古尼尔碎片", limit_lev=1},
		[27007] = {rare_type=2, id=202, artifact_id=27007, name="诸神黄昏碎片", limit_lev=1},
		[27008] = {rare_type=2, id=202, artifact_id=27008, name="海神三叉戟碎片", limit_lev=1},
		[15040] = {rare_type=2, id=203, artifact_id=15040, name="炼神石", limit_lev=1},
		[15041] = {rare_type=2, id=204, artifact_id=15041, name="中阶炼神石", limit_lev=1},
		[15042] = {rare_type=2, id=205, artifact_id=15042, name="高阶炼神石", limit_lev=1},
		[15050] = {rare_type=2, id=206, artifact_id=15050, name="突破石", limit_lev=1},
	},
}
-- -------------------senior_data_end---------------------
