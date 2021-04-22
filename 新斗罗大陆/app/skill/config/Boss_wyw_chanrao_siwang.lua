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
                    OPTIONS = {under_status = "rattan_stun", pass_key = {"selectTarget"}},
                },

                -- {
                --     CLASS = "action.QSBActorFadeIn",
                --     OPTIONS = { duration = 0.1, pass_key = {"selectTarget"}},
                -- },


                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_wyw_chaorao_front",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_wyw_chaorao_back",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "wyw_zhongji_heal_reduction_chanrao",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "chanrao_js",pass_key = {"selectTarget"}},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_wyw_chanrao_dot"},
                },
                
                {
                    CLASS = "action.QSBSuicide",
                },
                -- {
                --     CLASS = "action.QSBRemoveBuff",
                --     OPTIONS = {buff_id = "boss_chaoxuemuzhu_chanrao1"},
                -- },

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