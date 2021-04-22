 --斗罗AI 宗门武魂BOSS天气小精灵
--宗门武魂争霸
--id 61035
--[[
普攻
]]--
--创建人：庞圣峰
--创建时间：2018-12-29

local zmwh_boss_tongyong_tianqi= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 180, first_interval = 0},
                },
				{
                    CLASS = "action.QAIUnionDragonApplyBuff", --根据天气上buff
                }, 
            },
        },
		--预读天气技能
		{
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 999, first_interval = 999},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51391},
                }, 
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51392},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51393},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51394},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51395},
                },
				{
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 51396},
                },
            },
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
    },
}
        
return zmwh_boss_tongyong_tianqi