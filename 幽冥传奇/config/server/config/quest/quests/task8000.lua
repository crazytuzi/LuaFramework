return {
{
	id = 8000,
	parentid = 0,type = 1,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8000,
	content = Lang.Quest.desc8000,
	prom = 0,
	comp = 0,
	target = {
		{
			type = 0, id = 59, count = 25, rewardId = 0,useList = false,
			location = {
				sceneid = 22, x= 66,y = 61,entityName = Lang.EntityName.m59,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 1, id = 0, count = 10000000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
			{ type = 29, id = 0, count = 2000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80001,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80001,
	},
	CompMsTip = {
		Lang.Quest.compTip80001,
	},
	PassMsTip = {
	},
},
}