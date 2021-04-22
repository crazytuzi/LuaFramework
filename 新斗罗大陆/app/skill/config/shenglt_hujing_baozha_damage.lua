-- 技能 白鲸自爆炸黑鲸10%
-- 技能ID 53285
--[[
	黑化虎鲸 4105
	升灵台
	psf 2020-4-13
]]--

local shenglt_baihujing_baozha = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 3,
                        {expression = "self:has_buff:shenglt_heihujing_debuff", select = 1},
                        {expression = "self:has_buff:shenglt_baihujing_debuff", select = 2},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBActorStatus",
                                    OPTIONS = 
                                    {
                                        { "self:shenglt_heihujing", "self:decrease_hp:maxHp*1","under_status"},
                                    }
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBActorStatus",
                                    OPTIONS = 
                                    {
                                        { "self:shenglt_heihujing", "self:decrease_hp:maxHp*0.2","under_status"},
                                    }
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
    },
}

return shenglt_baihujing_baozha
