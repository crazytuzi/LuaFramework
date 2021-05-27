
MultiPropDropItemConfig =
{
	{
		item_id = 1552,
		attribute = { type = 0, id = 1552, count = 1, strong = 0, quality = 0, bind = 1 },
		itemCount = 1,
		needDelete = true,
		needYuanBao = 0,
		MinLevel = 50,
		Circle = 0,
		ActivityTime = {startTime = {year=2013, month=1, day=28, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=28, hour=23,min=59,sec=59}},
		UseTime = {startTime = {year=2013, month=1, day=28, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=28, hour=23,min=59,sec=59}},
		items =
		{
			{
				needMinBagGrid = 1,
				needYuanBao = 0,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops318.lua",
			},
			{
				needMinBagGrid =2 ,
				needYuanBao = 18,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops319.lua",
			},
			{
				needMinBagGrid =4 ,
				needYuanBao = 88,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops320.lua",
			},
			{
				needMinBagGrid =4 ,
				needYuanBao = 188,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops321.lua",
			},
		}
	},
	{
		item_id = 1554,
		attribute = { type = 0, id = 1554, count = 1, strong = 0, quality = 0, bind = 1 },
		itemCount = 1,
		needDelete = true,
		MinLevel = 40,
		Circle = 0,
		ActivityTime = {startTime = {year=2013, month=1, day=28, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=8, hour=23,min=59,sec=59}},
		UseTime = {},
		items =
		{
			{
				needMinBagGrid = 4,
				needYuanBao = 0,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops322.lua",
			},
			{
				needMinBagGrid =4 ,
				needYuanBao = 88,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops323.lua",
			},
			{
				needMinBagGrid =4 ,
				needYuanBao = 388,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops324.lua",
			},
			{
				needMinBagGrid =5 ,
				needYuanBao = 888,
				dropName = "data/config/item/scriptItemConfig/ProabilityDrops/probDrops325.lua",
			},
		}
	},
}
	MoneyPacketConfig =
	{
		item_id = 1553,
		attribute = { type = 0, id = 1553, count = 1, strong = 0, quality = 0, bind = 1 },
		itemCount = 1,
		needDelete = true,
		MinLevel = 40,
		Circle = 0,
		ActivityTime = {startTime = {year=2013, month=2, day=17, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=19, hour=23,min=59,sec=59}},
		UseTime = {startTime = {year=2013, month=1, day=30, hour=0,min=0,sec=0}
				,endTime = {year=3013, month=2, day=28, hour=23,min=59,sec=59}},
		items = nil;
	}
NianConfig = {
		item_id = 1555,
		needDelete = true,
		MinLevel = 1,
		BigFestiveFirecrackers = {item_id = 1557,Price = 3,skillId = 157; skillLevel = 2};
		SmallFestiveFirecrackers = {item_id = 1558,Price = 10000,skillId = 157; skillLevel = 3};
		SupremeJinlongId = 1388;
		ActivityTime = {startTime = {year=2013, month=1, day=28, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=28, hour=23,min=59,sec=59}},
		UseTime = {startTime = {year=2013, month=1, day=28, hour=0,min=0,sec=0}
				,endTime = {year=2013, month=2, day=28, hour=23,min=59,sec=59}},
		items =
		{
			{NianCount = 8,YuanBao = 1, Coin = 0, awards = {
					{ type = 0, id = 545, count = 1, strong = 0, quality = 0, bind = 1 },
				}
			},
			{NianCount = 16,YuanBao = 0, Coin = 0, awards = {
					{ type = 0, id = 276, count = 1, strong = 0, quality = 0, bind = 1 },
				}
			},
			{NianCount = 888,YuanBao = 0, Coin = 0, awards = {
					{ type = 0, id = 1388, count = 1, strong = 0, quality = 0, bind = 1 },
				}
			},
			{NianCount = 88,YuanBao = 888, Coin = 0, awards = {
					{ type = 0, id = 1388, count = 1, strong = 0, quality = 0, bind = 1 },
				}
			},
		},
	nSceenId = 8,
	monsters =
	{
		{
			{nMonsterID = 689, posX1 = 178, posX2 = 178,  posY = 199, nCount = 1, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 191, nCount = 7, nLiveTime = 3600,},
			{nMonsterID = 691, posX1 = 166, posX2 = 194,  posY = 191, nCount = 2, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 194, nCount = 7, nLiveTime = 3600,},
			{nMonsterID = 691, posX1 = 182, posX2 = 183,  posY = 198, nCount = 2, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 197, nCount = 7, nLiveTime = 3600,},
			{nMonsterID = 691, posX1 = 186, posX2 = 188,  posY = 206, nCount = 2, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 168, posX2 = 194,  posY = 201, nCount = 8, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 205, nCount = 8, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 209, nCount = 8, nLiveTime = 3600,},
			{nMonsterID = 690, posX1 = 166, posX2 = 194,  posY = 215, nCount = 9, nLiveTime = 3600,},
		},
	},
	}
	--]]