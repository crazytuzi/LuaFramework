
PublicTestCfg =
{
	isOpen = true,
	gameIndex = 2,
	time = {2020,11,23, 2020,11,28},
	TitleCfg = {
		consume = {type = 15, count = 8888},
		titleId = 4,
		validDay = 7,
		award = { {type = 0, id = 847, count = 1, bind = 1},
		          {type = 0, id = 540, count = 4, bind = 1},
			  {type = 0, id = 530, count = 4, bind = 1},
			  {type = 0, id = 562, count = 2, bind = 1},
			  {type = 0, id = 509, count = 10, bind = 1},},
		staitcAttrs =
		{
			{ type = 12, value = 0.06 },
			{ type = 16, value = 0.06 },
			{ type = 20, value = 0.06 },
			{ type = 6, value = 0.08 },
		},
	},
	InvestmentByDayCfg = {
		buyTime = {2015,11,6, 2015,11,14},
		investmentCount = 8800,
		returnTable = {7500,6000,6000,6000,6000,6000,7500},
		costRecoveringIndex = 1,
	},
	InvestmentByLevelCfg = {
		buyTime = {2015,11,6, 2015,11,20},
		investmentCount = 12800,
		returnTable = {{0,60,8000},{0,70,9000},{0,75,10000},{0,80,11000},{1,80,12000},{2,80,13000},{3,80,14000}},
		costRecoveringIndex = 1,
	},
	GroupBuyCfg = {
		{
			ybCount = 1000,
			buyCount = 200,
			award = { {type=0, id=677, count=1, bind=1},{type=0, id=676, count=1, bind=1} },
		},
		{
			ybCount = 5000,
			buyCount = 100,
			award = { {type=0, id=451, count=2, bind=1},{type=0, id=542, count=2, bind=1} },
		},
		{
			ybCount = 20000,
			buyCount = 40,
			award = { {type=0, id=451, count=4, bind=1},{type=0, id=543, count=2, bind=1} },
		},
		{
			ybCount = 50000,
			buyCount = 15,
			award = { {type=0, id=451, count=8, bind=1},{type=0, id=544, count=2, bind=1} },
		},
	},
	YbConsumeRanking = {
		minConsume = 50000,
		rankInterval = {{1, 1}, {2, 5}, {6, 20}},
		awardList =
		{
			{ {type=0, id=969, count=1, bind=1}, },
			{ {type=0, id=968, count=1, bind=1}, },
			{ {type=0, id=967, count=1, bind=1}, },
		},
	},
	HeroSuperCloth = {
		{type=0, id=791, count=1, bind=1},
		{type=0, id=797, count=1, bind=1},
		{type=0, id=803, count=1, bind=1},
	},
	Footprint = {
		{type=0, id=703, count=1, bind=1},
	},
	PayGift =
	{
		needMoney = 20000,
		award =
		{
			{type = 0, id = 652, count = 1, bind = 1},
			{type = 0, id = 700, count = 1, bind = 1},
			{type = 0, id = 696, count = 2, bind = 1},
			{type = 0, id = 846, count = 1, bind = 1},
		}
	},
	FireworkGift =
	{
		item_id = 915,
		buyNeedYb = 2000,
		itemList = {
			{
				{
					rand = {0, 100},
					award = {type = 0, id = 725,count = 1,bind = 1},
				},
				{
					rand = {101, 200},
					award = {type = 0, id = 727,count = 1,bind = 1},
				},
				{
					rand = {201, 300},
					award = {type = 0, id = 729,count = 1,bind = 1},
				},
				{
					rand = {301, 400},
					award = {type = 0, id = 717,count = 3,bind = 1},
				},
				{
					rand = {401, 500},
					award = {type = 0, id = 719,count = 3,bind = 1},
				},
				{
					rand = {501, 600},
					award = {type = 0, id = 724,count = 3,bind = 1},
				},
				{
					rand = {601, 700},
					award = {type = 0, id = 722,count = 3,bind = 1},
				},
				{
					rand = {701, 800},
					award = {type = 0, id = 859,count = 1,bind = 1},
				},
				{
					rand = {801, 950},
					award = {type = 0, id = 717,count = 2,bind = 1},
				},
				{
					rand = {951, 1100},
					award = {type = 0, id = 719,count = 2,bind = 1},
				},
				{
					rand = {1101, 1250},
					award = {type = 0, id = 724,count = 2,bind = 1},
				},
				{
					rand = {1251, 1400},
					award = {type = 0, id = 722,count = 2,bind = 1},
				},
				{
					rand = {1401, 1700},
					award = {type = 0, id = 717,count = 1,bind = 1},
				},
				{
					rand = {1701, 2000},
					award = {type = 0, id = 719,count = 1,bind = 1},
				},
				{
					rand = {2001, 2300},
					award = {type = 0, id = 724,count = 1,bind = 1},
				},
				{
					rand = {2301, 2600},
					award = {type = 0, id = 722,count = 1,bind = 1},
				},
				{
					rand = {2601, 3100},
					award = {type = 0, id = 716,count = 8,bind = 1},
				},
				{
					rand = {3101, 3600},
					award = {type = 0, id = 718,count = 8,bind = 1},
				},
				{
					rand = {3601, 4100},
					award = {type = 0, id = 721,count = 8,bind = 1},
				},
				{
					rand = {4101, 4600},
					award = {type = 0, id = 723,count = 8,bind = 1},
				},
				{
					rand = {4601, 5200},
					award = {type = 0, id = 716,count = 4,bind = 1},
				},
				{
					rand = {5201, 5800},
					award = {type = 0, id = 718,count = 4,bind = 1},
				},
				{
					rand = {5801, 6400},
					award = {type = 0, id = 721,count = 4,bind = 1},
				},
				{
					rand = {6401, 7000},
					award = {type = 0, id = 723,count = 4,bind = 1},
				},
				{
					rand = {7001, 7300},
					award = {type = 0, id = 687,count = 5,bind = 1},
				},
				{
					rand = {7301, 7600},
					award = {type = 0, id = 688,count = 5,bind = 1},
				},
				{
					rand = {7601, 7900},
					award = {type = 0, id = 689,count = 5,bind = 1},
				},
				{
					rand = {7901, 8500},
					award = {type = 0, id = 687,count = 3,bind = 1},
				},
				{
					rand = {8501, 9500},
					award = {type = 0, id = 688,count = 3,bind = 1},
				},
				{
					rand = {9501, 10000},
					award = {type = 0, id = 689,count = 3,bind = 1},
				},
			},
			{
				{
					rand = {0, 100},
					award = {type = 0, id = 726,count = 1,bind = 1},
				},
				{
					rand = {101, 200},
					award = {type = 0, id = 728,count = 1,bind = 1},
				},
				{
					rand = {201, 300},
					award = {type = 0, id = 730,count = 1,bind = 1},
				},
				{
					rand = {301, 400},
					award = {type = 0, id = 717,count = 3,bind = 1},
				},
				{
					rand = {401, 500},
					award = {type = 0, id = 719,count = 3,bind = 1},
				},
				{
					rand = {501, 600},
					award = {type = 0, id = 724,count = 3,bind = 1},
				},
				{
					rand = {601, 700},
					award = {type = 0, id = 722,count = 3,bind = 1},
				},
				{
					rand = {701, 800},
					award = {type = 0, id = 859,count = 1,bind = 1},
				},
				{
					rand = {801, 950},
					award = {type = 0, id = 717,count = 2,bind = 1},
				},
				{
					rand = {951, 1100},
					award = {type = 0, id = 719,count = 2,bind = 1},
				},
				{
					rand = {1101, 1250},
					award = {type = 0, id = 724,count = 2,bind = 1},
				},
				{
					rand = {1251, 1400},
					award = {type = 0, id = 722,count = 2,bind = 1},
				},
				{
					rand = {1401, 1700},
					award = {type = 0, id = 717,count = 1,bind = 1},
				},
				{
					rand = {1701, 2000},
					award = {type = 0, id = 719,count = 1,bind = 1},
				},
				{
					rand = {2001, 2300},
					award = {type = 0, id = 724,count = 1,bind = 1},
				},
				{
					rand = {2301, 2600},
					award = {type = 0, id = 722,count = 1,bind = 1},
				},
				{
					rand = {2601, 3100},
					award = {type = 0, id = 716,count = 8,bind = 1},
				},
				{
					rand = {3101, 3600},
					award = {type = 0, id = 718,count = 8,bind = 1},
				},
				{
					rand = {3601, 4100},
					award = {type = 0, id = 721,count = 8,bind = 1},
				},
				{
					rand = {4101, 4600},
					award = {type = 0, id = 723,count = 8,bind = 1},
				},
				{
					rand = {4601, 5200},
					award = {type = 0, id = 716,count = 4,bind = 1},
				},
				{
					rand = {5201, 5800},
					award = {type = 0, id = 718,count = 4,bind = 1},
				},
				{
					rand = {5801, 6400},
					award = {type = 0, id = 721,count = 4,bind = 1},
				},
				{
					rand = {6401, 7000},
					award = {type = 0, id = 723,count = 4,bind = 1},
				},
				{
					rand = {7001, 7300},
					award = {type = 0, id = 687,count = 5,bind = 1},
				},
				{
					rand = {7301, 7600},
					award = {type = 0, id = 688,count = 5,bind = 1},
				},
				{
					rand = {7601, 7900},
					award = {type = 0, id = 689,count = 5,bind = 1},
				},
				{
					rand = {7901, 8500},
					award = {type = 0, id = 687,count = 3,bind = 1},
				},
				{
					rand = {8501, 9500},
					award = {type = 0, id = 688,count = 3,bind = 1},
				},
				{
					rand = {9501, 10000},
					award = {type = 0, id = 689,count = 3,bind = 1},
				},
			},
		},
	},
}