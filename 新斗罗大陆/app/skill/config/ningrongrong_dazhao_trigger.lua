-- 技能 宁荣荣 大招触发治疗
-- 技能ID 309
-- 大招每0.5秒触发一次治疗,因为BUFF里的HOT少走了一些加成,所以走技能加血
--[[
	hero 宁荣荣
	ID:1027 
	psf 2018-10-8
]]--


local ningrongrong_dazhao_trigger = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
		{
			CLASS = "action.QSBArgsIsUnderStatus",
			OPTIONS = {is_attacker = true,reverse_result = false, status = "ningrongrong_hetiji"},
		},
		{
			CLASS = "composite.QSBSelector",
			ARGS = {
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBRemoveBuff",
							OPTIONS = {buff_id = "ningrongrong_hetiji_buff"},
						},
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
				{
					CLASS = "composite.QSBParallel",
					ARGS = {
						{
							CLASS = "action.QSBPlayEffect",
							OPTIONS = {is_hit_effect = true},
						},
						{
							CLASS = "action.QSBHitTarget",
						},
					},
				},
			},
		},
		{
			CLASS = "action.QSBRemoveBuff",
			OPTIONS = {buff_id = "ningrongrong_hetiji_buff"},
		},
		{
			CLASS = "action.QSBAttackFinish"
		},
    },
}

return ningrongrong_dazhao_trigger