return {
{
	id = 8005,
	parentid = 0,type = 3,level = 65,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 86400,maxcount = 1,
	cangiveup = true,
	automount = false,
	autoRun = false,
	excludetree = false,
	showTimerBox = false,
	randomTarget = false,
	name = Lang.Quest.name8005,
	content = Lang.Quest.desc8005,
	prom = 0,
	comp = 195,
	target = {
		{
			type = 45, id = 10, count = 1, rewardId = 0,useList = false,
			location = {
				sceneid = 4, x= 46,y = 68,entityName = Lang.EntityName.n00191,hideFastTransfer = false,
			},
		},
	},
	conds = {
		{ type = 0, id = 0, count = 75 },
		{ type = 14, id = 0, count = 5 },
	},
	awards = {
		{
			{ type = 0, id = 4068, count = 1, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk80051,
	},
	CompMsTalks = {
		Lang.Quest.compTlk80051,
	},
	CompMsTip = {
		Lang.Quest.compTip80051,
	},
	PassMsTip = {
	},
},
}