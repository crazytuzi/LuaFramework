-- 技能 自爆蜘蛛自爆
-- 技能ID 53326
--[[
	自爆蜘蛛
	升灵台"蜘蛛巢穴"
]]--
local renmianmozhu_zibao = 
{
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    -- OPTIONS = { animation = "dead_2"},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 60  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {   
                                {
                                    CLASS = "action.QSBHitTarget",--队友特定状态的目标伤害提升写在量表<skil_data>的bonus_damage_cond和bonus_damage_p字段
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "shenglt_zibaozhizhu_baozha" , is_hit_effect = false },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 37 / 24  },
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --   CLASS = "action.QSBPlayEffect",
                                --   OPTIONS = {is_hit_effect = false,effect_id = "zdb_atk11_3"},
                                -- },
                                {
                                    CLASS = "action.QSBTriggerSkill",
                                    OPTIONS = { skill_id = 53371   ,wait_finish = false},
                                },
                                -- {
                                --     CLASS = "action.QSBHitTarget",
                                -- },
                            },
                        },
                    },
                }, 
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return renmianmozhu_zibao