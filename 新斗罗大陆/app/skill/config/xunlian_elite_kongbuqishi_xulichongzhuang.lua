--枪骑兵蓄力冲撞
--NPC ID: 10015 10016 10017
--技能ID: 50301
--蓄力冲撞
--[[-----------------------------------------
	不要轻易修改,有特殊需求,尽量复制一份使用.
	避免影响其他同原型NPC!!!
]]-------------------------------------------
--创建人：庞圣峰
--创建时间：2018-3-21


local npc_qiangqibing_xulichongzhuang = {
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
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                    },
                }, 
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
						{
							CLASS = "action.QSBPlayLoopEffect",
							OPTIONS = {effect_id = "xiliangqibinghongkuang_2", is_hit_effect = false, follow_actor_animation = true},
						},
						{
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 78},
                        },
						{
							CLASS = "action.QSBStopLoopEffect",
							 OPTIONS = {effect_id = "xiliangqibinghongkuang_2"},
						},
                        {
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 1250 ,move_time = 0.5 ,interval_time = 1 ,is_hit_target = true ,bound_height = 25},
                        },
						{
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 650 ,move_time = 0.5 ,interval_time = 1 ,is_hit_target = false ,bound_height = 25},
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

return npc_qiangqibing_xulichongzhuang