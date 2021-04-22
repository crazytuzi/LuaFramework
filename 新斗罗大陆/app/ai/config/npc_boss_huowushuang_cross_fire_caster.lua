--斗罗AI 十字火焰施法者
--普通副本
--id 3293  6--16
--[[
造成十字火焰伤害
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_huowushuang_cross_fire_caster= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {

		{
            CLASS = "action.QAIAttackByHitlog",
        },
        {
            CLASS = "composite.QAISelector",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsAttacking",
                },
                {
                    CLASS = "action.QAIBeatBack",
                },
                {
                    CLASS = "action.QAIAttackClosestEnemy",
                },
            },
        },
    }
}
        
return npc_boss_huowushuang_cross_fire_caster