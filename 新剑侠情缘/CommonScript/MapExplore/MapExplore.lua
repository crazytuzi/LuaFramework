MapExplore.MAX_STEP = 10  --每个地图最多探索10次
MapExplore.MAX_RESET_TIME	= 1; --每章地图一天最多重置1次
MapExplore.MAX_SAME_ENEMY = 2; --对同一个敌人最多遇到 几次

MapExplore.MIN_LEVEL = 19 ;--19级别以后才显示地图探索
MapExplore.MAX_LEVEL = 70 ;
MapExplore.FIND_ENEMY_LEVEL = 10; --不会碰到低自己10级以上的玩家

local KIND_ENNEMY   = 1 --种类勿修改
local KIND_FUBEN    = 2
local KIND_ITEM 	= 3 
local KIND_COIN 	= 4

MapExplore.KIND_ENNEMY = KIND_ENNEMY
-- MapExplore.KIND_FUBEN  = KIND_FUBEN
MapExplore.KIND_ITEM   = KIND_ITEM
MapExplore.KIND_COIN   = KIND_COIN

MapExplore.GET_NOTHING_SET = {  --遇敌探空给的默认设置
	KIND_COIN, 500
}



MapExplore.RESET_COST = 20; --重置探索消耗20元宝


MapExplore.FIGHT_MAP = 1019 --探索遇敌异步战斗地图
MapExplore.ENTER_POINT = {2560, 2920} --探索遇敌地图点

--每一章对应的地图id
MapExplore.tbSectionMap  = {
	[1] = {
			 nMapTemplateId = 2000, --第一章的探索对应地图ID
			 nNeedLevel 	= 19;
			 szUiSpriteName = "fb_canghai05",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
			 nEvenIndex = 1, --对应事件池1
		  }, 
	[2] = {
			 nMapTemplateId = 2001,
			 nNeedLevel 	= 25;
			 nEvenIndex = 1, 
			 szUiSpriteName = "fb_zhulin05",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[3] = {
			 nMapTemplateId = 2002,
			 nNeedLevel 	= 30;
			 nEvenIndex = 1, 
			 szUiSpriteName = "fb_luoyegu05",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[4] = {
			 nMapTemplateId = 2003,
			 nNeedLevel 	= 35;
			 nEvenIndex = 1, 
			 szUiSpriteName = "fb_erengu",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[5] = {
			 nMapTemplateId = 2004,
			 nNeedLevel 	= 40;
			 nEvenIndex = 2, 
			 szUiSpriteName = "fb_digong07",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[6] = {
			 nMapTemplateId = 2005,
			 nNeedLevel 	= 45;
			 nEvenIndex = 2, 
			 szUiSpriteName = "fb_shanzhuang05",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[7] = {
			 nMapTemplateId = 2006,
			 nNeedLevel 	= 50;
			 nEvenIndex = 2, 
			 szUiSpriteName = "fb_xuedi01",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[8] = {
			 nMapTemplateId = 2007,
			 nNeedLevel 	= 55;
			 nEvenIndex = 2, 
			 szUiSpriteName = "fb_digong04",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[9] = {
			 nMapTemplateId = 2008,
			 nNeedLevel 	= 60;
			 nEvenIndex = 3, 
			 szUiSpriteName = "fb_erengu07",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
	[10] = {
			 nMapTemplateId = 2009,
			 nNeedLevel 	= 65;
			 nEvenIndex = 3, 
			 szUiSpriteName = "fb_shanzhuang06",
			 szUiAtlas	  = "UI/Atlas/Fuben/FubenMap_01.prefab",
		  },
}

local tbEventSetting = { --不同的事件池
	{ --1~39级
		tbProb = {
		 --第一位是概率，程序中使用时会累加到1
			{0.125, KIND_ENNEMY}, --遇敌
			{0.0741, KIND_COIN, 500}, --银两数
			{0.05145, KIND_COIN, 1000},
			{0.018, KIND_COIN, 2000},
			{0.0045, KIND_COIN, 3000},
			{0.0015, KIND_COIN, 5000},
			{0.00045, KIND_COIN, 10000},
			{0.05,  KIND_ITEM, 786}, --最后参数对应到道具id
			{0.025,  KIND_ITEM, 785}, 
			{0.025,  KIND_ITEM, 213}, 
			{0.4,  KIND_ITEM, 212}, 
			{0.15,  KIND_ITEM, 787}, 
			{0.025,  KIND_ITEM, 792}, 
			{0.025,  KIND_ITEM, 1234}, 
			{0.025,  KIND_ITEM, 1235}, 
		},
	},
	{ --40~59级
		tbProb = {
		 --第一位是概率，程序中使用时会累加到1
			{0.15, KIND_ENNEMY}, --遇敌
			{0.0988, KIND_COIN, 500}, --银两数
			{0.0686, KIND_COIN, 1000},
			{0.024, KIND_COIN, 2000},
			{0.006, KIND_COIN, 3000},
			{0.002, KIND_COIN, 5000},
			{0.0006, KIND_COIN, 10000},
			{0.05,  KIND_ITEM, 786}, --最后参数对应到道具id
			{0.025,  KIND_ITEM, 785}, 
			{0.025,  KIND_ITEM, 213}, 
			{0.3,  KIND_ITEM, 212}, 
			{0.025,  KIND_ITEM, 222}, 
			{0.15,  KIND_ITEM, 787}, 
			{0.025,  KIND_ITEM, 792}, 
			{0.025,  KIND_ITEM, 1234}, 
			{0.025,  KIND_ITEM, 1235}, 
		},
	},
	{ --60~69级
		tbProb = {
		 --第一位是概率，程序中使用时会累加到1
			{0.1435, KIND_ENNEMY}, --遇敌
			{0.10868, KIND_COIN, 500}, --银两数
			{0.07546, KIND_COIN, 1000},
			{0.0264, KIND_COIN, 2000},
			{0.0066, KIND_COIN, 3000},
			{0.0022, KIND_COIN, 5000},
			{0.00066, KIND_COIN, 10000},
			{0.055,  KIND_ITEM, 786}, --最后参数对应到道具id
			{0.0275,  KIND_ITEM, 785}, 
			{0.0195,  KIND_ITEM, 213}, 
			{0.002,  KIND_ITEM, 214}, 
			{0.25,  KIND_ITEM, 212}, 
			{0.0375,  KIND_ITEM, 222}, 
			{0.0025,  KIND_ITEM, 223}, 
			{0.165,  KIND_ITEM, 787}, 
			{0.0275,  KIND_ITEM, 792}, 
			{0.025,  KIND_ITEM, 1234}, 
			{0.025,  KIND_ITEM, 1235}, 
		},
	},
}

 --各个地图的位置配置, 第一个是起始位置, 
 --地图抓点时，注意玩家点与出现东西点是相隔一个场景格子（对角是一个格子，非对角是2个格子）
local tbMapStepSetting = {
	[2000] = {  
		{1075,1361, 7},  --参数3 初始朝向
		{1580,1860,  1636,1917, 8}, --玩家站的位置，出现的东西在的位置,方向
		{2055,2447,  2111,2503, 7},
		{2225,3345,  2226,3430, 3},
		{2057,4213,  2057,4297, 64},
		{2086,5052,  2086,5138, 64},
		{2084,5865,  2088,5951, 64},
		{2982,5530,  3067,5527, 17},
		{3766,5527,  3849,5525, 16},
		{4494,5530,  4580,5528, 16},
		{5558,5526,  5645,5529, 16},
	},
	[2001] = {
		{2139,3515, 32},
		{2139,2451, 2142,2366, 32},
		{2953,2450, 3070,2447, 17},
		{3848,2589, 3933,2590, 14},
		{5025,2872, 5111,2869, 13},
		{6423,2952, 6508,2953, 15},
		{6398,3877, 6397,3964, 1},		
		{6395,5055, 6400,5138, 64},  
		{5166,5024, 5056,5025, 50},
		{3682,5360, 3594,5361, 50},
		{2227,5362, 2142,5360, 49},
	},
	[2002] = {
		{3428,1092, 0},
		{2617,1606, 2563,1665, 54},
		{2142,2617, 2142,2700, 60},
		{2059,3763, 2057,3846, 64},
		{2001,4717, 2002,4799, 64},
		{2783,5193, 2840,5248, 9},
		{3568,5474, 3654,5476, 12}, 
		{4885,5306, 4971,5306, 16},
		{4886,4101, 4886,4015, 31},
		{5026,2899, 5026,2814, 30},
		{5024,1945, 5024,1861, 32},
	},
	[2003] = {
		{2237,2762, 62},
		{2003,3541, 2000,3623, 62},
		{1719,4184, 1722,4267, 61},
		{1694,5417, 1692,5502, 64},
		{3094,5502, 3178,5502, 15},
		{4048,5501, 4129,5501, 16},
		{4944,5498, 5027,5500, 16},
		{5531,4911, 5587,4856, 22},
		{4913,4043, 4913,3962, 37},
		{4942,2979, 4941,2896, 32},
		{4996,1748, 4997,1666, 32},
	},
	[2004] = {
		{1526,4904, 32},
		{1495,3767, 1499,3681, 32},
		{1472,2200, 1475,2115, 32},
		{3290,2278, 3377,2279, 16},
		{5166,2140, 5248,2141, 16},
		{5195,3961, 5196,4045, 1},
		{5249,5502, 5250,5585, 64},
		{5249,6621, 5251,6703, 64},
		{6818,6539, 6902,6538, 15},
		{8356,5389, 8443,5390, 17},
		{10065,5389, 10148,5389, 16},
	},
	[2005] = {
		{2890,848, 0},
		{2871,1915, 2872,2004, 64},
		{2868,2897, 2869,2981, 64},
		{2839,3849, 2840,3930, 64},
		{2814,5305, 2816,5389, 64},
		{2784,7208, 2786,7292, 64},
		{5336,7236, 5421,7236, 15},
		{7070,7210, 7153,7208, 16},
		{7124,5728, 7122,5669, 30},
		{6761,4074, 6704,4016, 33},
		{5614,3174, 5557,3123, 41},
	},
	[2006] = {
		{4634,1073, 48},
		{3822,1076, 3736,1076, 48},
		{2953,1078, 2869,1076, 48},
		{2086,1078, 2001,1075, 48},
		{1413,1469, 1413,1553, 53},
		{1413,2307, 1411,2394, 64},
		{1412,3232, 1417,3317, 64},
		{1580,4102, 1639,4155, 2},
		{3064,4491, 3151,4492, 13},
		{3740,3850, 3796,3793, 22},
		{4491,3012, 4550,2953, 24},
	},
	[2007] = {
		{3305,10719, 32},
		{3317,9196, 3317,9113, 32},
		{3347,7684, 3343,7597, 31},
		{3457,5865, 3458,5781, 31},
		{3456,4299, 3456,4215, 32},
		{3432,3261, 3432,3178, 32},
		{5725,3233, 5812,3231, 16},
		{7740,3231, 7828,3231, 16},
		{7826,5194, 7827,5278, 1},
		{7798,6620, 7798,6702, 64},
		{7714,8469, 7714,8552, 64},
	},
	[2008] = {
		{2559,3282, 16},
		{3400,3290, 3488,3292, 16},
		{4410,3287, 4493,3288, 16},
		{5330,3290, 5420,3288, 16},
		{6371,3313, 6455,3316, 15},
		{6398,5051, 6399,5135, 1},
		{6450,6345, 6455,6423, 1},
		{5559,6927, 5494,6985, 55},
		{4827,5726, 4745,5727, 44},
		{3682,5669, 3598,5669, 48},
		{2508,5670, 2425,5668, 48},
	},
	[2009] = {
		{2001,3045, 16},
		{2982,3035, 3062,3034, 16},
		{4270,3035, 4355,3040, 16},
		{6034,3066, 6119,3063, 15},
		{6088,4438, 6088,4524, 64},
		{6060,5893, 6063,5974, 64},
		{3767,5890, 3684,5896, 49},
		{3798,6590, 3796,6677, 63},
		{3793,8495, 3794,8583, 64},
		{4940,8524, 5031,8527, 15},
		{6394,8524, 6486,8523, 16},
	},
}

MapExplore.tbMapStepSetting = tbMapStepSetting

--------------设置end----

MapExplore.tbMaspIndex = {} --[nMapTemplateId] = tbProb
local tbMaspIndex = MapExplore.tbMaspIndex 

local function fnInitSettting()
	for i, v in ipairs(tbEventSetting) do
		--
		local tbProb = v.tbProb
		local nLastProb = 0
		for i2, v2 in ipairs(tbProb) do
			v2[1]  = nLastProb + v2[1]
			nLastProb = v2[1]

			if v[2] == KIND_ITEM or v[2] == KIND_COIN  then
				assert(v[3], i .. ',' .. i2)
			end
		end
		assert(math.abs( nLastProb - 1) <= 0.001, i.." but " ..nLastProb)
		
		
	end

	for nSect, v in ipairs(MapExplore.tbSectionMap) do
		local nMapTemplateId = v.nMapTemplateId
		assert(tbMaspIndex[nMapTemplateId] == nil, nSect)
		assert(#tbMapStepSetting[nMapTemplateId] == MapExplore.MAX_STEP + 1, nSect)
		local tbEvent = tbEventSetting[v.nEvenIndex]
		assert(tbEvent, nSect)

		tbMaspIndex[nMapTemplateId] = {
			tbProb = tbEvent.tbProb,
		};

	end
end

fnInitSettting();



function MapExplore:CanResetMap(nMapTemplateId, tbStepInfo, tbResetInfo)
	if not tbStepInfo[nMapTemplateId] then
		return false, "探索满以后才能重置"
	end
	if tbStepInfo[nMapTemplateId] < self.MAX_STEP then
		return false, "当前章节还没探索完"
	end

	local nResetTime = tbResetInfo[nMapTemplateId]
	if  nResetTime and nResetTime >= self.MAX_RESET_TIME   then
		return false, string.format("每个章节的探索进度每天只能重置%d次", self.MAX_RESET_TIME) 
	end

	return true
end