-- 技能 尘心大招 七杀真身
-- 技能ID 217
-- 定身目标,打六下
--[[
	hero 尘心
	ID:1028 
	psf 2018-5-4
]]--
--【【【【【【【【【【【【【【【【【【【【弃用】】】】】】】】】】】】】】】
local chenxin_dazhao_fumo3 = {
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
                    OPTIONS = {delay_time = 1},
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
                    OPTIONS = {delay_time = 1},
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
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="chenxin_skill"},
        },
		{
			CLASS = "action.QSBPlayAnimation",
			ARGS = {
				{
					CLASS = "action.QSBHitTarget",
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
							OPTIONS = {delay_frame = 40},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true, effect_id = "jiandouluo_attack11_3"},
						}, 	
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"}
						},
						{
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "fumo_chenxin_buff_3"}
						},
                    },
                },			
				{
                    CLASS = "composite.QSBSequence",
                    ARGS = {
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 35},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {shake = {amplitude = 12, duration = 0.17, count = 1},}
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 3},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {shake = {amplitude = 13, duration = 0.17, count = 1},}
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 3},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {shake = {amplitude = 14, duration = 0.17, count = 1},}
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 3},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {shake = {amplitude = 15, duration = 0.17, count = 1},}
						},
						{
							CLASS = "action.QSBDelayTime",
							OPTIONS = {delay_frame = 3},
						},
						{
							CLASS = "action.QSBBullet",	
							OPTIONS = {shake = {amplitude = 25, duration = 0.17, count = 1},}
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

return chenxin_dazhao_fumo3

