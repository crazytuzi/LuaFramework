
-- 独孤雁BOSS毒圈重置（spine）
-- 需要自己调技能和特效

-- 创建人：王鉴治
-- 创建时间：2020-4-29

local duguyan_duquan = 
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
                    OPTIONS = {delay_frame = 25},
                },
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {effect_id = "duguyan_attack13_1", is_hit_effect = false},
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
                    OPTIONS = {start_pos = {x = 0,y = 120}, effect_id = "duguyan_attack13_2_1", speed = 2000},
                },
            },
        },
    },
}

return duguyan_duquan