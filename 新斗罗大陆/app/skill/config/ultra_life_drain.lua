
local ultra_life_drain = {                            --古尔丹大招生命汲取
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {                                               --脚底特效法阵
            CLASS = "composite.QSBSequence",
            ARGS = {               
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_dazhao_1_1"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",            --上升气流
            ARGS = {
                 {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_dazhao_1_2"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",            --手上持续球体发光
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 36},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_dazhao_1_3"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",            --手上持续发散光芒
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_dazhao_1_4"},
                }, 
            },
        },        
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },
                {
                    CLASS = "action.QSBLaser",      -- 特殊子弹，激光形式的子弹
                    OPTIONS = {effect_id = "guerdan_dazhao_2", effect_width = 1280, use_clip = true, duration = 2.5, interval = 1, switch_target = false, hit_dummy = "dummy_body", cancel_skill = true},
                },
            },
        },
         {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 37},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "guerdan_dazhao_1_3_2", is_hit_effect = true, follow_actor_position = true},
                }, 
            },
        },
        {                                            --技能触发一个BUFF，由BUFF再触发一个回血技能
            CLASS = "composite.QSBSequence",
            ARGS = {               
                {
                    CLASS = "action.QSBApplyBuff",
					         OPTIONS = {buff_id = "life_drain_heal", is_target = false},
                },
            },
        },
        {                                           -- 清除回血BUFF
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35 + 75},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                   OPTIONS = {buff_id = "life_drain_heal", is_target = false},
                }, 
            },
        },
        {                                           -- 清楚附魔BUFF
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35 + 75},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                   OPTIONS = {buff_id = "guerdan_juexing_1", is_target = false},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                   OPTIONS = {buff_id = "guerdan_juexing_2", is_target = false},
                }, 
                {
                    CLASS = "action.QSBRemoveBuff",
                   OPTIONS = {buff_id = "guerdan_juexing_3", is_target = false},
                }, 
            },
        },
		  {                          --副本黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
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
        {                   -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
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
    },
}

return ultra_life_drain
