return {
{
	id = 32,
	parentid = 31,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = true,
	randomTarget = false,
	name = Lang.Quest.name32,
	content = Lang.Quest.desc32,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 39,
	target = {
		{
			type = 0, id = 29, count = 2, rewardId = 0,useList = false,
			location = {
				sceneid = 12, x= 57,y = 73,entityName = Lang.EntityName.m29,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 7305000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 60000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk321,
	},
	CompMsTalks = {
		Lang.Quest.compTlk321,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}