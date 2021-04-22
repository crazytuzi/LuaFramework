-- 技能 水冰儿普攻
-- 技能ID 50657
-- 类似子弹通用,但是攻击特效在攻击标点播
--[[
	boss 水冰儿
	ID:3176 智慧试炼
	psf 2018-5-31
]]--

local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    { 
                        {
                            CLASS = "action.QSBPlayAnimation",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {flip_follow_y = true},
                                },
                            },
                        },
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
									CLASS = "action.QSBDelayTime",
									OPTIONS = {delay_time = 15/24},
								},
								{
									CLASS = "action.QSBPlayEffect",
									OPTIONS = {is_hit_effect = false},
								},
							},
						},
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zidan_tongyong

