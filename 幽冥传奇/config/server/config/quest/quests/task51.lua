return {
{
	id = 51,
	parentid = 50,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = true,
	excludetree = true,
	showTimerBox = true,
	randomTarget = false,
	name = Lang.Quest.name51,
	content = Lang.Quest.desc51,
	promtype = 1,
	prom = 0,
	compType = 2,
	comp = 18,
	target = {
		{
			type = 20, id = 1, count = 10, rewardId = 0,useList = false,
			location = {
				sceneid = 2, x= 65,y = 129,entityName = Lang.EntityName.n00083,hideFastTransfer = false,
			},
		},
	},
	conds = {
	},
	awards = {
		{
			{ type = 2, id = 0, count = 9500000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
			{ type = 6, id = 0, count = 88000, group = 0,strong = 0,quality = 0,job = 0,sex = -1,bind = true,levelRate = 0.00, ringRate = 0.00},
		},
	},
	PromMsTalks = {
		Lang.Quest.promTlk511,
	},
	CompMsTalks = {
		Lang.Quest.compTlk511,
	},
	CompMsTip = {
	},
	PassMsTip = {
	},
},
}