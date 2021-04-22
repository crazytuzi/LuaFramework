-- 技能 鬼面盗贼旋转刀刃旋转
-- 技能ID 50361
-- 入场冒个烟,然后转
--[[
	boss 鬼面盗贼的刀刃
	ID:3284 副本6-8
	psf 2018-3-30
]]--

local boss_guimiandaozei_xuanzhuandaoren = {
    CLASS = "composite.QSBSequence",
    ARGS = {   
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{
			CLASS = "action.QSBPlayLoopEffect",
			OPTIONS = {effect_id = "hongquan_2", is_hit_effect = false},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {effect_id = "haunt_3", is_hit_effect = false},--入场特效
		},
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "stand", is_loop = true},
                },
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = true}
                },
                {
                    CLASS = "action.QSBHitTimer",
                },
				{
					CLASS = "composite.QSBSequence",
					ARGS = { 
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_time = 0.5},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
					},
				},
            },
        },

		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBActorKeepAnimation",
                    OPTIONS = {is_keep_animation = false}
                },
                {
                    CLASS = "action.QSBActorStand",
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_guimiandaozei_xuanzhuandaoren