local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayGodSkillAnimation",
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
				    CLASS = "action.QSBArgsRandomByActor",
				    OPTIONS = {random_pools = {{t = 15, dps = 35, health = 50}, {t = 45, dps = 45, health = 10}, {t = 30, dps = 30, health = 40}}, 
				    args_translate = { actorId = "copy_hero_id"}},
				},
				{
				    CLASS = "action.QSBSummonCopyHero",
				    OPTIONS = {pos = {x = 2, y = 1}, 
                    copy_slots = {1, 3, 5, 6}, 
                    percent = 0.6,
                    buff_id = "pf_ssaosika02_shenji_dot_jt", 
                    appear_skill = 201498, 
                    ai_name = "ssaosika_sj1_ai", 
                    ai_name_health = "ssaosika_sj1_ai_heal", 
                    is_visible = false , 
                    has_god_skill = false, 
                    has_enchat_skill = false,
                    set_color = ccc3(35, 35,120), 
                    set_color2 = ccc4(200, 250, 150 ,100)}
				},
            },
        },
        {
          CLASS = "action.QSBAttackFinish",
        },
    },
}

return common_xiaoqiang_victory