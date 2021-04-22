-- 技能 宁荣荣 九宝有名 强化版
-- 技能ID 190116
-- 单体加BUFF,目标血量少加另一个
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--

local ningrongrong_zidong2_plus = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = {  
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = true},
                                },
								{
									CLASS = "action.QSBActorStatus",
									OPTIONS = 
									{
									   { "target:hp_percent<0.33","target:apply_buff:pf_ningrongrong01_zidong2_plus_buff;y","under_status"},
									}
								},
								{
									CLASS = "action.QSBActorStatus",
									OPTIONS = 
									{
									   { "target:hp_percent<0.33","target:apply_buff:pf_ningrongrong01_zidong2_buff;y","not_under_status"},
									}
								},
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

return ningrongrong_zidong2_plus
