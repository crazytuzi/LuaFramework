-- 技能 神器擎天枪
-- 技能ID 2020006

local sq_qingtianqiang = 
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
                        trapId = "sq_qingtianqiang_shanghai1",
                        args = 
                        {
                            {delay_time = 0 , target_pos = true} ,
                        },
                    },
                },
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 2020108,target_type="skill_target"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return sq_qingtianqiang

