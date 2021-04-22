-- 技能 盘龙棍伤害1
-- 技能ID 2020082

local sq_panlonggun_shanghai1 = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "action.QSBArgsSelectTarget",
            OPTIONS = {lowest_hp = true},
        },
        {
            CLASS = "composite.QSBParallel",
            OPTIONS = {pass_key = {"selectTarget"}},
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "sq_lwg_attack1", is_hit_effect = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_panlonggun_shanghai1

