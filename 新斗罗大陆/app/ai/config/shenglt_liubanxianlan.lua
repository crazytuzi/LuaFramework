--斗罗AI：六瓣仙兰
--升灵台
--id 4116
--[[
蓄力群疗
]]
--psf 2020-4-14

local shenglt_liubanxianlan = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1.5, include_self = false, treat_hp_lowest = true},
        },
    },
}
        
return shenglt_liubanxianlan