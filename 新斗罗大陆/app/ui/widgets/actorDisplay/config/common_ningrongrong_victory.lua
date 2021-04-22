
local common_ningrongrong_victory = {
	CLASS = "composite.QUIDBParallel",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "victory"},
        },
		{
            CLASS = "action.QUIDBPlayEffect",
            OPTIONS = {effect_id = "nignrongrong_ui_victory"},
        },
    },
}

return common_ningrongrong_victory