--刺豚
--普通副本
--创建人：许成
--创建时间：2017-6-26

local npc_citun1= {     
            CLASS = "composite.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAITimer",
                    OPTIONS = {interval = 2000,first_interval=5},
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                    OPTIONS = {always = true},
                },
                {
                    CLASS = "action.QAIUseSkill",
                    OPTIONS = {skill_id = 50057},          --自爆
                },
            },
}
        
return npc_citun1