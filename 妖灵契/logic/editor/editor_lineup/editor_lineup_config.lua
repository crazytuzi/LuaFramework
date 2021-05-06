local config = {}

config.arg = {}

config.arg.template = 
{
	member_cnt = {
		name = "队友数量",
		key = "member_cnt",
		format = "number_type",
		default = 0,
	},
	partner_cnt = {
		name = "队长伙伴数",
		key = "partner_cnt",
		format = "number_type",
		default = 1,
	},
	lineup_type = {
		name = "站位类型",
		key = "lineup_type",
		select_update = function()
			return table.values(data.lineupdata.LINEUP_TYPE)
		end,
		force_input = true,
		default = "single",
	},
}

return config