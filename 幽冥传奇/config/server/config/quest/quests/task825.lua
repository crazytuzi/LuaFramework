return {
{
	id = 825,
	parentid = 706,type = 1,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name825,
	content = Lang.Quest.desc825,
	prom = 0,
	comp = 0,
	target = {
		{
			type = 19, id = 61, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 5, x= 77,y = 75,entityName = Lang.EntityName.n00102,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 70 },
	},
	awards = {
		{
			{ type = 3, id = 0, count = 1000000, group = 0,strong = 0,quality = 0,job = 1,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk8251,
	},
	CompMsTalks = {
		Lang.Quest.compTlk8251,
	},
	CompMsTip = {
		Lang.Quest.compTip8251,
	},
	PassMsTip = {
	},
},
}