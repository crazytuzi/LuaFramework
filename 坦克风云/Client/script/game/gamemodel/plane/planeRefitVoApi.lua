planeRefitVoApi = {
	skvMap = nil, --存放技能属性映射表缓存数据
}

function planeRefitVoApi:getCfg()
	if self.planeRefitCfg == nil then
		self.planeRefitCfg = G_requireLua("config/gameconfig/planeRefit")
	end
	return self.planeRefitCfg
end

function planeRefitVoApi:isOpen()
	return (base.planeRefit == 1)
end

function planeRefitVoApi:isCanEnter(isShowTips)
	if self:isOpen() == false then
		if isShowTips then
			G_showTipsDialog(getlocal("backstage180"))
		end
		return false
	end
	local openLv = self:getCfg().playerLevel
	if playerVoApi:getPlayerLevel() < openLv then
		if isShowTips then
			G_showTipsDialog(getlocal("elite_challenge_unlock_level", {openLv}))
		end
		return false
	end
	if SizeOfTable(planeVoApi:getPlaneList()) < SizeOfTable(planeCfg.plane) then
		if isShowTips then
			G_showTipsDialog(getlocal("planeRefit_enterConditionTips"))
		end
		return false
	end
	return true
end

--主入口界面(战机聚能)
function planeRefitVoApi:showMainDialog(layerNum)
	self:requestInit(function()
		require "luascript/script/game/scene/gamedialog/plane/planeChargeDialog"
		local td = planeChargeDialog:new(layerNum)
	    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("planeRefit_chargeText"), true, layerNum)
	    sceneGame:addChild(dialog, layerNum)
	end)
end

--战机改装界面（默认显示第一个部位第一架战机）
--@placeId[可选参数] : 部位id
--@planeId[可选参数] : 战机id
function planeRefitVoApi:showRefitDialog(layerNum, placeId, planeId)
	require "luascript/script/game/scene/gamedialog/plane/planeRefitDialog"
	local td = planeRefitDialog:new(layerNum, placeId, planeId)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("planeRefit_text"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--属性详情小弹板
--@paramsTb : 参数列表
--		|	-	[1]:部位id
--		|	-	[2]:战机id
--		|	-	[3]:改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:showAttributeDetailsSmallDialog(layerNum, paramsTb)
	require "luascript/script/game/scene/gamedialog/plane/planeRefitSmallDialog"
	planeRefitSmallDialog:showAttributeDetails(layerNum, getlocal("planeRefit_attributeDetails"), paramsTb)
end

--属性总览小弹板
--@paramsTb : 参数列表
--		|	-	[1]:部位id
--		|	-	[2]:战机id
function planeRefitVoApi:showAttributePandectSmallDialog(layerNum, paramsTb)
	require "luascript/script/game/scene/gamedialog/plane/planeRefitSmallDialog"
	planeRefitSmallDialog:showAttributePandect(layerNum, getlocal("battlebuff_overview"), paramsTb)
end

--自动改装界面
--@dialogObj : 关联的战机改装界面的planeRefitDialog对象
function planeRefitVoApi:showAutoRefitDialog(layerNum, dialogObj)
	require "luascript/script/game/scene/gamedialog/plane/planeAutoRefitDialog"
	local td = planeAutoRefitDialog:new(layerNum, dialogObj)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("planeRefit_text"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--自动改装详情界面
--@placeId : 部位id
--@planeId : 战机id
--@refitCount : 改装次数
--@refitConditionIndexTb : 改装条件的索引
--@lockRefitTypeIndexTb : 上锁的改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
--@responseData : 自动改装接口的响应数据
--@oldData : 调用自动改装接口前的旧数据
function planeRefitVoApi:showAutoRefitDetailsDialog(layerNum, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb, responseData, oldData)
	require "luascript/script/game/scene/gamedialog/plane/planeAutoRefitDetailsDialog"
	local td = planeAutoRefitDetailsDialog:new(layerNum, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb, responseData, oldData)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), nil, nil, nil, getlocal("planeRefit_text"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

--请求初始化数据接口
function planeRefitVoApi:requestInit(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:planeRefitInit(socketCallback)
end

--初始化数据
function planeRefitVoApi:initData(data)
	if data then
		if data.plane then
			if data.plane.einfo then
				--是否首次
				self.isFirst = (data.plane.einfo.isfirst == nil)

				if data.plane.einfo.resinfo then
					-- data.plane.einfo.resinfo[1] --最后一次聚能的时间戳, 跨天重置为零点时间戳

					--聚能消耗的资源索引值(每天随机)
					self.chargeCostResIndex = data.plane.einfo.resinfo[2]

					--聚能资源消耗次数(次日清零)
					self.chargeResCount = data.plane.einfo.resinfo[3]

					--聚能金币消耗次数(次日清零)
					self.chargeGoldCount = data.plane.einfo.resinfo[4]

					--改装次数(次日清零)
					self.refitCount = data.plane.einfo.resinfo[5]
				end

				--解锁部位的placeId
				if data.plane.einfo.unlock then
					self.unlockPlaceId = data.plane.einfo.unlock
				end
			end

			--核能等级([placeId])
			if data.plane.elevel then
				self.energyLevel = data.plane.elevel
			end

			--核能的能量点数([placeId][planeId])
			if data.plane.eginfo then
				self.energyExp = data.plane.eginfo
			end

			--消耗的改装点数
			if data.plane.refit then
				self.refitExp = data.plane.refit
			end

			--上次改装但未保存的临时数据
			if data.plane.lasthandle then
				self.refitTempExp = data.plane.lasthandle
			end

			--技能等级数据([placeId][planeId][refitTypeIndex][skillIndex])
			if data.plane.eskill then
				self.skillLevelData = data.plane.eskill
			end
			if data.plane.eskill or data.plane.refit then
				if self.svMap == nil then
					planeRefitVoApi:initSkvMap()
				end
			end
		end
	end
end

--聚能接口
--@placeId : 部位id
--@chargeType : 聚能类型(1-资源,2-金币)
--@chargeCount : 聚能次数
function planeRefitVoApi:requestCharge(callback, placeId, chargeType, chargeCount)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback(sData.data.handleTb)
        		end
        	end
        end
	end
	socketHelper:planeRefitCharge(socketCallback, placeId, chargeType, chargeCount)
end

--是否第一次进入改装系统聚能
function planeRefitVoApi:isFirstEnter()
	return self.isFirst
end

--获取部位数据
function planeRefitVoApi:getPlaceData()
	local cfg = self:getCfg()
	return cfg.place
end

--获取部位名称
--@placeId : 部位id
function planeRefitVoApi:getPlaceName(placeId)
	local cfg = self:getCfg()
	if cfg.place[placeId] then
		return getlocal(cfg.place[placeId].placeName)
	end
end

--获取部位图片
--@placeId : 部位id
function planeRefitVoApi:getPlacePic(placeId)
	local cfg = self:getCfg()
	if cfg.place[placeId] then
		return cfg.place[placeId].icon
	end
end

--获取聚能快捷次数
function planeRefitVoApi:getChargeShortcutCount()
	local cfg = self:getCfg()
	return cfg.fillCount
end

--获取聚能次数(次日清零)
--@cType : 1-资源，2-金币
function planeRefitVoApi:getChargeCount(cType)
	if cType == 1 then
		return (self.chargeResCount or 0)
	elseif cType == 2 then
		return (self.chargeGoldCount or 0)
	end
	return 0
end

--获取聚能消耗的资源数据
--#return
--#value1 : 资源索引值(1-铁，2-石油，3-铅，4-钛，5-水晶)
--#value2 : 现有的资源量
function planeRefitVoApi:getChargeCostResIndex()
	if self.chargeCostResIndex then
		local ownResNum
		if self.chargeCostResIndex == 1 then
			ownResNum = playerVoApi:getR1()
		elseif self.chargeCostResIndex == 2 then
			ownResNum = playerVoApi:getR2()
		elseif self.chargeCostResIndex == 3 then
			ownResNum = playerVoApi:getR3()
		elseif self.chargeCostResIndex == 4 then
			ownResNum = playerVoApi:getR4()
		elseif self.chargeCostResIndex == 5 then
			ownResNum = playerVoApi:getGold()
		end
		return self.chargeCostResIndex, ownResNum
	end
end

--获取聚能所消耗的资源
--@isShortcut : 是否勾选快捷聚能
function planeRefitVoApi:getChargeCostRes(isShortcut)
	local costRes
	local cfg = self:getCfg()
	if self.isFirst == true then
		costRes = cfg.firstFillCost
		if isShortcut == true then
			local resIndex = self:getChargeCostResIndex()
			if resIndex then
				local shortcutCount = self:getChargeShortcutCount()
				if resIndex <= 3 then
					local fillCost1Size = SizeOfTable(cfg.fillCost1)
					for i = 1, shortcutCount - 1 do
						costRes = (costRes or 0) + (cfg.fillCost1[i] or cfg.fillCost1[fillCost1Size])
					end
				else
					local fillCost2Size = SizeOfTable(cfg.fillCost2)
					local shortcutCount = self:getChargeShortcutCount()
					for i = 1, shortcutCount - 1 do
						costRes = (costRes or 0) + (cfg.fillCost2[i] or cfg.fillCost2[fillCost2Size])
					end
				end
			end
		end
	else
		local costIndex = self:getChargeCount(1) + 1
		local resIndex = self:getChargeCostResIndex()
		if resIndex then
			if resIndex <= 3 then
				if isShortcut == true then
					local fillCost1Size = SizeOfTable(cfg.fillCost1)
					local shortcutCount = self:getChargeShortcutCount()
					for i = costIndex, costIndex + shortcutCount - 1 do
						costRes = (costRes or 0) + (cfg.fillCost1[i] or cfg.fillCost1[fillCost1Size])
					end
				else
					costRes = cfg.fillCost1[costIndex]
					if costRes == nil then
						costRes = cfg.fillCost1[SizeOfTable(cfg.fillCost1)]
					end
				end
			else
				if isShortcut == true then
					local fillCost2Size = SizeOfTable(cfg.fillCost2)
					local shortcutCount = self:getChargeShortcutCount()
					for i = costIndex, costIndex + shortcutCount - 1 do
						costRes = (costRes or 0) + (cfg.fillCost2[i] or cfg.fillCost2[fillCost2Size])
					end
				else
					costRes = cfg.fillCost2[costIndex]
					if costRes == nil then
						costRes = cfg.fillCost2[SizeOfTable(cfg.fillCost2)]
					end
				end
			end
		end
	end
	return costRes
end

--获取聚能所消耗的金币
--@isShortcut : 是否勾选快捷聚能
function planeRefitVoApi:getChargeCostGold(isShortcut)
	local costIndex = self:getChargeCount(2) + 1
	local cfg = self:getCfg()
	local costGold
	if isShortcut == true then
		local fillCost3Size = SizeOfTable(cfg.fillCost3)
		local shortcutCount = self:getChargeShortcutCount()
		for i = costIndex, costIndex + shortcutCount - 1 do
			costGold = (costGold or 0) + (cfg.fillCost3[i] or cfg.fillCost3[fillCost3Size])
		end
	else
		costGold = cfg.fillCost3[costIndex]
		if costGold == nil then
			costGold = cfg.fillCost3[SizeOfTable(cfg.fillCost3)]
		end
	end
	return costGold
end

--获取满级聚能时转换的道具数据
--@cType : 1-资源，2-金币
--@isShortcut : 是否勾选快捷聚能
function planeRefitVoApi:getMaxLevelChargeItem(cType, isShortcut)
	local cfg = self:getCfg()
	if cfg.maxChange[cType] then
		local itemId = Split(cfg.maxChange[cType][1], "_")[2]
		local itemNum = cfg.maxChange[cType][2]
		if isShortcut then
			itemNum = itemNum * self:getChargeShortcutCount()
		end
		return FormatItem({p = {[itemId] = itemNum}})
	end
end

--获取当前等级的色值
--@level : 核能等级
function planeRefitVoApi:getLevelColor(level)
	local cfg = self:getCfg()
	local colorKey
	local colorSize = SizeOfTable(cfg.fillColor)
	for k, v in pairs(cfg.fillColor) do
		local nextV = cfg.fillColor[k + 1]
		if (level >= v.grade and (nextV and level < nextV.grade)) or nextV == nil then
			colorKey = v.useColor
			break
		end
	end
	if colorKey == "green" then
		return G_ColorGreen, colorKey
	elseif colorKey == "blue" then
		return G_ColorBlue, colorKey
	elseif colorKey == "purple" then
		return G_ColorPurple, colorKey
	elseif colorKey == "orange" then
		return G_ColorOrange, colorKey
	elseif colorKey == "red" then
		return G_ColorRed, colorKey
	end
end

--获取核能等级(默认为1级)
--@placeId : 部位id
function planeRefitVoApi:getEnergyLevel(placeId)
	if self.energyLevel and self.energyLevel[placeId] then
		return self.energyLevel[placeId]
	end
	return 1
end

--获取核能当前能量点数
--@placeId : 部位id
--@planeId : 战机id
function planeRefitVoApi:getEnergyCurExp(placeId, planeId)
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	if self.energyExp and self.energyExp[placeId] and self.energyExp[placeId][planeId] then
		return self.energyExp[placeId][planeId]
	end
	return 0
end

--获取当前核能等级升至一下级的最大能量点数
--@energyLv : 核能等级
function planeRefitVoApi:getEnergyMaxExp(energyLv)
	local cfg = self:getCfg()
	local chargeData = cfg.fill[energyLv + 1]
	if chargeData and chargeData.grade == energyLv + 1 then
		return chargeData.needPower
	end
	return 0
end

--判断当前的核能等级是否为最大等级
--@energyLv : 核能等级
function planeRefitVoApi:isMaxLevel(energyLv)
	return (self:getEnergyMaxExp(energyLv) == 0)
end

--获取当前核能等级升至一下级所需要的改装点数
--@energyLv : 核能等级
function planeRefitVoApi:getNextNeedRefit(energyLv)
	local cfg = self:getCfg()
	local chargeData = cfg.fill[energyLv + 1]
	if chargeData and chargeData.grade == energyLv + 1 then
		return chargeData.needRefit
	end
	return 0
end

--获取当前核能等级的可分配的改装点数
--@energyLv : 核能等级
function planeRefitVoApi:getRefitMaxExp(energyLv)
	local cfg = self:getCfg()
	local chargeData = cfg.fill[energyLv]
	if chargeData and chargeData.grade == energyLv then
		return chargeData.costPower
	end
	return 0
end

--获取该部位该战机该号位下的改装点数
--@placeId : 部位id
--@planeId : 战机id
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:getRefitExp(placeId, planeId, refitTypeIndex)
	local exp = 0
	if self.refitExp then
		if placeId and planeId and refitTypeIndex then
			planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
			if self.refitExp[placeId] and self.refitExp[placeId][planeId] and self.refitExp[placeId][planeId][refitTypeIndex] then
				exp = self.refitExp[placeId][planeId][refitTypeIndex]
			end
		elseif placeId and planeId and refitTypeIndex == nil then
			planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
			if self.refitExp[placeId] and self.refitExp[placeId][planeId] then
				for k, v in pairs(self.refitExp[placeId][planeId]) do
					exp = exp + v
				end
			end
		elseif placeId and planeId == nil and refitTypeIndex == nil then
			if self.refitExp[placeId] then
				for k, v in pairs(self.refitExp[placeId]) do
					for kk, vv in pairs(v) do
						exp = exp + v
					end
				end
			end
		else
			for k, v in pairs(self.refitExp) do
				for kk, vv in pairs(v) do
					for kkk, vvv in pairs(vv) do
						exp = exp + vvv
					end
				end
			end
		end
	end
	return exp
end

--获取该部位该战机下的改装点
--@placeId : 部位id
--@planeId : 战机id
function planeRefitVoApi:getRefitExpTb(placeId, planeId)
	if self.refitExp and placeId and planeId then
		planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
		if self.refitExp[placeId] and self.refitExp[placeId][planeId] then
			return self.refitExp[placeId][planeId]
		end
	end
end

--获取该部位该战机该号位下的改装类型数据
--@placeId : 部位id
--@planeId : 战机id
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:getRefitTypeData(placeId, planeId, refitTypeIndex)
	local cfg = self:getCfg()
	if cfg.refit and cfg.refit[placeId] and planeId then
		planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
		if cfg.refit[placeId][planeId] then
			if refitTypeIndex and cfg.refit[placeId][planeId][refitTypeIndex] then
				return cfg.refit[placeId][planeId][refitTypeIndex]
			elseif refitTypeIndex == nil then
				return cfg.refit[placeId][planeId]
			end
		end
	end
end

--获取该段(index)的改装进度百分比
--@refitTypeData : 改装类型的数据
--@refitExp : 改装点数
--@index : 分段的索引值（从12点方向的顺时针开始）
function planeRefitVoApi:getRefitPercentageByIndex(refitTypeData, refitExp, index)
	local percentage = 0
	if refitTypeData and refitTypeData.powerNeed and refitTypeData.powerNeed[index] then
		if refitExp >= refitTypeData.powerNeed[index] then
			percentage = 100
		else
			if index == 1 then
				percentage = refitExp / refitTypeData.powerNeed[index] * 100
			else
				if refitExp <= refitTypeData.powerNeed[index - 1] then
					percentage = 0
				else
					percentage = (refitExp - refitTypeData.powerNeed[index - 1]) / (refitTypeData.powerNeed[index] - refitTypeData.powerNeed[index - 1]) * 100
				end
			end
		end
	end
	if percentage > 100 then
		percentage = 100
	end
	return percentage
end

--获取改装消耗的道具id
function planeRefitVoApi:getRefitCostPropId()
	local cfg = self:getCfg()
	if cfg.refitNeed and cfg.refitNeed[1] then
		local strArray = Split(cfg.refitNeed[1], "_")
		if strArray and strArray[2] then
			local pid = strArray[2]
			return pid
		end
	end
end

--获取改装消耗的道具数量
--@lockCount : 改装部位的加锁个数
function planeRefitVoApi:getRefitCostPropNum(lockCount)
	local cfg = self:getCfg()
	if cfg.refitCost[(lockCount or 0) + 1] then
		return cfg.refitCost[(lockCount or 0) + 1]
	end
	return 0
end

--改装接口
--@placeId : 部位id
--@planeId : 战机id
--@lockRefitTypeIndexTb : 上锁的改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:requestRefit(callback, placeId, planeId, lockRefitTypeIndexTb)
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:planeRefitRefit(socketCallback, placeId, planeId, lockRefitTypeIndexTb)
end

--获取改装次数
function planeRefitVoApi:getRefitCount()
	return (self.refitCount or 0)
end

--获取最大改装次数
function planeRefitVoApi:getRefitMaxCount()
	local cfg = self:getCfg()
	return cfg.refitNum
end

--保存改装接口
--@placeId : 部位id
--@planeId : 战机id
function planeRefitVoApi:requestSaveRefit(callback, placeId, planeId)
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		--改装保存时可能会影响战机的相关数据(威力值,技能槽)
        		planeVoApi:updatePlaneList(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:planeRefitSaveRefit(socketCallback, placeId, planeId)
end

--获取未保存的临时改装点数
--@placeId : 部位id
--@planeId : 战机id
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:getRefitTempExp(placeId, planeId, refitTypeIndex)
	if self.refitTempExp then
		if placeId and planeId then
			planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
			if self.refitTempExp[placeId] and self.refitTempExp[placeId][planeId] then
				local tempExp = 0
				for k, v in pairs(self.refitTempExp[placeId][planeId]) do
					if v[1] == refitTypeIndex then
						return v[2]
					elseif refitTypeIndex == nil then
						tempExp = tempExp + v[2]
					end
				end
				if refitTypeIndex == nil then
					return tempExp
				end
			end
		end
	end
end

--该部位该战机是否有未保存的临时改装点数
--@placeId : 部位id
--@planeId : 战机id
function planeRefitVoApi:isHaveRefitTempExp(placeId, planeId)
	if self.refitTempExp then
		if placeId and planeId then
			planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
			if self.refitTempExp[placeId] then
				local tempExpSize, tempExpChangeTb = 0
				for k, v in pairs(self.refitTempExp[placeId][planeId]) do
					tempExpSize = tempExpSize + 1
					if tempExpChangeTb == nil then
						tempExpChangeTb = {}
					end
					tempExpChangeTb[v[1]] = v[2]
				end
				return (tempExpSize > 0), tempExpChangeTb
			end
		end
	end
	return false
end

--自动改装接口
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
--@refitCount : 改装次数
--@refitConditionIndexTb : 改装条件的索引
--@lockRefitTypeIndexTb : 上锁的改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:requestAutoRefit(callback, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb)
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		--自动改装时可能会影响战机的相关数据(威力值,技能槽)
        		planeVoApi:updatePlaneList(sData.data)
        		if type(callback) == "function" then
        			callback(sData.data)
        		end
        	end
        end
	end
	socketHelper:planeRefitAutoRefit(socketCallback, placeId, planeId, refitCount, refitConditionIndexTb, lockRefitTypeIndexTb)
end

--获取可选择的自动改装次数
function planeRefitVoApi:getAutoRefitCountTb()
	local cfg = self:getCfg()
	return cfg.autoRefit
end

--获取自动改装次数的等级限制
--@autoRefitCountTbIndex : 自动改装次数表的索引值
function planeRefitVoApi:getAutoRefitCountOfLvLimit(autoRefitCountTbIndex)
	local cfg = self:getCfg()
	return cfg.autoLock[autoRefitCountTbIndex]
end

--技能升级接口
--@placeId : 部位id
--@planeId : 战机id（因后端识别成了number类型，故该id必须是处理后的number类型）
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
--@skillIndex : 分段的索引值（从12点方向的顺时针开始）
function planeRefitVoApi:requestSkillUpgrade(callback, placeId, planeId, refitTypeIndex, skillIndex)
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
        	if sData and sData.data then
        		self:initData(sData.data)
        		if type(callback) == "function" then
        			callback()
        		end
        	end
        end
	end
	socketHelper:planeRefitSkillUpgrade(socketCallback, placeId, planeId, refitTypeIndex, skillIndex)
end

--获取技能配置数据
--@skillId : 技能id（参考planeRefit.lua文件中的refitSkill）
function planeRefitVoApi:getSkillCfg(skillId)
	local cfg = self:getCfg()
	if cfg.refitSkill then
		if tonumber(skillId) then
			skillId = "s" .. skillId
		end
		return cfg.refitSkill[skillId]
	end
end

--获取激活技能等级(默认为1级)
--@placeId : 部位id
--@planeId : 战机id
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
--@skillIndex : 分段的索引值（从12点方向的顺时针开始）
--@isCheckValid : 是否检测真实生效的等级
function planeRefitVoApi:getSkillLevel(placeId, planeId, refitTypeIndex, skillIndex, isCheckValid)
	local skillLv = 1
	if self.skillLevelData and placeId and planeId then
		planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
		if self.skillLevelData[placeId] and self.skillLevelData[placeId][planeId] and self.skillLevelData[placeId][planeId][refitTypeIndex] 
			and self.skillLevelData[placeId][planeId][refitTypeIndex][skillIndex] then
			skillLv = self.skillLevelData[placeId][planeId][refitTypeIndex][skillIndex]
		end
		if isCheckValid == true then
			local refitExp = self:getRefitExp(placeId, planeId, refitTypeIndex)
			local validMaxLv = self:getSkillValidMaxLv(refitExp)
			if validMaxLv and skillLv > validMaxLv then
				skillLv = validMaxLv
			end
		end
	end
	return skillLv
end

--获取该部位(placeId)该飞机(planeId)该位置(refitTypeIndex)下的主技能名称
--@placeId : 部位id
--@planeId : 战机id
--@refitTypeIndex : 改装类型索引（从UI界面上看是从左至右、从上至下的顺序）
function planeRefitVoApi:getRefitTypeName(placeId, planeId, refitTypeIndex)
	local refitTypeData = self:getRefitTypeData(placeId, planeId, refitTypeIndex)
	if refitTypeData then
		local skillCfg = self:getSkillCfg(refitTypeData.skill1)
		if skillCfg then
			return getlocal(skillCfg.skillName)
		end
	end
	return ""
end

--获取技能当前等级升至下一级所消耗的道具
--@skillLv : 技能等级
function planeRefitVoApi:getSkillUpgradeCost(skillLv)
	local cfg = self:getCfg()
	if cfg.skillUp and cfg.skillUp[skillLv + 1] then
		return FormatItem(cfg.skillUp[skillLv + 1].cost, nil, true)
	end
end

--获取技能当前等级所需要的改装点数
--@skillLv : 技能等级
function planeRefitVoApi:getSkillNeedRefitExp(skillLv)
	local cfg = self:getCfg()
	if cfg.skillUp and cfg.skillUp[skillLv] then
		return cfg.skillUp[skillLv].needRefit
	end
end


--获取激活技能在当前改装点数下生效的最大等级
--@refitExp : 改装点数
function planeRefitVoApi:getSkillValidMaxLv(refitExp)
	local cfg = self:getCfg()
	if cfg.skillUp then
		local maxLv = 1
		for lv, v in ipairs(cfg.skillUp) do
			if refitExp >= v.needRefit then
				maxLv = lv
			else
				break
			end
		end
		return maxLv
	end
end

--获取技能的属性值
--@skillId : 技能id（参考planeRefit.lua文件中的refitSkill）
--@skillLv : 技能等级
--@refitExp : 改装点数（如果不为nil，且为激活技能类型时，将按照真实的生效技能等级计算属性值）
function planeRefitVoApi:getSkillAttributeValue(skillId, skillLv, refitExp)
	local skillCfg = self:getSkillCfg(skillId)
	if skillCfg then
		if skillCfg.getType == 1 then --基础技能(属性计算：value2*改装点+value1)
			return skillCfg.value2 * refitExp + skillCfg.value1
		elseif skillCfg.getType == 2 then --激活技能(属性计算：value2*等级+value1)
			if refitExp then
				local validMaxLv = self:getSkillValidMaxLv(refitExp)
				if validMaxLv and skillLv > validMaxLv then
					skillLv = validMaxLv
				end
			end
			return skillCfg.value2 * skillLv + skillCfg.value1
		end
	end
	return 0
end

--获取技能属性
--@skillType : 技能类型（参考planeRefit.lua文件中的refitSkill）
function planeRefitVoApi:getSkillAttribute(skillType)
	local attributeValue = 0
	if self:isCanEnter() == false then
		return attributeValue
	end
	local cfg = self:getCfg()
	local skillIdTb = cfg.mirror[skillType]
	if skillIdTb then
		for k, skillId in pairs(skillIdTb) do
			local isValid, searchData = self:isValidBySkillId(skillId)
			if isValid then
				local placeId, planeId, refitTypeIndex = searchData[1], searchData[2], searchData[3]
				local refitCfgData = self:getRefitTypeData(placeId, planeId, refitTypeIndex)
				if refitCfgData then
					local refitExp = self:getRefitExp(placeId, planeId, refitTypeIndex)
					if skillId == tonumber(refitCfgData.skill1) then --基础技能
						attributeValue = attributeValue + self:getSkillAttributeValue(skillId, 0, refitExp)
					else
						for skillIndex, skillId_a in pairs(refitCfgData.skill2) do --激活技能
							if skillId == skillId_a then
								local skillLv = self:getSkillLevel(placeId, planeId, refitTypeIndex, skillIndex)
								attributeValue = attributeValue + self:getSkillAttributeValue(skillId, skillLv, refitExp)
								break
							end
						end
					end
				end
			end
		end
	end
	return attributeValue
end

--获取战机的威力值
--@planeId : 战机id
function planeRefitVoApi:getStrength(planeId)
	local strength = 0
	if self:isCanEnter() == false then
		return strength
	end
	local cfg = self:getCfg()
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	for k, v in pairs(cfg.refit) do --5个部位
		for kk, vv in pairs(v) do --4架战机
			for kkk, vvv in pairs(vv) do --4个改装类型
				if kk == planeId then
					--基础技能
					local skill1Cfg = self:getSkillCfg(vvv.skill1)
					if skill1Cfg then
						local refitExp = self:getRefitExp(k, kk, kkk)
						strength = strength + skill1Cfg.intensity * refitExp / 100
					end
					--激活技能
					local refitExp = self:getRefitExp(k, kk, kkk)
					for skillIndex, skillId in pairs(vvv.skill2) do
						if refitExp >= vvv.powerNeed[skillIndex] then --是否激活
							local skill2Cfg = self:getSkillCfg(skillId)
							if skill2Cfg then
								local skillLv = self:getSkillLevel(k, kk, kkk, skillIndex)
								strength = strength + skill2Cfg.intensity * skillLv
							end
						end
					end
				end
			end
		end
	end
	strength = math.floor(strength)
	return strength
end

--判断该部位(placeId)是否解锁
--@placeId : 部位id
function planeRefitVoApi:isUnlockByPlaceId(placeId)
	if self.unlockPlaceId then
		for k, v in pairs(self.unlockPlaceId) do
			if v == placeId then
				return true
			end
		end
	end
	local strength = 0
	local planeList = planeVoApi:getPlaneList()
	for k, v in pairs(planeList) do
		strength = strength + v:getStrength()
	end
	local cfg = self:getCfg()
	return (strength >= cfg.requirement[placeId]), cfg.requirement[placeId]
end

--判断该技能(skillId)是否生效
--@skillId : 技能id（参考planeRefit.lua文件中的refitSkill）
function planeRefitVoApi:isValidBySkillId(skillId)
	local skillCfg = self:getSkillCfg(skillId)
	if skillCfg then
		local placeId = skillCfg.search[1]
		if self:isUnlockByPlaceId(placeId) then --该技能对应的部位已解锁
			if skillCfg.getType == 1 then --基础技能(根据改装点数默认生效)
				return true, skillCfg.search
			else --激活技能
				local planeId = skillCfg.search[2]
				local refitTypeIndex = skillCfg.search[3]
				local refitCfgData = self:getRefitTypeData(placeId, planeId, refitTypeIndex)
				if refitCfgData then
					local refitExp = self:getRefitExp(placeId, planeId, refitTypeIndex)
					for skillIndex, skillId_a in pairs(refitCfgData.skill2) do
						if skillId == skillId_a and refitExp >= refitCfgData.powerNeed[skillIndex] then --该技能已激活
							return true, skillCfg.search
						end
					end
				end
			end
		end
	end
	return false
end

--根据战机id来判断对应的增加技能槽位的技能是否解锁
--@planeId : 战机id
function planeRefitVoApi:isUnlockPlaneSkillSlot(planeId)
	if self:isCanEnter() == false then
		return
	end
	local cfg = self:getCfg()
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	local skillList = cfg.mirror[14] --约定类型为14的技能是增加战机技能槽位的技能(参考配置文件planeRefit.lua)
	if skillList == nil then
		return false
	end
	for kk, skillId in pairs(skillList) do
		local isValid, searchData = self:isValidBySkillId(skillId)
		if isValid then
			local placeId, planeId_a, refitTypeIndex = searchData[1], searchData[2], searchData[3]
			if planeId == planeId_a then
				local skillLv = 1
				local refitCfgData = self:getRefitTypeData(placeId, planeId, refitTypeIndex)
		        if refitCfgData then
		            for skillIndex, skillId_a in pairs(refitCfgData.skill2) do
		                if skillId == skillId_a then
		                    skillLv = self:getSkillLevel(placeId, planeId, refitTypeIndex, skillIndex)
		                    break
		                end
		            end
		        end
		        local refitExp = self:getRefitExp(placeId, planeId, refitTypeIndex)
		        local attrValue = self:getSkillAttributeValue(skillId, skillLv, refitExp)
				return true, attrValue, skillId
			end
		else
			local skillCfg = self:getSkillCfg(skillId)
			if skillCfg and planeId == skillCfg.search[2] then
				return false, skillCfg.search[1]
			end
		end
	end
	return false
end

--添加事件监听
--@listenerFunc : 触发事件的回调方法
function planeRefitVoApi:addEventListener(listenerFunc)
	if self:isCanEnter() == false then
		return
	end
	if type(listenerFunc) ~= "function" then
		return
	end
	if eventDispatcher:hasEventHandler("planeRefit.refit", listenerFunc) == false then
        eventDispatcher:addEventListener("planeRefit.refit", listenerFunc)
    end
end

--触发事件函数
--@eventType : 事件类型(1-改装数据发生变化时的事件,2-改装过程中核能升级时的事件,3-技能升级时的事件)
--@skillIdTb : 影响到的技能id表
--@params : 扩展参数表
function planeRefitVoApi:dispatchEvent(eventType, skillIdTb, params)
	local eventData = {
		eventType = eventType,
		sid = skillIdTb,
		params = params,
	}
	eventDispatcher:dispatchEvent("planeRefit.refit", eventData)
end

--移除事件监听
--@listenerFunc : 触发事件的回调方法
function planeRefitVoApi:removeEventListener(listenerFunc)
	if listenerFunc == nil then
		return
	end
	eventDispatcher:removeEventListener("planeRefit.refit", listenerFunc)
	listenerFunc = nil
end

--检测技能的激活和失效状态
--@placeId : 部位id
--@planeId : 战机id
--@prevRefitExpTb : 上一次的改装点数表数据
function planeRefitVoApi:checkSkillState(placeId, planeId, prevRefitExpTb)
	if type(prevRefitExpTb) ~= "table" then
		do return end
	end
	local skillStateTb, skillStateTbSize = {}, 0
	local cfg = self:getCfg()
	planeId = tonumber(planeId) or tonumber(RemoveFirstChar(planeId))
	for refitTypeIndex, v in ipairs(cfg.refit[placeId][planeId]) do
		local prevRefitExp = prevRefitExpTb[refitTypeIndex]
		if prevRefitExp then
			local curRefitExp = self:getRefitExp(placeId, planeId, refitTypeIndex)
			if prevRefitExp ~= curRefitExp then --改装点数发生变化
				--激活状态检测
				for skillIndex, needRefitExp in ipairs(v.powerNeed) do
					local nextNeedRefitExp = v.powerNeed[skillIndex + 1] or (needRefitExp + 1)
					if prevRefitExp < needRefitExp and curRefitExp >= needRefitExp and curRefitExp < nextNeedRefitExp then
						table.insert(skillStateTb, {skillId = v.skill2[skillIndex], state = 1})
						skillStateTbSize = skillStateTbSize + 1
					end
				end
				--失效状态检测
				for skillIndex = table.maxn(v.powerNeed), 1, -1 do
					local prevNeedRefitExp = v.powerNeed[skillIndex - 1] or 0
					local needRefitExp = v.powerNeed[skillIndex]
					if prevRefitExp >= needRefitExp and curRefitExp < needRefitExp and curRefitExp >= prevNeedRefitExp then
						table.insert(skillStateTb, {skillId = v.skill2[skillIndex], state = 0})
						skillStateTbSize = skillStateTbSize + 1
					end
				end
			end
		end
	end

	local skillIconSize = 60
	local function createSkillItem(stateData)
		local skillCfg = self:getSkillCfg(stateData.skillId)
		if skillCfg then
			local stateStr = (stateData.state == 1) and getlocal("activation") or getlocal("planeRefit_notValidText")
			local skillBg = LuaCCScale9Sprite:createWithSpriteFrameName("newTipDi.png", CCRect(0, 50, 1, 1), function()end)
			skillBg:setContentSize(CCSize(300, 55))
			local skillIcon = (stateData.state == 1) and CCSprite:createWithSpriteFrameName(skillCfg.icon) or GraySprite:createWithSpriteFrameName(skillCfg.icon)
			skillIcon:setScale(skillIconSize / skillIcon:getContentSize().width)
			skillIcon:setPosition(20, skillBg:getContentSize().height / 2)
			skillBg:addChild(skillIcon)
			local skillNameLb = GetTTFLabelWrap(getlocal(skillCfg.skillName) .. stateStr, 25, CCSizeMake(255, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
			skillNameLb:setAnchorPoint(ccp(0, 0.5))
			skillNameLb:setPosition(skillIcon:getPositionX() + skillIconSize / 2 + 10, skillBg:getContentSize().height / 2)
			skillNameLb:setColor((stateData.state == 1) and G_ColorGreen or G_ColorWhite)
			skillBg:addChild(skillNameLb)
			return skillBg
		end
	end
	local skillItemSpaceH = 20
	local posY = (G_VisibleSizeHeight - (skillStateTbSize * skillIconSize + (skillStateTbSize - 1) * skillItemSpaceH)) / 2
	for k, v in ipairs(skillStateTb) do
		local skillItem = createSkillItem(v)
		if skillItem then
			skillItem:setPosition(G_VisibleSizeWidth + skillItem:getContentSize().width, posY + skillIconSize / 2)
			sceneGame:addChild(skillItem, 99)
			local skillItemSeqArr = CCArray:create()
			skillItemSeqArr:addObject(CCDelayTime:create(0.1 * k))
			skillItemSeqArr:addObject(CCMoveTo:create(0.5, ccp(G_VisibleSizeWidth / 2, skillItem:getPositionY())))
			skillItemSeqArr:addObject(CCDelayTime:create(1))
			skillItemSeqArr:addObject(CCCallFunc:create(function()
				skillItem:removeFromParentAndCleanup(true)
				skillItem = nil
			end))
			skillItem:runAction(CCSequence:create(skillItemSeqArr))
			posY = posY + skillIconSize + skillItemSpaceH
		end
	end
end

--初始化技能属性映射表
function planeRefitVoApi:initSkvMap()
	if self.skvMap == nil then
		self.skvMap = {}
	end
	local rcfg = planeRefitVoApi:getCfg()
	for k,v in pairs(rcfg.mirror) do
		if self.skvMap[k] == nil and k >= 51 then
			self.skvMap[k] = planeRefitVoApi:getSkillAttribute(k)
		end
	end
end

function planeRefitVoApi:getSkvMap()
	return (self.skvMap or {})
end

function planeRefitVoApi:setSkvByType(skvtype, skv)
	if skv and tonumber(skv) then
		if self.skvMap == nil then
			self.skvMap = {}
		end
		local sv = tonumber(skv)
		skv = sv < 0 and 0 or sv
		self.skvMap[skvtype] = skv
	end
end

--获取技能的属性值
function planeRefitVoApi:getSkvByType(skvtype)
	if self.skvMap == nil then --数据没有初始化则直接返回
		do return 0 end
	end
	if self.skvMap[skvtype] then
		return self.skvMap[skvtype]
	end
	return 0
end

function planeRefitVoApi:clear()
	self.isFirst = nil
	self.chargeResCount = nil
	self.chargeGoldCount = nil
	self.chargeCostResIndex = nil
	self.energyLevel = nil
	self.energyExp = nil
	self.refitCount = nil
	self.unlockPlaceId = nil
	self.refitExp = nil
	self.refitTempExp = nil
	self.skillLevelData = nil
	self.skvMap = nil
end