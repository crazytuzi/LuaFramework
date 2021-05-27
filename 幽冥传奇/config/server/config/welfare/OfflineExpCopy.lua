
--#include "..\..\language\LangCode.txt"
OfflineExpSceneGetEvent =
{
	offlineExpActorLevel = 1,
	offlineKillMonster = 2,
	offlineVipLevel = 3,
}
OfflineExpCopyCfg =
{
	OpenLevel = {0, 70},
	AwardCondition =
	{
		{
			preNum = 1000000,
			needVipLevel = 1,
			costMoneyType = 3,
			CostMoneyNum = 50,
		},
		{
			preNum = 1000000,
			needVipLevel = 3,
			costMoneyType = 3,
			CostMoneyNum = 150,
		},
	},
	OfflineExpScenes =
	{
		{
			MaxHour = 72,
			SceneName = Lang.ScriptTips.OfflineExpCopy011,
			GetCond =
			{
				{
					{
						event = OfflineExpSceneGetEvent.offlineExpActorLevel,
						param = 0,
						param2 = 70,
					},
				},
			},
			EveryHourAwards =
			{
				{ type = 1, id = 0, count = 1000000, bind = 1, },
				{ type = 3, id = 0, count = 10000, bind = 1, },
			},
		},
		{
			MaxHour = 72,
			SceneName = Lang.ScriptTips.OfflineExpCopy012,
			GetCond =
			{
				{
					{
						event = OfflineExpSceneGetEvent.offlineExpActorLevel,
						param = 0,
						param2 = 90,
					},
					{
						event = OfflineExpSceneGetEvent.offlineKillMonster,
						param = 286,
						param2 = 1,
					},
				},
			},
			EveryHourAwards =
			{
				{ type = 1, id = 0, count = 1000000, bind = 1, },
				{ type = 3, id = 0, count = 15000, bind = 1, },
			},
		},
		{
			MaxHour = 72,
			SceneName = Lang.ScriptTips.OfflineExpCopy013,
			GetCond =
			{
				{
					{
						event = OfflineExpSceneGetEvent.offlineExpActorLevel,
						param = 0,
						param2 = 100,
					},
					{
						event = OfflineExpSceneGetEvent.offlineKillMonster,
						param = 288,
						param2 = 1,
					},
				},
			},
			EveryHourAwards =
			{
				{ type = 1, id = 0, count = 1000000, bind = 1, },
				{ type = 3, id = 0, count = 20000, bind = 1, },
			},
		},
		{
			MaxHour = 72,
			SceneName = Lang.ScriptTips.OfflineExpCopy014,
			GetCond =
			{
				{
					{
						event = OfflineExpSceneGetEvent.offlineVipLevel,
						param = 2,
					},
					{
						event = OfflineExpSceneGetEvent.offlineExpActorLevel,
						param = 0,
						param2 = 110,
					},
					{
						event = OfflineExpSceneGetEvent.offlineKillMonster,
						param = 290,
						param2 = 1,
					},
				},
			},
			EveryHourAwards =
			{
				{ type = 1, id = 0, count = 1000000, bind = 1, },
				{ type = 3, id = 0, count = 25000, bind = 1, },
			},
		},
		{
			MaxHour = 72,
			SceneName = Lang.ScriptTips.OfflineExpCopy015,
			GetCond =
			{
				{
					{
						event = OfflineExpSceneGetEvent.offlineVipLevel,
						param = 4,
					},
					{
						event = OfflineExpSceneGetEvent.offlineExpActorLevel,
						param = 0,
						param2 = 120,
					},
					{
						event = OfflineExpSceneGetEvent.offlineKillMonster,
						param = 292,
						param2 = 1,
					},
				},
			},
			EveryHourAwards =
			{
				{ type = 1, id = 0, count = 1000000, bind = 1, },
				{ type = 3, id = 0, count = 30000, bind = 1, },
			},
		},
	},
}