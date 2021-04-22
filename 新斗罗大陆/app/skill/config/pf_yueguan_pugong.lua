-- 技能 月关 普攻
-- ID 169
-- 魂师普攻,会让菊花集火目标
--[[
	hero 月关
	ID:1018
	psf 2018-7-24
]]--
local yueguan_pugong = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {is_target = true, buff_id = "yueguan_pugong_aim"},
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent>0.6","target:apply_buff:tongyong_shoot_mark","under_status"}
			},
		},
		{
			CLASS = "action.QSBActorStatus",
			OPTIONS = 
			{
			   { "target:hp_percent>0.6","target:remove_buff:tongyong_shoot_mark","not_under_status"}
			},
		},
		{
			CLASS = "action.QSBPlayEffect",
			OPTIONS = {is_hit_effect = false},
		},
        {
             CLASS = "composite.QSBSequence",
             ARGS = 
             {
                {
					CLASS = "action.QSBPlayAnimation",
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {flip_follow_y = true},
						},
					},
				},
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return yueguan_pugong

