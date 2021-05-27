return {
{
	id = 64,
	parentid = 63,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = true,
	randomTarget = false,
	name = Lang.Quest.name64,
	content = Lang.Quest.desc64,
	promtype = 1,
	prom = 0,
	comp = 19,
	compType = 2,
	target = {
		{
			type = 14, id = 31, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 2, x= 129,y = 71,entityName = Lang.EntityName.n00080,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 10800000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 102000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk641,
	},
	CompMsTalks = {
		Lang.Quest.compTlk641,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}