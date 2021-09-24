supplyShopVoApi = {}

function supplyShopVoApi:getOpenLv()
    local supplyShopCfg = self:getSupplyShopCfg()
    if supplyShopCfg and supplyShopCfg.openLv then
        return supplyShopCfg.openLv
    end
    return 0
end

function supplyShopVoApi:isOpen()
	if base.bjSwitch == 1 and playerVoApi:getPlayerLevel() >= self:getOpenLv() then
		return true
	end
	return false
end

function supplyShopVoApi:getSupplyShopCfg()
	local supplyShopCfg = G_requireLua("config/gameconfig/bjshop")
	return supplyShopCfg
end

--显示补给商店主界面
function supplyShopVoApi:showSupplyShopDialog(layerNum)
	self:requestData(function()
		require "luascript/script/game/scene/gamedialog/supplyShopDialog"
		supplyShopDialog:showSupplyShopDialog(layerNum, getlocal("supplyShop_titleText"))
		if otherGuideMgr.isGuiding and otherGuideMgr.curStep and otherGuideMgr.curStep == 82 then
	    	otherGuideMgr:endNewGuid()
	    end
	end)
end

function supplyShopVoApi:initData(data)
	if self.tabData == nil then
		self.tabData = {}
	end
	local supplyShopCfg = self:getSupplyShopCfg()
	self.tabData[2] = {
		itemData = {}, 	  --物品数据
		customNum = 0, 	  --定制次数
		cdTimer = 0  	  --CD时间戳
	}
	self.tabData[2].itemData = supplyShopCfg.spConfig
	if data then
		if data.bjshop then
			self.tabData[2].customNum = data.bjshop[1]
			self.tabData[2].cdTimer = data.bjshop[6]

			local customType = data.bjshop[2] --定制类型(spConfig的id、spStoreList的id)
			local storeListId = data.bjshop[3]--具体的商店id(spStoreList的第二层id)
			if customType > 0 and storeListId > 0 then
				self.tabData[3] = {
					itemData = {}, --物品数据
					customType = customType,
					doubleNum = data.bjshop[4], --翻倍次数
				}
				local spStoreList = supplyShopCfg.spStoreList[customType][storeListId]
				for k, v in pairs(data.bjshop[5]) do
					local spStoreData = spStoreList[tonumber(k)]
					table.insert(self.tabData[3].itemData, { id = spStoreData.id, dis = spStoreData.dis, costItem = spStoreData.p, rewardItem = spStoreData.r, buyNum = v })
				end
				table.sort(self.tabData[3].itemData, function(a, b) return a.id < b.id end)
			end
		end
		if data.bjresouce then
			self.tabData[1] = {
				itemData = {}, --物品数据
				cdTimer = data.bjresouce[3] --CD时间戳
			}
			local rslData = supplyShopCfg.resStoreList[data.bjresouce[1]]
			for k, v in pairs(data.bjresouce[2]) do
				local key = Split(k, "_")
				local rslItemData = rslData[tonumber(key[1])]
				self.tabData[1].itemData[tonumber(key[2])] = { id = rslItemData.id, costItem = rslItemData.p, rewardItem = rslItemData.r, buyNum = v }
			end
		end
	end
end

--初始化CD时间
function supplyShopVoApi:initCDTimer(cdTimerTb)
	if self.tabData == nil then
		self.tabData = {}
	end
	for k, cdTimer in pairs(cdTimerTb) do
		if self.tabData[k] == nil then
			self.tabData[k] = {}
		end
		self.tabData[k].cdTimer = cdTimer
	end
end

--重置定购次数
function supplyShopVoApi:resetCustomNum()
	if self.tabData and self.tabData[2] then
		self.tabData[2].customNum = 0
	end
end

--补给商店数据
function supplyShopVoApi:requestData(callback)
	local function socketCallback(fn, data)
		local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	self:initData(sData.data)
            	if callback then
            		callback()
            	end
            end
        end
    end
	socketHelper:supplyShopGet(socketCallback)
end

--补给商店购买
--@ stype:1 资源 2商店,   sid:商品id（资源特殊处理）
function supplyShopVoApi:requestBuy(callback, stype, sid)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if callback then
                    callback()
                end
            end
        end
    end
	socketHelper:supplyShopBuy(socketCallback, stype, sid)
end

--补给商店订购
--@ spid:定制商店类型(id)
function supplyShopVoApi:requestCustomBuy(callback, spid)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if callback then
                    callback()
                end
            end
        end
    end
	socketHelper:supplyShopCustomBuy(socketCallback, spid)
end

--补给商店翻倍
--@ spid:定制商店类型(id)
function supplyShopVoApi:requestDouble(callback, spid)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
                self:initData(sData.data)
                if callback then
                    callback()
                end
            end
        end
    end
	socketHelper:supplyShopDouble(socketCallback, spid)
end

function supplyShopVoApi:getTabData(tabIndex)
	if self.tabData and self.tabData[tabIndex] then
		return self.tabData[tabIndex]
	end
end

--获取最大补货(定购)次数
function supplyShopVoApi:getMaxCustomNum()
	local supplyShopCfg = self:getSupplyShopCfg()
	return supplyShopCfg.spRefreshNum
end

--获取补货(定购)价格
--@ customNum:定购次数
function supplyShopVoApi:getCustomPrice(customNum)
	local maxCustomNum = self:getMaxCustomNum()
	local supplyShopCfg = self:getSupplyShopCfg()
    local costPrice = supplyShopCfg.spRefreshCost[customNum + 1]
    if customNum + 1 > maxCustomNum then
        costPrice = supplyShopCfg.spRefreshCost[maxCustomNum]
    end
    return costPrice
end

--获取翻倍价格，最大翻倍次数
--@ spcId:定购类型(spConfig的id), doubleNum:当前已翻倍次数
function supplyShopVoApi:getDoublePrice(spcId, doubleNum)
	local supplyShopCfg = self:getSupplyShopCfg()
	local spCfg = supplyShopCfg.spConfig[spcId]
	if spCfg then
		local maxDoubleNum = SizeOfTable(spCfg.rCost) --最大翻倍次数
		if doubleNum - 1 >= maxDoubleNum then
			return spCfg.rCost[maxDoubleNum], maxDoubleNum
		else
			return spCfg.rCost[doubleNum], maxDoubleNum
		end
	end
	return 0
end

function supplyShopVoApi:tick()
	local isShowTips = false
	if self.tabData then
		for k = 1, 2 do
			if self.tabData[k] and self.tabData[k].cdTimer and self.tabData[k].cdTimer < base.serverTime then
				isShowTips = true
				break
			end
		end
	end
	if isShowTips then
		portScene:addSupplyShopCopterTips()
	else
		portScene:removeSupplyShopCopterTips()
	end
end

function supplyShopVoApi:clear()
	self.tabData = nil
end