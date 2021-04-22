local common_xiaoqiang_victory = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
				    CLASS = "action.QSBArgsRandomByActor",
				    OPTIONS = {random_pools = {{t = 10, dps = 10, health = 80}, {t = 30, dps = 60, health = 10}, {t = 10, dps = 10, health = 60}}, 
				    args_translate = { actorId = "copy_hero_id"}}
				},
				{
				    CLASS = "action.QSBSummonCopyHero",
				    OPTIONS = {pos = {x = 2, y = 4.5}, copy_slots = {1, 3, 5, 6}, percent = 0.7, buff_id = "ssaosika_zhenji_dot_jt",
                    appear_skill = 190280,is_visible = false, ai_name = "ssaosika_zj2_ai",ai_name_health = "ssaosika_zj2_ai",has_god_skill = false, has_enchat_skill = false,
                    set_color = ccc3(35, 35,120) , set_color2 = ccc4(200, 250, 150 ,100)}
				},
            },
        },
        {
          CLASS = "action.QSBAttackFinish",
        },
    },
}

return common_xiaoqiang_victory