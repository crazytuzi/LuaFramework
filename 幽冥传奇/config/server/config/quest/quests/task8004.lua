return {
{
	id = 8004,
	parentid = 0,type = 3,level = 65,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = true,
	automount = false,
	autoRun = false,
	excludetree = false,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8004,
	content = Lang.Quest.desc8004,
	prom = 0,
	comp = 165,
	target = {
		{
			type = 45, id = 5, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 5, x= 79,y = 73,entityName = Lang.EntityName.n00170,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 76 },
	},
	awards = {
		{
			{ type = 1, id = 0, count = 5000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 4214, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 17, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80041,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80041,
	},
	CompMsTip = {
		Lang.Quest.compTip80041,
	},
	PassMsTip = {
	},
},
}