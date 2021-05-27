return {
{
	id = 8105,
	parentid = 0,type = 1,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 15,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8105,
	content = Lang.Quest.desc8105,
	prom = 0,
	comp = 0,
	target = {
		{
			type = 9, id = 120, count = 300, rewardId = 0,useList = false,
			location = {
				sceneid = 26, x= 56,y = 50,entityName = Lang.EntityName.m94,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 121 },
	},
	awards = {
		{
			{ type = 11, id = 1, count = 1000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 29, id = 0, count = 2000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 17, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk81051,
	},
	CompMsTalks = {
		Lang.Quest.compTlk81051,
	},
	CompMsTip = {
		Lang.Quest.compTip81051,
	},
	PassMsTip = {
	},
},
}