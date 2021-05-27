return {
{
	id = 3,
	parentid = 2,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name3,
	content = Lang.Quest.desc3,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 3,
	target = {
		{
			type = 0, id = 2, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 1, x= 98,y = 34,entityName = Lang.EntityName.m2,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 43500, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 28, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 6000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk31,
	},
	CompMsTalks = {
		Lang.Quest.compTlk31,
	},
	CompMsTip = {
		Lang.Quest.compTip31,
	},
	PassMsTip = {
	},
},
}