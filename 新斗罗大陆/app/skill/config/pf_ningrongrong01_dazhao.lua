-- 技能 宁荣荣 九宝有名护盾消失清除BUFF
-- 技能ID 300
-- 上BUFF
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--


local ningrongrong_dazhao = {
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
		{
            CLASS = "action.QSBPlaySound"
        },
		{
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="pf_ningrongrong01_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBApplyBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
				{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
					ARGS = {
						{
							CLASS = "composite.QSBParallel",
							ARGS = {
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = false},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
							},
						},
					},
                },
				{
					CLASS = "action.QSBRemoveBuff",
					OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
	},
}
return ningrongrong_dazhao