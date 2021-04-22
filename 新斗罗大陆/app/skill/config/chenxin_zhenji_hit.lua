-- 技能 尘心真技剑痕攻击
-- 技能ID 190071
-- 攻击;处在chenxin_jianhen_baoji状态时,该脚本作为给自己加暴击BUFF的技能
--[[
	hero 尘心
	ID:1028 
	psf 2018-11-14
]]--

local chenxin_zhenji_hit = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,status = "chenxin_jianhen_baoji"},
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
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "chenxin_jianhen_baoji_buff"},
						},				
						{
							CLASS = "action.QSBAttackFinish",
						},
					},	
				},
				--正常情况下该技能打伤害
				{
					CLASS = "composite.QSBSequence",
					ARGS = 
					{
						{
							CLASS = "composite.QSBParallel",
							ARGS = 
							{
								{
									CLASS = "action.QSBApplyBuff",
									OPTIONS = {buff_id = "chenxin_jianhen_baoshang_buff"},
								},
								{
									CLASS = "action.QSBHitTarget",
								},
								-- {
									-- CLASS = "action.QSBHitTarget",
								-- },
								{
									CLASS = "action.QSBRemoveBuff",
									OPTIONS = {buff_id = "chenxin_jianhen_baoshang_buff"},
								},
							},
						},
						{
							CLASS = "action.QSBAttackFinish",
						},
					},	
				},		
			},			
		},				
	},
}

return chenxin_zhenji_hit

