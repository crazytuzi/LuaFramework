--曼陀罗蛇
--NPC原型 10009
--普攻ID:50015
--蓄力预警直线冲锋
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：许成
--创建时间：2017-6-17
--迭代: 庞圣峰 2018-3-21

local npc_mantuoluoshe= {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
        {   
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 20,first_interval= 2 },
                },
                -- {
                --     CLASS = "action.QAIAttackByHitlog",
                --     OPTIONS = {always = true},
                -- },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50033},          --毒蛇冲刺
                },
            },
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
        
return npc_mantuoluoshe