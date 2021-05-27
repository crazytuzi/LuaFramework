
EquipMeltCfg =
{
	limit =
	{
		{
			days = 30,
			circleShow = 6,
			circle = 7,
		},
		{
			days = 40,
			circleShow = 6,
			circle = 8,
		},
	},
	-- 可融合的装备类型 客户端显示"背包"用与红点提示用
	item_type_list = {
		{1, 2, 3, 4, 5, 6, 7, 8},
		{9, 10, 11, 12, 13, 14, 41, 42, 43, 44, 45, 46, 15, 16, 39, 40,},
	},
	tabbar_title = {
	{"神装", "热血"},
	{"身上", "背包"},
	},
	meltcfg =
	{
		{
			{
				circleLimit = 7,
				consumes = {{type = 6, id = 0, count = 5000000,},},
				attrrate = 1000,
			},
			{
				circleLimit = 7,
				consumes = {{type = 6, id = 0, count = 10000000,},},
				attrrate = 2000,
			},
			{
				circleLimit = 7,
				consumes = {{type = 6, id = 0, count = 20000000,},},
				attrrate = 3000,
			},
			{
				circleLimit = 7,
				consumes = {{type = 6, id = 0, count = 30000000,},},
				attrrate = 4000,
			},
			{
				circleLimit = 7,
				consumes = {{type = 6, id = 0, count = 50000000,},},
				attrrate = 5000,
			},
		},
		{
			{
				consumes = {{type = 6, id = 0, count = 5000000,},},
				attrrate = 1000,
			},
			{
				consumes = {{type = 6, id = 0, count = 10000000,},},
				attrrate = 2000,
			},
			{
				consumes = {{type = 6, id = 0, count = 20000000,},},
				attrrate = 3000,
			},
			{
				consumes = {{type = 6, id = 0, count = 30000000,},},
				attrrate = 4000,
			},
			{
				consumes = {{type = 6, id = 0, count = 50000000,},},
				attrrate = 5000,
			},
		},
	},
}