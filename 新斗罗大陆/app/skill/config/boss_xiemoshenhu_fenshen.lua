-- 技能 BOSS邪魔神虎 分身
-- 技能ID 50863
-- 分身出俩怪
--[[
	boss 邪魔神虎
	ID:3696
	psf 2018-7-19
]]--

local boss_xiemoshenhu_fenshen = 
{
	CLASS = "composite.QSBSequence",
	ARGS =
	{
		{
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
		{
			CLASS = "action.QSBActorFadeOut",
			OPTIONS = {duration = 0.2, revertable = true},
		},
		{
            CLASS = "action.QSBTeleportToAbsolutePosition",
            OPTIONS = {pos = {x = 640, y = 300}},
        },
		{
			CLASS = "composite.QSBParallel",
			ARGS = 
			{
				{
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{
							CLASS = "action.QSBPlayAnimation",
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS =
					{
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 20/24 },
						},
						{
							CLASS = "action.QSBArgsIsDirectionLeft",
							OPTIONS = {is_attacker = true},
						},
						{
							CLASS = "composite.QSBSelector",
							ARGS = 
							{   
								{
									CLASS = "action.QSBSummonMonsters",
							        OPTIONS = {wave = -1},
								},
								{
									CLASS = "action.QSBSummonMonsters",
							        OPTIONS = {wave = -2},
								},
							},
						},
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
						},
					},
				},
			},
		},
	},
}
return boss_xiemoshenhu_fenshen