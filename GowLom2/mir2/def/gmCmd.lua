local gmCmd = {
	common = {},
	sort = {}
}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/cmd.txt")
	local datas = string.split(file, "\r\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ";")

			if data[6] == "common" then
				gmCmd.common[#gmCmd.common + 1] = data
			else
				if not gmCmd.sort[data[6]] then
					gmCmd.sort[data[6]] = {}
				end

				gmCmd.sort[data[6]][#gmCmd.sort[data[6]] + 1] = data
			end
		end
	end

	return 
end, 0)

return gmCmd
