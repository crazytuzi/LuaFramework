Boss.Def = {
nRewardRate = 5;
nTimeDuration = 12 * 60;  -- 活动持续时间
nPlayerEnterLevel = 30;   -- 武林盟主参与等级限制
nFinishWaitTime = 5;      -- 最终分数结算超时

nRobCd = 180;       -- 抢夺CD
nRobHate = 30000;   -- 抢夺成功添加的仇恨值
nProtectRobCd = 60; -- 被抢夺后的保护时间
nExtraProtectRobCd = 120; -- 被抢夺成功追加的保护时间
nBossFightCd = 180; -- 攻击盟主的CD

nRobFightMap = 1017; -- 抢夺地图
nBossFightMap = 1017; -- 打boss地图

nSortRankWaitingTime = 5; -- 排序间隔时间
nCheckEndTime = 2;

tbNPC_POS =
{
	{	-- 我方点
		{2761, 2490,},
		{2184, 2490,},
		{1569, 2490,},
		{2761, 2787,},
		{2166, 2787,},
		{1559, 2787,},

	},
	{	-- 敌方点
		{1582, 1469,},
		{2221, 1466,},
		{2759, 1479,},
		{1582, 1150,},
		{2234, 1153,},
		{2770, 1171,},
	}
};

nRobBattleTime = 150; -- 抢夺战超时时间

nRobScoreBaseRateMin = 5; -- 抢分时最小基础分百分比
nRobScoreBaseRateMax = 20; -- 抢分时最大基础分百分比

nNoKinRewardScore = 1000; -- 没有家族时对应的家族奖励价值量
nNoKinIgnoreItemId = 1378; -- 无家族时的不可获得的ItemId, 此处是独孤剑同伴

nWeekendExtraAuctionActivityRate = 0.5; -- 周末额外奖励加成

tbServerFightFaction =	--某些门派因异步战斗问题需要在服务端进行战斗，换包请移除
{
};

-- 家族排名 拍卖对应分数
--[[KinRwardRankScore = {
	{Rank = 1, Score = 120000};  -- 第一名
	{Rank = 2, Score = 100000};  -- 第二名
	{Rank = 4, Score = 90000};  -- 第三名
	{Rank = 10, Score = 80000};
	{Rank = 20, Score = 75000};
	{Rank = 30, Score = 70000};
	{Rank = 40, Score = 60000};
	{Rank = math.huge, Score = 50000}; -- 41-无穷  0.6
};--]]

tbKinRewardRankScore = {
	{
		TimeFrame = "OpenLevel39";
		tbRankScore = {
			{Rank = 1, Score = 120000};  -- 第一名
			{Rank = 2, Score = 100000};  -- 第二名
			{Rank = 4, Score = 90000};  -- 第四名以上
			{Rank = 8, Score = 80000};
			{Rank = 12, Score = 75000};
			{Rank = 18, Score = 20000};
			{Rank = 24, Score = 5000};
			{Rank = math.huge, Score = 1000}; -- 41-无穷  0.6
		};
	};
	{
		TimeFrame = "OpenLevel99";
		tbRankScore = {
			{Rank = 1, Score = 150000};  -- 第一名
			{Rank = 2, Score = 120000};  -- 第二名
			{Rank = 4, Score = 110000};  -- 第四名以上
			{Rank = 8, Score = 96000};
			{Rank = 12, Score = 75000};
			{Rank = 18, Score = 20000};
			{Rank = 24, Score = 5000};
			{Rank = math.huge, Score = 1000}; -- 41-无穷  0.6
		};
	};
	{
		TimeFrame = "OpenLevel119";
		tbRankScore = {
			{Rank = 1, Score = 160000};  -- 第一名
			{Rank = 2, Score = 140000};  -- 第二名
			{Rank = 4, Score = 130000};  -- 第四名以上
			{Rank = 8, Score = 110000};
			{Rank = 12, Score = 75000};
			{Rank = 18, Score = 20000};
			{Rank = 24, Score = 5000};
			{Rank = math.huge, Score = 1000}; -- 41-无穷  0.6
		};
	};
};

-- 家族威望奖励
KinPrestigeRward = {
	{Rank = 1, Prestige = 100 * 2};
	{Rank = 2, Prestige = 80 * 2};
	{Rank = 3, Prestige = 60 * 2};
	{Rank = 4, Prestige = 50 * 2};
	{Rank = 6, Prestige = 40 * 2};
	{Rank = 11, Prestige = 35 * 2};
	{Rank = 16, Prestige = 30};
	{Rank = 21, Prestige = 20};
	{Rank = 26, Prestige = 10};
	{Rank = 36, Prestige = 5};
	{Rank = math.huge, Prestige = 1};
};


nBossHpMaxValue = 4000000000;

-- 武林盟主Boss配置
tbBossSetting = {
	{TimeFrame = "OpenDay1A", Data = {Hp = 5000000, NpcIds = {634}}};              --第1天晚上
	{TimeFrame = "OpenDay2A", Data = {Hp = 15000000, NpcIds = {634}}};             --第2天中午
	{TimeFrame = "OpenDay2C", Data = {Hp = 30000000, NpcIds = {634}}};             --第2天晚上
	{TimeFrame = "OpenDay3A", Data = {Hp = 80000000, NpcIds = {634,}}};             --第3天中午
	{TimeFrame = "OpenDay3B", Data = {Hp = 150000000, NpcIds = {634}}};            --第3天晚上
	{TimeFrame = "OpenLevel49", Data = {Hp = 200000000, NpcIds = {634}}};           --开服第5天，开放49级上限
	{TimeFrame = "OpenDay7", Data = {Hp = 200000000, NpcIds = {634}}};              --开服第7天
	{TimeFrame = "OpenDay10", Data = {Hp = 300000000, NpcIds = {634}}};             --开服第10天
	{TimeFrame = "OpenDay12", Data = {Hp = 500000000, NpcIds = {634}}};             --开服第12天
	{TimeFrame = "OpenLevel59", Data = {Hp = 800000000, NpcIds = {634}}};           --开服第15天，开放59级上限
	{TimeFrame = "OpenDay15", Data = {Hp = 800000000, NpcIds = {634}}};             --开服第15天
	{TimeFrame = "OpenDay20", Data = {Hp = 1200000000, NpcIds = {634}}};             --开服第20天
	{TimeFrame = "OpenLevel69", Data = {Hp = 1500000000, NpcIds = {63}}};           --开服第33天，开放69级上限
	{TimeFrame = "OpenDay33", Data = {Hp = 2000000000, NpcIds = {634}}};             --开服第33天
	{TimeFrame = "OpenDay45", Data = {Hp = 2000000000, NpcIds = {634}}};             --开服第45天
	{TimeFrame = "OpenLevel79", Data = {Hp = 2000000000, NpcIds = {634, 1896}}};           --开服第69天，开放79级上限（新增南宫飞云）
	{TimeFrame = "OpenDay70", Data = {Hp = 2000000000, NpcIds = {634, 1896}}};             --开服第70天
	{TimeFrame = "OpenDay90", Data = {Hp = 2000000000, NpcIds = {634, 1896}}};             --开服第90天
	{TimeFrame = "OpenDay100", Data = {Hp = 2000000000, NpcIds = {634, 1896}}};            --开服第100天
	{TimeFrame = "OpenLevel89", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};           --开服第114天，开放89级上限（新增杨影枫）
	{TimeFrame = "OpenDay130", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};            --开服第130天
	{TimeFrame = "OpenDay160", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};             --开服第160天
	{TimeFrame = "OpenDay180", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};             --开服第180天
	{TimeFrame = "OpenLevel99", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897}}};	        --开服第174天，开放99级上限
	{TimeFrame = "OpenLevel109", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897, 2189}}};	        --开服第249天，开放109级上限
	--{TimeFrame = "OpenLevel179", Data = {Hp = 2000000000, NpcIds = {634, 1896, 1897, 2189}}};	        --开服第249天，开放109级上限
};

tbBossHpStage = {
	{HpRate = 0.3, ScoreRate = 3, Texture = "BossStage03", RateTexture = "Points03"};
	{HpRate = 0.6, ScoreRate = 2, Texture = "BossStage02", RateTexture = "Points02"};
	{HpRate = math.huge, ScoreRate = 1, Texture = "BossStage01", RateTexture = "Points01"};
};

nBossKinMemberN = 5; -- 当家族参与人数达到此分后, 最低获取的贡献如下 nBossKinMemberNMinScore
nBossKinMemberNMinScore = 80;
nBossPlayerScoreN = 2000; -- 当玩家分数达到此分后, 最低获取的贡献如下 nBossPlayerScoreNMinScore
nBossPlayerScoreNMinScore = 80;

--奖励货币类型
szAwardMoneyType = "Contrib";
-- 个人排名奖励
tbPlayerBoxRankScore = {
	{Rank = 1, Honor = 300};  -- 第一名
	{Rank = 2, Honor = 260};  -- 第二名
	{Rank = 10, Honor = 240};
	{Rank = 20, Honor = 220};
	{Rank = 50, Honor = 200};
	{Rank = 100, Honor = 50};
	{Rank = 200, Honor = 30};
	{Rank = 400, Honor = 4};
	{Rank = 700, Honor = 3};
	{Rank = 1000, Honor = 2};
	{Rank = math.huge, Honor = 1};
};

-- 家族排名奖励
tbKinBoxRankScore = {
	{Rank = 1, Honor = 300};  -- 第一名
	{Rank = 2, Honor = 240};  -- 第二名
	{Rank = 4, Honor = 200};  -- 第三名
	{Rank = 8, Honor = 170};
	{Rank = 12, Honor = 70};
	{Rank = 18, Honor = 10};
	{Rank = 24, Honor = 5};
	{Rank = math.huge, Honor = 1}; -- 上面的排名之后到无穷大  0.6
};

-- 武林盟主 拍卖 物品
tbAuctionRewards = {
	{
		TimeFrame = "OpenLevel39";
		Rewards = {
					{nRate = 4.25/5.5, Items = {1393}},						--盟主令
					--{nBossId = 634, nRate = 0.5/5.5, Items = {1378}},		--独孤剑同伴
					{nRate = 1.25/5.5, Items = {1183}},						--T2稀有衣服
				};
	};
	{
		TimeFrame = "OpenLevel49";
		Rewards = {
					{nRate = 3.75/5.5, Items = {1393}},						--盟主令
					{nBossId = 634, nRate = 0.5/5.5, Items = {1378}},		--独孤剑同伴
					{nRate = 1.25/5.5, Items = {1184}},						--T3稀有衣服
				};
	};
	{
		TimeFrame = "OpenLevel59";
		Rewards = {
					{nRate = 2/5.5, Items = {1393}},						--盟主令
					{nRate = 1/5.5, Items = {1394}},						--名将令
					{nBossId = 634, nRate = 0.75/5.5, Items = {1378}},		--独孤剑同伴
					{nRate = 1.25/5.5, Items = {2124}},						--T4稀有衣服碎片
					{nRate = 0.5/5.5, Items = {4307}},						--2级金属
				};
	};
	{
		TimeFrame = "OpenLevel69";
		Rewards = {
					{nRate = 0.5/5.5, Items = {1393}},						--盟主令
					{nRate = 1.5/5.5, Items = {1394}},						--名将令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},			--独孤剑同伴
					{nRate = 0.75/5.5, Items = {4307}},						--2级金属
					{nRate = 1/5.5, Items = {2125}},						--T5稀有衣服碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--独孤剑魂石
				};
	};
	{
		TimeFrame = "OpenDay42";
		Rewards = {
					{nRate = 0.5/5.5, Items = {1393}},						--盟主令
					{nRate = 1.25/5.5, Items = {1394}},						--名将令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},			--独孤剑同伴
					{nRate = 0.75/5.5, Items = {4307}},						--2级金属
					{nRate = 0.75/5.5, Items = {2125}},						--T5稀有衣服碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--独孤剑魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
				};
	};
	{
		TimeFrame = "OpenLevel79";
		Rewards = {
					{nRate = 0.25/5.5, Items = {1393}},						--盟主令
					{nRate = 0.75/5.5, Items = {1394}},						--名将令
					{nRate = 0.75/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},			--独孤剑同伴
					{nBossId = 1896, nRate = 1/5.5, Items = {2253}},		--南宫飞云同伴
					{nRate = 0.75/5.5, Items = {4307}},						--2级金属
					--{nRate = 0.5/5.5, Items = {4308}},					--3级金属
					{nRate = 0.75/5.5, Items = {2126}},						--T6稀有衣服碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2880}},		--南宫飞云魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
				};
	};
	{
		TimeFrame = "OpenDay99";
		Rewards = {
					{nRate = 0.25/5.5, Items = {1393}},						--盟主令
					{nRate = 0.75/5.5, Items = {1394}},						--名将令
					{nRate = 0.75/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 1/5.5, Items = {1378}},			--独孤剑同伴
					{nBossId = 1896, nRate = 1/5.5, Items = {2253}},		--南宫飞云同伴
					{nRate = 0.25/5.5, Items = {4307}},						--2级金属
					{nRate = 0.5/5.5, Items = {4308}},						--3级金属
					{nRate = 0.75/5.5, Items = {2126}},						--T6稀有衣服碎片
					{nBossId = 634, nRate = 0.75/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.75/5.5, Items = {2880}},		--南宫飞云魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
				};
	};
	{
		TimeFrame = "OpenLevel89";
		Rewards = {
					{nRate = 0.25/5.5, Items = {1393}},						--盟主令
					{nRate = 0.5/5.5, Items = {1394}},						--名将令
					{nRate = 0.75/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.5/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.25/5.5, Items = {4307}},						--2级金属
					{nRate = 0.5/5.5, Items = {4308}},						--3级金属
					{nRate = 0.5/5.5, Items = {2979}},						--T7稀有衣服碎片
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenLevel99";
		Rewards = {
					{nRate = 0.25/5.5, Items = {1393}},						--盟主令
					{nRate = 0.5/5.5, Items = {1394}},						--名将令
					{nRate = 0.75/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.5/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.2/5.5, Items = {4307}},						--2级金属
					{nRate = 0.55/5.5, Items = {4308}},						--3级金属
					--{nRate = 0.5/5.5, Items = {4309}},					--4级金属
					{nRate = 0.5/5.5, Items = {2980}},						--T8稀有衣服碎片
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenDay188";
		Rewards = {
					{nRate = 0.25/5.5, Items = {1393}},						--盟主令
					{nRate = 0.25/5.5, Items = {1394}},						--名将令
					{nRate = 0.5/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.5/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.25/5.5, Items = {4307}},						--2级金属
					{nRate = 0.55/5.5, Items = {4308}},						--3级金属
					--{nRate = 0.5/5.5, Items = {4309}},					--4级金属
					{nRate = 0.5/5.5, Items = {2980}},						--T8稀有衣服碎片
					{nRate = 0.5/5.5, Items = {1396}},						--帝皇令
					{nRate = 0.5/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.25/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0.5/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.5/5.5, Items = {2804}},						--和氏璧
				};
	};
	{
		TimeFrame = "OpenDay224";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.1/5.5, Items = {1394}},						--名将令
					{nRate = 0.15/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nRate = 0.1/5.5, Items = {4308}},						--3级金属
					{nRate = 0.25/5.5, Items = {4309}},						--4级金属
					{nRate = 0.2/5.5, Items = {2980}},						--T8稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.15/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nRate = 0.25/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.25/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel109";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.1/5.5, Items = {1394}},						--名将令
					{nRate = 0.15/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4308}},						--3级金属
					{nRate = 0.25/5.5, Items = {4309}},						--4级金属
					{nRate = 0.2/5.5, Items = {2981}},						--T9稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.15/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.25/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.25/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel119";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.1/5.5, Items = {1394}},						--名将令
					{nRate = 0.15/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4308}},						--3级金属
					{nRate = 0.25/5.5, Items = {4309}},						--4级金属
					--{nRate = 0.5/5.5, Items = {4310}},					--5级金属
					{nRate = 0.2/5.5, Items = {3679}},						--T10稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.15/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.25/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.25/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenDay399";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.1/5.5, Items = {1394}},						--名将令
					{nRate = 0.15/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.2/5.5, Items = {3679}},						--T10稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.15/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.25/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.25/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel129";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.1/5.5, Items = {1394}},						--名将令
					{nRate = 0.15/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.2/5.5, Items = {5821}},						--T11稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.15/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.5/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.5/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.5/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.5/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.25/5.5, Items = {2396}},						--高级修为书
					{nRate = 0.25/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel139";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.05/5.5, Items = {1394}},						--名将令
					{nRate = 0.05/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.15/5.5, Items = {5822}},						--T12稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.05/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.15/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.15/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.15/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.15/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.15/5.5, Items = {2396}},						--高级修为书
					{nRate = 1/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel149";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.05/5.5, Items = {1394}},						--名将令
					{nRate = 0.05/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.15/5.5, Items = {5823}},						--T13稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.05/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.15/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.15/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.15/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.15/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.15/5.5, Items = {2396}},						--高级修为书
					{nRate = 1/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel159";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.05/5.5, Items = {1394}},						--名将令
					{nRate = 0.05/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.15/5.5, Items = {5824}},						--T14稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.05/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.15/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.15/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.15/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.15/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.15/5.5, Items = {2396}},						--高级修为书
					{nRate = 1/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel169";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.05/5.5, Items = {1394}},						--名将令
					{nRate = 0.05/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.15/5.5, Items = {5825}},						--T15稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.05/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.15/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.15/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.15/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.15/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.15/5.5, Items = {2396}},						--高级修为书
					{nRate = 1/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel179";
		Rewards = {
					{nRate = 0.1/5.5, Items = {1393}},						--盟主令
					{nRate = 0.05/5.5, Items = {1394}},						--名将令
					{nRate = 0.05/5.5, Items = {1395}},						--逐鹿令
					{nBossId = 634, nRate = 0.35/5.5, Items = {1378}},		--独孤剑同伴
					{nBossId = 1896, nRate = 0.35/5.5, Items = {2253}},		--南宫飞云同伴
					{nBossId = 1897, nRate = 0.35/5.5, Items = {2254}},		--杨影枫同伴
					{nBossId = 2189, nRate = 0.35/5.5, Items = {2255}},		--唐简同伴
					{nRate = 0.1/5.5, Items = {4309}},						--4级金属
					{nRate = 0.25/5.5, Items = {4310}},						--5级金属
					{nRate = 0.15/5.5, Items = {10376}},						--T16稀有衣服碎片
					{nRate = 1.55/5.5, Items = {1396}},						--帝皇令
					{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
					{nRate = 0.05/5.5, Items = {3461}},						--苍虹降龙绳碎片
					{nBossId = 634, nRate = 0.15/5.5, Items = {2668}},		--独孤剑魂石
					{nBossId = 1896, nRate = 0.15/5.5, Items = {2880}},		--南宫飞云魂石
					{nBossId = 1897, nRate = 0.15/5.5, Items = {2881}},		--杨影枫魂石
					{nBossId = 2189, nRate = 0.15/5.5, Items = {3897}},		--唐简魂石
					{nRate = 0.15/5.5, Items = {2396}},						--高级修为书
					{nRate = 1/5.5, Items = {2804}},						--和氏璧
					{nRate = 0.55/5.5, Items = {6152}},						--真气丹5000
				};
	};
	{
		TimeFrame = "OpenLevel189";
		Rewards = {
						{nRate = 0.1/5.5, Items = {1393}},						--盟主令
						{nRate = 0/5.5, Items = {1394}},						--名将令
						{nRate = 0/5.5, Items = {1395}},						--逐鹿令
						{nBossId = 634, nRate = 0.15/5.5, Items = {1378}},		--独孤剑同伴
						{nBossId = 1896, nRate = 0.15/5.5, Items = {2253}},		--南宫飞云同伴
						{nBossId = 1897, nRate = 0.15/5.5, Items = {2254}},		--杨影枫同伴
						{nBossId = 2189, nRate = 0.15/5.5, Items = {2255}},		--唐简同伴
						{nRate = 0.1/5.5, Items = {4309}},						--4级金属
						{nRate = 0.2/5.5, Items = {4310}},						--5级金属
						{nRate = 0.25/5.5, Items = {10979}},					--6级金属
						{nRate = 0.1/5.5, Items = {10377}},						--T17稀有衣服碎片
						{nRate = 1/5.5, Items = {1396}},						--帝皇令
						{nRate = 1/5.5, Items = {3462}},						--赤金驭天绳碎片
						{nRate = 0/5.5, Items = {3461}},						--苍虹降龙绳碎片
						{nBossId = 634, nRate = 0/5.5, Items = {2668}},		--独孤剑魂石
						{nBossId = 1896, nRate = 0/5.5, Items = {2880}},		--南宫飞云魂石
						{nBossId = 1897, nRate = 0/5.5, Items = {2881}},		--杨影枫魂石
						{nBossId = 2189, nRate = 0/5.5, Items = {3897}},		--唐简魂石
						{nRate = 0.1/5.5, Items = {2396}},						--高级修为书
						{nRate = 1.75/5.5, Items = {2804}},						--和氏璧
						{nRate = 0.75/5.5, Items = {6152}},						--真气丹5000
				};
	};
};

nJoinBossContrib = 0; -- 每轮参与时给予【200贡献】的参与奖励
}

-- 各战力玩家, 打盟主时的最大合理原始分范围.. {战力, 原始分}
Boss.Def.tbLegalBossFightScore = {
	{20000000, 1800000},
	{18000000, 1500000},
	{16000000, 1250000},
	{14000000, 1000000},
	{12000000, 850000},
	{10000000, 700000},
	{8000000, 550000},
	{6000000, 450000},
	{5000000, 337500},
	{4000000, 225000},
	{3000000, 180000},
	{2000000, 135000},
	{1000000, 115000},
	{500000, 67500},
	{300000, 30000},
	{200000, 22500},
	{100000, 16500},
	{50000, 13500},
	{0, 6000},
};

Boss.Def.nMaxFightBossScoreScaleRate = 2; -- 客户端打盟主时的最大得分倍率, 与服务端对比
Boss.Def.nFightBossScoreExpireTime = 24 * 3600 * 7; -- 服务端盟主分数过期时间
Boss.Def.BOSS_FIGHT_SCORE_GROUP = 100;
Boss.Def.BOSS_FIGHT_SCORE_TIME  = 1;
Boss.Def.BOSS_FIGHT_SCORE_SCORE = 2;

function Boss:GetLimitBossFightScore(pPlayer)
	local nNow = GetTime();
	local nLastServerTime = pPlayer.GetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_TIME);
	local nLastServerScore = pPlayer.GetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_SCORE);
	if nNow - nLastServerTime < Boss.Def.nFightBossScoreExpireTime and nLastServerScore > 0 then
		return nLastServerScore * Boss.Def.nMaxFightBossScoreScaleRate;
	end

	local nFightPower = pPlayer.GetFightPower();
	local tbLastInfo = Boss.Def.tbLegalBossFightScore[1];
	for _, tbInfo in ipairs(Boss.Def.tbLegalBossFightScore) do
		if nFightPower > tbInfo[1] then
			return tbInfo[2];
		end
		tbLastInfo = tbInfo;
	end
	return tbLastInfo[2];
end

function Boss:UpdateServerBossFightScore(pPlayer, nOrgScore)
	local nNow = GetTime();
	pPlayer.SetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_TIME, nNow);
	pPlayer.SetUserValue(Boss.Def.BOSS_FIGHT_SCORE_GROUP, Boss.Def.BOSS_FIGHT_SCORE_SCORE, nOrgScore);
end

function Boss:GetAuctionRewards()
	local tbCurAwards = Boss.Def.tbAuctionRewards[1].Rewards;
	for _, tbItem in ipairs(Boss.Def.tbAuctionRewards) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		tbCurAwards = tbItem.Rewards;
	end

	return tbCurAwards;
end

function Boss:GetBossHpStageInfo(nHpRate)
	for _, tbStageInfo in ipairs(Boss.Def.tbBossHpStage) do
		if nHpRate <= tbStageInfo.HpRate then
			return tbStageInfo.ScoreRate, tbStageInfo.RateTexture, tbStageInfo.Texture;
		end
	end
	Log("Error:Wrong in GetBossHpStageInfo");
	return 1, "Points01", "Error:Wrong in GetBossHpStageInfo";
end

function Boss:CanJoinBoss(pPlayer)
	return AsyncBattle:CanStartAsyncBattle(pPlayer) or Map:IsKinMap(pPlayer.nMapTemplateId);
end

function Boss:IsFightMap(nMapTemplateId)
	return Map:IsKinMap(nMapTemplateId) or AsyncBattle.ASYNC_BATTLE_MAP_TYPE[Map:GetClassDesc(nMapTemplateId)];
end

function Boss:IsAuctionRewardOnSale()
	-- if Sdk:IsEfunHKTW() then
	-- 	return Sdk.Def.bIsEfunTWHKWeekendActOpen;
	-- end

	local nWeekDay = Lib:GetLocalWeekDay();
	return nWeekDay == 6 or nWeekDay == 7;
end

function Boss:GetAuctionRewardScale()
	local nExtraReward = 0;
	if Boss:IsAuctionRewardOnSale() then
		nExtraReward = nExtraReward + Boss.Def.nWeekendExtraAuctionActivityRate;
	end

	if self.nActivityRewardExtraRate then
		nExtraReward = nExtraReward + self.nActivityRewardExtraRate;
	end

	return 1 + nExtraReward;
end

function Boss:SetActivityRewardExtraRate(nExtraRate)
	self.nActivityRewardExtraRate = nExtraRate;
end

function Boss:GetCurTimeKinRewardRankScore()
	local tbCurRankScore = Boss.Def.tbKinRewardRankScore[1].tbRankScore;
	for _, tbItem in ipairs(Boss.Def.tbKinRewardRankScore) do
		if GetTimeFrameState(tbItem.TimeFrame) ~= 1 then
			break;
		end
		tbCurRankScore = tbItem.tbRankScore;
	end

	return tbCurRankScore;
end