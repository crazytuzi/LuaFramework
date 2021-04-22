-- 技能 尘心大招 七杀真身
-- 技能ID 201217
-- 定身目标,打六下
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--

local chenxin_dazhao = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 90},
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
        {               --竞技场黑屏
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true,},   --不会打断特效
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 90},
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
			CLASS = "action.QSBPlayAnimation",
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_gudouluo_attack11_1_1",haste = true},
				}, 
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 95},
				},
				{
					CLASS = "action.QSBPlayEffect",
					OPTIONS = {is_hit_effect = false, effect_id = "pf_gudouluo01_attack11_1_2",haste =true},
				}, 
            },
        },	
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
				
				{
                    CLASS = "composite.QSBSequence",
                    ARGS = {
                        {
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 95},
                        },
                        {
                            CLASS = "action.QSBArgsSelectTarget",
                            OPTIONS = {lowest_hp = true, change_all_node_target = true},
                        },
						{
		                    CLASS = "action.QSBBullet",
		                    OPTIONS = {start_pos = {x = 125,y = 115}, effect_id = "pf_gudouluo01_attack11_2", speed = 2000, hit_effect_id = "pf_gudouluo01_attack11_3"},
		                },
		                {
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 20},
						},
						{
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {buff_id = {"pf_gudouluo01_fumo2_p", "pf_gudouluo01_fumo2_m", "pf_gudouluo01_dazhao_cuihua;y"}, is_target = true, no_cancel = true},
                        },
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 25},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
                    },
                },			
            },
        },
    },
}

return chenxin_dazhao

