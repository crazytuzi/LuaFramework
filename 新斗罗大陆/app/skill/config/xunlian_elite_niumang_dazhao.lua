local boss_niumang_dazhao = 
{
	CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    OPTIONS = {pos = {x = 640, y = 320}},
                },
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
            },
        },
         -------------------------------------- 播放攻击动画
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 10 / 24 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11_1"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 7 / 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "boss_tianqingniumang_attack11_5_1" ,is_hit_effect = false},        --转斧特效
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 52 / 30},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "tianqingniumang_attack11_6" ,is_hit_effect = false},          --捶地水花
                                },
                            },
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tianqingniumang_attack11_1" , is_hit_effect = false},           --地面水塘
                        },                        
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 25 / 24 },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 10 / 24 },
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {effic_id = "tianqingniumang_attack11_1" , is_hit_effect = false},
        --         },
        --     },
        -- },
        --------------------------------------配合动画帧数进行拉人和伤害判定
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
            	{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 52 / 24},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {effect_id = "tianqingniumang_attack11_3_1" , is_hit_effect = false},
                        },
                        {
        					CLASS = "action.QSBDragActor",
        					OPTIONS = {pos_type = "self" , pos = {x = 130,y = 0} , duration = 0.25, flip_with_actor = true },
        				},
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 73},
                -- },
                        -- {
                        --     CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                        --     OPTIONS = {interval_time = 0 , attacker_face = false , attacker_underfoot = true , count = 1, distance = 0, trapId = "shenluowanxiang_aoe"} ,
                        -- },
        				-- {
        				-- 	CLASS = "action.QSBHitTarget",
        				-- },
                    },
                },
			},
		},
        -----
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 10 / 24},
        --         },
        --         -- {
        --         --     CLASS = "action.QSBPlayEffect",
        --         --     OPTIONS = {effect_id = "hongquan_niumanglaren",is_hit_effect = false},
        --         -- },
        --         {
        --             CLASS = "action.QSBPlayLoopEffect",
        --             OPTIONS = {effect_id = "hongquan_niumanglaren",is_hit_effect = false},
        --         },
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_time = 60 / 24},
        --         },
        --         {
        --             CLASS = "action.QSBStopLoopEffect",
        --             OPTIONS = {effect_id = "hongquan_niumanglaren",is_hit_effect = false},
        --         },
        --     },
        -- },  	
	},
}
return boss_niumang_dazhao