--  创建人：刘悦璘
--  创建时间：2018.04.08
--  NPC：八角寒冰草BOSS
--  类型：位移
local boss_bajiaohanbingcao_fanfuhengtiao = {
    CLASS = "composite.QSBParallel",
    ARGS = {

        {
             CLASS = "composite.QSBSequence",
             ARGS = {
                {  
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true,},
                    ARGS = {
                        {
                            CLASS = "action.QSBArgsIsLeft", -- 根据自己是否在屏幕左半侧选择
                            OPTIONS = {is_attacker = true},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            OPTIONS = {pass_args = true}, -- 把选择的子行为的传递参数传递下去
                            ARGS = {
                                {
                                    CLASS = "action.QSBSetActorToPos",
                                    OPTIONS = {pos = {x = 940, y = 300},speed = 1500, effectId = "haunt_3"},
                                },
                                {
                                    CLASS = "action.QSBSetActorToPos",
                                    OPTIONS = {pos = {x = 300, y = 300},speed = 1500, effectId = "haunt_3"},
                                },
                            },
                        },
                    }, 
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return boss_bajiaohanbingcao_fanfuhengtiao