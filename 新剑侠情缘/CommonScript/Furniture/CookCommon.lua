Require("CommonScript/Item/Class/RandomItem.lua")

Furniture.Cook = Furniture.Cook or {}
local Cook = Furniture.Cook

Cook.Def = {
	szOpenFrame = "OpenLevel109",	--开启时间轴
	szMinLevel = 90,	--玩家最低等级

	nAuctionCostItem = 11733,	--拍卖消耗道具
	tbAddActionTime = {8 * 3600, 19 * 3600},	--允许上架的时间段

	nFurnitureTemplateId = 11642,	--灶台家具id，用于任务系统
	nMaterialKindMin = 1000,	--食材类型id最小值，用于与食材id区分

	tbExtraBuffs = {	--吃菜获得额外buff
		-- 活动加成buff
		5901, 5902, 5903, 5904, 5905, 5906, 5907, 5908, 5909, 5910,
		5911, 5912, 5913, 5914, 5915, 5916, 5917, 5918, 5919, 5920,
		5921, 5922, 5923, 5925, 5926, 5927, 5928, 5929, 5930, 5931,
		5932, 5933, 5934, 5935, 5936, 5937, 5938, 5939, 5940,
		5941, 5942, 5943, 5944, 5945, 5946, 5947, 5948, 5949, 5950,
		5951, 5952, 5953, 5954, 5955, 5956, 5957, 5958, 5959, 5960,
		5961, 5962, 5963, 5964, 5965, 5966, 5967, 5968, 5969, 5970,

		-- 其他buff
	},

	nHuntingMapId = 1703,	--猎场地图id
	nFishingMapId = 1702,	--渔场地图id
	tbFishingPos = {9350, 2783}, --渔场玩家坐标

	-- 任务设置，概率分母均为10000
	tbTask = {
		nMax = 3,	--领取上限
		nRateNormal = 8000,	--普通玩家触发任务概率
		nRateSmall = 6000,	--小号玩家触发任务概率
		tbCfg = {
			[1] = {	--普通
				nRateNormal = 6000,	--奖励等级概率(普通)
				nRateSmall = 9000,	--奖励等级概率(小号)
				tbMaterials = {	--奖励食材配置
					{11378, 2500},	--{食材道具id, 概率}
					{11381, 2500},
					{11384, 2500},
					{11390, 2500},
				},
			},
			[2] = {	--珍品
				nRateNormal = 3000,
				nRateSmall = 1000,
				tbMaterials = {
					{11379, 2500},	--{食材道具id, 概率}
					{11382, 2500},
					{11385, 2500},
					{11391, 2500},
				},
			},
			[3] = {	--绝品
				nRateNormal = 1000,
				nRateSmall = 0,
				tbMaterials = {
					{11380, 2500},	--{食材道具id, 概率}
					{11383, 2500},
					{11386, 2500},
					{11392, 2500},
				},
			},
		},
	},

	-- 采集食材(客户端)
	tbClientGatherMaterial = {
		[3756] = {	-- 普通水
			tbMaterial = { --产出材料列表
				{1, 9000}, --{材料id, 概率（分母为10000）}
				{2, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[10] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{9131	,22487	},
					{11888	,22999	},
					{13292	,21261	},
					{16996	,19129	},
					{17019	,18070	},
					{14241	,11736	},
					{11928	,8885	},
					{11983	,9342	},
					{8620	,11016	},
					{6844	,15180	},
				},
				[15] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{15453	,16557	},
					{16184	,16184	},
					{14028	,16125	},
					{6763	,17676	},
					{5378	,15693	},
					{6184	,14700	},
					{9120	,7009	},
					{2928	,11431	},
					{19131	,11293	},
					{13322	,4306	},
				},
				[418] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{2666	,12297	},
					{9224	,14607	},
					{12676	,8883	},
					{12563	,5656	},
					{12543	,3632	},
					{6777	,6846	},
					{6010	,9548	},

				},
			},
		},
		[3758] = {	-- 普通菜
			tbMaterial = { --产出材料列表
				{13, 9000}, --{材料id, 概率（分母为10000）}
				{14, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[404] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{11512	,2738	},
					{11148	,4050	},
					{13471	,6020	},
					{9037	,5744	},
					{7546	,9969	},
					{3862	,10336	},
					{4107	,13163	},
					{5772	,14199	},
					{13709	,11750	},

				},
				[405] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{3939	,3386	},
					{3237	,11324	},
					{6064	,10423	},
					{8760	,10203	},
					{14562	,14299	},
					{14765	,10480	},


				},
				[407] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{3019	,13390	},
					{5765	,13973	},
					{14012	,11934	},
					{12266	,9351	},
					{5750	,3578	},
					{8309	,7260	},
					{9438	,10310	},
				},
			},
		},
		[3760] = {	-- 普通鸡蛋
			tbMaterial = { --产出材料列表
				{19, 9000}, --{材料id, 概率（分母为10000）}
				{20, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[402] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{7791	,3311	},
					{8730	,6015	},
					{11497	,11772	},
					{6003	,11374	},
					{2509	,8662	},
					{2485	,7382	},
					{4213	,6693	},
					{4703	,8117	},
					{9071	,9657	},


				},
				[408] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{16244	,10964	},
					{14162	,10614	},
					{3858	,6404	},
					{3731	,4557	},
					{7158	,3492	},
					{8266	,5535	},
					{8592	,9769	},

				},
				[410] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{8356	,14108	},
					{6858	,12725	},
					{4192	,12223	},
					{5982	,3587	},
					{11963	,3752	},
					{13895	,7656	},
					{9553	,7131	},

				},
			},
		},
		[3762] = {	-- 普通香菇
			tbMaterial = { --产出材料列表
				{22, 9000}, --{材料id, 概率（分母为10000）}
				{23, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[401] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{11116	,12352	},
					{4370	,13527	},
					{1435	,7109	},
					{12041	,2017	},
				},
				[406] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{5610	,12741	},
					{8697	,12352	},
					{10515	,11973	},
					{12403	,10759	},
					{10428	,9723	},
					{11961	,6889	},
					{10965	,5040	},
				},
				[413] = {	-- map
					tbCount = {1, 2},	-- 每次刷新个数上下限
					{8356	,14108	},
					{6858	,12725	},
					{4192	,12223	},
					{5982	,3587	},
					{11963	,3752	},
					{13895	,7656	},
					{9553	,7131	},
				},
			},
		},
		[3764] = {	-- 普通辣椒
			tbMaterial = { --产出材料列表
				{25, 9000}, --{材料id, 概率（分母为10000）}
				{26, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[420] = {	-- map
					tbCount = {2, 5},	-- 每次刷新个数上下限
					{12707	,4558	},
					{7270	,2790	},
					{2939	,5685	},
					{1569	,9799	},
					{4011	,12410	},
					{8008	,9231	},
					{5312	,6608	},
				},
			},
		},
		[3766] = {	-- 普通银耳
			tbMaterial = { --产出材料列表
				{28, 9000}, --{材料id, 概率（分母为10000）}
				{29, 1000},
			},
			nConsumeItemId = 101,	--消耗材料id
			tbMaps = {
				[416] = {	-- map
					tbCount = {2, 5},	-- 每次刷新个数上下限
					{13126	,11476	},
					{13014	,9752	},
					{11853	,6058	},
					{8900	,6071	},
					{5122	,4237	},
					{10877	,2864	},
					{12354	,3750	},
				},
			},
		},
		--[3768] = {	-- 普通虾
		--	tbMaterial = { --产出材料列表
		--		{40, 9000}, --{材料id, 概率（分母为10000）}
		--		{41, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[403] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{9564	,3395	},
		--			{6319	,3833	},
		--			{5950	,4183	},
		--			{6444	,7077	},
--
		--		},
		--	},
		--},
		--[3770] = {	-- 普通螃蟹
		--	tbMaterial = { --产出材料列表
		--		{43, 9000}, --{材料id, 概率（分母为10000）}
		--		{44, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[412] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{12141	,5445	},
		--			{14402	,4119	},
		--			{12386	,3386	},
		--			{11024	,3742	},
		--			{6772	,3307	},
		--		},
		--	},
		--},
		--[3772] = {	-- 普通鲤鱼
		--	tbMaterial = { --产出材料列表
		--		{46, 9000}, --{材料id, 概率（分母为10000）}
		--		{47, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[400] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{2917	,8370	},
		--			{3087	,12408	},
		--			{9644	,14920	},
--
		--		},
		--	},
		--},
		--[3774] = {	-- 普通鲈鱼
		--	tbMaterial = { --产出材料列表
		--		{49, 9000}, --{材料id, 概率（分母为10000）}
		--		{50, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[1000] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{4912	,2108	},
		--			{5651	,2990	},
		--			{4474	,2514	},
		--			{7260	,5095	},
		--			{6200	,5120	},
		--		},
		--	},
		--},
		--[3776] = {	-- 普通银鱼
		--	tbMaterial = { --产出材料列表
		--		{52, 9000}, --{材料id, 概率（分母为10000）}
		--		{53, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[411] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{6767	,3169	},
		--			{2247	,8472	},
		--			{14677	,9888	},
		--			{14319	,5388	},
		--		},
		--	},
		--},
		--[3778] = {	-- 普通鳗鱼
		--	tbMaterial = { --产出材料列表
		--		{55, 9000}, --{材料id, 概率（分母为10000）}
		--		{56, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[421] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{7346	,8213	},
		--			{9157	,7415	},
		--			{12078	,6743	},
		--			{5073	,6406	},
		--			{5376	,4369	},
		--			{9708	,5631	},
		--			{11938	,7738	},
--
		--		},
		--	},
		--},
		--[3780] = {	-- 普通河豚
		--	tbMaterial = { --产出材料列表
		--		{58, 9000}, --{材料id, 概率（分母为10000）}
		--		{59, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[403] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{4766	,5764	},
		--			{5495	,6095	},
		--			{3310	,8814	},
--
		--		},
		--	},
		--},
		--[3782] = {	-- 普通江团
		--	tbMaterial = { --产出材料列表
		--		{61, 9000}, --{材料id, 概率（分母为10000）}
		--		{62, 1000},
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbMaps = {
		--		[419] = {	-- map
		--			tbCount = {2, 5},	-- 每次刷新个数上下限
		--			{7154	,4773	},
		--			{7243	,5992	},
		--			{8817	,3965	},
		--			{8505	,6350	},
		--			{7152	,7215	},
		--		},
		--	},
		--},
	},

	-- 采集食材(服务端)
	tbServerGatherMaterial = {
		[3757] = {	-- 高级水
			tbRespawnTimes = {9, 12},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{3, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{10,7608	,10857	},
				{10,11325	,8916	},
				{10,14275	,11469	},
				{10,7862	,12658	},
				{10,8517	,19464	},
				{15,6855	,18180	},
				{15,6816	,15702	},
				{15,13337	,8642	},
				{15,10306	,4514	},
				{15,6360	,7512	},
				{15,13498	,17001	},
				{15,1057	,11238	},
				{418,2006	,2257	},
				{418,14305	,13267	},
				{418,1070	,15468	},
			},
		},
		[3759] = {	-- 高级菜
			tbRespawnTimes = {5, 7},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{15, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{404,15138	,8964	},
				{404,13663	,2782	},
				{404,4727	,2991	},
				{404,3759	,6980	},
				{404,8614	,13725	},
				{405,14080	,5515	},
				{405,16545	,7945	},
				{405,9666	,14608	},
				{405,5721	,13820	},
				{405,3194	,12306	},
				{407,8435	,2993	},
				{407,11657	,3168	},
				{407,15325	,6509	},
				{407,1358	,10193	},
				{407,6728	,13119	},

			},
		},
		[3761] = {	-- 高级鸡蛋
			tbRespawnTimes = {9, 12},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{21, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{402,1893	,2866	},
				{402,2925	,11862	},
				{402,12657	,2990	},
				{402,9266	,12328	},
				{408,3488	,3773	},
				{408,15508	,3709	},
				{408,15235	,15064	},
				{408,6870	,14115	},
				{408,2819	,15252	},
				{410,8690	,1821	},
				{410,13854	,5607	},
				{410,3216	,4041	},
				{410,1913	,8968	},
				{410,13319	,13645	},

			},
		},
		[3763] = {	-- 高级香菇
			tbRespawnTimes = {5, 7},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{24, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{401,3205	,1831	},
				{401,1900	,2984	},
				{401,2460	,7478	},
				{401,12375	,11403	},
				{401,13605	,7387	},
				{401,12428	,3804	},
				{401,7281	,3839	},
				{401,6782	,7096	},
				{406,9717	,1983	},
				{406,3695	,1288	},
				{406,1809	,4746	},
				{406,1689	,10155	},
				{406,3075	,12600	},
				{413,11803	,2705	},
				{413,13693	,3599	},
				{413,13790	,13994	},
				{413,2570	,7111	},
				{413,3306	,2844	},
			},
		},
		[3765] = {	-- 高级辣椒
			tbRespawnTimes = {1, 3},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{27, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{420,13158	,2360	},
				{420,6145	,12855	},
				{420,12368	,13366	},
				{420,12982	,7952	},
				{420,13333	,6735	},
			},
		},
		[3767] = {	-- 高级银耳
			tbRespawnTimes = {1, 3},	--每天刷新次数上下限
			tbMaterial = { --产出材料列表
				{30, 10000}, --{材料id, 概率（分母为10000）}
			},
			nConsumeItemId = 101,	--消耗材料id
			tbCount = {1, 1},	-- 每次刷新个数上下限
			tbPoints = {
				{416,12620	,2228	},
				{416,1992	,2989	},
				{416,2287	,9102	},
				{416,2370	,13351	},
				{416,12778	,12912	},
			},
		},
		--[3769] = {	-- 高级虾
		--	tbRespawnTimes = {5, 7},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{42, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{403,14239	,2879	},
		--		{403,10687	,3157	},
		--		{403,3576	,11606	},
--
		--	},
		--},
		--[3771] = {	-- 高级螃蟹
		--	tbRespawnTimes = {1, 3},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{45, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{412,7832	,2345	},
		--		{412,11243	,3765	},
		--		{412,14682	,5780	},
--
		--	},
		--},
		--[3773] = {	-- 高级鲤鱼
		--	tbRespawnTimes = {5, 7},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{48, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{400,13790	,4293	},
		--		{400,8486	,1617	},
		--		{400,2981	,11172	},
		--		{400,9092	,14929	},
--
		--	},
		--},
		--[3775] = {	-- 高级鲈鱼
		--	tbRespawnTimes = {5, 7},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{51, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{1000,6596	,5286	},
		--		{1000,5099	,2330	},
		--		{1000,3666	,4440	},
--
		--	},
		--},
		--[3777] = {	-- 高级银鱼
		--	tbRespawnTimes = {1, 3},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{54, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{411,14396	,5312	},
		--		{411,14655	,10177	},
		--		{411,2225	,8768	},
		--	},
		--},
		--[3779] = {	-- 高级鳗鱼
		--	tbRespawnTimes = {1, 3},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{57, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{421,6468	,4750	},
		--		{421,5631	,4398	},
		--		{421,15436	,7006	},
		--		{421,15746	,4550	},
		--		{421,4910	,14677	},
		--	},
		--},
		--[3781] = {	-- 高级河豚
		--	tbRespawnTimes = {1, 3},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{60, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{403,3276	,4967	},
		--		{403,3284	,8152	},
		--		{403,3199	,12215	},
--
		--	},
		--},
		--[3783] = {	-- 高级江团
		--	tbRespawnTimes = {1, 3},	--每天刷新次数上下限
		--	tbMaterial = { --产出材料列表
		--		{63, 10000}, --{材料id, 概率（分母为10000）}
		--	},
		--	nConsumeItemId = 101,	--消耗材料id
		--	tbCount = {1, 1},	-- 每次刷新个数上下限
		--	tbPoints = {
		--		{419,7670	,3504	},
		--		{419,6011	,3379	},
		--		{419,5483	,7765	},
		--	},
		--},
	},

	-- 服务器采集刷新配置
	nServerGatherLiveTime = 3 * 3600,	--存活时间
	tbServerGatherRespawn = {
		{"0:00", "2:00", 1},	--开始时间，结束时间，概率权值
		{"2:00", "4:00", 1},
		{"4:00", "6:00", 1},
		{"6:00", "8:00", 1},
		{"8:00", "10:00", 2},
		{"10:00", "12:00", 2},
		{"12:00", "14:00", 3},
		{"14:00", "16:00", 3},
		{"16:00", "18:00", 3},
		{"18:00", "20:00", 4},
		{"20:00", "22:00", 4},
		{"22:00", "24:00", 4},
	},

	-- 钓鱼相关配置
	tbFishingCfg = {
		nHookTime = 1.5,	--上钩持续时间（秒）
		nTaskId = 3612,	--钓鱼任务id
		nBestFishDailyLimit = 3,	--绝品鱼每日限制
		tbFoods = {	--鱼饵
			{
				102, 25, 55, 0, 1, --食材id, 上钩时间下限（秒），上钩时间上限, 宝箱概率(分母10000), 鱼篓特殊配置
				tbQuality = {	--品质
					{0, {10000, 0, 0, 0}},	--{进度条百分比下限, {miss概率，品质1概率，品质2概率，品质3概率}}
					{1, {8000, 2000, 0, 0}},
					{10, {7000, 3000, 0, 0}},
					{20, {6000, 4000, 0, 0}},
					{30, {5000, 5000, 0, 0}},
					{40, {4000, 6000, 0, 0}},
					{50, {3000, 6500, 500, 0}},
					{60, {2500, 6500, 1500, 0}},
					{70, {2000, 6500, 1500, 0}},
					{80, {1500, 6500, 2000, 0}},
					{90, {1000, 6500, 2500, 0}},
				},
			},
			{
				103, 15, 35, 0, 2,
				tbQuality = {	--品质
					{0, {10000, 0, 0, 0}},	--{进度条百分比下限, {miss概率，品质1概率，品质2概率，品质3概率}}
					{1, {8000, 2000, 0, 0}},
					{10, {7000, 3000, 0, 0}},
					{20, {6000, 4000, 0, 0}},
					{30, {5000, 5000, 0, 0}},
					{40, {4000, 6000, 0, 0}},
					{50, {3000, 6500, 500, 0}},
					{60, {2500, 3500, 1000, 0}},
					{70, {2000, 6000, 2000, 0}},
					{80, {1000, 5500, 3000, 500}},
					{90, {500, 4500, 4000, 1000}},
				},
			},
			{
				104, 15, 35, 1500, 2,
				tbQuality = {	--品质
					{0, {10000, 0, 0, 0}},	--{进度条百分比下限, {miss概率，品质1概率，品质2概率，品质3概率}}
					{1, {8000, 2000, 0, 0}},
					{10, {7000, 3000, 0, 0}},
					{20, {6000, 4000, 0, 0}},
					{30, {5000, 5000, 0, 0}},
					{40, {4000, 6000, 0, 0}},
					{50, {3000, 6500, 500, 0}},
					{60, {2500, 6500, 1000, 0}},
					{70, {2000, 5500, 2000, 500}},
					{80, {1000, 5000, 3000, 1000}},
					{90, {500, 2500, 5000, 2000}},
				},
			},
		},

		tbMaps = {	--地图
			[1000] = {
				{49, 50, 51, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  忘忧岛——鲈鱼
			},
			[400] = {
				{46, 47, 48, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  锁云渊——鲤鱼
			},
			[403] = {
				{40, 41, 42, 7000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  洞庭湖畔——虾、河豚
				{58, 59, 60, 3000},
			},
			[419] = {
				{61, 62, 63, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  风陵渡——江团
			},
			[411] = {
				{43, 44, 45, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  伏牛山——螃蟹
			},
			[412] = {
				{52, 53, 54, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  古战场——银鱼
			},
			[421] = {
				{55, 56, 57, 10000},	--{食材id(低品质）, 中品质, 高品质, 概率（分母10000）}  昆虚脉藏——鳗鱼
			},
		},

		tbWeelExs = {	--鱼篓特殊配置
			[1] = {
				nWeelHeight = 90,	--鱼篓的高度
				tbWeelMoveRange = {250, -250},	--鱼篓活动范围，最高最低
				nWeelFishMeetDis = 25,	--鱼篓与鱼判定为重合时，Y坐标误差最大值
			},
			[2] = {
				nWeelHeight = 120,	--鱼篓的高度
				tbWeelMoveRange = {235, -235},	--鱼篓活动范围，最高最低
				nWeelFishMeetDis = 35,	--鱼篓与鱼判定为重合时，Y坐标误差最大值
			},
		},

		tbWeel = {	--鱼篓通用配置
			nWeelDropAcc = 250,		--鱼篓掉落加速度
			nWeelPushAcc = -300,	--按下按钮鱼篓运动加速度

			nProgressBarInit = 35,		--进度条默认百分比
			nProgressBarDecSpeed = 10,	--进度条每秒下降多少百分比
			nProgressBarIncSpeed = 15,	--进度条每秒上涨多少百分比

			nWeelChestMeetDis = 30,	--鱼篓与宝箱判定为重合时，Y坐标误差最大值
			nChestDecSpeed = 10,	--宝箱进度条每秒下降多少百分比
			nChestIncSpeed = 25,	--宝箱进度条每秒上涨多少百分比
		},

		tbFishMoveRange = {250, -250},	--鱼活动范围，最高最低
		nChestId = 12011,	--宝箱道具id
		nPowerProgreeSpeed = 2,	--甩杆进度条速度(0~1 / s)

		tbCamera = {	--摄像机设置
			nDistance = 16,
			nAngle = 5,
			nViewField = 23,
		},
	},

	-- 打猎相关配置
	tbHuntingCfg = {
		nFireInterval = 0.5,	--开火间隔（秒）
		tbCameraPos = {10000, 6500},	--摄像机坐标
		nDailyLimit = 2,	--每日次数上限
		nMiddleWidth = 350,	--屏幕中间区域宽度，用于确定释放技能id
		tbWeapons = {	--武器
			{105, {5971, 5972, 5973}, 100, {0, 1, 3}},	--{食材id, {技能id左,中,右}, 伤害量, {buff id(0为无buff), 等级, 持续时间（秒）}}
			{106, {5974, 5975, 5976}, 100, {5980, 30, 3}},
			{107, {5977, 5978, 5979}, 300, {0, 1, 3}},
		},
		tbHitBuff = {2452, 2},	--被击中后加buff{id，等级}
		nHiddenNpcId = 1800,	--用于释放技能的隐藏npc
		nTotalTime = 60*10,	--时间限制（秒）
		nMaxHitDis = 100,	--击中最大范围
		nMaxScareDis = 2000,	--惊吓最大范围
		tbAnimalOutPos = {	--视野外的点
			{5014, 2147},
			{6425, 2311},
			{7492, 2311},
			{8559, 2360},
			{5958, 9195},
			{7500, 9179},
			{8797, 9187},
		},
		tbAnimalInPos = {	--视野内的点
			{6428, 7492},
			{5822, 6997},
			{5188, 5777},
			{5654, 4267},
			{7573, 5069},
			{4902, 6637},
			{6053, 5356},

		},
		nFirstBornTime = 5,	--第一次生成猎物等待时间（秒）
		tbAnimals = {	--动物配置
			[3830] = {120, 1000, 1000, {	--[npcId] = {触发频率（秒），触发概率, 血量, 食材产出配置}        --熊
				{37, 7800}, {38, 2000}, {39, 200},	-- 食材id，概率
			}},
			[3831] = {30, 5000, 300, {
				{34, 7800}, {35, 2000}, {36, 200},	-- 食材id，概率                                          --猪
			}},
			[3832] = {30, 5000, 100, {
				{31, 7800}, {32, 2000}, {33, 200},	-- 食材id，概率                                          --鸡
			}},
		},
		tbMaps = {	--允许进入打猎的地图
			[15] = true,
		},
	},

	-- 以下由程序配置
	nMaterialSaveGrp = 199,
	nGatherSaveGrp = 200,
	nGatherSlotPerGrp = 2,
	nMenuSaveGrp = 201,
	nTaskSaveGrp = 202,
	nFishHuntSaveGrp = 202,
	nHuntingDailyLimitKey = 20,
	nLastHuntFishTimeKey = 21,
	nBestFishKeyBegin = 22,	--绝品鱼每天个数起始key
	nBestFishKeyEnd = 41,
	tbCookTypes = {
		Zhu = 1,
		Dun = 2,
		Kao = 3,
		Jian = 4,
		Zheng = 5,
	},
}

-- 非预设菜
Cook.Def.tbDefaultFood = {
	[Cook.Def.tbCookTypes.Zhu] = 11690,	--类型 = item id
	[Cook.Def.tbCookTypes.Dun] = 11691,
	[Cook.Def.tbCookTypes.Kao] = 11692,
	[Cook.Def.tbCookTypes.Jian] = 11693,
	[Cook.Def.tbCookTypes.Zheng] = 11694,
}

function Cook:IsOpened(pPlayer)
--[[
	if pPlayer and pPlayer.nLevel < self.Def.szMinLevel then
		return false
	end
	return GetTimeFrameState(self.Def.szOpenFrame) == 1
]]
	return false
end

function Cook:GetItemNameByBuff(nBuffId, nLevel)
	if not self.tbBuffMap[nBuffId] then
		return
	end
	local nItemId = self.tbBuffMap[nBuffId][nLevel]
	if not nItemId then
		return
	end
	return Item:GetItemTemplateShowInfo(nItemId)
end

function Cook:LoadSettings()
	self.tbMaterialSetting = LoadTabFile("Setting/Cook/CookMaterials.tab", "ddddsddsssd", "nId",
		{"nId", "nTab", "nKind", "nSubType", "szName", "nQuality", "nScore", "szIconSprite",
		"szIconAtlas", "szDesc", "nIsBest"})
	self.tbCookBookSetting = LoadTabFile("Setting/Cook/CookBook.tab", "ddsddddddsssss", "nId",
		{"nId", "nType", "szName", "nPart1", "nPart2", "nPart3", "nPart4", "nPart5", "nQuality",
		"szProduce", "szIconSprite", "szIconAtlas", "szPic", "szDesc"})

	local tbItems = LoadTabFile("Setting/Item/Other/CookItem.tab", "dsdd", "TemplateId",
		{"TemplateId", "ClassName", "ExtParam1", "ExtParam2"})
	self.tbBuffMap = {}
	self.tbMaterialBoxMap = {}
	for nItemId, tb in pairs(tbItems) do
		if tb.ClassName == "CookMeal" then
			self.tbBuffMap[tb.ExtParam1] = self.tbBuffMap[tb.ExtParam1] or {}
			self.tbBuffMap[tb.ExtParam1][tb.ExtParam2] = nItemId
		elseif tb.ClassName == "RandomItem" then
			self.tbMaterialBoxMap[nItemId] = Item:GetClass("RandomItem"):GetFirstItemParam(tb.ExtParam1)
		end
	end

	self.tbMaxSlot = {}
	self.tbCookBookTypes = {}
	for _, v in pairs(self.tbCookBookSetting) do
		-- szProduce: 最低分数（含）:item;
		v.tbProduce = {}
		for _, sz in ipairs(Lib:SplitStr(v.szProduce, ";")) do
			local tbParts = Lib:SplitStr(sz, ":")
			if #tbParts == 2 then
				local tb = {tonumber(tbParts[1]), tonumber(tbParts[2])}
				table.insert(v.tbProduce, tb)
			end
		end
		v.szProduce = nil

		local nType = v.nType
		self.tbMaxSlot[nType] = self.tbMaxSlot[nType] or {}
		local nSlot = 0
		for i = 5, 1, -1 do
			local nId = v["nPart"..i]
			if nSlot <= 0 and nId > 0 then
				nSlot = i
			end
			if (self.tbMaxSlot[nType][nId] or 0) < nSlot then
				self.tbMaxSlot[nType][nId] = nSlot
			end
		end

		self.tbCookBookTypes[nType] = self.tbCookBookTypes[nType] or {}
		table.insert(self.tbCookBookTypes[nType], v.nId)
	end

	self.tbKindMaterials = {}
	for nId, tb in pairs(self.tbMaterialSetting) do
		self.tbKindMaterials[tb.nKind] = self.tbKindMaterials[tb.nKind] or {}
		table.insert(self.tbKindMaterials[tb.nKind], nId)
	end
	for _, tb in pairs(self.tbKindMaterials) do
		table.sort(tb, function(nId1, nId2)
			local tbMaterial1 = self.tbMaterialSetting[nId1]
			local tbMaterial2 = self.tbMaterialSetting[nId2]
			return tbMaterial1.nSubType < tbMaterial2.nSubType or
				(tbMaterial1.nSubType == tbMaterial2.nSubType and
					(tbMaterial1.nScore < tbMaterial2.nScore or
						(tbMaterial1.nScore == tbMaterial2.nScore and tbMaterial1.nId < tbMaterial2.nId)
					)
				)
		end)
	end

	self.tbCookBookMaterials = {}
	for nId, tb in pairs(self.tbCookBookSetting) do
		self.tbCookBookMaterials[tb.nType] = self.tbCookBookMaterials[tb.nType] or {}
		self.tbCookBookMaterials[tb.nType][nId] = {}
		for i = 1, 5 do
			local nPart = tb["nPart"..i]
			if nPart <= 0 then
				break
			end
			self.tbCookBookMaterials[tb.nType][nId][nPart] = true
		end
	end

	self.tbCookShopSetting = {}
	self.tbCookShopSettingMap = {}
	local tbTmp = LoadTabFile("Setting/Cook/CookShop.tab", "dddsd", nil,
		{"nMaterialId", "nTab", "nSort", "szMoneyType", "nPrice"})
	for _, v in ipairs(tbTmp) do
		self.tbCookShopSetting[v.nTab] = self.tbCookShopSetting[v.nTab] or {}
		table.insert(self.tbCookShopSetting[v.nTab], v)
		self.tbCookShopSettingMap[v.nMaterialId] = v
	end
	for _, tb in pairs(self.tbCookShopSetting) do
		table.sort(tb, function(v1, v2)
			return v1.nSort < v2.nSort or (v1.nSort == v2.nSort and v1.nMaterialId < v2.nMaterialId)
		end)
	end

	self.tbTaskSetting = LoadTabFile("Setting/Task/CookTaskList.tab", "ddd", "nTaskId",
		{"nTaskId", "nDurationDay", "nDifficulty"})

	self.tbFishSettings = LoadTabFile("Setting/Cook/CookFishing.tab", "ddddddds", "nMaterialId",
		{"nMaterialId", "nSpeed", "nJumpInterval", "nJumpRate", "nJumpRangeMin", "nJumpRangeMax", "nJumpSpeed", "szIcon"})
end
Cook:LoadSettings()

function Cook:GetBoxMaterialId(nBoxId)
	return self.tbMaterialBoxMap[nBoxId]
end

function Cook:IsTask(nTaskId)
	return nTaskId and self.tbTaskSetting[nTaskId]
end

function Cook:GetTaskDifficulty(nTaskId)
	return self.tbTaskSetting[nTaskId].nDifficulty
end

function Cook:GetProduce(nMenuId, nScore)
	local tbMenu = self:GetCookbookInfo(nMenuId)
	local nItemId = 0
	local nIdx = 0
	for i, tb in ipairs(tbMenu.tbProduce) do
		if nScore >= tb[1] then
			nItemId = tb[2]
			nIdx = i
		else
			break
		end
	end
	return nItemId, nIdx
end

function Cook:GetCookBookType(pPlayer, nType)
	local tbRet = {}
	local tbBookIds = self.tbCookBookTypes[nType]
	for _, nId in ipairs(tbBookIds) do
		if self:IsMenuUnlocked(pPlayer, nId) then
			table.insert(tbRet, nId)
		end
	end
	return tbRet, #tbBookIds
end

function Cook:GetCookbookInfo(nId)
	return self.tbCookBookSetting[nId]
end

function Cook:GetMaterialSubType(nMaterialId)
	local tbMaterial = self:GetMaterialInfo(nMaterialId)
	return tbMaterial.nSubType
end

function Cook:GetMaterialKind(nMaterialId)
	local tbMaterial = self:GetMaterialInfo(nMaterialId)
	return tbMaterial.nKind
end

function Cook:IsMaterialOfKind(nMaterialId, nKind)
	return nKind == self:GetMaterialKind(nMaterialId)
end

function Cook:GetMaterialInfo(nId)
	return self.tbMaterialSetting[nId]
end

function Cook:GetMaterialCount(pPlayer, nId)
	return pPlayer.GetUserValue(self.Def.nMaterialSaveGrp, nId)
end

function Cook:GetMaterials(pPlayer)
	local tbRet = {}
	for _, v in pairs(self.tbMaterialSetting) do
		if v.nTab == 1 then
			local nId = v.nId
			local nCount = self:GetMaterialCount(pPlayer, nId)
			if nCount > 0 then
				table.insert(tbRet, {nId, nCount})
			end
		end
	end
	return tbRet
end

function Cook:GetMaterialsByTab(pPlayer, nTab)
	local tbRet = {}
	for _, v in pairs(self.tbMaterialSetting) do
		if v.nTab == nTab then
			local nCount = self:GetMaterialCount(pPlayer, v.nId)
			if nCount > 0 then
				table.insert(tbRet, {v.nId, nCount})
			end
		end
	end
	table.sort(tbRet, function(a, b)
		return a[1] < b[1]
	end)
	return tbRet
end

function Cook:GetMaxSlotByMaterial(nType, nMaterialId)
	local nKind = self:GetMaterialKind(nMaterialId)
	local nSubType = self:GetMaterialSubType(nMaterialId)
	return math.max(self.tbMaxSlot[nType][nSubType] or 0, self.tbMaxSlot[nType][nKind] or 0, 1)
end

-- id << 16 + mapid
function Cook:PackGatherIdMap(nNpcId, nMapTemplateId)
	return nNpcId * 2^16 + nMapTemplateId
end

function Cook:GetClientGatherState(nBits, nIdx)
	return Lib:LoadBits(nBits, nIdx - 1, nIdx - 1)
end

function Cook:GetClientGatherStateIdx(pPlayer, nNpcId, nMapTemplateId)
	local nPacked = self:PackGatherIdMap(nNpcId, nMapTemplateId)
	for i = 1, 255 - self.Def.nGatherSlotPerGrp + 1, self.Def.nGatherSlotPerGrp do
		if pPlayer.GetUserValue(self.Def.nGatherSaveGrp, i) == nPacked then
			return i
		end
	end
end

function Cook:IsMenuUnlocked(pPlayer, nMenuId)
	return pPlayer.GetUserValue(self.Def.nMenuSaveGrp, nMenuId) == 1
end

function Cook:GetGatherConsumeItemId(nNpcId)
	local tb = self.Def.tbServerGatherMaterial[nNpcId] or self.Def.tbClientGatherMaterial[nNpcId]
	return tb.nConsumeItemId or 0
end

function Cook:CheckGatherConsume(pPlayer, nNpcId)
	local nConsumeItemId = self:GetGatherConsumeItemId(nNpcId)
	if nConsumeItemId <= 0 then
		return true
	end
	return self:GetMaterialCount(pPlayer, nConsumeItemId) > 0
end

--[[
tbCfg = {
	{1, 1000},
	{2, 9000},
}
]]
function Cook:GetRandomMaterial(tbCfg)
	local nRand = MathRandom(10000)
	local nMax = 0
	for _, v in ipairs(tbCfg) do
		nMax = nMax + v[2]
		if nRand <= nMax then
			return v[1]
		end
	end
	Log("[x] Cook:GetRandomMaterial", nRand)
	Lib:LogTB(tbCfg)
	Log(debug.traceback())
	return tbCfg[1][1]
end

function Cook:IsExtraSkill(nSkillId)
	return Lib:IsInArray(self.Def.tbExtraBuffs, nSkillId)
end

function Cook:CanAddPersonalAuction(pPlayer, nItemTemplateId, nItemId)
	local pItem = KItem.GetItemObj(nItemId or 0)
	if not pItem or Item:IsForbidStall(pItem) then
		return false
	end
	local bAuction = KItem.GetItemExtParam(nItemTemplateId, 4) == 1
	return bAuction and pPlayer.GetItemCountInBags(self.Def.nAuctionCostItem) > 0
		and pPlayer.GetItemCountInBags(nItemTemplateId) > 0
end

function Cook:GetTaskMaterialItemId(pPlayer, nTaskId)
	if not nTaskId or not self.tbTaskSetting[nTaskId] then
		return 0
	end
	for i = 1, 3 do
		local nIdx = i * 3 - 2
		local nId = pPlayer.GetUserValue(self.Def.nTaskSaveGrp, nIdx)
		if nId == nTaskId then
			return pPlayer.GetUserValue(self.Def.nTaskSaveGrp, nIdx + 1)
		end
	end
	Log("[x] Cook:GetTaskMaterialItemId", pPlayer.dwID, nTaskId)
	return 0
end