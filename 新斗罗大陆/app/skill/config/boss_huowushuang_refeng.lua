-- 技能 BOSS火无双 十字火焰伤害
-- 技能ID 50371
-- 十字AOE
--[[
	boss 火无双
	ID:3287 副本6-16
	psf 2018-3-30
]]--

local boss_huowushuang_refeng = {
	CLASS = "composite.QSBParallel",
	ARGS = 
	{
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
		},
		{   
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true}, --不会打断特效
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animaion = "attack11"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "action.QSBPlaySound",
        },
        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = 
            {
                {
                    CLASS = "action.QSBSelectTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.35},
                },
                {
                    CLASS = "action.QSBUncancellable",
                },
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
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = 1480,y = 400, global = true}, dead_ok = false, single = true},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = 1480,y = 250, global = true}, dead_ok = false, single = true},
                                            
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = 1480,y = 550, global = true}, dead_ok = false, single = true},
                                            
                                },    
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
								},								
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = -300,y = 400, global = true}, dead_ok = false, single = true},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = -300,y = 250, global = true}, dead_ok = false, single = true},
                                },
                                {
                                    CLASS = "action.QSBBullet",
                                    OPTIONS = {effect_id = "huowushuang_attack12_3", speed = 850, is_tornado = true, tornado_size = {width = 235, height = 145},
                                    start_pos = {x = -300,y = 550, global = true}, dead_ok = false, single = true},
                                },
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
								},	
                            },
                        },
                    },
                },
            },
        },
	},
}

return boss_huowushuang_refeng