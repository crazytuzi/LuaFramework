----------------------------------------------------
-- 此文件由数据工具生成
-- 星命配置数据--star_divination_data.xml
--------------------------------------

Config = Config or {} 
Config.StarDivinationData = Config.StarDivinationData or {}

-- -------------------divination_const_start-------------------
Config.StarDivinationData.data_divination_const_length = 11
Config.StarDivinationData.data_divination_const = {
	["divine_cost"] = {code="divine_cost", val={17,500}, desc=[[单次占卜消耗星魂数量]]},
	["divine_cost10"] = {code="divine_cost10", val={17,4888}, desc=[[10次占卜消耗星魂数量]]},
	["divine_change"] = {code="divine_change", val={15,50}, desc=[[单次观星]]},
	["divine_change10"] = {code="divine_change10", val={15,488}, desc=[[十连观星]]},
	["divine_times"] = {code="divine_times", val=9999, desc=[[每日钻石可兑换抽取次数]]},
	["divine_free"] = {code="divine_free", val=1, desc=[[每日星魂单抽免费次数]]},
	["divine_buy"] = {code="divine_buy", val={18,100}, desc=[[钻石单抽购买获得的星灵积分数量]]},
	["divine_buy10"] = {code="divine_buy10", val={18,1000}, desc=[[钻石10连抽购买获得的星灵积分数量]]},
	["up_item"] = {code="up_item", val=10301, desc=[[星命精华]]},
	["exchange_item"] = {code="exchange_item", val=18, desc=[[星灵积分]]},
	["divine_open"] = {code="divine_open", val={{'open_day',3},{'lev',42}}, desc=[[开服第3天且等级达到42级开启观星]]}
}
-- -------------------divination_const_end---------------------


-- -------------------divination_flash_name_start-------------------
Config.StarDivinationData.data_divination_flash_name_length = 12
Config.StarDivinationData.data_divination_flash_name = {
	[1] = {star_name="白羊", id=1},
	[2] = {star_name="金牛", id=2},
	[3] = {star_name="双子", id=3},
	[4] = {star_name="巨蟹", id=4},
	[5] = {star_name="狮子", id=5},
	[6] = {star_name="处女", id=6},
	[7] = {star_name="天秤", id=7},
	[8] = {star_name="天蝎", id=8},
	[9] = {star_name="射手", id=9},
	[10] = {star_name="摩羯", id=10},
	[11] = {star_name="水瓶", id=11},
	[12] = {star_name="双鱼", id=12}
}
-- -------------------divination_flash_name_end---------------------


-- -------------------divination_flash_start-------------------
Config.StarDivinationData.data_divination_flash_length = 20
Config.StarDivinationData.data_divination_flash = {
	[1] = {count=1, expend={{15,20}}},
	[2] = {count=2, expend={{15,20}}},
	[3] = {count=3, expend={{15,20}}},
	[4] = {count=4, expend={{15,30}}},
	[5] = {count=5, expend={{15,30}}},
	[6] = {count=6, expend={{15,30}}},
	[7] = {count=7, expend={{15,40}}},
	[8] = {count=8, expend={{15,40}}},
	[9] = {count=9, expend={{15,40}}},
	[10] = {count=10, expend={{15,50}}},
	[11] = {count=11, expend={{15,50}}},
	[12] = {count=12, expend={{15,50}}},
	[13] = {count=13, expend={{15,50}}},
	[14] = {count=14, expend={{15,50}}},
	[15] = {count=15, expend={{15,80}}},
	[16] = {count=16, expend={{15,80}}},
	[17] = {count=17, expend={{15,80}}},
	[18] = {count=18, expend={{15,80}}},
	[19] = {count=19, expend={{15,80}}},
	[20] = {count=20, expend={{15,80}}}
}
-- -------------------divination_flash_end---------------------


-- -------------------explain_start-------------------
Config.StarDivinationData.data_explain_length = 3
Config.StarDivinationData.data_explain = {
	[1] = {id=1, title="观星规则", desc="1.观星可获得命格和星命升级材料，但只能获得已解锁的命格种类\n2.可通过挑战星命塔来解锁新的命格类型\n3.命格的品质由低到高分为：绿、蓝、紫、橙、红5种\n4.当前点亮的宝石颜色决定下一次抽取到的命格品质\n5.当前运势可提高获得对应类型命格的概率，可消耗少量钻石进行刷新"},
	[2] = {id=2, title="观星掉落", desc="应国家有关法律规定，对游戏内容观星物品产出概率进行公布，这些“概率”均是在大样本（大量用户）下的统计数值，与单个玩家的少量测试数据之间可能存在一定差异，<div fontcolor=#a95f0f>希望广大玩家理性消费，健康游戏。"},
	[3] = {id=3, title="", desc="绿色命格                                                                      37.86%\n蓝色命格                                                                      31.88%\n紫色命格                                                                      8.3%\n橙色命格                                                                      2.90%\n红色命格                                                                      0.6%\n星命精华                                                                      15.47%\n炼星石                                                                        1.76%\n中级炼星石                                                                    1.22%"}
}
-- -------------------explain_end---------------------
