
local pour_wine_dwarf= {
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
                    OPTIONS = {delay_time = 5},
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
                    OPTIONS = {delay_frame = 30},
                },
                {
                    CLASS = "action.QSBPlayLoopEffect",
                    OPTIONS = {effect_id = "pour_wine_dwarf_1"},
                }, 
        	},
    	},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 86},
                },
                {
                    CLASS = "action.QSBStopLoopEffect",
                    OPTIONS = {effect_id = "pour_wine_dwarf_1"},
                }, 
            },
        },
    	{
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 106},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "pour_wine_dwarf_2"},
                }, 
        	},
    	},
    },
}

return pour_wine_dwarf

