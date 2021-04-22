

local guimei_guiyingchongchong = {

    CLASS = "composite.QSBSequence",

    ARGS = {

        {

            CLASS = "composite.QSBParallel",

            ARGS = {

                {

                    CLASS = "action.QSBManualMode",

                    OPTIONS = {enter = true, revertable = true},

                },

                {

                    CLASS = "action.QSBActorStand",

                },

                {

                    CLASS = "action.QSBPlayAnimation",

                    OPTIONS = {animation = "attack12_1"},

                },

                {

                    CLASS = "action.QSBActorFadeOut",

                    OPTIONS = {duration = 0.25, revertable = true},

                },

            },

        },

        {

            CLASS = "action.QSBTeleportToPosition",

        },

        {

            CLASS = "composite.QSBParallel",

            ARGS = {

                {

                    CLASS = "action.QSBPlayAnimation",

                    OPTIONS = {animation = "attack12_2"},

                },

                {

                    CLASS = "action.QSBActorFadeIn",

                    OPTIONS = {duration = 0.25, revertable = true},

                },

            },

        },

        {

            CLASS = "action.QSBManualMode",

            OPTIONS = {exit = true},

        },

        {

            CLASS = "action.QSBAttackFinish"

        },

    },

}



return guimei_guiyingchongchong