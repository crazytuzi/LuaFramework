-- 英雄特殊普攻动作
local common_atk02 = {
	CLASS = "composite.QUIDBSequence",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack02"},
        },
    },
}

return common_atk02