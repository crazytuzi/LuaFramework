
EquipStarCfg =
{
	levelLimit  = {0,32},
	starConsume =
	{
		{
			starRate = 100,
			addRate = 0,
			starConsumes = { 
				{ type = 3, id = 0, count = 100000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 0, }, 
			},
		},
		{
			starRate = 80,
			addRate = 20,
			starConsumes = { 
				{ type = 3, id = 0, count = 300000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 150, }, 
			},
		},
		{
			starRate = 65,
			addRate = 35,
			starConsumes = { 
				{ type = 3, id = 0, count = 400000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 500, }, 
			},
		},
		{
			starRate = 50,
			addRate = 50,
			starConsumes = { 
				{ type = 3, id = 0, count = 600000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 1000, }, 
			},
		},
		{
			starRate = 40,
			addRate = 60,
			starConsumes = { 
				{ type = 3, id = 0, count = 900000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 2000, }, 
			},
		},
		{
			starRate = 30,
			addRate = 70,
			starConsumes = { 
				{ type = 3, id = 0, count = 1200000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 4000, }, 
			},
		},
		{
			starRate = 25,
			addRate = 75,
			starConsumes = { 
				{ type = 3, id = 0, count = 1700000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 8500, }, 
			},
		},
		{
			starRate = 20,
			addRate = 80,
			starConsumes = { 
				{ type = 3, id = 0, count = 2000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 16500, }, 
			},
		},
		{
			starRate = 15,
			addRate = 85,
			starConsumes = { 
				{ type = 3, id = 0, count = 3000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 25000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 4000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 75000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 5500000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 125000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 8000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 200000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 11000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 300000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 15000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 500000, }, 
			},
		},
		{
			starRate = 10,
			addRate = 90,
			starConsumes = { 
				{ type = 3, id = 0, count = 20000000, }, 
			},
			addRateConsumes = { 
				{ type = 10, id = 0, count = 750000, }, 
			},
		},
	},

	recoverConsume = 			--强化上限恢复所损失的星级的消耗
	{
		{	--恢复1星的消耗
			{ type = 3, id = 0, count = 0 },
		},

		{	--恢复2星的消耗
			{ type = 3, id = 0, count = 2000000 },
		},

		{	--恢复3星的消耗
			{ type = 3, id = 0, count = 3000000 },
		},

		{	--恢复4星的消耗
			{ type = 3, id = 0, count = 5000000 },
		},

		{	--恢复5星的消耗
			{ type = 3, id = 0, count = 7000000 },
		},

		{	--恢复6星的消耗
			{ type = 3, id = 0, count = 10000000 },
		},

		{	--恢复7星的消耗
			{ type = 3, id = 0, count = 14000000 },
		},

		{	--恢复8星的消耗
			{ type = 3, id = 0, count = 20000000 },
		},

		{	--恢复9星的消耗
			{ type = 10, id = 0, count = 5000 },
		},

		{	--恢复10星的消耗
			{ type = 10, id = 0, count = 10000 },
		},

		{	--恢复11星的消耗
			{ type = 10, id = 0, count = 15000 },
		},

		{	--恢复12星的消耗
			{ type = 10, id = 0, count = 20000 },
		},

		{	--恢复13星的消耗
			{ type = 10, id = 0, count = 30000 },
		},

		{	--恢复14星的消耗
			{ type = 10, id = 0, count = 50000 },
		},

		{	--恢复15星的消耗
			{ type = 10, id = 0, count = 75000 },
		},
	},

	transferConsume = 			--强化星级转移的消耗
	{
		{	--1星转移的消耗
			{ type = 3, id = 0, count = 100000 },
		},

		{	--2星转移的消耗
			{ type = 3, id = 0, count = 200000 },
		},

		{	--3星转移的消耗
			{ type = 3, id = 0, count = 400000 },
		},

		{	--4星转移的消耗
			{ type = 3, id = 0, count = 600000 },
		},

		{	--5星转移的消耗
			{ type = 3, id = 0, count = 1000000 },
		},

		{	--6星转移的消耗
			{ type = 3, id = 0, count = 1500000 },
		},

		{	--7星转移的消耗
			{ type = 3, id = 0, count = 2400000 },
		},

		{	--8星转移的消耗
			{ type = 3, id = 0, count = 4000000 },
		},

		{	--9星转移的消耗
			{ type = 3, id = 0, count = 6200000 },
		},

		{	--10星转移的消耗
			{ type = 3, id = 0, count = 10000000 },
		},

		{	--11星转移的消耗
			{ type = 10, id = 0, count = 25000 },
		},

		{	--12星转移的消耗
			{ type = 10, id = 0, count = 40000 },
		},

		{	--13星转移的消耗
			{ type = 10, id = 0, count = 60000 },
		},

		{	--14星转移的消耗
			{ type = 10, id = 0, count = 100000 },
		},

		{	--15星转移的消耗
			{ type = 10, id = 0, count = 150000 },
		},
	},
}
