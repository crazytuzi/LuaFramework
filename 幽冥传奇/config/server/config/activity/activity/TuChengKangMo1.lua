return {
{
	name = Lang.ActivityName.name00039,
	desc = Lang.ActivityName.desc00039,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "11:00-12:00",
	level = 40,
	icon = 33,
	type = 1,
	index =2,
	mainAwardDesc = Lang.ActivityName.mainAward010,
	openTimes=
	{
		{
			opensererday = {1},
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"11:00-12:00",
			}
		},
	},
	awards=
	{
		{type=0,id=680,count=-1,bind=0,strong=0,quality=0},
		{type=0,id=681,count=-1,bind=0,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00174,
			conds = { },
		},
	},
},
}