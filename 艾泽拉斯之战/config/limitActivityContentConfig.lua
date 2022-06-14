dataConfig.configs.limitActivityContentConfig ={
	[1] = {
		['id'] = 1,
		['name'] = '开服有礼',
		['description'] = '$$global.dayText(1)$$至$$global.dayText(7)$$登陆即可获得开服大礼包一份！',
		['icon'] = 'i1047.jpg',
		['activityID'] = { 1 },
		['drawOrder'] = 10
	},
	[2] = {
		['id'] = 2,
		['name'] = '七日礼',
		['description'] = '$$global.roleDayText(1)$$至$$global.roleDayText(7)$$每日都可领取登陆礼包！#n#n*每日24:00即可领取次日奖励',
		['icon'] = 'i1040.jpg',
		['activityID'] = {2, 3, 4, 5, 6, 7, 8},
		['drawOrder'] = 20
	},
	[3] = {
		['id'] = 3,
		['name'] = '富可敌国',
		['description'] = '$$global.roleDayText(7)$$23:59之前金矿等级达到6级即可领取礼包一份！',
		['icon'] = 'i1042.jpg',
		['activityID'] = { 9 },
		['drawOrder'] = 60
	},
	[4] = {
		['id'] = 4,
		['name'] = '横扫天下',
		['description'] = '$$global.roleDayText(7)$$23:59之前在特定冒险章节获得满星即可领取相应礼包！',
		['icon'] = 'i1043.jpg',
		['activityID'] = {10, 11, 12, 13},
		['drawOrder'] = 50
	},
	[5] = {
		['id'] = 5,
		['name'] = '神兵利器',
		['description'] = '$$global.roleDayText(7)$$23:59之前将任意紫色装备强化至20即可领取礼包一份！',
		['icon'] = 'i1045.jpg',
		['activityID'] = { 14 },
		['drawOrder'] = 70
	},
	[6] = {
		['id'] = 6,
		['name'] = '登堂入室',
		['description'] = '$$global.roleDayText(7)$$23:59之前国王等级达到30级即可领取礼包一份！',
		['icon'] = 'i1041.jpg',
		['activityID'] = { 15 },
		['drawOrder'] = 90
	},
	[7] = {
		['id'] = 7,
		['name'] = '初露锋芒',
		['description'] = '$$global.dayText(2)$$内参加一场实时对战精英赛即可领取礼包一份！',
		['icon'] = 'i1046.jpg',
		['activityID'] = { 16 },
		['drawOrder'] = 30
	},
	[8] = {
		['id'] = 8,
		['name'] = '天梯争霸赛',
		['description'] = '$$global.dayText(3)$$21:05分按照天梯排位赛排名发放额外奖励！#n#n只要满足排名要求，可同时领取所有不同档次的礼包。届时奖励将通过邮件发放，请注意查收。',
		['icon'] = 'i1048.jpg',
		['activityID'] = {17, 18, 19},
		['drawOrder'] = 40
	},
	[9] = {
		['id'] = 9,
		['name'] = '猛将如云',
		['description'] = '$$global.roleDayText(7)$$23:59之前获得30个不同的兵种即可领取礼包一份！',
		['icon'] = 'i1044.jpg',
		['activityID'] = { 20 },
		['drawOrder'] = 80
	},
	[10] = {
		['id'] = 10,
		['name'] = '充值有礼',
		['description'] = '$$global.roleDayText(7)$$23:59之前充值达到指定金额即可领取礼包！#n#n奖励将通过邮件发放，请注意查收。',
		['icon'] = 'i1042.jpg',
		['activityID'] = {21, 22, 23, 24},
		['drawOrder'] = 21
	},
	[11] = {
		['id'] = 11,
		['name'] = '每日充值',
		['description'] = '$$global.roleDayText(3)$$23:59之前每日充值任意金额即可领取奖励！#n#n奖励将通过邮件发放，请注意查收。',
		['icon'] = 'i1030.jpg',
		['activityID'] = {25, 26, 27},
		['drawOrder'] = 22
	},
	[12] = {
		['id'] = 12,
		['name'] = '消耗促（目前关闭）',
		['description'] = '$$global.roleDayText(7)$$23:59消耗3000钻即可领取礼包一份！#n#n奖励将通过邮件发放，请注意查收。',
		['icon'] = 'i1042.jpg',
		['activityID'] = { 28 },
		['drawOrder'] = 23
	},
	[13] = {
		['id'] = 13,
		['name'] = '20倍返还',
		['description'] = '本次删档测试截止于$$global.roleDayText(7)$$24:00，期间充值的玩家将在8月公测时获得充值额（元）20倍的钻石返还，同时保留VIP等级、保留累计充值额度（可领取各种充值活动奖励）。',
		['icon'] = 'i1042.jpg',
		['activityID'] = { 29 },
		['drawOrder'] = 1
	}
}
