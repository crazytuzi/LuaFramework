--七宝琉璃弟子 精英
--NPC原型 10014
--普攻ID:50297
--治疗兵,低血闪现
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：庞圣峰
--创建时间：2018-3-21

local npc_qibaoliulidizi_elite = {     
	CLASS = "composite.QAISelector",
    ARGS =
    {
        -- {
            -- CLASS = "composite.QAISequence",
            -- ARGS = 
            -- {
                -- {
                    -- CLASS = "action.QAITimer",
                    -- OPTIONS = {interval = 10,first_interval=0},
                -- },
                -- {
                    -- CLASS = "action.QAIAttackAnyEnemy",
                    -- OPTIONS = {always = true},
                -- },
                -- {
                    -- CLASS = "action.QAIUseSkill",
                    -- OPTIONS = {skill_id = 50298}, --全队加防御
                -- },
            -- },
        -- },
		{
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.6},
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 1.5, include_self = false, treat_hp_lowest = true},
        },
    },
}
        
return npc_qibaoliulidizi_elite