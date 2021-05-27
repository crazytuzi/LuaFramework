return {
{
	id = 13,
	parentid = 12,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name13,
	content = Lang.Quest.desc13,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 16,
	target = {
		{
			type = 0, id = 14, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 6, x= 68,y = 55,entityName = Lang.EntityName.m14,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 537500, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 26000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk131,
	},
	CompMsTalks = {
		Lang.Quest.compTlk131,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}