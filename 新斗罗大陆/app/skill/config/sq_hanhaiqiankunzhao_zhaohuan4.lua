-- 技能 瀚海乾坤罩召唤4
-- 技能ID 2020039

local sq_hanhaiqiankunzhao_zhaohuan4 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
            OPTIONS = {is_god_arm = true},
        },
        {
            CLASS = "action.QSBSummonGhosts",
            OPTIONS = {
                actor_id = 30008, life_span = 12,number = 1, no_fog = true, use_render_texture = false, 
                relative_pos = {x=0,y=0},appear_skill = 2020044,
                is_attacked_ghost = true,
                enablehp = true,
                percents = {armor_physical = 1, armor_magic = 1},
                hp_percent = 1.15,
                same_target = true,
                lock_target = true
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return sq_hanhaiqiankunzhao_zhaohuan4

