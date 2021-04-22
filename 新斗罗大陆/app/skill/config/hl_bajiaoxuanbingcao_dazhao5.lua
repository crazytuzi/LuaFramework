local niumang_dazhao = {
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        }, 
        {                           --竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.6, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
         -------------------------------------- 播放攻击动画
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 13},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "hl_bajiaoxuanbingcao_attack11_1_1" ,is_hit_effect = false,not_cancel_with_skill = true},          --捶地水花
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 45},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "hl_bajiaoxuanbingcao_attack11_1_2" ,is_hit_effect = false,not_cancel_with_skill = true},         --内吸水浪
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {teammate=true, buff_id = {"hl_bajiaoxuanbingcao_dazhao_buff_6"}},
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {teammate=true, buff_id = {"hl_bajiaoxuanbingcao_dazhao_dun_buff_6"}},
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate=true,just_hero=true,lowest_hp=true,not_copy_hero=true, set_black_board = {lowest_hp_target = "selectTarget"}}
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "hl_bajiaoxuanbingcao_dazhao_buff_6_plus", get_black_board = {selectTaregt = "lowest_hp_target"}},
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBArgsSelectTarget",
                    OPTIONS = {is_teammate=true,just_hero=true,highest_attack=true,not_copy_hero=true,except_role="health"}
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {pass_key={"selectTarget"},buff_id = {"hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},check_selectTarget = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {pass_key={"selectTarget"},buff_id = {"hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},check_selectTarget = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {pass_key={"selectTarget"},buff_id = {"hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},check_selectTarget = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {pass_key={"selectTarget"},buff_id = {"hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},check_selectTarget = true},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {pass_key={"selectTarget"},buff_id = {"hl_bajiaoxuanbingcao_dazhao_trigger_buff_6"},check_selectTarget = true},
                },
            },
        },
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 60},
                },
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = {"hl_bajiaoxuanbingcao_dazhao_1"}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 50},
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 6, duration = 0.2, count = 2,},
                },
            },
        },
	},
}
return niumang_dazhao