--序章BOSS 鬼魅 闪现
--创建人：庞圣峰
--创建时间：2018-3-13

local prologue_boss_guimei_shanxian = {
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
            CLASS = "action.QSBTeleportToAbsolutePosition",
			OPTIONS = {pos={x = 120,y = 225}},
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

return prologue_boss_guimei_shanxian