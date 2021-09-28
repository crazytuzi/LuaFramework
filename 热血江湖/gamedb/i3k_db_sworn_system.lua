i3k_db_sworn_system = 
{
	openLvl = 70,
	expendPropId = 67695,
	leastLimitPeople = 2,
	maxLimitPeople = 4,
	numLimitPrefix = 5,
	numLimitPostfix = 2,
	costPrefix = 300,
	costPostfix = {0, 100, 200, },
	leastBirth = 2145888000,
	maxBirth = 31420800,
	swornNpcId = 19110,
	relationNpcId = 19111,
	helpFightRewardId = 67697,
	helpFightRewardTimes = 10,
	hideHelpBtn = {[6] = true, [35] = true, [37] = true, [40] = true, },
	msgChangeCost = 50,
	likeNeedItem = 65820
};
i3k_db_sworn_title_orderSeats =
{
	[1] = {  id = 1, order = 1, gender = 1, isBigger = 1, iconId = 891, notes = '大哥'},
	[2] = {  id = 2, order = 2, gender = 1, isBigger = 1, iconId = 892, notes = '二哥'},
	[3] = {  id = 3, order = 3, gender = 1, isBigger = 1, iconId = 893, notes = '三哥'},
	[4] = {  id = 4, order = 1, gender = 2, isBigger = 1, iconId = 894, notes = '大姐'},
	[5] = {  id = 5, order = 2, gender = 2, isBigger = 1, iconId = 895, notes = '二姐'},
	[6] = {  id = 6, order = 3, gender = 2, isBigger = 1, iconId = 896, notes = '三姐'},
	[7] = {  id = 7, order = 2, gender = 1, isBigger = 0, iconId = 897, notes = '二弟'},
	[8] = {  id = 8, order = 3, gender = 1, isBigger = 0, iconId = 898, notes = '三弟'},
	[9] = {  id = 9, order = 4, gender = 1, isBigger = 0, iconId = 899, notes = '四弟'},
	[10] = {  id = 10, order = 2, gender = 2, isBigger = 0, iconId = 900, notes = '二妹'},
	[11] = {  id = 11, order = 3, gender = 2, isBigger = 0, iconId = 901, notes = '三妹'},
	[12] = {  id = 12, order = 4, gender = 2, isBigger = 0, iconId = 902, notes = '四妹'},

};
i3k_db_sworn_value =
{
	{ lvl = 1 , swornValue = 15000 , expAddition = 200 , titleId = 321 },
	{ lvl = 2 , swornValue = 45000 , expAddition = 500 , titleId = 322 },
	{ lvl = 3 , swornValue = 75000 , expAddition = 800 , titleId = 323 },
	{ lvl = 4 , swornValue = 135000 , expAddition = 1200 , titleId = 324 },
	{ lvl = 5 , swornValue = 200000 , expAddition = 1600 , titleId = 325 },

};
i3k_db_sworn_actRewards =
{
	[1] = { class = 1, actValue = 120, bgFree = 2, lvlClass = { 70, 90, 111, },mustDrop = {{ id = 100058, times = 1},{ id = 100058, times = 1},{ id = 100058, times = 1},} ,mayDrop = {{ id = 240, times = 1},{ id = 240, times = 1},{ id = 240, times = 1},},  },
	[2] = { class = 2, actValue = 240, bgFree = 2, lvlClass = { 70, 90, 111, },mustDrop = {{ id = 100059, times = 1},{ id = 100059, times = 1},{ id = 100059, times = 1},} ,mayDrop = {{ id = 240, times = 1},{ id = 240, times = 1},{ id = 240, times = 1},},  },
	[3] = { class = 3, actValue = 420, bgFree = 2, lvlClass = { 70, 90, 111, },mustDrop = {{ id = 100060, times = 1},{ id = 100060, times = 1},{ id = 100060, times = 1},} ,mayDrop = {{ id = 240, times = 1},{ id = 240, times = 1},{ id = 240, times = 1},},  },
	[4] = { class = 4, actValue = 600, bgFree = 2, lvlClass = { 70, 90, 111, },mustDrop = {{ id = 100061, times = 1},{ id = 100061, times = 1},{ id = 100061, times = 1},} ,mayDrop = {{ id = 240, times = 1},{ id = 240, times = 1},{ id = 240, times = 1},},  },
	[5] = { class = 5, actValue = 800, bgFree = 3, lvlClass = { 70, 90, 111, },mustDrop = {{ id = 100062, times = 2},{ id = 100062, times = 2},{ id = 100062, times = 2},} ,mayDrop = {{ id = 240, times = 2},{ id = 240, times = 2},{ id = 240, times = 2},},  },

};
i3k_db_sworn_task = 
{
	[1] = {
		{id = 101,
			objective = 10000,
			icon = 8862,
			name =  '情同手足（一）',
			desc =  '完成條件：金蘭值達到<c=purple>10000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 102,
			objective = 20000,
			icon = 8862,
			name =  '情同手足（二）',
			desc =  '完成條件：金蘭值達到<c=purple>20000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 103,
			objective = 30000,
			icon = 8862,
			name =  '情同手足（三）',
			desc =  '完成條件：金蘭值達到<c=purple>30000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 104,
			objective = 45000,
			icon = 8862,
			name =  '情同手足（四）',
			desc =  '完成條件：金蘭值達到<c=purple>45000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 105,
			objective = 60000,
			icon = 8862,
			name =  '情同手足（五）',
			desc =  '完成條件：金蘭值達到<c=purple>60000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 106,
			objective = 90000,
			icon = 8862,
			name =  '情同手足（六）',
			desc =  '完成條件：金蘭值達到<c=purple>90000</c>點',
			achiPoint = 10,
			weight = 1
		},
		{id = 107,
			objective = 120000,
			icon = 8862,
			name =  '情同手足（七）',
			desc =  '完成條件：金蘭值達到<c=purple>120000</c>點',
			achiPoint = 10,
			weight = 1
		},
	},
	[2] = {
		{id = 201,
			objective = 5,
			icon = 8863,
			name =  '患難與共（一）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>5</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 202,
			objective = 20,
			icon = 8863,
			name =  '患難與共（二）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>20</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 203,
			objective = 40,
			icon = 8863,
			name =  '患難與共（三）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>40</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 204,
			objective = 65,
			icon = 8863,
			name =  '患難與共（四）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>65</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 205,
			objective = 90,
			icon = 8863,
			name =  '患難與共（五）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>90</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 206,
			objective = 120,
			icon = 8863,
			name =  '患難與共（六）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>120</c>次',
			achiPoint = 10,
			weight = 2
		},
		{id = 207,
			objective = 150,
			icon = 8863,
			name =  '患難與共（七）',
			desc =  '完成條件：與線上的金蘭成員組隊通關任意組隊副本累計<c=purple>150</c>次',
			achiPoint = 10,
			weight = 2
		},
	},
	[3] = {
		{id = 301,
			objective = 2,
			icon = 2551,
			name =  '江湖正道（一）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>2</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 302,
			objective = 5,
			icon = 2551,
			name =  '江湖正道（二）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>5</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 303,
			objective = 10,
			icon = 2551,
			name =  '江湖正道（三）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>10</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 304,
			objective = 15,
			icon = 2551,
			name =  '江湖正道（四）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>15</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 305,
			objective = 25,
			icon = 2551,
			name =  '江湖正道（五）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>25</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 306,
			objective = 35,
			icon = 2551,
			name =  '江湖正道（六）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>35</c>次',
			achiPoint = 10,
			weight = 3
		},
		{id = 307,
			objective = 45,
			icon = 2551,
			name =  '江湖正道（七）',
			desc =  '完成條件：與金蘭成員組隊參與會武場<c=purple>45</c>次',
			achiPoint = 10,
			weight = 3
		},
	}
}i3k_db_achi_point_reward = 
{
	{stage = 1,
		objective = 60,
		girl = {rewardID = 66749, rewardCount = 3},
		boy = {rewardID = 66751, rewardCount = 3}
	},
	{stage = 2,
		objective = 120,
		girl = {rewardID = 67405, rewardCount = 1},
		boy = {rewardID = 67405, rewardCount = 1}
	},
	{stage = 3,
		objective = 180,
		girl = {rewardID = 67956, rewardCount = 1},
		boy = {rewardID = 67955, rewardCount = 1}
	},
}