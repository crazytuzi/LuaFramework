
-- 胡列娜普攻重置（spine）
-- 需要自己调技能和特效

-- 创建人：王鉴治
-- 创建时间：2020-5-23
local huliena_pugong = 
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
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
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
                    OPTIONS = {delay_frame = 5},
                },
                {
					CLASS = "action.QSBPlayEffect",  --出手特效
					OPTIONS = {effect_id = "huliena_attack01_1", is_hit_effect = false},
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 25},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 100,y = 80}, effect_id = "huliena_attack01_2", speed = 2000, hit_effect_id = "huliena_attack01_3"},
                },
            },
        },
    },
}

return huliena_pugong