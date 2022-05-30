local OpenCheck = {}

function OpenCheck.getOpenLevelById(id, curLevel, curVipLevel)
	local needLevel = -1
	local needVipLevel = -1
	local bNeedAll = true
	local bHasOpen = false
	local prompt = ""
	local data_open_open = require("data.data_open_open")
	for i, v in ipairs(data_open_open) do
		if v.system == id then
			if v.level ~= nil and #v.level > 0 then
				needLevel = v.level[1]
			end
			if v.vip ~= nil then
				needVipLevel = v.vip
			end
			if v.need_all == 1 then
				bNeedAll = true
			elseif v.need_all == 2 then
				bNeedAll = false
			end
			prompt = v.prompt1 or ""
			break
		end
	end
	if bNeedAll then
		if curLevel >= needLevel and curVipLevel >= needVipLevel then
			bHasOpen = true
		end
	elseif curLevel >= needLevel or curVipLevel >= needVipLevel then
		bHasOpen = true
	end
	return bHasOpen, prompt
end

function OpenCheck.checkIsOpenNewFuncByLevel(beforeLevel, curLevel)
	local open = false
	local openSystems = {}
	if beforeLevel < curLevel then
		local disLv = curLevel - beforeLevel
		local data_open_open = require("data.data_open_open")
		for k = 1, disLv do
			local level = beforeLevel + k
			for i, v in ipairs(data_open_open) do
				if v.prama_num ~= nil and v.prama_num > 0 and v.arr_needLevel ~= nil and 0 < #v.arr_needLevel then
					for j, vl in ipairs(v.arr_needLevel) do
						if level == vl then
							if game.player:getAppOpenData().appstore == APPOPEN_STATE.close and game.player:getLevel() >= 24 then
								return open, openSystems
							end
							open = true
							table.insert(openSystems, v.system)
							break
						end
					end
				end
			end
		end
	end
	return open, openSystems
end

return OpenCheck