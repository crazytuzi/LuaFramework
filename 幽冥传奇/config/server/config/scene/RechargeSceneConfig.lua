
--#include "..\..\language\LangCode.txt" once
RechargeSceneNpcTeleId =254
RechargeSceneConfig =
{
	{
		mapIdx					= 1,
		sceneId					= 211,
		levelSts				= 1,
		openOrCombServerDay		= {7,0},
		enterDailyRechargeLimit	= 9888,
		enterPos				= {70,139},
		npcDesc					= Lang.ScriptTips.RechargeSceneDesc01,
	},
	{
		mapIdx					= 2,
		sceneId					= 212,
		levelSts				= 2,
		openOrCombServerDay		= {7,0},
		enterConsume 			=
  		{
    		{type = 5, id = 0, count = 5000, quality = 0, strong = 0 },
   		},
		enterPos				= {67,22},
		noCheckFromScene		= true,
		npcDesc					= Lang.ScriptTips.RechargeSceneDesc02,
	},
	{
		mapIdx					= 3,
		sceneId					= 213,
		levelSts				= 3,
		openOrCombServerDay		= {7,0},
		enterConsume 			=
  		{
    		{type = 5, id = 0, count = 25000, quality = 0, strong = 0 },
   		},
		enterPos				= {38,37},
		noCheckFromScene		= true,
		npcDesc					= Lang.ScriptTips.RechargeSceneDesc03,
	},
}
