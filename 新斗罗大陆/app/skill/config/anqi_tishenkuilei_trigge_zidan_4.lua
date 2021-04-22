
local zidan_tongyong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true}
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {flip_follow_y = true,target_teammate_lowest_hp_percent=true,justHero=true,ignore_hit=true,pass_key={"selectTarget"}},
                },
                {
                    CLASS = "action.QSBTriggerSkillIgnoreCD",
                    OPTIONS = {skill_id=40262,skill_level=1,debug=true},
                },
                {
                    CLASS = "action.QSBPlayMountSkillAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return zidan_tongyong
