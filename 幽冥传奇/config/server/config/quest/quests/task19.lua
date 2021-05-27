return {
{
	id = 19,
	parentid = 18,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name19,
	content = Lang.Quest.desc19,
	promtype = 1,
    prom = 0,
	compType = 2,
	comp = 15,
	target = {
		{
			type = 0, id = 519, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 285, x= 46,y = 42,entityName = Lang.EntityName.m519,hideFastTransfer = false,
			},
		},
		{
			type = 0, id = 520, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 285, x= 41,y = 30,entityName = Lang.EntityName.m520,hideFastTransfer = false,
			},
		},
		{
			type = 0, id = 521, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 285, x= 45,y = 24,entityName = Lang.EntityName.m521,hideFastTransfer = false,
			},
		},
		{
			type = 0, id = 522, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 285, x= 51,y = 25,entityName = Lang.EntityName.m522,hideFastTransfer = false,
			},
		},
		{
			type = 0, id = 523, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 285, x= 58,y = 34,entityName = Lang.EntityName.m523,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 1040000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 38000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk191,
	},
	CompMsTalks = {
		Lang.Quest.compTlk191,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}