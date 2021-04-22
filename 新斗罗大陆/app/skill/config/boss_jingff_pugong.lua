-- 技能 金刚狒狒普攻
-- 技能ID 30004
-- 万吨重拳：单体攻击，改概率将人击退，并且击退的同时，目标脚下留下一个震眼的陷阱，持续伤害，并减低移速
--[[
    hunling 金刚狒狒
    ID:2004
    psf 2019-6-10
]]--

local hl_jingff_pugong = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {--[[effect_id = "jingangfeifei_attack01_1",]] is_hit_effect = false, haste = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = { is_hit_effect = true},
                        },
                    },
                },
                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = {
                        failed_select = 2,
                        {expression = "self:random<0.33", select = 1},
                    }
                },
                {
                    CLASS = "composite.QSBSelector",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDragActor",
                                    OPTIONS = {pos_type = "self" , pos = {x = 480,y = 0} , duration = 0.5, flip_with_actor = true },
                                },
								{
									CLASS = "action.QSBTrap", 
									OPTIONS = 
									{ 
										trapId = "zudui_jingff_pugong_trap", is_attackee = false,
										args = 
										{
											{delay_time = 0 , relative_pos = { x = 0, y = 0}} ,
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

return hl_jingff_pugong