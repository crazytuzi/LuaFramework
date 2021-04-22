-- 技能 宁荣荣 琉璃幻光 强化版
-- 技能ID 190115
-- 射出多发(1+5)随机子弹治疗队友(后五发必定治疗血最少的),第一发固定当前目标
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-9-10
]]--

local ningrongrong_zidong1_plus = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlaySound",
        },
		{
			CLASS = "composite.QSBSequence",
			ARGS = 
			{
				{
					CLASS = "action.QSBDelayTime",
					OPTIONS = {delay_frame = 35 },
				},
				{
					CLASS = "action.QSBBullet",
					OPTIONS = {start_pos = {x = 50,y = 250}},
				},
			},
		},
		{
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
				{
					CLASS = "action.QSBPlayAnimation",--如果有多个攻击标点,PlayAnimation里的内容会在各个标点逐个执行一句
					ARGS = 
					{
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {target_teammate_lowest_hp_percent = true},
						},
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {target_teammate_lowest_hp_percent = true},
						},
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {target_teammate_lowest_hp_percent = true},
						},
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {target_teammate_lowest_hp_percent = true},
						},
						{
							CLASS = "action.QSBBullet",
							OPTIONS = {target_teammate_lowest_hp_percent = true},
						},
					}
				},
				{
					CLASS = "action.QSBAttackFinish",
				},
			},
		},
    },
}

return ningrongrong_zidong1_plus
