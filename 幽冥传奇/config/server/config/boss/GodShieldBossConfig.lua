
GodShieldBossConfig =
{
	shieldName = "英雄神盾",
	shieldEffect = 303,
	showIcon = 4384,
	getDesc = "击败{color;FF00ff00;5个}守护神，激活{color;FF00ff00;英雄神盾}",
	attDesc = "激活属性：{color;FF00ff00;怪物减免 +1000}",
	skillDesc = "特殊效果：每次攻击时，有概率使怪物{color;FF00ff00;石化5秒！}",
	bossList =
	{
			{
				bossIdx = 1,
				sceneId = 88,
				fubenId	= 12,
				autoFreshMonster = true,
				monsters 	=
				{
					{ monsterId = 1673, sceneId = 88, num = 1,  pos = {22,30}, livetime = 3600, isBoss=true,},
				},
				enterLevelLimit	= {0,40},
				enterPos		= {16,17},
				reloginType		= 1,
				DropsShow 	=
				{
					{type = 0, id = 4017, count = 3, quality = 0, strong = 0, },
					{type = 0, id = 4713, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 141, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 155, count = 1, quality = 0, strong = 0, },
				},
				enterConsume 	=
				{
					{type = 0, id = 4261, count = 1, quality = 0, strong = 0, },
				},
				beInTime 		=  3600,
			},
			{
				bossIdx = 2,
				sceneId = 88,
				fubenId	= 12,
				autoFreshMonster = true,
				monsters 	=
				{
					{ monsterId = 1674, sceneId = 88, num = 1,  pos = {22,30}, livetime = 3600, isBoss=true,},
				},
				enterLevelLimit	= {0,50},
				enterPos		= {16,17},
				reloginType		= 1,
				DropsShow 	=
				{
					{type = 0, id = 4017, count = 5, quality = 0, strong = 0, },
					{type = 0, id = 4713, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 151, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 165, count = 1, quality = 0, strong = 0, },
				},
				enterConsume 	=
				{
					{type = 0, id = 4261, count = 1, quality = 0, strong = 0, },
				},
				beInTime 		=  3600,
			},
			{
				bossIdx = 3,
				sceneId = 88,
				fubenId	= 12,
				autoFreshMonster = true,
				monsters 	=
				{
					{ monsterId = 1675, sceneId = 88, num = 1,  pos = {22,30}, livetime = 3600, isBoss=true,},
				},
				enterLevelLimit	= {0,60},
				enterPos		= {16,17},
				reloginType		= 1,
				DropsShow 	=
				{
					{type = 0, id = 4417, count = 188, quality = 0, strong = 0, },
					{type = 0, id = 4713, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 191, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 185, count = 1, quality = 0, strong = 0, },
				},
				enterConsume 	=
				{
					{type = 10, id = 0, count = 188, quality = 0, strong = 0, },
				},
				beInTime 		=  3600,
			},
			{
				bossIdx = 4,
				sceneId = 88,
				fubenId	= 12,
				autoFreshMonster = true,
				monsters 	=
				{
					{ monsterId = 1676, sceneId = 88, num = 1,  pos = {22,30}, livetime = 3600, isBoss=true,},
				},
				enterLevelLimit	= {0,70},
				enterPos		= {16,17},
				reloginType		= 1,
				DropsShow 	=
				{
					{type = 0, id = 4417, count = 288, quality = 0, strong = 0, },
					{type = 0, id = 4713, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 231, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 241, count = 1, quality = 0, strong = 0, },
				},
				enterConsume 	=
				{
					{type = 10, id = 0, count = 288, quality = 0, strong = 0, },
				},
				beInTime 		=  3600,
			},
			{
				bossIdx = 5,
				sceneId = 88,
				fubenId	= 12,
				autoFreshMonster = true,
				monsters 	=
				{
					{ monsterId = 1677, sceneId = 88, num = 1,  pos = {22,30}, livetime = 3600, isBoss=true,},
				},
				enterLevelLimit	= {0,80},
				enterPos		= {16,17},
				reloginType		= 1,
				DropsShow 	=
				{
					{type = 0, id = 4417, count = 388, quality = 0, strong = 0, },
					{type = 0, id = 4713, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 311, count = 1, quality = 0, strong = 0, },
					{type = 0, id = 297, count = 1, quality = 0, strong = 0, },
				},
				enterConsume 	=
				{
					{type = 10, id = 0, count = 388, quality = 0, strong = 0, },
				},
				beInTime 		=  3600,
			},
	},
}
