-- 英雄普攻动作
local common_atk12 = {
	CLASS = "composite.QUIDBSequence",
    ARGS = {
        {
            CLASS = "action.QUIDBPlayAnimation",
            OPTIONS = {animation = "attack12"},
        },
    },
}

return common_atk12