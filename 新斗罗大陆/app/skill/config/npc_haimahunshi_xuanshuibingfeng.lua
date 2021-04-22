-- 技能 玄冰冰封
-- 技能ID 50043 50067
-- 前方矩形区域AOE冰冻, 如果自身带有combo_mark,将先闪现到目标身后
--[[
	boss 象甲宗
	ID:3282 副本6-4
	psf 2018-3-30
]]--

local npc_haimahunshi_xuanshuibingfeng = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 12 / 24 },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBActorFadeOut",
                                    OPTIONS = {duration = 0.75, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "chuxian_lanse" , is_hit_effect = false},
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 45 / 24 },
                                },
                                {
                                    CLASS = "action.QSBTeleportToTargetBehind",
                                    OPTIONS = {verify_flip = true}
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "chuxian_lanse" , is_hit_effect = false},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 12 / 24 },
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBActorFadeIn",
                                            OPTIONS = {duration = 0.75, revertable = true},
                                        },
                                        -- {
                                        --     CLASS = "action.QSBPlayEffect",
                                        --     OPTIONS = {effect_id = "chuxian_lanse" , is_hit_effect = false},
                                        -- },
                                    },
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 70 / 24 },
                                },
                                {
                                    CLASS = "action.QSBRemoveBuff",
                                    OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
                                },                                
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBPlayAnimation",
                                            ARGS = {
                                                {
                                                    CLASS = "composite.QSBParallel",
                                                    ARGS = 
                                                    {  
                                                        {
                                                            CLASS = "action.QSBPlayEffect",
                                                            OPTIONS = {is_hit_effect = true},
                                                        },
                                                        {
                                                            CLASS = "action.QSBHitTarget",
                                                        },
                                                    },
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "bingfengyujing" , is_hit_effect = false},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySound" ,
                                        },
                                    },
                                },
                            },
                        },         
                    },
                },
            },
        },
		-- {
		-- 	CLASS = "action.QSBArgsIsUnderStatus",
		-- 	OPTIONS = {is_attacker = true,status = "combo_mark"},
		-- },
		-- {
		-- 	CLASS = "composite.QSBSelector",
		-- 	ARGS = 
		-- 	{
		-- 		{
		-- 			CLASS = "composite.QSBSequence",
		-- 			ARGS = 
  --                   {
		-- -- 				-- {
		-- -- 				-- 	CLASS = "action.QSBApplyBuff",
		-- -- 				-- 	OPTIONS = {is_target = true, buff_id = "2S_stun"},
		-- -- 				-- },
		-- 				{
		-- 					CLASS = "action.QSBTeleportToTargetBehind",
		-- 					OPTIONS = {verify_flip = true}
		-- 				},
		-- 			},
		-- 		},
		-- 	},
  --       },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = false},
        --         },
        --         {
        --             CLASS = "action.QSBPlayAnimation",
        --             ARGS = {
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {  
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {is_hit_effect = true},
        --                         },
        --                         {
        --                             CLASS = "action.QSBHitTarget",
        --                         },
        --                     },
        --                 },
        --             },
        --         },
        --         {
        --             CLASS = "action.QSBPlaySound"
        --         },
        --     },
        -- },
		{
			CLASS = "action.QSBLockTarget",
			OPTIONS = {is_lock_target = false},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_haimahunshi_xuanshuibingfeng