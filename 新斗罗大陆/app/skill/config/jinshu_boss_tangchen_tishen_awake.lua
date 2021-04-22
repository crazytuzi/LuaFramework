-- 技能 BOSS唐晨蝙蝠唤醒
-- 技能ID 50826
-- 清除boss_tangchen_bianfu_zhaohuan_debuff
--[[
	boss 唐晨 
	ID:3676 副本14-8
	psf 2018-7-4
]]--

local boss_tangchen_tishen_awake = 
{
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,reverse_result = false, status = "tc_zhaohuan"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = 
			{
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBUncancellable",
						},
						{
							CLASS = "action.QSBRemoveBuff",  --去掉应该应该加给唐晨替身的BUFF
							OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff"},
						},
						{
							CLASS = "action.QSBRemoveBuff", -- 如果处在变身状态,就去掉变身buff,变回原来的样子
							OPTIONS = {is_target = false, buff_id = "boss_tangchen_bianfu_zhaohuan_debuff"},
						},
						{
							CLASS = "action.QSBApplyBuff", --确保tc_zhaohuan标记还在
							OPTIONS = {buff_id = "boss_tangchen_bianfu_zhaohuan_buff"},
						},
						{
							CLASS = "action.QSBAttackFinish"
						},
					},
				},
				{
					CLASS = "composite.QSBSequence",
					ARGS = {
						{
							CLASS = "action.QSBRemoveBuff",  --去掉应该应该加给唐晨替身的BUFF
							OPTIONS = {buff_id = "boss_tangchen_tishen_zhaohuan_buff"},
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

return boss_tangchen_tishen_awake