Boss.ZDef = Boss.ZDef or {};

-- 每服参加决赛的家族数
Boss.ZDef.nJoinKinCountPerWorld = 5;
Boss.ZDef.szTimeFrame = "OpenLevel89";
Boss.ZDef.nPreStartTime = 60;
Boss.ZDef.nKinShowRankCount = 10;
Boss.ZDef.nPlayerShowRankCount = 20;
Boss.ZDef.nRobListTopSelect = 20;
Boss.ZDef.nDefaultRank = 9999;
Boss.ZDef.nRobMaxHigherHonorLevel = 30;

-- 日常盟主1~10名家族对应的累计积分
Boss.ZDef.tbRankScore4Cross = {10,9,8,7,6,5,4,3,2,1};


Boss.ZDef.tbPlayerRankTitleAward = {
	{"AddTimeTitle", 2048, -1},
	{"AddTimeTitle", 2049, -1},
	{"AddTimeTitle", 2049, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
	{"AddTimeTitle", 2050, -1},
};


-- 家族排名 拍卖对应分数
Boss.ZDef.KinRwardRankScore = {
	{Rank = 1, Score = 280000};  -- 第一名
	{Rank = 2, Score = 250000};  -- 第二名
	{Rank = 4, Score = 200000};  -- 第三名
	{Rank = 8, Score = 180000};
	{Rank = 12, Score = 80000};
	{Rank = 18, Score = 40000};
	{Rank = 24, Score = 20000};
	{Rank = math.huge, Score = 1000}; -- 25-无穷  0.6
};

-- 个人排名奖励
Boss.ZDef.tbPlayerBoxRankScore = {
	{Rank = 1, Honor = 1200};  -- 第一名
	{Rank = 2, Honor = 1000};  -- 第二名
	{Rank = 10, Honor = 950};
	{Rank = 20, Honor = 850};
	{Rank = 50, Honor = 700};
	{Rank = 100, Honor = 500};
	{Rank = 200, Honor = 180};
	{Rank = 400, Honor = 40};
	{Rank = 700, Honor = 30};
	{Rank = 1000, Honor = 20};
	{Rank = math.huge, Honor = 10};
};

-- 家族排名奖励
Boss.ZDef.tbKinBoxRankScore = {
	{Rank = 1, Honor = 1000};  -- 第一名
	{Rank = 2, Honor = 800};  -- 第二名
	{Rank = 4, Honor = 650};  -- 第三名
	{Rank = 8, Honor = 550};
	{Rank = 12, Honor = 250};
	{Rank = 18, Honor = 50};
	{Rank = 24, Honor = 40};
	{Rank = math.huge, Honor = 10}; -- 上面的排名之后到无穷大  0.6
};

-- 跨服武林盟主Boss配置
Boss.ZDef.tbBossSetting = {
	{TimeFrame = "OpenLevel89", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};           --开放89级上限
	{TimeFrame = "OpenLevel109", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897, 2189}}};           --开放109级上限
	{TimeFrame = "OpenLevel139", Data = {Hp = 2000000000, NpcIds = {3329}}};           --开放139级上限
};

-- 跨服盟主拍卖物品，格式参考CommonScript\BossDef.lua tbAuctionRewards
Boss.ZDef.tbAuctionRewards =
{
	{
		TimeFrame = "OpenLevel89";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0.25/5.5, Items = {1394}},						--名将令
					{nRate = 1/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.25/5.5, Items = {4307}},						--2级金属
					{nRate = 0.5/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {2979}},						--7阶稀有衣服碎片
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenLevel99";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0.25/5.5, Items = {1394}},						--名将令
					{nRate = 1/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.25/5.5, Items = {4307}},						--2级金属
					{nRate = 0.5/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {2980}},						--8阶稀有衣服碎片
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenDay188";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0.25/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.2/5.5, Items = {4307}},						--2级金属
					{nRate = 0.55/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {2980}},						--8阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenDay224";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},			--独孤剑同伴
					{nBossId = 1896, nRate = 1/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 1/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {2980}},						--8阶稀有衣服碎片
					{nRate = 1.25/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel109";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},		    --独孤剑同伴
					{nBossId = 1896, nRate = 1/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 1/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 1/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {2981}},						--9阶稀有衣服碎片
					{nRate = 1.25/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel119";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.75/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {3679}},						--10阶稀有衣服碎片
					{nRate = 1.5/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenDay399";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.75/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0.5/5.5, Items = {3679}},						--10阶稀有衣服碎片
					{nRate = 1.5/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel129";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.75/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.75/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0.5/5.5, Items = {5821}},						--11阶稀有衣服碎片
					{nRate = 1.5/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.75/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel139";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
					{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0/5.5, Items = {5822}},						--12阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.5/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel149";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
					{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0/5.5, Items = {5823}},						--13阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.2/5.5, Items = {6152}},						--真气丹5000
					{nRate = 0.3/5.5, Items = {10014}, bSilver = true},						--随侯珠
				};
	};
	{
		TimeFrame = "OpenLevel159";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
					{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0/5.5, Items = {5824}},						--14阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.2/5.5, Items = {6152}},						--真气丹5000
					{nRate = 0.3/5.5, Items = {10014}, bSilver = true},						--随侯珠
				};
	};
	{
		TimeFrame = "OpenLevel169";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
					{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0/5.5, Items = {5825}},						--15阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.2/5.5, Items = {6152}},						--真气丹5000
					{nRate = 0.3/5.5, Items = {10014}, bSilver = true},						--随侯珠
				};
	};
	{
		TimeFrame = "OpenLevel179";
		Rewards = {
					{nRate = 0/5.5, Items = {1393}},						--盟主令
					{nRate = 0/5.5, Items = {1394}},						--名将令
					{nRate = 0/5.5, Items = {1395}},						--逐鹿令
					--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
					{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
					{nRate = 0/5.5, Items = {4309}},						--4级金属
					{nRate = 0.5/5.5, Items = {4310}},						--5级金属
					{nRate = 0/5.5, Items = {10376}},						--16阶稀有衣服碎片
					{nRate = 1/5.5, Items = {1396}},						--帝皇令
					{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
					--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
					--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
					--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
					--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
					{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
					{nRate = 0/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.2/5.5, Items = {6152}},						--真气丹5000
					{nRate = 0.3/5.5, Items = {10014}, bSilver = true},						--随侯珠
				};
	};
	{
		TimeFrame = "OpenLevel189";
		Rewards = {
						{nRate = 0/5.5, Items = {1393}},						--盟主令
						{nRate = 0/5.5, Items = {1394}},						--名将令
						{nRate = 0/5.5, Items = {1395}},						--逐鹿令
						--{nBossId = 634, nRate = 1.5/5.5, Items = {1378}},		--独孤剑同伴
						--{nBossId = 1896, nRate = 1.5/5.5, Items = {2253}},	--南宫飞云同伴
						--{nBossId = 1897, nRate = 1.5/5.5, Items = {2254}},	--杨影枫同伴
						--{nBossId = 2189, nRate = 1.5/5.5, Items = {2255}},	--唐简同伴
						{nBossId = 3329, nRate = 1.5/5.5, Items = {3552}},		--鬼谷子同伴
						{nRate = 0/5.5, Items = {4309}},						--4级金属
						{nRate = 0.5/5.5, Items = {4310}},						--5级金属
						{nRate = 0.5/5.5, Items = {10979}},						--6级金属
						{nRate = 0/5.5, Items = {10376}},						--16阶稀有衣服碎片
						{nRate = 0.5/5.5, Items = {1396}},						--帝皇令
						{nRate = 0/5.5, Items = {3462}},						--赤金驭天绳碎片
						{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
						--{nBossId = 634, nRate = 1.5/5.5, Items = {2668}},		--魂石·独孤剑（唯一）
						--{nBossId = 1896, nRate = 1.5/5.5, Items = {2880}},	--南宫飞云魂石
						--{nBossId = 1897, nRate = 1.5/5.5, Items = {2881}},	--杨影枫魂石
						--{nBossId = 2189, nRate = 1.5/5.5, Items = {3897}},	--唐简魂石
						{nBossId = 3329, nRate = 0.75/5.5, Items = {9977}},		--鬼谷子魂石（阴）
						{nBossId = 3329, nRate = 0.75/5.5, Items = {9980}},		--鬼谷子魂石（阳）
						{nRate = 0/5.5, Items = {2396}},						--高级修为书
						{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
						{nRate = 0.2/5.5, Items = {6152}},						--真气丹5000
						{nRate = 0.3/5.5, Items = {10014}, bSilver = true},						--随侯珠
				};
	};
}

function Boss:GetCrossAuctionRewards()
	local tbCurAwards = Boss.ZDef.tbAuctionRewards[1].Rewards;
	for _, tbItem in ipairs(Boss.ZDef.tbAuctionRewards) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		tbCurAwards = tbItem.Rewards;
	end

	return tbCurAwards;
end

function Boss:GetCrossPlayerRankTitleAward(nRank)
	local tbAward = Boss.ZDef.tbPlayerRankTitleAward[nRank];
	if not tbAward then
		return;
	end

	tbAward[3] = GetTime() + 7 * 24 * 3600;
	return tbAward;
end