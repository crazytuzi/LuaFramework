

local boss_yuxiaogang_huangjingshenglongpao = {

     CLASS = "composite.QSBParallel",

     ARGS = {

        {

            CLASS = "action.QSBPlaySound"

        },

        {

            CLASS = "action.QSBPlaySound",

            OPTIONS = {sound_id ="yuxiaogang_walk"},

        },

        {

            CLASS = "composite.QSBSequence",

             ARGS = {

                {

                    CLASS = "action.QSBPlayAnimation",

                    ARGS = {

                        {

                            CLASS = "composite.QSBParallel",

                            ARGS = {

                                {

                                    CLASS = "action.QSBPlayEffect",

                                    OPTIONS = {is_hit_effect = true},

                                },

                                {

                                    CLASS = "action.QSBHitTarget",

                                },

                            },

                        },

                    },

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

                    CLASS = "action.QSBPlayEffect",

                    OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                },

                {

                    CLASS = "action.QSBPlayLoopEffect",

                    OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                },

                {

                    CLASS = "action.QSBDelayTime",

                    OPTIONS = {delay_time = 2},

                },

                {

                    CLASS = "action.QSBStopLoopEffect",

                    OPTIONS = {effect_id = "yuxiaogang_hongkuang",is_hit_effect = false},

                },

            }    

        },

    },

}



return boss_yuxiaogang_huangjingshenglongpao