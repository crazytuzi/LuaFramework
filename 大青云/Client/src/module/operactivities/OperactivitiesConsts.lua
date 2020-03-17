--[[
运营活动 Constants
2015-10-12 11:44:42
liyuan
]]
--------------------------------------------------------



_G.OperactivitiesConsts = {}

--入口图标
OperactivitiesConsts.iconShouchong = 1 --首冲btn1
OperactivitiesConsts.iconShouchongDay = 2--每日首充btn2
OperactivitiesConsts.iconHuodong1 = 3 --新服特惠btn3
OperactivitiesConsts.iconHuodong2 = 4 --精彩活动btn4
OperactivitiesConsts.iconHuodong3 = 5 --改成抽奖了
OperactivitiesConsts.iconHuodong4 = 6 --精彩活动btn6
OperactivitiesConsts.iconHuodong5 = 7 --精彩活动btn7
OperactivitiesConsts.iconLevel	  = 8 --等级投资
OperactivitiesConsts.iconFight	  = 9 --战力投资
OperactivitiesConsts.delayReawrd = 300
OperactivitiesConsts.BtnUIMap = {
	[OperactivitiesConsts.iconShouchong] = UIOperactivitesFirstRecharge,
	[OperactivitiesConsts.iconShouchongDay] = UIOperactivitesDalyRecharge,
	[OperactivitiesConsts.iconHuodong1] = UIMainOperActivites,
	[OperactivitiesConsts.iconHuodong2] = UIMainOperActivites,
	[OperactivitiesConsts.iconHuodong3] = UIOperactivitesAward,
	[OperactivitiesConsts.iconHuodong4] = UIMainOperActivites,
	[OperactivitiesConsts.iconHuodong5] = UIMainOperActivites,
	[OperactivitiesConsts.iconLevel] = UIOperactivitesLevel,
	[OperactivitiesConsts.iconFight] = UIOperactivitesFight,
}


OperactivitiesConsts.RankNameList = {
	[1] = StrConfig['operactivites28'],
	[2] = StrConfig['operactivites29'],
	[3] = StrConfig['operactivites30'],
	[4] = StrConfig['operactivites31'],
	[5] = StrConfig['operactivites32'],
	[6] = StrConfig['operactivites33'],
	[7] = '',
	[8] = '',
	[9] = StrConfig['operactivites34'],
	[10] = StrConfig['operactivites38'],
	[11] = StrConfig['operactivites39'],
	[12] = StrConfig['operactivites40'],
	[13] = StrConfig['operactivites41'],
}



OperactivitiesConsts.FirstChargeTipsCfg = {
	[1] = {
		['level'] = 0, 				--玩家等级
		['sen'] = "v_shouchong_xuanbing.sen", 				--场景
		["icon"] = "sctips_title2.png", 				--图片
		['compulsion'] = false,		--是否强制
	},
	[2] = {
		['level'] = 40, 
		['sen'] = "v_shouchong_xuanbing.sen", 
		["icon"] = "sctips_title2.png", 
		['compulsion'] = true,
	},
	[3] = {
		['level'] = 60, 
		['sen'] = "v_shouchong_300wan.sen", 
		["icon"] = "sctips_title3.png", 
		['compulsion'] = true,
	},
	[4] = {
		['level'] = 80, 
		['sen'] = "v_shouchong_jiangziya.sen", 
		["icon"] = "sctips_title4.png", 
		['compulsion'] = true,
	},
	[5] = {
		['level'] = 90, 
		['sen'] = "v_shouchong_baiyinvip.sen", 
		["icon"] = "sctips_title5.png", 
		['compulsion'] = true,
	},	
	[6] = {
		['level'] = 100, 
		['sen'] = "v_shouchong_jiangziya.sen", 
		["icon"] = "sctips_title4.png", 
		['compulsion'] = true,
	},
	[7] = {
		['level'] = 110, 
		['sen'] = "v_shouchong_shengjidan.sen", 
		["icon"] = "sctips_title6.png", 
		['compulsion'] = true,
	},		
	[8] = {
		['level'] = 130, 
		['sen'] = "v_shouchong_xuanbing.sen", 
		["icon"] = "sctips_title2.png", 
		['compulsion'] = true,	
	},
	[9] = {
		['level'] = 150, 
		['sen'] = "v_shouchong_baiyinvip.sen", 
		["icon"] = "sctips_title5.png", 
		['compulsion'] = true,			
	},
}