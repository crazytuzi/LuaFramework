return {
{
	name =Lang.ActivityName.name00017,
	desc=Lang.ActivityName.desc00017,
	--时间的描述,如果是20:30-21:05这样的就不需要记录到语言包，如果是"全天"就需要记录到语言包
	timeDesc = Lang.ActivityName.timeDesc00008,
	level = 35,
	icon = 7,
	type = 3,
	index =0,
	mainAwardDesc = Lang.ActivityName.mainAward005,
	openTimes=
	{
		{
			opensererday = {7},
			months={},
			days ={},
			weeks={0},
			minutes=
			{
				"16:00-23:00",
			}
		},
	},
	awards=
	{
		{type=0,id=578,count=1,bind=0,strong=0,quality=0},
	},
	npc=
	{
		{
			sceneId=8,name=Lang.EntityName.n00024,
			conds = { },
		},
	},
},
}