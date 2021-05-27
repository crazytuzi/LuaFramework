return {
{
	id = 27,
	parentid = 26,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name27,
	content = Lang.Quest.desc27,
	promtype = 1,
    prom = 0,
	compType = 2,
	comp = 35,
	target = {
		{
			type = 14, id = 1, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 292, x= 52,y = 52,entityName = Lang.EntityName.m852,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 2222000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 54000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = false,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk271,
	},
	CompMsTalks = {
		Lang.Quest.compTlk271,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}