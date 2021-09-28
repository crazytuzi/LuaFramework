local itemdesc = {}

scheduler.performWithDelayGlobal(function ()
	local file = res.getfile("config/itemdesc.txt")
	local datas = string.split(file, "\n")

	for i, v in ipairs(datas) do
		if v ~= "" then
			local data = string.split(v, "=")
			itemdesc[data[1]] = data[2]
		end
	end

	return 
end, 0)

return itemdesc
