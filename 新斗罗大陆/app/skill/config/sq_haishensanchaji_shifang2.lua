-- 技能 海神三叉戟释放2
-- 技能ID 2020022

local sq_haishensanchaji_shifang2 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "sq_haishensanchaji_siwangchufa2", teammate_and_self = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "sq_haishensanchaji_chufa2", is_target = false},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "sq_haishensanchaji_shunjian_chufa2", teammate_and_self = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "sq_haishensanchaji_qianghua2", teammate_and_self = true},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "sq_haishensanchaji_biaoji", is_target = false},
                },
            },
        },
        {
            CLASS = "action.QSBArgsIsHero",
            OPTIONS = {is_attacker = true},
        },
        {
            CLASS = "composite.QSBSelector",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "sq_scj_attack2_1", pos  = {x = 640 , y = 400}, ground_layer = true},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "sq_scj_attack2_2", pos  = {x = 640 , y = 400}, ground_layer = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "sq_haishensanchaji_hudun2", teammate_and_self = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlaySceneEffect",
                            OPTIONS = {effect_id = "sq_scj_attack2_1_1", pos  = {x = 640 , y = 400}, ground_layer = true},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "sq_scj_attack2_2_1", pos  = {x = 640 , y = 400}, ground_layer = true},
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = "sq_haishensanchaji_hudun2", teammate_and_self = true},
                        },
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBAttackFinish",
                        },
                    },
                },
            },
        },
    },
}

return sq_haishensanchaji_shifang2

