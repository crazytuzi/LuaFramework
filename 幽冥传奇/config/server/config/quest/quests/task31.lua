return {
{
	id = 31,
	parentid = 30,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = false,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name31,
	content = Lang.Quest.desc31,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 38,
	target = {
		{
			type = 0, id = 28, count = 2, rewardId = 0,useList = false,
			location = {
				sceneid = 12, x= 102,y = 76,entityName = Lang.EntityName.m28,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 3080000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 58000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk311,
	},
	CompMsTalks = {
		Lang.Quest.compTlk311,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}