acCustomVoApi = {}

function acCustomVoApi:getAcVo(version)
    return activityVoApi:getActivityVo("jblb_" .. (version or ""))
end

function acCustomVoApi:getActiveTitle(version)
	local vo = self:getAcVo(version)
	if vo and vo.activeTitle then
		return vo.activeTitle
	end
	return ""
end

function acCustomVoApi:getActiveDesc(version)
	local vo = self:getAcVo(version)
	if vo and vo.activeDesc then
		return vo.activeDesc
	end
	return ""
end

function acCustomVoApi:initRandomCfg()
	if self.colorTb == nil then
		self.colorTb = { 
	    	{ bgColor = ccc4(23, 36, 36, 255), cellBgColor = ccc3(137, 215, 210), cellBgTouchColor = ccc3(56, 121, 117) }, 
	    	{ bgColor = ccc4(36, 30, 16, 255), cellBgColor = ccc3(160, 115,  56), cellBgTouchColor = ccc3(127, 88, 28) }, 
	    	{ bgColor = ccc4(36, 28, 23, 255), cellBgColor = ccc3(183, 104,  73), cellBgTouchColor = ccc3(133, 76, 54) }, 
	    	{ bgColor = ccc4(14, 28, 34, 255), cellBgColor = ccc3(95,  136, 178), cellBgTouchColor = ccc3(60, 98, 136) },
	    }
	end
	if self.imageIndex == nil then
	    self.imageIndex = {
	    	{ "infoBg", 4 }, {  "person", 4 },  { "descBg", 4 }, { "cellBg", 4 }, { "gift", 6 },  { "color", SizeOfTable(self.colorTb) }, { "icon", 5 }
		}
	end
end

function acCustomVoApi:getRandomData(version)
	local settingsKey = "jblb_" .. version .. "@".. playerVoApi:getUid() .. "@" .. base.curZoneID
	local rNumStr = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	return Split(rNumStr, "@")
end

function acCustomVoApi:setRandomData(version, data)
	local vo = self:getAcVo(version)
	local settingsKey = "jblb_" .. version .. "@".. playerVoApi:getUid() .. "@" .. base.curZoneID
	local settingsValue = vo.st .. "@" .. vo.et .. "@"
	for k, v in pairs(self.imageIndex) do
		settingsValue = settingsValue .. (data[v[1]] or 0) .. "-"
	end
	CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, settingsValue)
	CCUserDefault:sharedUserDefault():flush()
end

function acCustomVoApi:getRandomIndexOfKey(version, key)
	local vo = self:getAcVo(version)
	if vo then
		self:initRandomCfg()
		local rNumTb = self:getRandomData(version)
		local maxRandomValue = 5
		for k, v in pairs(self.imageIndex) do
			if v[1] == key then
				maxRandomValue = v[2]
				break
			end
		end
		local isSaveData = false
		local rData = {}
		local randomIndex
		if SizeOfTable(rNumTb) == 3 then
			local acSt = tonumber(rNumTb[1])
			local acEt = tonumber(rNumTb[2])
			rNumTb = Split(rNumTb[3] or "", "-")
			for k, v in pairs(self.imageIndex) do
				rData[v[1]] = tonumber(rNumTb[k]) or 0
				if v[1] == key then
					randomIndex = rData[v[1]]
				end
			end
			if randomIndex == 0 and (acSt == vo.st and acEt == vo.et) then
				randomIndex = math.random(1, maxRandomValue)
				rData[key] = randomIndex
				isSaveData = true
			elseif not (acSt == vo.st and acEt == vo.et) then
				local randomValue = math.random(1, maxRandomValue)
				while randomValue == randomIndex do
					randomValue = math.random(1, maxRandomValue)
				end
				randomIndex = randomValue
				rData[key] = randomIndex
				isSaveData = true
			end
		else
			randomIndex = math.random(1, maxRandomValue)
			rData[key] = randomIndex
			isSaveData = true
		end
		if isSaveData then
			for k, v in pairs(self.imageIndex) do
				if rData[v[1]] == nil then
					rData[v[1]] = 0
				end
			end
			self:setRandomData(version, rData)
		end
		return randomIndex
	end
end

function acCustomVoApi:getThemeColor(version)
	local themeColorIndex = self:getRandomIndexOfKey(version, "color")
	if themeColorIndex then
		return self.colorTb[themeColorIndex].cellBgColor, self.colorTb[themeColorIndex].cellBgTouchColor
	end
end

function acCustomVoApi:getIconImage(version)
	local acIconIndex = self:getRandomIndexOfKey(version, "icon")
	if acIconIndex then
		return "propNewBox" .. acIconIndex .. ".png"
	end
	return "Icon_novicePacks.png"
end

function acCustomVoApi:getUIRandomData(version)
	self:initRandomCfg()
	local rData = {}
	for k, v in pairs(self.imageIndex) do
		rData[v[1]] = self:getRandomIndexOfKey(version, v[1])
	end
	return rData
end

function acCustomVoApi:getColorOfBg(index)
	if self.colorTb and self.colorTb[index] then
		return self.colorTb[index].bgColor
	end
end

function acCustomVoApi:getColorOfCellBg(index)
	if self.colorTb and self.colorTb[index] then
		return self.colorTb[index].cellBgColor
	end
end

function acCustomVoApi:getTimeStr(version)
    local vo = self:getAcVo(version)
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return ""
end

function acCustomVoApi:canReward(acKey)
	local arr = Split(acKey or "", "_")
	if arr and arr[1] == "jblb" and arr[2] then
		local version = arr[2]
		local vo = self:getAcVo(version)
		if self:getActiveType(version) == 2 then
			if vo and vo.shopList and vo.rechargeGoldLimit then
				local rgNum = self:getRechargeGoldNum(version)
				for k, v in pairs(vo.shopList) do
					if self:getBuyNum(v.index, version) == 0 and rgNum >= tonumber(vo.rechargeGoldLimit[v.index]) then
						return true
					end
				end
			end
		end
	end
	return false
end

function acCustomVoApi:isCanEnter(version)
	local vo
	local isShowTip = true
	if type(version) == "table" then
		vo = version
		isShowTip = false
	else
		vo = self:getAcVo(version)
	end
	if vo then
		if vo.openLv and vo.openVip then
			local startLv = tonumber(vo.openLv[1]) or 0
			local endLv = tonumber(vo.openLv[2]) or 99999
			local startVip = tonumber(vo.openVip[1]) or 0
			local endVip = tonumber(vo.openVip[2]) or 99999
			local playerLv = playerVoApi:getPlayerLevel()
			local playerVip = playerVoApi:getVipLevel()
			if playerLv >= startLv and playerLv <= endLv and playerVip >= startVip and playerVip <= endVip then
				return true
			end
			if isShowTip then
				local tipStr
				if not (playerLv >= startLv and playerLv <= endLv) then
					tipStr = getlocal("lv_not_enough")
				elseif not (playerVip >= startVip and playerVip <= endVip) then
					tipStr = getlocal("backstage2006")
				end
				if tipStr then
					smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
				end
			end
		end
	end
	return false
end

function acCustomVoApi:getShopList(version)
	local acType = self:getActiveType(version)
	local vo = self:getAcVo(version)
	if vo and vo.shopList and ((acType == 2 and vo.rechargeGoldLimit) or (vo.limit and vo.cost)) then
		local shopTb = {}
		for k, v in pairs(vo.shopList) do
			local index = v.index
			if acType == 2 then
				table.insert(shopTb, { index = index, name = v.name, reward = v.reward, limit = tonumber(vo.rechargeGoldLimit[index]) })
			else
				table.insert(shopTb, { index = index, name = v.name, reward = v.reward, limit = vo.limit[index], cost = vo.cost[index] })
			end
		end
		table.sort(shopTb, function(a, b) return a.index < b.index end)
		return shopTb
	end
end

--购买接口
--@ sid : 商品id
--@ buyNum : 购买数量
function acCustomVoApi:requestBuy(callback, sid, version, buyNum)
	local acKey = "jblb_" .. version
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data[acKey] then
                    self:updateData(sData.data[acKey], version)
                end
            	if callback then
            		callback()
            	end
            end
        end
    end
	socketHelper:acCustomBuy(socketCallback, sid, acKey, buyNum)
end

function acCustomVoApi:getBuyNum(sid, version)
	local vo = self:getAcVo(version)
	if vo and vo.buyNumTb then
		if vo.buyNumTb["i" .. sid] then
			return vo.buyNumTb["i" .. sid]
		end
	end
	return 0
end

function acCustomVoApi:updateData(data, version)
    if data then
        local vo = self:getAcVo(version)
        if vo then
        	vo:updateData(data)
        	activityVoApi:updateShowState(vo)
        end
    end
end

--return 2:充值礼包，否则:金币礼包
function acCustomVoApi:getActiveType(version)
	local vo = self:getAcVo(version)
	if vo and vo.activeType then
		return tonumber(vo.activeType)
	end
end

function acCustomVoApi:getRechargeGoldNum(version)
	local vo = self:getAcVo(version)
	if vo and vo.rechargeGoldNum then
		return tonumber(vo.rechargeGoldNum)
	end
	return 0
end

function acCustomVoApi:clearAll()
end