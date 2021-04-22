local RANGE = 550
local CENTER_X, CENTER_Y = 450, 320 + (BATTLE_SCENE_HEIGHT - BATTLE_SCREEN_HEIGHT) * 0.5 -- 请不要在别处使用这一行，这一行复盘无法通过
local FIRE_NUMBER = 6
local FILTER = FIRE_NUMBER / 2 * 0.2

local fire_index = 0
local _l, _r
local function _randomlist()
    local list = {}
    for i = 1, FIRE_NUMBER do
        list[i] = i
    end
    q.shuffleArray(list)
    return list
end
local function _getRandomRange(list, index)
    local a = list[index]
    local min, max = math.max(0, math.floor((a - 0.5 - FILTER) / FIRE_NUMBER * 10000)), math.min(10000, math.ceil((a + 0.5 + FILTER) / FIRE_NUMBER * 10000))
    return math.random(min, max) / 10000
end
local function _random()
    if fire_index == 0 then
        _l = _randomlist()
        _r = _randomlist()
    end
    local l, r = _getRandomRange(_l, fire_index + 1), _getRandomRange(_r, fire_index + 1)
    first_index = math.fmod(fire_index + 1, FIRE_NUMBER)
    return l, r
end

local function randompos()
    local x, y
    local obj = {is_attacker = true}
    setmetatable(obj, {__index = function(t, k)
        if x == nil or y == nil then
            local l, r = _random()
            -- local l, r = math.random(0, 10000) / 10000, math.random(0, 10000) / 10000
            l = RANGE * l
            r = 2 * 3.1415926 * r
            x = math.cos(r) * l + CENTER_X
            y = math.sin(r) * l * 0.333 + CENTER_Y
        end
        local ret
        if k == "x" then
            ret = x
            x = nil
        elseif k == "y" then
            ret = y
            y = nil
        end
        return ret
    end})
    return obj
end

local ultra_npc_rain_of_fire = {
    CLASS = "composite.QSBParallel",
    ARGS = {
    	{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11", is_loop = true},
                },
                -- {
                --     CLASS = "action.QSBAttackFinish"
                -- },
                
            },
        },
    
       
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
               
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 10},
                },


             --  第一波火雨开始
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
     			-- 震屏效果
				      	{
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 10},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.2, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.17},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.12},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.1, count = 1,},
				                }, 
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.09},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.05, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.06},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0, count = 1,},
				                },  
				            },
				        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 5},
                                -- },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                    },
                },
            

    -- 第一波火雨结束

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },

           
                -- 第二波火雨

                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                       -- 震屏效果
				      	{
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 10},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.2, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.17},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.12},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.1, count = 1,},
				                }, 
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.09},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.05, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.06},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0, count = 1,},
				                },  
				            },
				        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 25 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 5},
                                -- },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                    },
                },

                -- 第二波火雨结束

                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                },

       

                -- 第三波火雨

                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        -- 震屏效果
				      	{
				            CLASS = "composite.QSBSequence",
				            ARGS = {
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_frame = 10},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.2, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.17},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 15, duration = 0.15, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.12},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.1, count = 1,},
				                }, 
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.09},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0.05, count = 1,},
				                },
				                {
				                    CLASS = "action.QSBDelayTime",
				                    OPTIONS = {delay_time = 0.06},
				                },
				                {
				                 CLASS = "action.QSBShakeScreen",
				                    OPTIONS = {amplitude = 12, duration = 0, count = 1,},
				                },  
				            },
				        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        --  {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        --  {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        --  {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        --  {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30 + 0.25, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                         {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBArgsTime",
                                    OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                },
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = randompos(),
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "rain_of_fire_1",},
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBArgsTime",
                        --             OPTIONS = {time = (math.random(0, 100) / 100) * 20 / 30, args_translate = {time = "delay_time"}},
                        --         },
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --         },
                        --         {
                        --             CLASS = "action.QSBArgsPosition",
                        --             OPTIONS = randompos(),
                        --         },
                        --         {
                        --             CLASS = "action.QSBPlaySceneEffect",
                        --             OPTIONS = {effect_id = "rain_of_fire_1",},
                        --         },
                        --     },
                        -- },
                           
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_frame = 5},
                                -- },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                    },
                },

                -- 第三波火雨结束

                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
    },
}

return ultra_npc_rain_of_fire