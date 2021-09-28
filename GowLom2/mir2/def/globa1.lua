cJobWarrior = 0
cJobMagian = 1
cJobTaoist = 2
cJobAss = 3
DIR_AROUND = {
	{
		0,
		-1
	},
	{
		1,
		-1
	},
	{
		1,
		0
	},
	{
		1,
		1
	},
	{
		0,
		1
	},
	{
		-1,
		1
	},
	{
		-1,
		0
	},
	{
		-1,
		-1
	}
}
cAreaStateNormal = 0
cAreaStateFight = 1
cAreaStateSafe = 2
cAreaStateGuildWar = 4
cAreaStateDareWar = 8
cAreaStateReliveable = 22
cBigFireDragonRace = 104
cBigFireDragonAppr = 240
cFireDragonStatueRace = 108
cFireDragonStatueApprLeft = 243
cFireDragonStatueApprRight = 244
U_None = -1
U_DRESS = 0
U_WEAPON = 1
U_RIGHTHAND = 2
U_NECKLACE = 3
U_HELMET = 4
U_ARMRINGL = 5
U_ARMRINGR = 6
U_RINGL = 7
U_RINGR = 8
U_BUJUK = 9
U_BELT = 10
U_BOOTS = 11
U_CHARM = 12
U_MASK = 13
U_YuPei = 14
U_HORSE = 15
U_XueYu = 16
U_R_DP = 17
U_R_YP = 18
U_R_BF = 19
U_R_HL = 20
U_MINGZHONG = 21
U_WUSHAN = 22
U_MOSHAN = 23
U_SHENFANG = 24
U_SHENSHANG = 25
TNumericType = {
	ntDonate = 0,
	ntMerit = 1,
	ntSpring = 2,
	ntContribute = 4,
	ntWingSpirit = 7,
	ntCanJuan = 3,
	ntYueLi = 5,
	ntJunGong = 6
}
GameStateType = {
	game = 4,
	login = 0,
	notice = 3,
	selected = 2,
	upt = 1
}
Sdk39LoginRetCode = {
	[500106.0] = "access_token绑定异常",
	[500102.0] = "游戏包里面配置的渠道id错误",
	[500002.0] = "您当日累计在线游戏时间已经达到3小时，请绑定身份证信息",
	[500103.0] = "游戏包里面配置的应用id错误",
	[-3.0] = "获取userinfo失败",
	[500202.0] = "下单验证模块错误",
	[500203.0] = "下单异常",
	[-4.0] = "allow_login返回，禁止登录",
	[500104.0] = "渠道方用户数据没有拿到",
	[500100.0] = "未知错误",
	[500001.0] = "验证接口错误",
	[-1.0] = "渠道sdk登录失败",
	[500105.0] = "禁止登录",
	[500101.0] = "游戏包id不存在",
	[-1000.0] = "聚合服务端返回数据为空 ",
	[500201.0] = "下单用户记录不存在",
	[500003.0] = "您未满18周岁，并且已经累计在线游戏时间已经达到3小时，今日已无法再游戏",
	[-2.0] = "获取token失败"
}
Sdk39InitRetCode = {
	[-1.0] = "渠道sdk初始化失败",
	[-1000.0] = "聚合服务端返回数据为空",
	[-2.0] = "获取serverid失败，聚合后台未配置正式服"
}

return 
