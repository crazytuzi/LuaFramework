return {
{
	id = 12,
	parentid = 11,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name12,
	content = Lang.Quest.desc12,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 14,
	target = {
		{
			type = 0, id = 12, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 6, x= 11,y = 49,entityName = Lang.EntityName.m12,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 475000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 24000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk121,
	},
	CompMsTalks = {
		Lang.Quest.compTlk121,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}