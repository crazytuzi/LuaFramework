OpenSvrConsumRankingCfg =
{
	name = "消费排行",
	openLevel = 0,
	isvisible=0,
	noticeRank = {1, 4},
	minRankingConsum = 20000,
	tips = "{wordcolor;f7a93a;活动说明：}{wordcolor;e3ddb9;活动期间，满足消费金额，便可参加排行}{color;ff00ff00;(注：活动结束后奖励通过邮件发放)}",
	GiftLevels =
	{
		[1] = {
			tips = "第一名:60万元宝；第二名:40万元宝；\n第三名:30万元宝；第四名:20万元宝；\n第五名:15万元宝；第六名:12万元宝；\n第七名:10万元宝；第八名:8万元宝；\n第九名:5万元宝；第十名:3万元宝；\n参与奖:2万元宝；",
			tip_bar = "上榜需求：",
			idx = 1,
			openDays={1,3},
			mailDesc = "恭喜您在开服活动-消费排行第一期排行中获得第{color;ff00ff00;%d}名,请接收排行奖励!!",
			rankings=
			{
{condition=600000,award={
{type=0,id=3790,count=1,bind =1},
{type=0,id=3491,count=1,bind =1},
{type=0,id=3477,count=20,bind =1},
{type=0,id=3503,count=5,bind =1},
{type=0,id=3621,count=20,bind =1},
},},
{condition=400000,award={
{type=0,id=3501,count=500,bind =1},
{type=0,id=3490,count=1,bind =1},
{type=0,id=3477,count=10,bind =1},
{type=0,id=3503,count=3,bind =1},
{type=0,id=3621,count=10,bind =1},
},},
{condition=300000,award={
{type=0,id=3501,count=400,bind =1},
{type=0,id=3489,count=1,bind =1},
{type=0,id=3568,count=100,bind =1},
{type=0,id=3502,count=20,bind =1},
{type=0,id=3621,count=5,bind =1},
},},
{condition=200000,award={
{type=0,id=3501,count=300,bind =1},
{type=0,id=3488,count=1,bind =1},
{type=0,id=3568,count=80,bind =1},
{type=0,id=3502,count=10,bind =1},
{type=0,id=3621,count=5,bind =1},
},},
{condition=150000,award={
{type=0,id=3501,count=200,bind =1},
{type=0,id=3485,count=10,bind =1},
{type=0,id=3568,count=70,bind =1},
{type=0,id=3502,count=8,bind =1},
{type=0,id=3621,count=4,bind =1},
},},
{condition=120000,award={
{type=0,id=3501,count=150,bind =1},
{type=0,id=3485,count=8,bind =1},
{type=0,id=3568,count=60,bind =1},
{type=0,id=3502,count=6,bind =1},
{type=0,id=3621,count=3,bind =1},
},},
{condition=100000,award={
{type=0,id=3501,count=120,bind =1},
{type=0,id=3485,count=6,bind =1},
{type=0,id=3568,count=55,bind =1},
{type=0,id=3502,count=5,bind =1},
{type=0,id=3621,count=3,bind =1},
},},
{condition=80000,award={
{type=0,id=3501,count=100,bind =1},
{type=0,id=3485,count=5,bind =1},
{type=0,id=3568,count=50,bind =1},
{type=0,id=3502,count=4,bind =1},
{type=0,id=3621,count=3,bind =1},
},},
{condition=50000,award={
{type=0,id=3501,count=80,bind =1},
{type=0,id=3485,count=4,bind =1},
{type=0,id=3568,count=45,bind =1},
{type=0,id=3502,count=3,bind =1},
{type=0,id=3621,count=3,bind =1},
},},
{condition=30000,award={
{type=0,id=3501,count=60,bind =1},
{type=0,id=3485,count=3,bind =1},
{type=0,id=3568,count=40,bind =1},
{type=0,id=3502,count=2,bind =1},
{type=0,id=3621,count=3,bind =1},
},},},
join_award =
{condition=20000,award={
{type=0,id=3501,count=50,bind =1},
{type=0,id=3526,count=1,bind =1},
{type=0,id=3568,count=30,bind =1},
{type=0,id=3507,count=10,bind =1},
{type=0,id=3482,count=5,bind =1},
},},},
		[2] = {
			tips = "第一名:40万元宝；第二名:30万元宝；\n第三名:20万元宝；第四名:10万元宝；\n第五名:8万元宝；第六名:6万元宝；\n第七名:5万元宝；第八名:4万元宝；\n第九名:3万元宝；第十名:2.5万元宝；\n参与奖:2万元宝；",
			tip_bar = "上榜需求：",
			idx = 2,
			openDays={6,7},
			mailDesc = "恭喜您在开服活动-消费排行第二期排行中获得第{color;ff00ff00;%d}名,请接收排行奖励!!",
			rankings=
			{
{condition=400000,award={
{type=0,id=3933,count=1,bind =1},
{type=0,id=3493,count=200,bind =1},
{type=0,id=3496,count=200,bind =1},
{type=0,id=3558,count=200,bind =1},
},},
{condition=300000,award={
{type=0,id=3506,count=1800,bind =1},
{type=0,id=3493,count=160,bind =1},
{type=0,id=3496,count=160,bind =1},
{type=0,id=3558,count=160,bind =1},
},},
{condition=200000,award={
{type=0,id=3506,count=1200,bind =1},
{type=0,id=3493,count=120,bind =1},
{type=0,id=3496,count=120,bind =1},
{type=0,id=3558,count=120,bind =1},
},},
{condition=100000,award={
{type=0,id=3506,count=900,bind =1},
{type=0,id=3493,count=100,bind =1},
{type=0,id=3496,count=80,bind =1},
{type=0,id=3558,count=80,bind =1},
},},
{condition=80000,award={
{type=0,id=3506,count=700,bind =1},
{type=0,id=3493,count=90,bind =1},
{type=0,id=3496,count=70,bind =1},
{type=0,id=3558,count=70,bind =1},
},},
{condition=60000,award={
{type=0,id=3506,count=500,bind =1},
{type=0,id=3493,count=80,bind =1},
{type=0,id=3496,count=60,bind =1},
{type=0,id=3558,count=60,bind =1},
},},
{condition=50000,award={
{type=0,id=3506,count=300,bind =1},
{type=0,id=3493,count=70,bind =1},
{type=0,id=3496,count=60,bind =1},
{type=0,id=3558,count=50,bind =1},
},},
{condition=40000,award={
{type=0,id=3506,count=200,bind =1},
{type=0,id=3493,count=65,bind =1},
{type=0,id=3496,count=60,bind =1},
{type=0,id=3558,count=50,bind =1},
},},
{condition=30000,award={
{type=0,id=3506,count=180,bind =1},
{type=0,id=3493,count=60,bind =1},
{type=0,id=3496,count=60,bind =1},
{type=0,id=3558,count=50,bind =1},
},},
{condition=25000,award={
{type=0,id=3506,count=160,bind =1},
{type=0,id=3493,count=50,bind =1},
{type=0,id=3496,count=60,bind =1},
{type=0,id=3558,count=50,bind =1},
},},},
join_award =
{condition=20000,award={
{type=0,id=3506,count=30,bind =1},
{type=0,id=3493,count=20,bind =1},
{type=0,id=3496,count=20,bind =1},
{type=0,id=3526,count=2,bind =1},
},},},
	},
}
