--  创建人：蔡允卿
--  创建时间：2018.04.12
--  NPC：宁风致
--  类型：治疗
local npc_boss_ningfengzhi = {
 CLASS = "composite.QAISelector",
    ARGS =
    {
        {
             CLASS = "composite.QAISequence",
             ARGS = 
             {
                 {
                     CLASS = "action.QAITimer",
                     OPTIONS = {interval =16 ,first_interval=4},
                 },
                 {
                     CLASS = "action.QAIUseSkill",
                     OPTIONS = {skill_id = 50203},
                 },
             },
         },
        {
             CLASS = "composite.QAISequence",
             ARGS = 
             {
                 {
                     CLASS = "action.QAITimer",
                     OPTIONS = {interval =16 ,first_interval=11},
                 },
                 {
                     CLASS = "action.QAIUseSkill",
                     OPTIONS = {skill_id = 50204},
                 },
             },
        },
        {
             CLASS = "composite.QAISequence",
             ARGS = 
             {
                 {
                     CLASS = "action.QAITimer",
                     OPTIONS = {interval =16 ,first_interval=16},
                 },
                 {
                     CLASS = "action.QAIUseSkill",
                     OPTIONS = {skill_id = 50201},
                 },
             },
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.75},
        },
        {
            CLASS = "action.QAITeleport",
            OPTIONS = {interval = 10.0, hp_less_than = 0.35},
        },
        {
            CLASS = "action.QAITreatTeammate",
            OPTIONS = {hp_below = 2, include_self = false, treat_hp_lowest = true},
        },
    },    
}

return npc_boss_ningfengzhi
    