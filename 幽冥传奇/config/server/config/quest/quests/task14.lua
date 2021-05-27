return {
{
	id = 14,
	parentid = 13,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name14,
	content = Lang.Quest.desc14,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 12,
	target = {
		{
			type = 3, id = 515, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 281, x= 24,y = 21,entityName = Lang.EntityName.m16,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 605000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 50000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk141,
	},
	CompMsTalks = {
		Lang.Quest.compTlk141,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}