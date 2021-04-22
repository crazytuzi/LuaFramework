--斗罗AI 9-4BOSS
--普通副本
--character_id 3535random_firetrap
--[[
大火球砸地晕50580(普攻)
 X型火焰
火焰旋风
召唤炽火
]]--
--创建人：刘悦璘
--创建时间：2018-5-6

local npc_boss_yan = {     
    CLASS = "composite.QAISelector",
    ARGS =
    {
  --       {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 500, first_interval = 0},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50098},
  --               },
  --           },
  --       },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 30, first_interval = 15},
  --               },
		-- 		{
  --                   CLASS = "action.QAIAttackAnyEnemy",
  --                   OPTIONS = {always = true},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50581},      --X型火焰
  --               },
  --           },
  --       },
		-- {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAITimer",
  --                   OPTIONS = {interval = 15, first_interval = 15},
  --               },
  --               {
  --                   CLASS = "action.QAIIsUsingSkill",
  --                   OPTIONS = {reverse_result = true , check_skill_id = 50095},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50583},      --火焰旋风
  --               },
  --           },
  --       },
  --       {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAIHPLost",
  --                   OPTIONS = {hp_less_then = {0.7}},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50095},    --召唤炽火-1
  --               },
  --           },
  --       },
  --       {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAIHPLost",
  --                   OPTIONS = {hp_less_then = {0.4}},
  --               },
  --               {
  --                   CLASS = "action.QAIUseSkill",
  --                   OPTIONS = {skill_id = 50095},     --召唤炽火-1
  --               },
  --           },
  --       },
  --       {
  --           CLASS = "composite.QAISequence",
  --           ARGS = 
  --           {
  --               {
  --                   CLASS = "action.QAIIsUsingSkill",
  --                   OPTIONS = {reverse_result = true , check_skill_id = 50095},
  --               },
  --               {
  --                   CLASS = "action.QAIIsUsingSkill",
  --                   OPTIONS = {reverse_result = true , check_skill_id = 50581},
  --               },
  --               {
  --                   CLASS = "action.QAIIsUsingSkill",
  --                   OPTIONS = {reverse_result = true , check_skill_id = 50583},
  --               },
  --               {
  --                   CLASS = "action.QAITeleport",
  --                   OPTIONS = {interval = 10.0, hp_less_than = 0.85},
  --               },
  --           },
  --       },
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
                    CLASS = "action.QAIAttackAnyEnemy",
                    
                },
            },
        },
    }
}
        
return npc_boss_yan