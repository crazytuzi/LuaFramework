acCashGiftBagVoApi = {}

function acCashGiftBagVoApi:getAcVo()
    return activityVoApi:getActivityVo("xjlb")
end

function acCashGiftBagVoApi:getActiveTitle()
	local vo = self:getAcVo()
	if vo and vo.activeTitle then
		return vo.activeTitle
	end
	return ""
end

function acCashGiftBagVoApi:getActiveDesc()
	local vo = self:getAcVo()
	if vo and vo.activeDesc then
		return vo.activeDesc
	end
	return ""
end

function acCashGiftBagVoApi:initRandomCfg()
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
	    	{ "infoBg", 4 }, {  "person", 4 },  { "descBg", 4 }, { "cellBg", 1 }, { "gift", 5 },  { "color", SizeOfTable(self.colorTb) }, { "icon", 5 }
		}
	end
end

function acCashGiftBagVoApi:getRandomData()
	local settingsKey = "xjlb_" .. "@".. playerVoApi:getUid() .. "@" .. base.curZoneID
	local rNumStr = CCUserDefault:sharedUserDefault():getStringForKey(settingsKey)
	return Split(rNumStr, "@")
end

function acCashGiftBagVoApi:setRandomData(data)
	local vo = self:getAcVo()
	local settingsKey = "xjlb_" .. "@".. playerVoApi:getUid() .. "@" .. base.curZoneID
	local settingsValue = vo.st .. "@" .. vo.et .. "@"
	for k, v in pairs(self.imageIndex) do
		settingsValue = settingsValue .. (data[v[1]] or 0) .. "-"
	end
	CCUserDefault:sharedUserDefault():setStringForKey(settingsKey, settingsValue)
	CCUserDefault:sharedUserDefault():flush()
end

function acCashGiftBagVoApi:getRandomIndexOfKey(key)
	local vo = self:getAcVo()
	if vo then
		self:initRandomCfg()
		local rNumTb = self:getRandomData()
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
			self:setRandomData(rData)
		end
		return randomIndex
	end
end

function acCashGiftBagVoApi:getThemeColor()
	local themeColorIndex = self:getRandomIndexOfKey("color")
	if themeColorIndex then
		return self.colorTb[themeColorIndex].cellBgColor, self.colorTb[themeColorIndex].cellBgTouchColor
	end
end

function acCashGiftBagVoApi:getIconImage()
	--[[
	local acIconIndex = self:getRandomIndexOfKey("icon")
	if acIconIndex then
		return "propNewBox" .. acIconIndex .. ".png"
	end
	--]]
	local acIconIndex = self:getRandomIndexOfKey("gift")
	if acIconIndex then
		return "acxjlb_giftBag_" .. acIconIndex .. ".png"
	end
	return "Icon_novicePacks.png"
end

function acCashGiftBagVoApi:getUIRandomData()
	self:initRandomCfg()
	local rData = {}
	for k, v in pairs(self.imageIndex) do
		rData[v[1]] = self:getRandomIndexOfKey(v[1])
	end
	return rData
end

function acCashGiftBagVoApi:getColorOfBg(index)
	if self.colorTb and self.colorTb[index] then
		return self.colorTb[index].bgColor
	end
end

function acCashGiftBagVoApi:getColorOfCellBg(index)
	if self.colorTb and self.colorTb[index] then
		return self.colorTb[index].cellBgColor
	end
end

function acCashGiftBagVoApi:getTimeStr()
    local vo = self:getAcVo()
    if vo then
        local activeTime = vo.et - base.serverTime > 0 and G_formatActiveDate(vo.et - base.serverTime) or nil
        if activeTime == nil then
            activeTime = getlocal("serverwarteam_all_end")
        end
        return getlocal("activityCountdown") .. ":" .. activeTime
    end
    return ""
end

function acCashGiftBagVoApi:canReward()
	local shopList = self:getShopList()
	if shopList then
		for k, v in pairs(shopList) do
			local rData = self:getRechargeData(v.index)
		    local rState, rNum = 0, 0
		    if rData then
		        rState = (rData[1] or 0) --充值状态  默认 0 未充值； 1 已充值； 2 已领取
		        rNum = (rData[2] or 0) --领取次数
		    end
		    if rState == 1 then --可领取
		    	return true
		    end
		end
	end
	return false
end

function acCashGiftBagVoApi:isCanEnter(isShowTip)
	if isShowTip == nil then
		isShowTip = true
	end
	local vo = self:getAcVo()
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

function acCashGiftBagVoApi:getShopList()
	local vo = self:getAcVo()
	if vo and vo.shopList then
		table.sort(vo.shopList, function(a, b) return a.index < b.index end)
		return vo.shopList
	end
end

function acCashGiftBagVoApi:getRechargeData(index)
	local vo = self:getAcVo()
	if vo and vo.rewardData then
		return vo.rewardData["t" .. index]
	end
end

--领取奖励接口
--@rewardIndex : 奖励索引
function acCashGiftBagVoApi:requestReward(callback, rewardId)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		if sData.data.xjlb then
        			self:updateData(sData.data.xjlb)
        		end
	        	if type(callback) == "function" then
	        		callback()
	        	end
	        end
        end
    end
	socketHelper:acCashGiftBagReward(socketCallback, rewardId)
end

function acCashGiftBagVoApi:updateData(data)
	if data then
        local vo = self:getAcVo()
        if vo then
        	vo:updateData(data)
        	activityVoApi:updateShowState(vo)
        end
    end
end

function acCashGiftBagVoApi:clearAll()
end