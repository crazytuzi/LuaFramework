-- 技能 BOSS柳二龙龙爪手
-- 技能ID 50652
-- 单体抓一下,然后拉过来
--[[
	boss 柳二龙 
	ID:3175 力量试炼
	psf 2018-5-31
]]--

local boss_liuerlong_zidong2_st = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "action.QSBPlaySound"
        },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
				-- {
    --                 CLASS = "action.QSBPlayAnimation",
    --    --              ARGS = 
    --    --              {
    --    --                  {
    --    --                      CLASS = "action.QSBBullet",
				-- 			-- OPTIONS = { time = 0.42, shake = {amplitude = 23, duration = 0.17, count = 1},},
    --    --                  },
    --    --              },
    --             },
				-- {
				--     CLASS = "composite.QSBSequence",
				--     ARGS = 
				--     {
				--         {
				--             CLASS = "action.QSBDelayTime",
				--             OPTIONS = {delay_frame = 17},
				--         },
				--         {
				--             CLASS = "action.QSBDragActor",
				--             OPTIONS = {pos_type = "self" , pos = {x = 125,y = 0} , duration = 0.25, flip_with_actor = true },
				--         },
				--     },
				-- },
    --             {
    --                 CLASS = "composite.QSBParallel",
    --                 ARGS = 
    --                 {
    --                     {
    --                         CLASS = "action.QSBPlayAnimation",
    --                         ARGS = 
    --                         {
    --                             {
    --                                 CLASS = "composite.QSBParallel",
    --                                 ARGS = 
    --                                 {
    --                                     -- {
    --                                     --     CLASS = "action.QSBPlayEffect",
    --                                     --     OPTIONS = {is_hit_effect = true},
    --                                     -- },
    --                                     {
    --                                         CLASS = "action.QSBHitTarget",
    --                                     },
    --                                 },
    --                             },
    --                         },
    --                     },
    --                 },
    --             },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {is_hit_effect = true},
                                -- },
                                {
                                    CLASS = "action.QSBHitTarget",
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
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 8 / 24},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "boss_liuerlong_attack14_1_3" ,is_hit_effect = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 8 / 24},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "boss_liuerlong_attack14_1_4" ,is_hit_effect = true},
                                        },
                                    },
                                },
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
                            OPTIONS = {delay_time = 15 / 24},
                        },
                        {
                            CLASS = "action.QSBDragActor",
                            OPTIONS = {pos_type = "self" , pos = {x = 250,y = 0} , duration = 0.4, flip_with_actor = true },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_liuerlong_zidong2_st

