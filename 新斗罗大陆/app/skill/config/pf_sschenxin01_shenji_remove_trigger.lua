-- 技能 ss剑道尘心选目标1
-- 技能ID 584
-- 施加破绽
--[[
	魂师 剑道尘心
	ID:1056
	psf 2020-4-21
]]--

local sschenxin_select_target1 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBActorFadeOut",
            OPTIONS = {duration = 0.01, revertable = true},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attacker = true , enter_stop_position = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 2 / 30 ,pass_key = {"pos"}},
                },
                {
                    CLASS = "action.QSBTeleportToAbsolutePosition",
                    -- OPTIONS = {pos = {x = 500, y = 320}},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3 / 30 },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBActorFadeIn",
                            OPTIONS = {duration = 0.01, revertable = true},
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack21"},
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 3, duration = 0.4, count = 3,},
                        },
                        {
                            CLASS = "action.QSBTriggerSkill",
                            OPTIONS = {skill_id = 200583, wait_finish = true},
                        },
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 33},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return sschenxin_select_target1

