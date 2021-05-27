return {
{
	id = 8003,
	parentid = 999,type = 3,level = 65,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = true,
	automount = false,
	autoRun = false,
	excludetree = false,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8003,
	content = Lang.Quest.desc8003,
	prom = 0,
	comp = 164,
	target = {
		{
			type = 45, id = 9, count = 2, rewardId = 0,useList = false,
			location = {
				sceneid = 4, x= 54,y = 70,entityName = Lang.EntityName.n00171,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 70 },
	},
	awards = {
		{
			{ type = 1, id = 0, count = 5000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 4047, count = 2, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 17, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80031,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80031,
	},
	CompMsTip = {
		Lang.Quest.compTip80031,
	},
	PassMsTip = {
	},
},
}