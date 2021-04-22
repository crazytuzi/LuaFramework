--斗罗SKILL 宗门延爆(二阶弱化版)
--宗门武魂争霸
--id 51342 51349
--通用 主体
--[[
两人DEBUFF
]]--
--创建人：庞圣峰
--创建时间：2019-1-2

local zmwh_boss_tongyong_second3 = 
{
     CLASS = "composite.QSBSequence",
     ARGS = 
     {
        {
            CLASS = "composite.QSBParallel",
            ARGS =
            {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    -- OPTIONS = {animation = "attack09"},
                },
                {
                    CLASS = "action.QSBPlaySound"
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 40 /24 },
                        },
						{
							CLASS = "composite.QSBParallel",
							ARGS =
							{
								{
									CLASS = "action.QSBApplyBuffMultiple",
									OPTIONS = {target_type = "teammate", buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
								}, 
								{
									CLASS = "action.QSBApplyBuffMultiple",
									OPTIONS = {target_type = "teammate", buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
								}, 
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {attacker_target = true, buff_id = "zmwh_boss_qiwuhun_third2_debuff"},
								}, 
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {attacker_target = true, buff_id = "zmwh_boss_qiwuhun_third2_yujing"},
								}, 
							},
						},
						{
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 47 /24 },
                        },
                        {
                            CLASS = "action.QSBShakeScreen",
                            OPTIONS = {amplitude = 3, duration = 0.15, count = 1,},
                        },
                    },
                },
            },
        },
    },
}

return zmwh_boss_tongyong_second3