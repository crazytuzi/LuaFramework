return {
{
	name = Lang.ActivityName.name00027,
	desc = Lang.ActivityName.desc00052,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "20:15-21:30",
	level = 1,
	icon = 36,
	type = 1,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward012,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={},
			minutes=
			{
				"20:15-21:30",
			}
		},
	},
	awards=
	{
		{type=0,id=1055,count=1,bind=0,strong=0,quality=0},
		{type=0,id=1063,count=1,bind=0,strong=0,quality=0},
		{type=0,id=1061,count=1,bind=0,strong=0,quality=0},
		{type=0,id=354,count=1,bind=0,strong=0,quality=0},
		{type=0,id=944,count=1,bind=0,strong=0,quality=0},
		{type=6,id=0,count=-1,bind=1,strong=0,quality=0},
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00173,
			conds = { },
		},
	},
},
}