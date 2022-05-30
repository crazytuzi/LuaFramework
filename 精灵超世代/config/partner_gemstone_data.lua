----------------------------------------------------
-- 此文件由数据工具生成
-- 伙伴宝石配置数据--partner_gemstone_data.xml
--------------------------------------

Config = Config or {} 
Config.PartnerGemstoneData = Config.PartnerGemstoneData or {}

-- -------------------const_start-------------------
Config.PartnerGemstoneData.data_const_length = 7
Config.PartnerGemstoneData.data_const = {
	["num_gem_kind"] = {val=1, desc=[[装备同种类宝石镶嵌数量]]},
	["hole_opener"] = {val=70001, desc=[[打孔道具ID]]},
	["mosaic_gemstone"] = {val={70101,70201,70301,70401}, desc=[[可镶嵌宝石ID]]},
	["source_item"] = {val=70002, desc=[[镶嵌前往获取读取的物品ID]]},
	["order_gemstone"] = {val={70301,70101,70401,70201}, desc=[[装备宝石图标显示（武器，鞋子，衣服，帽子）]]},
	["gem_fragments"] = {val=70003, desc=[[宝石碎片id]]},
	["gem_open_lev"] = {val=45, desc=[[宝石开放等级]]}
}
-- -------------------const_end---------------------


-- -------------------upgrade_start-------------------
Config.PartnerGemstoneData.data_upgrade_length = 124
Config.PartnerGemstoneData.data_upgrade = {
	["1_0"] = {type=1, lev=0, limit_lev=0, attr={{'atk',0}}, expend=1, add={}, icon=70301},
	["1_1"] = {type=1, lev=1, limit_lev=45, attr={{'atk',32}}, expend=2, add={{70003,1}}, icon=70301},
	["1_2"] = {type=1, lev=2, limit_lev=45, attr={{'atk',64}}, expend=3, add={{70003,3}}, icon=70301},
	["1_3"] = {type=1, lev=3, limit_lev=45, attr={{'atk',103}}, expend=4, add={{70003,6}}, icon=70301},
	["1_4"] = {type=1, lev=4, limit_lev=45, attr={{'atk',145}}, expend=5, add={{70003,10}}, icon=70302},
	["1_5"] = {type=1, lev=5, limit_lev=50, attr={{'atk',190}}, expend=6, add={{70003,15}}, icon=70302},
	["1_6"] = {type=1, lev=6, limit_lev=52, attr={{'atk',239}}, expend=7, add={{70003,21}}, icon=70302},
	["1_7"] = {type=1, lev=7, limit_lev=54, attr={{'atk',290}}, expend=8, add={{70003,28}}, icon=70303},
	["1_8"] = {type=1, lev=8, limit_lev=56, attr={{'atk',345}}, expend=9, add={{70003,36}}, icon=70303},
	["1_9"] = {type=1, lev=9, limit_lev=58, attr={{'atk',404}}, expend=10, add={{70003,45}}, icon=70303},
	["1_10"] = {type=1, lev=10, limit_lev=60, attr={{'atk',465}}, expend=12, add={{70003,55}}, icon=70304},
	["1_11"] = {type=1, lev=11, limit_lev=62, attr={{'atk',526}}, expend=14, add={{70003,67}}, icon=70304},
	["1_12"] = {type=1, lev=12, limit_lev=64, attr={{'atk',594}}, expend=16, add={{70003,81}}, icon=70304},
	["1_13"] = {type=1, lev=13, limit_lev=66, attr={{'atk',665}}, expend=18, add={{70003,97}}, icon=70305},
	["1_14"] = {type=1, lev=14, limit_lev=68, attr={{'atk',737}}, expend=20, add={{70003,115}}, icon=70305},
	["1_15"] = {type=1, lev=15, limit_lev=70, attr={{'atk',811}}, expend=22, add={{70003,135}}, icon=70305},
	["1_16"] = {type=1, lev=16, limit_lev=72, attr={{'atk',892}}, expend=24, add={{70003,157}}, icon=70306},
	["1_17"] = {type=1, lev=17, limit_lev=74, attr={{'atk',969}}, expend=26, add={{70003,181}}, icon=70306},
	["1_18"] = {type=1, lev=18, limit_lev=76, attr={{'atk',1053}}, expend=28, add={{70003,207}}, icon=70306},
	["1_19"] = {type=1, lev=19, limit_lev=78, attr={{'atk',1141}}, expend=30, add={{70003,235}}, icon=70307},
	["1_20"] = {type=1, lev=20, limit_lev=80, attr={{'atk',1228}}, expend=32, add={{70003,265}}, icon=70307},
	["1_21"] = {type=1, lev=21, limit_lev=82, attr={{'atk',1318}}, expend=34, add={{70003,297}}, icon=70307},
	["1_22"] = {type=1, lev=22, limit_lev=84, attr={{'atk',1412}}, expend=36, add={{70003,331}}, icon=70308},
	["1_23"] = {type=1, lev=23, limit_lev=86, attr={{'atk',1509}}, expend=38, add={{70003,367}}, icon=70308},
	["1_24"] = {type=1, lev=24, limit_lev=88, attr={{'atk',1609}}, expend=40, add={{70003,405}}, icon=70308},
	["1_25"] = {type=1, lev=25, limit_lev=90, attr={{'atk',1710}}, expend=42, add={{70003,445}}, icon=70309},
	["1_26"] = {type=1, lev=26, limit_lev=92, attr={{'atk',1813}}, expend=44, add={{70003,487}}, icon=70309},
	["1_27"] = {type=1, lev=27, limit_lev=94, attr={{'atk',1920}}, expend=46, add={{70003,531}}, icon=70309},
	["1_28"] = {type=1, lev=28, limit_lev=96, attr={{'atk',2026}}, expend=48, add={{70003,577}}, icon=70310},
	["1_29"] = {type=1, lev=29, limit_lev=98, attr={{'atk',2136}}, expend=50, add={{70003,625}}, icon=70310},
	["1_30"] = {type=1, lev=30, limit_lev=100, attr={{'atk',2250}}, expend=0, add={{70003,675}}, icon=70310},
	["2_0"] = {type=2, lev=0, limit_lev=0, attr={{'speed',0}}, expend=1, add={}, icon=70101},
	["2_1"] = {type=2, lev=1, limit_lev=45, attr={{'speed',2}}, expend=2, add={{70003,1}}, icon=70101},
	["2_2"] = {type=2, lev=2, limit_lev=45, attr={{'speed',4}}, expend=3, add={{70003,3}}, icon=70101},
	["2_3"] = {type=2, lev=3, limit_lev=45, attr={{'speed',6}}, expend=4, add={{70003,6}}, icon=70101},
	["2_4"] = {type=2, lev=4, limit_lev=45, attr={{'speed',8}}, expend=5, add={{70003,10}}, icon=70102},
	["2_5"] = {type=2, lev=5, limit_lev=50, attr={{'speed',10}}, expend=6, add={{70003,15}}, icon=70102},
	["2_6"] = {type=2, lev=6, limit_lev=52, attr={{'speed',12}}, expend=7, add={{70003,21}}, icon=70102},
	["2_7"] = {type=2, lev=7, limit_lev=54, attr={{'speed',14}}, expend=8, add={{70003,28}}, icon=70103},
	["2_8"] = {type=2, lev=8, limit_lev=56, attr={{'speed',16}}, expend=9, add={{70003,36}}, icon=70103},
	["2_9"] = {type=2, lev=9, limit_lev=58, attr={{'speed',18}}, expend=10, add={{70003,45}}, icon=70103},
	["2_10"] = {type=2, lev=10, limit_lev=60, attr={{'speed',20}}, expend=12, add={{70003,55}}, icon=70104},
	["2_11"] = {type=2, lev=11, limit_lev=62, attr={{'speed',22}}, expend=14, add={{70003,67}}, icon=70104},
	["2_12"] = {type=2, lev=12, limit_lev=64, attr={{'speed',24}}, expend=16, add={{70003,81}}, icon=70104},
	["2_13"] = {type=2, lev=13, limit_lev=66, attr={{'speed',26}}, expend=18, add={{70003,97}}, icon=70105},
	["2_14"] = {type=2, lev=14, limit_lev=68, attr={{'speed',28}}, expend=20, add={{70003,115}}, icon=70105},
	["2_15"] = {type=2, lev=15, limit_lev=70, attr={{'speed',30}}, expend=22, add={{70003,135}}, icon=70105},
	["2_16"] = {type=2, lev=16, limit_lev=72, attr={{'speed',32}}, expend=24, add={{70003,157}}, icon=70106},
	["2_17"] = {type=2, lev=17, limit_lev=74, attr={{'speed',34}}, expend=26, add={{70003,181}}, icon=70106},
	["2_18"] = {type=2, lev=18, limit_lev=76, attr={{'speed',36}}, expend=28, add={{70003,207}}, icon=70106},
	["2_19"] = {type=2, lev=19, limit_lev=78, attr={{'speed',38}}, expend=30, add={{70003,235}}, icon=70107},
	["2_20"] = {type=2, lev=20, limit_lev=80, attr={{'speed',40}}, expend=32, add={{70003,265}}, icon=70107},
	["2_21"] = {type=2, lev=21, limit_lev=82, attr={{'speed',42}}, expend=34, add={{70003,297}}, icon=70107},
	["2_22"] = {type=2, lev=22, limit_lev=84, attr={{'speed',44}}, expend=36, add={{70003,331}}, icon=70108},
	["2_23"] = {type=2, lev=23, limit_lev=86, attr={{'speed',46}}, expend=38, add={{70003,367}}, icon=70108},
	["2_24"] = {type=2, lev=24, limit_lev=88, attr={{'speed',48}}, expend=40, add={{70003,405}}, icon=70108},
	["2_25"] = {type=2, lev=25, limit_lev=90, attr={{'speed',50}}, expend=42, add={{70003,445}}, icon=70109},
	["2_26"] = {type=2, lev=26, limit_lev=92, attr={{'speed',52}}, expend=44, add={{70003,487}}, icon=70109},
	["2_27"] = {type=2, lev=27, limit_lev=94, attr={{'speed',54}}, expend=46, add={{70003,531}}, icon=70109},
	["2_28"] = {type=2, lev=28, limit_lev=96, attr={{'speed',56}}, expend=48, add={{70003,577}}, icon=70110},
	["2_29"] = {type=2, lev=29, limit_lev=98, attr={{'speed',58}}, expend=50, add={{70003,625}}, icon=70110},
	["2_30"] = {type=2, lev=30, limit_lev=100, attr={{'speed',60}}, expend=0, add={{70003,675}}, icon=70110},
	["3_0"] = {type=3, lev=0, limit_lev=0, attr={{'def',0}}, expend=1, add={}, icon=70401},
	["3_1"] = {type=3, lev=1, limit_lev=45, attr={{'def',22}}, expend=2, add={{70003,1}}, icon=70401},
	["3_2"] = {type=3, lev=2, limit_lev=45, attr={{'def',45}}, expend=3, add={{70003,3}}, icon=70401},
	["3_3"] = {type=3, lev=3, limit_lev=45, attr={{'def',72}}, expend=4, add={{70003,6}}, icon=70401},
	["3_4"] = {type=3, lev=4, limit_lev=45, attr={{'def',101}}, expend=5, add={{70003,10}}, icon=70402},
	["3_5"] = {type=3, lev=5, limit_lev=50, attr={{'def',133}}, expend=6, add={{70003,15}}, icon=70402},
	["3_6"] = {type=3, lev=6, limit_lev=52, attr={{'def',167}}, expend=7, add={{70003,21}}, icon=70402},
	["3_7"] = {type=3, lev=7, limit_lev=54, attr={{'def',203}}, expend=8, add={{70003,28}}, icon=70403},
	["3_8"] = {type=3, lev=8, limit_lev=56, attr={{'def',242}}, expend=9, add={{70003,36}}, icon=70403},
	["3_9"] = {type=3, lev=9, limit_lev=58, attr={{'def',282}}, expend=10, add={{70003,45}}, icon=70403},
	["3_10"] = {type=3, lev=10, limit_lev=60, attr={{'def',325}}, expend=12, add={{70003,55}}, icon=70404},
	["3_11"] = {type=3, lev=11, limit_lev=62, attr={{'def',368}}, expend=14, add={{70003,67}}, icon=70404},
	["3_12"] = {type=3, lev=12, limit_lev=64, attr={{'def',416}}, expend=16, add={{70003,81}}, icon=70404},
	["3_13"] = {type=3, lev=13, limit_lev=66, attr={{'def',466}}, expend=18, add={{70003,97}}, icon=70405},
	["3_14"] = {type=3, lev=14, limit_lev=68, attr={{'def',515}}, expend=20, add={{70003,115}}, icon=70405},
	["3_15"] = {type=3, lev=15, limit_lev=70, attr={{'def',567}}, expend=22, add={{70003,135}}, icon=70405},
	["3_16"] = {type=3, lev=16, limit_lev=72, attr={{'def',624}}, expend=24, add={{70003,157}}, icon=70406},
	["3_17"] = {type=3, lev=17, limit_lev=74, attr={{'def',678}}, expend=26, add={{70003,181}}, icon=70406},
	["3_18"] = {type=3, lev=18, limit_lev=76, attr={{'def',737}}, expend=28, add={{70003,207}}, icon=70406},
	["3_19"] = {type=3, lev=19, limit_lev=78, attr={{'def',798}}, expend=30, add={{70003,235}}, icon=70407},
	["3_20"] = {type=3, lev=20, limit_lev=80, attr={{'def',859}}, expend=32, add={{70003,265}}, icon=70407},
	["3_21"] = {type=3, lev=21, limit_lev=82, attr={{'def',923}}, expend=34, add={{70003,297}}, icon=70407},
	["3_22"] = {type=3, lev=22, limit_lev=84, attr={{'def',988}}, expend=36, add={{70003,331}}, icon=70408},
	["3_23"] = {type=3, lev=23, limit_lev=86, attr={{'def',1056}}, expend=38, add={{70003,367}}, icon=70408},
	["3_24"] = {type=3, lev=24, limit_lev=88, attr={{'def',1126}}, expend=40, add={{70003,405}}, icon=70408},
	["3_25"] = {type=3, lev=25, limit_lev=90, attr={{'def',1197}}, expend=42, add={{70003,445}}, icon=70409},
	["3_26"] = {type=3, lev=26, limit_lev=92, attr={{'def',1269}}, expend=44, add={{70003,487}}, icon=70409},
	["3_27"] = {type=3, lev=27, limit_lev=94, attr={{'def',1344}}, expend=46, add={{70003,531}}, icon=70409},
	["3_28"] = {type=3, lev=28, limit_lev=96, attr={{'def',1418}}, expend=48, add={{70003,577}}, icon=70410},
	["3_29"] = {type=3, lev=29, limit_lev=98, attr={{'def',1495}}, expend=50, add={{70003,625}}, icon=70410},
	["3_30"] = {type=3, lev=30, limit_lev=100, attr={{'def',1575}}, expend=0, add={{70003,675}}, icon=70410},
	["4_0"] = {type=4, lev=0, limit_lev=0, attr={{'hp_max',0}}, expend=1, add={}, icon=70201},
	["4_1"] = {type=4, lev=1, limit_lev=45, attr={{'hp_max',161}}, expend=2, add={{70003,1}}, icon=70201},
	["4_2"] = {type=4, lev=2, limit_lev=45, attr={{'hp_max',323}}, expend=3, add={{70003,3}}, icon=70201},
	["4_3"] = {type=4, lev=3, limit_lev=45, attr={{'hp_max',517}}, expend=4, add={{70003,6}}, icon=70201},
	["4_4"] = {type=4, lev=4, limit_lev=45, attr={{'hp_max',727}}, expend=5, add={{70003,10}}, icon=70202},
	["4_5"] = {type=4, lev=5, limit_lev=50, attr={{'hp_max',953}}, expend=6, add={{70003,15}}, icon=70202},
	["4_6"] = {type=4, lev=6, limit_lev=52, attr={{'hp_max',1196}}, expend=7, add={{70003,21}}, icon=70202},
	["4_7"] = {type=4, lev=7, limit_lev=54, attr={{'hp_max',1454}}, expend=8, add={{70003,28}}, icon=70203},
	["4_8"] = {type=4, lev=8, limit_lev=56, attr={{'hp_max',1729}}, expend=9, add={{70003,36}}, icon=70203},
	["4_9"] = {type=4, lev=9, limit_lev=58, attr={{'hp_max',2020}}, expend=10, add={{70003,45}}, icon=70203},
	["4_10"] = {type=4, lev=10, limit_lev=60, attr={{'hp_max',2327}}, expend=12, add={{70003,55}}, icon=70204},
	["4_11"] = {type=4, lev=11, limit_lev=62, attr={{'hp_max',2634}}, expend=14, add={{70003,67}}, icon=70204},
	["4_12"] = {type=4, lev=12, limit_lev=64, attr={{'hp_max',2974}}, expend=16, add={{70003,81}}, icon=70204},
	["4_13"] = {type=4, lev=13, limit_lev=66, attr={{'hp_max',3329}}, expend=18, add={{70003,97}}, icon=70205},
	["4_14"] = {type=4, lev=14, limit_lev=68, attr={{'hp_max',3685}}, expend=20, add={{70003,115}}, icon=70205},
	["4_15"] = {type=4, lev=15, limit_lev=70, attr={{'hp_max',4057}}, expend=22, add={{70003,135}}, icon=70205},
	["4_16"] = {type=4, lev=16, limit_lev=72, attr={{'hp_max',4461}}, expend=24, add={{70003,157}}, icon=70206},
	["4_17"] = {type=4, lev=17, limit_lev=74, attr={{'hp_max',4849}}, expend=26, add={{70003,181}}, icon=70206},
	["4_18"] = {type=4, lev=18, limit_lev=76, attr={{'hp_max',5269}}, expend=28, add={{70003,207}}, icon=70206},
	["4_19"] = {type=4, lev=19, limit_lev=78, attr={{'hp_max',5705}}, expend=30, add={{70003,235}}, icon=70207},
	["4_20"] = {type=4, lev=20, limit_lev=80, attr={{'hp_max',6142}}, expend=32, add={{70003,265}}, icon=70207},
	["4_21"] = {type=4, lev=21, limit_lev=82, attr={{'hp_max',6594}}, expend=34, add={{70003,297}}, icon=70207},
	["4_22"] = {type=4, lev=22, limit_lev=84, attr={{'hp_max',7063}}, expend=36, add={{70003,331}}, icon=70208},
	["4_23"] = {type=4, lev=23, limit_lev=86, attr={{'hp_max',7548}}, expend=38, add={{70003,367}}, icon=70208},
	["4_24"] = {type=4, lev=24, limit_lev=88, attr={{'hp_max',8049}}, expend=40, add={{70003,405}}, icon=70208},
	["4_25"] = {type=4, lev=25, limit_lev=90, attr={{'hp_max',8550}}, expend=42, add={{70003,445}}, icon=70209},
	["4_26"] = {type=4, lev=26, limit_lev=92, attr={{'hp_max',9067}}, expend=44, add={{70003,487}}, icon=70209},
	["4_27"] = {type=4, lev=27, limit_lev=94, attr={{'hp_max',9601}}, expend=46, add={{70003,531}}, icon=70209},
	["4_28"] = {type=4, lev=28, limit_lev=96, attr={{'hp_max',10134}}, expend=48, add={{70003,577}}, icon=70210},
	["4_29"] = {type=4, lev=29, limit_lev=98, attr={{'hp_max',10684}}, expend=50, add={{70003,625}}, icon=70210},
	["4_30"] = {type=4, lev=30, limit_lev=100, attr={{'hp_max',11250}}, expend=0, add={{70003,675}}, icon=70210}
}
-- -------------------upgrade_end---------------------


-- -------------------resonate_start-------------------
Config.PartnerGemstoneData.data_resonate_length = 12
Config.PartnerGemstoneData.data_resonate = {
	[1] = {lev=1, need_lev=40, attr={{'atk',36},{'def',25},{'hp_max',184},{'speed',5}}},
	[2] = {lev=2, need_lev=80, attr={{'atk',49},{'def',34},{'hp_max',248},{'speed',10}}},
	[3] = {lev=3, need_lev=120, attr={{'atk',67},{'def',46},{'hp_max',335},{'speed',15}}},
	[4] = {lev=4, need_lev=160, attr={{'atk',90},{'def',63},{'hp_max',453},{'speed',20}}},
	[5] = {lev=5, need_lev=200, attr={{'atk',122},{'def',85},{'hp_max',611},{'speed',25}}},
	[6] = {lev=6, need_lev=240, attr={{'atk',165},{'def',115},{'hp_max',825},{'speed',30}}},
	[7] = {lev=7, need_lev=280, attr={{'atk',222},{'def',156},{'hp_max',1114},{'speed',35}}},
	[8] = {lev=8, need_lev=320, attr={{'atk',301},{'def',210},{'hp_max',1505},{'speed',40},{'dam',10},{'res',10}}},
	[9] = {lev=9, need_lev=360, attr={{'atk',406},{'def',284},{'hp_max',2032},{'speed',45},{'dam',20},{'res',20}}},
	[10] = {lev=10, need_lev=400, attr={{'atk',548},{'def',384},{'hp_max',2743},{'speed',50},{'dam',30},{'res',30}}},
	[11] = {lev=11, need_lev=440, attr={{'atk',740},{'def',518},{'hp_max',3703},{'speed',55},{'dam',40},{'res',40}}},
	[12] = {lev=12, need_lev=480, attr={{'atk',1000},{'def',700},{'hp_max',5000},{'speed',60},{'dam',50},{'res',50}}}
}
-- -------------------resonate_end---------------------


-- -------------------explain_start-------------------
Config.PartnerGemstoneData.data_explain_length = 1
Config.PartnerGemstoneData.data_explain = {
	[1] = {id=1, title="规则说明", desc="1.同一英雄宝石总等级达到要求时，即可激活宝石共鸣，共鸣等级越高，属性越高\n2.当英雄卸下装备，导致宝石总等级不满足要求时，则宝石共鸣等级自动降低"}
}
-- -------------------explain_end---------------------
