--曼陀罗蛇毒蛇冲刺
--NPC ID: 10009
--技能ID: 50033
--蓄力冲撞
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：庞圣峰
--创建时间：2018-3-21



local mantuoluoshe_dushechongci = {	
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        -- {
        --     CLASS = "action.QSBApplyBuff",
        --     OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        -- },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
					-- ARGS = 
     --                {
     --                    {
     --                        CLASS = "composite.QSBParallel",
     --                        ARGS = 
     --                        {
     --                            {
     --                                CLASS = "action.QSBPlayEffect",
     --                                OPTIONS = {effect_id = "qiandaoliu_whzs_3" , is_hit_effect = false},
     --                            },
     --                        },
     --                    },
     --                },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "mantuoluobaoqi" , is_hit_effect = false},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 2, duration = 0.75, count = 2,},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 42 / 24},
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 8, duration = 0.35, count = 2,},
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 42 / 24},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            OPTIONS = {forward_mode = true},
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsIsDirectionLeft",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "composite.QSBSelector",
                                    ARGS = 
                                    {   
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                    OPTIONS = {interval_time = 0.01, attacker_face = false,attacker_underfoot = true,count = 4, distance = 150, trapId = "mantuluocf2"},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                                    OPTIONS = {interval_time = 0.01, attacker_face = false,attacker_underfoot = true,count = 4, distance = 150, trapId = "mantuluocf"},
                                                },
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsIsDirectionLeft",
                            OPTIONS = {is_attacker = true},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {   
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                            OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "mantuoluocf_yujing2"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                            OPTIONS = {interval_time = 0.1, attacker_face = true,attacker_underfoot = true,count = 1, distance = 0, trapId = "mantuoluocf_yujing"},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
		        -- {
		        --     CLASS = "composite.QSBSequence",
		        --     ARGS = {
		        --         {
		        --             CLASS = "action.QSBPlayEffect",
		        --             OPTIONS = {effect_id = "boss_mantuoluoshe_1",is_hit_effect = false},
		        --         },
		        --         {
		        --             CLASS = "action.QSBPlayLoopEffect",
		        --             OPTIONS = {effect_id = "boss_mantuoluoshe_2",is_hit_effect = false},
		        --         },
		        --         {
		        --             CLASS = "action.QSBDelayTime",
		        --             OPTIONS = {delay_time = 1},
		        --         },
		        --         {
		        --             CLASS = "action.QSBStopLoopEffect",
		        --             OPTIONS = {effect_id = "boss_mantuoluoshe_2",is_hit_effect = false},
		        --         },
		        --     },   
		        -- },
                -- {
                --     CLASS = "action.QSBApplyBuff",
                --     OPTIONS = {buff_id = "npc_mantuoluoshe_chongci_hongkuang", is_target = false},
                -- },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 42 / 24},
                        },   
						{
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 3500 ,move_time = 0.225 ,interval_time = 0.075 ,is_hit_target = true ,bound_height = 40},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return mantuoluoshe_dushechongci