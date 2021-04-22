-- 作用：消除buff
local boss_chanraosiwang_1 = 

{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {

        {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = { delay_time = 1},
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
                    OPTIONS = {under_status = "rattan_stun", pass_key = {"selectTarget"}},
                },



                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "chanrao_js"},
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