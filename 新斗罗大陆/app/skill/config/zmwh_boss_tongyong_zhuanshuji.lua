--斗罗SKILL 专属技
--宗门武魂争霸
--id 51336
--通用 主体
--[[
根据武魂形象释放专属技
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_tongyong_zhuanshuji = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
		-- {
            -- CLASS = "action.QSBPlayUnionDragonSpecialSkillEffect",
        -- },
        {
			CLASS = "action.QSBAttackFinish",
		},
    },
}

return zmwh_boss_tongyong_zhuanshuji

