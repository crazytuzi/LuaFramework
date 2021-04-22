--破之一族普攻
--NPC ID: 10010 10011 10012
--技能ID: 50293
--抛物线远程子弹
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：庞圣峰
--创建时间：2018-3-21

local npc_pozhiyizu_pugong = {
    CLASS = "composite.QSBSequence",
    ARGS = {      
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "action.QSBBullet",
                            -- OPTIONS = { is_throw = true, from_target = false,hit_duration = -1, 
							-- speed_power = 0.8, throw_speed = 1800, throw_angel = 60, 
							-- at_position={x = 0, y = -10}},
                        },
                    },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
            },
        },       
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return npc_pozhiyizu_pugong

