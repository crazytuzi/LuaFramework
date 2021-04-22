
local anqi_mifengnnaiping_attack5 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {teammate_lowest_hp = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    OPTIONS = {pass_key = {"pos"}},
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBMultipleTrap",
                            OPTIONS = {trapId = "anqi_mifengnaiping_attack",count = 1, interval_time = 0.6},
                        },
                        {
                            CLASS = "action.QSBMultipleTrap",
                            OPTIONS = {trapId = "anqi_mifengnaiping_attack1",count = 1},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 74},
                },
                {
                    CLASS = "action.QSBTriggerSkill",
                    OPTIONS = {skill_id = 40514,target_type="skill_target"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return anqi_mifengnnaiping_attack5

