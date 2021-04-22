--斗罗AI 召唤炽火
--普通副本
--id 3288  6--16
--[[
50372	随机指人大火球(作为普攻)
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_huowushuang_chihuo= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
		{
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 15.0, hp_less_than = 0.5},
        },
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
        
return npc_boss_huowushuang_chihuo