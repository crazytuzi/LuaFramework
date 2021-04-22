

local pour_wine_drunken_dwarf= {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                         {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "stand02"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2},
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
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "pour_wine_drunken_dwarf_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "pour_wine_drunken_dwarf_1"},
                }, 
            },
        },
    },
}

return pour_wine_drunken_dwarf

