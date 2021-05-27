return {
{
	name = Lang.ActivityName.name00011,
	desc = Lang.ActivityName.desc00011,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = "",
	level = 1,
	icon = 1,
	type = 5,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward005,
	openTimes=
	{
		{
			months={},
			days ={},
			weeks={4,5},
			minutes=
			{
				"16:30-17:00",
			}
		},
	},
	awards=
	{
		{type=0,id=574,count=1,bind=0,strong=0,quality=0},
		{type=0,id=575,count=1,bind=0,strong=0,quality=0},
		{type=0,id=570,count=1,bind=0,strong=0,quality=0},
		{type=0,id=571,count=1,bind=0,strong=0,quality=0},
		{type=0,id=572,count=1,bind=0,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00180,
			conds = { },
		},
	},
},
}