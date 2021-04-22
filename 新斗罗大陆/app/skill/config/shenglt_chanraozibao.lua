local qiangzhen_zibao =
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {under_status = "attack_order"},
        },
        {

            CLASS = "composite.QSBParallel",
            ARGS = 
            {

                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_chaoxuemuzhu_chanrao", multiple_target_with_skill = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 1},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = { duration = 0.01, is_target = true },
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "boss_chaoxuemuzhu_jihuo", multiple_target_with_skill = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "chaorao_yishang", multiple_target_with_skill = true},
                },

                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return qiangzhen_zibao