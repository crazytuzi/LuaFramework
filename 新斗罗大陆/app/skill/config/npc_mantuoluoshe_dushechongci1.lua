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



local npc_mantuoluoshe_dushechongci1 = {	
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
					 ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
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
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "npc_mantuoluoshe_chongci_hongkuang", is_target = false},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 5 },
                        },   
						{
                            CLASS = "action.QSBHeroicalLeap",
                            OPTIONS = {speed = 1500 ,move_time = 0.4 ,interval_time = 0.4 ,is_hit_target = true ,bound_height = 1},
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

return npc_mantuoluoshe_dushechongci1