
local ultra_wild_mushrooms = {         -- 野性蘑菇，符文图腾

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
                                    OPTIONS = {delay_frame = 52},
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
                    OPTIONS = {effect_id = "huichun_1_1"},     --左右手
                }, 
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "huichun_1_2"},     --左右手
                }, 
            },
        },
    },
}

return ultra_wild_mushrooms
