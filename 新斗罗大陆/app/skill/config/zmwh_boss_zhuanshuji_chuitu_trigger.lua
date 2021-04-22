--斗罗SKILL 专属技触发技
--宗门武魂争霸
--id 51356
--通用 主体
--[[
命中四人触发,清除全场计数debuff,给自己加护盾
]]--
--创建人：庞圣峰
--创建时间：2019-1-9

local zmwh_boss_zhuanshuji_chuitu_trigger = {
	CLASS = "composite.QSBSequence",
	ARGS = {
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {multiple_target_with_skill = true, buff_id = "zmwh_boss_zhuanshuji_count_debuff"},
		},
		{
			CLASS = "action.QSBApplyBuff",
			OPTIONS = {buff_id = "zmwh_boss_zhuanshuji_hudun_buff"},
		},
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return zmwh_boss_zhuanshuji_chuitu_trigger