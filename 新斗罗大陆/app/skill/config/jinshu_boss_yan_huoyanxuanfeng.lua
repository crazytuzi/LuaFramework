-- 技能 BOSS焱 火焰旋风
-- 技能ID 50371
-- 火焰旋风
--[[
    boss 焱
    ID:3287 副本9-4
    刘悦璘 2018-5-6
]]--

local boss_yan_huoyanxuanfeng = {
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
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {   
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 1280 , y = 180}, ground_layer = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 1280 , y = 350}, ground_layer = true},
                                        },
                                        {
                                            CLASS = "action.QSBPlaySceneEffect",
                                            OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 1280 , y = 520}, ground_layer = true},
                                        },
                                        {
                                            CLASS = "action.QSBRemoveBuff",
                                            OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                                        },
                                    },
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 30},
                                },
                                {
                                    CLASS = "composite.QSBParallel",
                                    ARGS = {
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                            start_pos = {x = 1480,y = 180, global = true}, dead_ok = false, single = true},
                                        },
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                            start_pos = {x = 1480,y = 350, global = true}, dead_ok = false, single = true},
                                        },
                                        {
                                            CLASS = "action.QSBBullet",
                                            OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                            start_pos = {x = 1480,y = 520, global = true}, dead_ok = false, single = true},          
                                        },
                                    },
                                },
                            },
                            {
                                CLASS = "composite.QSBSequence",
                                ARGS = 
                                {   
                                    {
                                        CLASS = "composite.QSBParallel",
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 0 , y = 180}, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 0 , y = 350}, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBPlaySceneEffect",
                                                OPTIONS = {effect_id = "hongkuang_3", pos  = {x = 0 , y = 520}, ground_layer = true},
                                            },
                                            {
                                                CLASS = "action.QSBRemoveBuff",
                                                OPTIONS = {buff_id = "mianyi_suoyou_zhuangtai"},
                                            },
                                        },
                                    },
                                    {
                                        CLASS = "action.QSBDelayTime",
                                        OPTIONS = {delay_frame = 30},
                                    },
                                    {
                                        CLASS = "composite.QSBParallel",
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBBullet",
                                                OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                                start_pos = {x = -300,y = 180, global = true}, dead_ok = false, single = true},
                                            },
                                            {
                                                CLASS = "action.QSBBullet",
                                                OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                                start_pos = {x = -300,y = 350, global = true}, dead_ok = false, single = true},
                                            },
                                            {
                                                CLASS = "action.QSBBullet",
                                                OPTIONS = {effect_id = "yan_attack12_3", speed = 250, is_tornado = true, tornado_size = {width = 135, height = 100},
                                                start_pos = {x = -300,y = 520, global = true}, dead_ok = false, single = true},          
                                            },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
	},
}

return boss_yan_huoyanxuanfeng