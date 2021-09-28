local titledesc = {}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/fenghao.txt")
	local datas = string.split(file, "\r\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, "=")
			titledesc[data[1]] = data[2]
		end
	end

	return 
end, 0)

return titledesc
