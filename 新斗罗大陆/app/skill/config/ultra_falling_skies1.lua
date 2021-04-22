local RANGE = 470
local CENTER_X, CENTER_Y = 640, 360
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
            -- local l, r = app.random(0, 10000) / 10000, app.random(0, 10000) / 10000
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


local ultra_falling_skies1 = {       -- 星辰陨落
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
                    CLASS = "action.QSBAttackFinish",
                },
                
            },
        },


        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.20},
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
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2.20},
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

        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "falling_skies_1", is_hit_effect = false},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 80},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "falling_skies_y"},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 59},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {                               --同时流星雨第一层，不延时
                            CLASS = "composite.QSBSequence",
                            ARGS = { 
                                {                                       --     每组流星雨为3个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为3个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为3个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为3个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },



                            },
                        },

                        {                               --同时流星雨第一层，延时7帧
                            CLASS = "composite.QSBSequence",
                            ARGS = { 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },



                            },
                        },

                        {                               --同时流星雨第一层，延时14帧
                            CLASS = "composite.QSBSequence",
                            ARGS = { 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 14},
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },



                            },
                        },


                        {                               --同时流星雨第一层，延时21帧
                            CLASS = "composite.QSBSequence",
                            ARGS = { 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 21},
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为4个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },



                            },
                        },

                        {                               --同时流星雨第一层，延时28帧
                            CLASS = "composite.QSBSequence",
                            ARGS = { 
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 28},
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },
                                {                                       --     每组流星雨为2个
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                        {
                                            CLASS = "composite.QSBSequence",
                                            ARGS = {
                                                {
                                                    CLASS = "action.QSBArgsTime",
                                                    OPTIONS = {time = (50 / 100) * 6 / 30, args_translate = {time = "delay_time"}},
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
                                                    OPTIONS = {effect_id = "falling_skies_3",},
                                                },
                                            },
                                        },
                                    },
                                },



                            },
                        },
















                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 7},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_range_hit = true},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return ultra_falling_skies1