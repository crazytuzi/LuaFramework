config = {}

config.select =
{
	pos_type = {
		{"head", "头部"},
		{"waist", "腰部"},
		{"foot", "脚部"},
		{"chest", "胸前"},
		{"node", "节点"},
		{"model", "模型"},
	},
	buff_type = {
		{"normal", "普通"},
		{"add", "叠加"},
		{"multi", "多层"},
		{"chain", "链接"},
	},
}
config.arg = {}
config.arg.buff = {
	{
		name = "ID",
		key = "buff_id",
		format = "number_type",
		default = 0,
	},
	{
		name = "类型",
		key = "buff_type",
		select_type = "buff_type",
		default = "normal",
		refresh_args = true,
	},
	["add"] = {
		{
			name = "叠加个数",
			key = "add_cnt",
			format = "number_type",
			default = 1,
		},
	}
}

config.arg.effect =
{
	{
		name = "特效路径",
		key = "path",
		select = function() 
				local dirs = {"/Effect/Buff","/Effect/Magic"}
				local newList = {""}
				if Utils.IsEditor() then
					for _, dir in pairs(dirs) do
						local list = IOTools.GetFiles(IOTools.GetGameResPath(dir), "*.prefab", true)
						for i, sPath in ipairs(list) do
							local idx = string.find(sPath, dir)
							if idx then
								table.insert(newList, string.sub(sPath, idx+1, string.len(sPath)))
							end
						end
					end
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		format = "string_type",
		input_width = 150,
	},
	{
		name = "材质球(?)",
		key = "mat_path",
		select = function() 
				local list = IOTools.GetFiles(IOTools.GetGameResPath("/Material"), "*.mat", true)
				local newList = {""}
				for i, sPath in ipairs(list) do
					local idx = string.find(sPath, "Material")
					if idx then
						table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
					end
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		format = "string_type",
		input_width = 150,
	},
	{
		name = "高度",
		key = "height",
		format = "number_type",
		default = 0,
	},
	{
		name = "位置类型",
		key = "pos_type",
		select_type = "pos_type",
		default = "waist",
		input_width = 150,
		refresh_args = true,
	},
	["node"] = {
		{
			name = "节点编号",
			key = "node_idx",
			format = "number_type",
			default = 0,
		}
	},
	["model"] = {
		{
			name = "模型",
			key = "find_path",
			select = {"Mount_Hit", "Mount_Head", "Mount_Shadow", "Bip001"},
			format = "string_type",
			default = "Bip001",
		}
	},
}
config.arg.template ={


	layer_paths = {
		name = "层buff",
		key = "chest_layer",
		select = function() 
				local list = IOTools.GetFiles(IOTools.GetGameResPath("/Effect/Buff"), "*.prefab", true)
				local newList = {""}
				for i, sPath in ipairs(list) do
					local idx = string.find(sPath, "Effect/Buff")
					if idx then
						table.insert(newList, string.sub(sPath, idx, string.len(sPath)))
					end
					
				end
				return newList
			end,
		wrap = function(s) return IOTools.GetFileName(s, true) end,
		format = "string_type",
		input_width = 150,
	},
}
return config