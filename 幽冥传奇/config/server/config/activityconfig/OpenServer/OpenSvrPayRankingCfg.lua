
OpenSvrPayRankingCfg =
{
	name = "充值排行",
	openLevel = 0,
	isvisible=0,
	noticeRank = {1, 4},
	minRankingPay = 20000,
	tips = "{wordcolor;f7a93a;活动说明：}{wordcolor;e3ddb9;活动期间，满足充值金额，便可参加排行}{color;ff00ff00;(注：活动结束后奖励通过邮件发放)}",
	GiftLevels =
	{
		[1] = {
			tips = "第一名:40万元宝；第二名:30万元宝；\n第三名:20万元宝；第四名:10万元宝；\n第五名:8万元宝；第六名:6万元宝；\n第七名:6万元宝；第八名:4万元宝；\n第九名:3万元宝；第十名:2.5万元宝；\n参与奖:2万元宝；",
			tip_bar = "上榜需求：",
			idx = 1,
			openDays={4,5},
			mailDesc = "恭喜您在开服活动-充值排行第一期排行中获得第{color;ff00ff00;%d}名,请接收排行奖励!!",
			rankings=
			{
{condition=400000,award={
{type=0,id=3933,count=1,bind =1},
{type=0,id=3595,count=2,bind =1},
{type=0,id=3479,count=150,bind =1},
{type=0,id=3508,count=15,bind =1},
},},
{condition=300000,award={
{type=0,id=3506,count=1800,bind =1},
{type=0,id=3595,count=1,bind =1},
{type=0,id=3479,count=100,bind =1},
{type=0,id=3508,count=10,bind =1},
},},
{condition=200000,award={
{type=0,id=3506,count=1200,bind =1},
{type=0,id=3594,count=2,bind =1},
{type=0,id=3479,count=80,bind =1},
{type=0,id=3508,count=8,bind =1},
},},
{condition=100000,award={
{type=0,id=3506,count=900,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=60,bind =1},
{type=0,id=3508,count=6,bind =1},
},},
{condition=80000,award={
{type=0,id=3506,count=700,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},
{condition=60000,award={
{type=0,id=3506,count=500,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},
{condition=50000,award={
{type=0,id=3506,count=300,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},
{condition=40000,award={
{type=0,id=3506,count=200,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},
{condition=30000,award={
{type=0,id=3506,count=180,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},
{condition=25000,award={
{type=0,id=3506,count=160,bind =1},
{type=0,id=3594,count=1,bind =1},
{type=0,id=3479,count=50,bind =1},
{type=0,id=3508,count=5,bind =1},
},},},
join_award=
{condition=20000,award={
{type=0,id=3506,count=30,bind =1},
{type=0,id=3593,count=1,bind =1},
{type=0,id=3479,count=30,bind =1},
{type=0,id=3508,count=3,bind =1},
},},},
	},
}
