--斗罗AI 黄金玳瑁
--升灵台
--id 4111
--[[
一根筋
]]--
--psf 2020-4-14

local npc_wugui2_ai = {
    CLASS = "composite.QAISelector",
    ARGS =
    {  
       {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "action.QAIIsHaveTarget",
                },
                {
                    CLASS = "action.QAISequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAITimer",
                            OPTIONS = {interval = 6, first_interval = 2, allow_frameskip = true},
                        },
                        {
                            CLASS = "action.QAITrackTarget",
                        },
                        {
                            CLASS = "action.QAIResult",
                            OPTIONS = {result = true},
                        },
                    },
                },
            },
        },

        {
            CLASS = "action.QAISequence",
            ARGS = 
            {
                {
                    CLASS = "decorate.QAIInvert",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QAIIsHaveTarget",
                        },
                    },
                },
                {
                    CLASS = "action.QAIAttackAnyEnemy",
                },
                {
                    CLASS = "action.QAITrackTarget",
                },
                {
                    CLASS = "action.QAIRewindTimers",
                },
            },
        },
    },
}
        
return npc_wugui2_ai