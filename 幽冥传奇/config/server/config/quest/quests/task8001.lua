return {
{
	id = 8001,
	parentid = 999,type = 3,level = 65,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = true,
	automount = false,
	autoRun = false,
	excludetree = false,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8001,
	content = Lang.Quest.desc8001,
	prom = 0,
	comp = 140,
	target = {
		{
			type = 45, id = 1, count = 3, rewardId = 0,useList = false,
			location = {
				sceneid = 5, x= 74,y = 60,entityName = Lang.EntityName.n00104,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 60 },
	},
	awards = {
		{
			{ type = 1, id = 0, count = 5000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 4261, count = 10, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 17, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80011,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80011,
	},
	CompMsTip = {
		Lang.Quest.compTip80011,
	},
	PassMsTip = {
	},
},
}