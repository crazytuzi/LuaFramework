--序章比比东长矛陷阱
--创建人：张义
--创建时间：2018年4月9日18:29:58
--修改时间：



local prologue_boss_mohuabibidong_changmao = {
      CLASS = "composite.QSBParallel",
     ARGS = {
        {

             CLASS = "composite.QSBSequence",
             ARGS = {
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5 / 24 * 30},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5 / 24 * 30},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "bbdboss_attack15_1"},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="xuzhang_bibidong_zm"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 35, duration = 0.2, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.2},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 30, duration = 0.2, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.2},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 35, duration = 0.1, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45 / 24 * 30},
                },
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="xuzhang_bibidong_zd"},
                },
            },
        },
    },
}

return prologue_boss_mohuabibidong_changmao


