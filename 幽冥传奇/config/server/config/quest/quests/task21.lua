return {
{
	id = 21,
	parentid = 20,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name21,
	content = Lang.Quest.desc21,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 31,
	target = {
		{
			type = 0, id = 24, count = 2, rewardId = 0,useList = false,
			location = {
				sceneid = 10, x= 43,y = 32,entityName = Lang.EntityName.m24,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 1282000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 42000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk211,
	},
	CompMsTalks = {
		Lang.Quest.compTlk211,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}