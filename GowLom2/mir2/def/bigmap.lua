local bigmap = {}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/bigmap.txt")
	local datas = string.split(file, "\r\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, ";")

			if data[1] ~= "" then
				local id = data[1]

				if not bigmap[id] then
					bigmap[id] = {}
				end

				if data[2] ~= "" then
					data[2] = string.gsub(data[2], "/L", "\n")
				end

				bigmap[id][#bigmap[id] + 1] = data
			end
		end
	end

	return 
end, 0)

return bigmap
