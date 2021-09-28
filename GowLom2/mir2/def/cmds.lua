local cmds = {
	all = {
		{
			"@天地合一",
			"@天地合一"
		},
		{
			"@允许天地合一",
			"@允许天地合一"
		}
	},
	custom = {
		回城复活 = "@relive",
		卡位恢复 = "@resetpoint"
	},
	get = function (key)
		for k, v in pairs(cmds.all) do
			if v[1] == key then
				return v[2]
			end
		end

		return 
	end
}

return cmds
