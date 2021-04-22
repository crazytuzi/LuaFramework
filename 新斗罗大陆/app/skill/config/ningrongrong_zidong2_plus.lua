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
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
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
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningrongrong_attack14_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 0},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "ningrongrong_attack14_1_1", is_hit_effect = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35},
                },               
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {  
                        {
                            CLASS = "action.QSBActorStatus",
                            OPTIONS = 
                            {
                                { "target:hp_percent<0.33","target:apply_buff:ningrongrong_zidong2_plus_buff;y","under_status"},
                            }
                        },
                        {
                            CLASS = "action.QSBActorStatus",
                            OPTIONS = 
                            {
                                { "target:hp_percent<0.33","target:apply_buff:ningrongrong_zidong2_buff;y","not_under_status"},
                            }
                        },
                    },
                },
            },
        },
    },
}

return ningrongrong_zidong2_plus
