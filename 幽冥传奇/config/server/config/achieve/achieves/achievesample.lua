return {
{
		id = 0,
		broadcast = false,
		name = Lang.AchieveName.name0000,
		groupId = 0,
		needCondCount = 1,
		desc = Lang.AchieveName.desc0000,
		icon = 23,
		isDelete = false,
		isDefaultActive = false,
		isDayRefresh = false,
		isMonthRefresh = false,
		showPos = 0,
		sceneId=0,
		npcName ="",  --用在活跃度里，去哪个场景找npc，默认是""可以不配置，请在Lang.EntityName语言包里找
	    uiId =0,
		badgeId = 1,
		conds =
		{
			{ eventId = 0, count = 1 },
		},
		awards=
		{
			{ type = 11, id= 0 , count = 1, job = 0, sex = -1, vipLevel = 0, },
			{ type = 7, id= 0 , count = 100, job = 0, sex = -1 },
			{ type = 8, id= 1 , count = 1, job = 0, sex = -1 },
		},
		parent = -1,
		gift=
		{
			{ type = 1, id =1, count = 1, },
		},
	},
}