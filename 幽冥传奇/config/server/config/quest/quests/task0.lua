return {
{
	id = 0,
	parentid = 0,type = 0,level = 0,circle = 0,entrust = 0,star = 0,guideId = 0,timelimit = 0,interval = 0,maxcount = 1,
	cangiveup = false,
	automount = true,
	autoRun = false,
	excludetree = true,
	randomTarget = false,
	name = Lang.Quest.name0,
	content = Lang.Quest.desc0,
	prom = { type = 0, scene = Lang.SceneName.s00001, npc = Lang.EntityName.n00003 },
	comp = { type = 0, scene = Lang.SceneName.s00001, npc = Lang.EntityName.n00003 },
	npcInfo = {
		{
			npcid = 1,
			npcname = Lang.EntityName.n00001,
			sceneid = 1,
			x = 70,
			y = 15,
		},
		{
			npcid = 1,
			npcname = Lang.EntityName.n00001,
			sceneid = 1,
			x = 70,
			y = 15,
		},
	},
	target = {
	},
	conds = {
		{ type = 0, id = 0, count = 1 },
	},
	awards = {
	},
	PromMsTalks = {
		Lang.Quest.promTlk01,
	},
	CompMsTalks = {
		Lang.Quest.compTlk01,
	},
	CompMsTip = {
		Lang.Quest.compTip01,
	},
	PassMsTip = {
	},
	CompCallBack = "OnFinLeanrSkill",
	CompCallbackArg = {
		 { 3, 16, 45, 30, 59, 71, 83, 96,},
	},
},
}