--序章比比东长矛陷阱
--创建人：张义
--创建时间：2018年4月17日21:20:20
--修改时间：



local prologue_boss_mohuabibidong_zhenshishijie = {
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlaySound",
                    OPTIONS = {sound_id ="chengniantangsan_dz1",is_loop = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
                }, 
                {
                    CLASS = "action.QSBStopSound",
                    OPTIONS = {sound_id ="chengniantangsan_dz1"},
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
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {follow_actor_animation = true, effect_id = "bbd_cha_1"},
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 5 / 24 * 30},
        --         },
        --         {
        --          CLASS = "action.QSBShakeScreen",
        --             OPTIONS = {amplitude = 25, duration = 0.2, count = 2,},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 0.2},
        --         },
        --         {
        --          CLASS = "action.QSBShakeScreen",
        --             OPTIONS = {amplitude = 20, duration = 0.2, count = 2,},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 0.2},
        --         },
        --         {
        --          CLASS = "action.QSBShakeScreen",
        --             OPTIONS = {amplitude = 25, duration = 0.2, count = 2,},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 0.2},
        --         },
        --         {
        --          CLASS = "action.QSBShakeScreen",
        --             OPTIONS = {amplitude = 20, duration = 0.2, count = 2,},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 0.2},
        --         },
        --         {
        --          CLASS = "action.QSBShakeScreen",
        --             OPTIONS = {amplitude = 25, duration = 0.2, count = 2,},
        --         },
        --     },
        -- },
    },
}

return prologue_boss_mohuabibidong_zhenshishijie


