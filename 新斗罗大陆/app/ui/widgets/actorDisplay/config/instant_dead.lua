
local instant_dead = {
	CLASS = "composite.QUIDBSequence",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "dead", instant = true},
        },
    },
}

return instant_dead