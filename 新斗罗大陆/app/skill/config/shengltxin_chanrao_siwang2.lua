-- 作用：消除buff
local boss_chanraosiwang_1 = 

{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {

        {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_frame = 10},
        },
        -- {
        --     CLASS = "action.QSBArgsSelectTarget",
        --     OPTIONS = {under_status = "stun_2", pass_key = {"selectTarget"}},
        -- },

        {

            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {under_status = "stun_1", pass_key = {"selectTarget"}},
                },

                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = { duration = 0.1, pass_key = {"selectTarget"}},
                },


                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_chaoxuemuzhu_jihuo",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "chaorao_yishang",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_chaoxuemuzhu_chanrao1"},
                },

                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        -- {
        --             CLASS = "action.QSBActorFadeIn",
        --             OPTIONS = { duration = 0.1, is_target = true },
        -- },
    },
}
return boss_chanraosiwang_1