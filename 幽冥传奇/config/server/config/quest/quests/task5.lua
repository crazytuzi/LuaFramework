return {
{
	id = 5,
	parentid = 4,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name5,
	content = Lang.Quest.desc5,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 5,
	target = {
		{
			type = 0, id = 4, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 1, x= 32,y = 9,entityName = Lang.EntityName.m4,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 122500, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 446, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 10000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk51,
	},
	CompMsTalks = {
		Lang.Quest.compTlk51,
	},
	CompMsTip = {
		Lang.Quest.compTip51,
	},
	PassMsTip = {
	},
},
}