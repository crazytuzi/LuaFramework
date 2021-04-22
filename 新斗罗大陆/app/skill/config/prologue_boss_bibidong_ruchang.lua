--序章比比东AI
--创建人：张义
--创建时间：2018年4月9日22:45:11
--修改时间：



local prologue_boss_bibidong_ruchang = {
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
                    OPTIONS = {delay_frame = 22 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 18, duration = 0.16, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.16},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 14, duration = 0.08, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 46 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 18, duration = 0.16, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.16},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 14, duration = 0.08, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 76 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 18, duration = 0.16, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.16},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 14, duration = 0.08, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 108 / 24 * 30},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.12, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.12, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.12, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.12, count = 2,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 10, duration = 0.12, count = 2,},
                },
            },
        },
    },
}

return prologue_boss_bibidong_ruchang