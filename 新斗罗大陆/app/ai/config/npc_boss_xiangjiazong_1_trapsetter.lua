--斗罗AI 象甲宗BOSS藤蔓陷阱放置者
--普通副本
--id 3282  6--4
--[[
普攻
冲锋跳跃
摔倒
锤地板
狂暴
]]--
--创建人：庞圣峰
--创建时间：2018-3-28

local npc_boss_xiangjiazong_1_trapsetter= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 300,first_interval = 15},
                },
				{
                    CLASS = "action.QAIAttackByStatus",
					OPTIONS = {is_team = true, status = "boss_special_mark"},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50377}, -- 初次召唤陷阱
                },
				{
                    CLASS = "action.QAIIgnoreHitLog",
                },
            },
        },
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 36,first_interval = 51.5},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50378},
                },
            },
        },
    }
}
        
return npc_boss_xiangjiazong_1_trapsetter