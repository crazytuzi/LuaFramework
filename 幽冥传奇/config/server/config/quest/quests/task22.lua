return {
{
	id = 22,
	parentid = 21,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = true,
	randomTarget = false,
	name = Lang.Quest.name22,
	content = Lang.Quest.desc22,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 32,
	target = {
		{
			type = 0, id = 25, count = 2, rewardId = 0,useList = false,
			location = {
				sceneid = 10, x= 75,y = 17,entityName = Lang.EntityName.m25,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 1424000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 44000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk221,
	},
	CompMsTalks = {
		Lang.Quest.compTlk221,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}