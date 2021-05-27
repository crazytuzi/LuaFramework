return {
{
	id = 4,
	parentid = 3,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name4,
	content = Lang.Quest.desc4,
	promtype = 1,
    prom = 0,
	compType = 0,
	comp = 4,
	target = {
		{
			type = 0, id = 3, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 1, x= 78,y = 11,entityName = Lang.EntityName.m3,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 78000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 49, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = 0,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 0, id = 50, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = 1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 8000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk41,
	},
	CompMsTalks = {
		Lang.Quest.compTlk41,
	},
	CompMsTip = {
		Lang.Quest.compTip41,
	},
	PassMsTip = {
	},
},
}