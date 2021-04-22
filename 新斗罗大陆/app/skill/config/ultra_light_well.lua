
local ultra_spell_barrier = {         -- 光明之泉，怀特迈恩

    CLASS = "composite.QSBParallel",
    ARGS = {
        {       -- 动作
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack14"},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 20},
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
                                    OPTIONS = {delay_frame = 65},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_1_l"},     --左右手
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_1_r"},     --左右手
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_1_2_l"},   --左右手
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_1_2_r"},   --左右手
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_1_1"},     --身体
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 65},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "huaitemaien_guangmingzhiquan_3", pos  = {x = 650 , y = 320}},
                },
            },
        },
    },
}

return ultra_spell_barrier
