local guimei_guiyingchongchong = {

    CLASS = "composite.QSBSequence",

    ARGS = {

        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBPlayMountSkillAnimation",
        },
        {
            CLASS = "action.QSBArgsFindDragPosBySkillRange",
            OPTIONS = {args_translate = {pos = "target_pos"}, assassin_list = {1012, 1031, 1025, 1033}},
        },
        {

            CLASS = "action.QSBMoveWithHook",
            OPTIONS = {head_effect_id = "feitianshenzhua_attack01_1", body_src = "effect/feitianshenzhua_attack01_2.PNG", body_offset = {x = 0, y = 0}, body_width = 235, animation_speed = 2200, move_speed = 2000},

        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false,buff_id = "anqi_feitianshenzhua_feitianzenyi_buff5"},
        },
        {

            CLASS = "action.QSBAttackFinish"

        },

    },

}



return guimei_guiyingchongchong