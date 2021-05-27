return {
{
	name =Lang.ActivityName.name00006,
	desc=Lang.ActivityName.desc00006,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "22:30-23:05",
	level = 40,
	icon = 37,
	type = 1,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward017,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"22:30-23:05",
			}
		},
	},
	awards=
	{
		{type=6,id=20000,count=-1,bind=1,strong=0,quality=0},
		{type=2,id=0,count=-1,bind=1,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00079,
			conds = { },
		},
	},
},
}