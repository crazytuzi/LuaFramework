return {
{
	id = 8002,
	parentid = 0,type = 3,level = 70,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = true,
	automount = false,
	autoRun = false,
	excludetree = false,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8002,
	content = Lang.Quest.desc8002,
	prom = 0,
	comp = 139,
	target = {
		{
			type = 45, id = 2, count = 3, rewardId = 0,useList = false,
			location = {
				sceneid = 4, x= 47,y = 73,entityName = Lang.EntityName.n00107,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 50 },
	},
	awards = {
		{
			{ type = 1, id = 0, count = 5000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 4264, count = 3, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 17, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80021,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80021,
	},
	CompMsTip = {
		Lang.Quest.compTip80021,
	},
	PassMsTip = {
	},
},
}