return {
{
	id = 824,
	parentid = 825,type = 1,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name824,
	content = Lang.Quest.desc824,
	prom = 0,
	comp = 55,
	target = {
		{
			type = 9, id = 70, count = 10, rewardId = 0,useList = false,
			location = {
				sceneid = 61, x= 20,y = 22,entityName = Lang.EntityName.m1513,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 70 },
	},
	awards = {
		{
			{ type = 0, id = 4304, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk8241,
	},
	CompMsTalks = {
		Lang.Quest.compTlk8241,
	},
	CompMsTip = {
		Lang.Quest.compTip8241,
	},
	PassMsTip = {
	},
},
}