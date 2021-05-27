
ReXueBaZheBossCfg =
{
	openday = 8,
	actTime = {weeks = {1, 3, 5}, starttm = {20, 30}, endtm = {21, 00},},
	hurtValue = 10000,
	rankname = "ReXueBaZheRanking.txt",
	rankMaxCount = 10,
	boss =
	{
		bossid = 917,
		liveTime = 3600,
		sceneid = 328,
		x = 42,
		y = 41,
	},
	rankAwards =
	{
		mail_title = "热血霸者",
		mail_desc = "恭喜您在热血霸者伤害积分获得第%d名次，请您再接再厉！以下是奖励，敬请收纳！",
		ranks =
		{
			{
				range = {1,},
				awards =
				{
{type = 0,id = 2414,count = 1,bind = 1},
{type = 0,id = 2415,count = 1,bind = 1},
{type = 0,id = 2051,count = 100,bind = 1},
{type = 0,id = 2514,count = 500,bind = 1},
				},
			},
			{
				range = {2,},
				awards =
				{
{type = 0,id = 2415,count = 1,bind = 1},
{type = 0,id = 2052,count = 50,bind = 1},
{type = 0,id = 2053,count = 50,bind = 1},
{type = 0,id = 2514,count = 400,bind = 1},
				},
			},
			{
				range = {3,},
				awards =
				{
{type = 0,id = 2053,count = 30,bind = 1},
{type = 0,id = 2054,count = 30,bind = 1},
{type = 0,id = 2514,count = 300,bind = 1},
				},
			},
			{
				range = {4,10},
				awards =
				{
{type = 0,id = 2053,count = 20,bind = 1},
{type = 0,id = 2054,count = 20,bind = 1},
{type = 0,id = 2514,count = 200,bind = 1},
				},
			},
			{
				range = {11},
				awards =
				{
{type = 0,id = 2053,count = 10,bind = 1},
{type = 0,id = 2054,count = 10,bind = 1},
{type = 0,id = 2514,count = 100,bind = 1},
				},
			},
		},
	},
	joinAwards =
	{
		mail_title = "热血霸者",
		mail_desc = "恭喜您在热血霸者活动中获得参与奖，请您再接再厉！以下是奖励，敬请收纳！",
		awards = {
		{type = 0,id = 2053,count = 5,bind = 1},
		{type = 0,id = 2514,count = 50,bind = 1},
		},
	},
}