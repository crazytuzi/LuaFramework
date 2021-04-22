-- 技能 神器擎天枪
-- 技能ID 2020009

local sq_qingtianqiang4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
  --       {
		-- 	CLASS = "action.QSBPlayEffect",
		-- 	OPTIONS = {effect_id = "ssmahongjun_attack01_1", is_hit_effect = false},
		-- },
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBTrap", 
                    OPTIONS = 
                    { 
                        trapId = "sq_qingtianqiang_shanghai4",
                        args = 
                        {
                            {delay_time = 0 , target_pos = true} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 2020111,target_type="skill_target"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return sq_qingtianqiang4

