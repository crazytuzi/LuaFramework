-- @Author: liaoxianbo
-- @Date:   2020-10-23 15:43:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 11:49:23

local QActivityRoundsBaseChild = import(".QActivityRoundsBaseChild")
local QActivityCustomShop = class("QActivityCustomShop",QActivityRoundsBaseChild)

local QNotificationCenter = import("..controllers.QNotificationCenter")
local QVIPUtil = import(".QVIPUtil")
local QActivity = import(".QActivity")
local QUIViewController = import("..ui.QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")

QActivityCustomShop.RECHARGE_ACTION = 1 --充值
QActivityCustomShop.FREEGET_ACTION = 2 -- 领取
QActivityCustomShop.NOTCUSTOM_ACTION = 3 -- 未订制

function QActivityCustomShop:ctor(luckType)
    QActivityCustomShop.super.ctor(self,luckType)
    cc.GameObject.extend(self)

    self._customShopList = {}	--商店物品
    self._customShopContent = {} --礼品池
    self._giftInfo = {} --从后端获取礼包记录
end

function QActivityCustomShop:timeRefresh( event )
	-- body
	if event.time and event.time == 0 then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})
	end
end

function QActivityCustomShop:activityShowEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})
end

function QActivityCustomShop:activityEndCallBack(  )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})
end

function QActivityCustomShop:handleOnLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})
end

function QActivityCustomShop:handleOffLine( )
	-- body
	remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})
end

function QActivityCustomShop:getActivityInfoWhenLogin( success, fail )
	if self.isOpen then
		self:_loadActivity()
    	self:requestMyCustomInfo(success, fail)
    end
end



function QActivityCustomShop:checkCustomIsOpen()
	return self.isOpen
end

--giftType 1 付费 2 充值
function QActivityCustomShop:checkPayGiftTipsByType(giftType)
	local allItemList = self:getCustomShopList()
	for _,v in pairs(allItemList) do
		if giftType == v.type then
			local itemInfo = self:analyGiftInfoServerItem(v)
			if q.isEmpty(itemInfo) == false then
				if itemInfo.btnState == QActivityCustomShop.FREEGET_ACTION and v.type == 1 then --付费可领取
					return true
				end

				if itemInfo.isFree == true and itemInfo.sellout == false then --免费未订制或领取
					return true
				end
			end
		end
	end

	return false
end

function QActivityCustomShop:checkRedTips()
	if not self:checkCustomIsOpen() then
		return false
	end

	if self:checkPayGiftTipsByType(1) or self:checkPayGiftTipsByType(2) then
		return true
	end

	return false
end

function QActivityCustomShop:openDialog()
	if not self:checkCustomIsOpen() then
		return
	end

	self:requestMyCustomInfo(function( )
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityCustomShop"})
	end)	
end


-------------------数据相关处理-------------------------------
function QActivityCustomShop:getCustomShopList( )
	self.rowNum = 1
	if q.isEmpty(self._customShopList) then
		local customShopList = db:getStaticByName("custom_shop")
		self._customShopList = customShopList[tostring(self.rowNum)]

		table.sort( self._customShopList, function(a,b)
			if a.id ~= b.id then
				return a.id < b.id
			end
		end )
	end

	return self._customShopList
end

function QActivityCustomShop:getCustomShopContent()
	if q.isEmpty(self._customShopContent) then
		self._customShopContent = db:getStaticByName("custom_item_content")
	end

	return self._customShopContent
end

function QActivityCustomShop:getCustomShopContentById(id)
	local customShopContent = self:getCustomShopContent()
	for _,v in pairs(customShopContent) do
		if v.id == id then
			return self:analysisServerItem(v.item_content) 
		end
	end

	return {}
end

--解析后台的item字符串
function QActivityCustomShop:analysisServerItem(itemStr, tbl)
	if tbl == nil then tbl = {} end
	if itemStr == nil or itemStr == "" then
		return tbl
	end
	local items = string.split(itemStr, ";")
    if items and table.nums(items) > 0 then
    	for _,v1 in ipairs(items) do
    		if v1 ~= nil and v1 ~= "" then
	    		local v2 = string.split(v1, "^")
	    		if v2 ~= nil and table.nums(v2) > 1 then
	    			local typeName = remote.items:getItemType(v2[1])
	    			if typeName == nil then
	    				typeName = ITEM_TYPE.ITEM
	    				table.insert(tbl, {id = tonumber(v2[1]), typeName = typeName, count = tonumber(v2[2])})
	    			else
	    				table.insert(tbl, {typeName = v2[1], count = tonumber(v2[2])})
	    			end
	    		end
	    	end
    	end
    end
    return tbl
end

function QActivityCustomShop:getRechargeInfo(recharge_buy_productid)
	local rechargeConfig = db:getRecharge()
	for _,v in pairs(rechargeConfig) do
		if v.recharge_buy_productid == recharge_buy_productid then
			return v
		end
	end
	return nil
end

function QActivityCustomShop:getServerGiftInfoById(id)
	for _,v in pairs(self._giftInfo or {}) do
		if v.giftId == id then
			return v
		end
	end 
	return {}
end

function QActivityCustomShop:analyGiftInfoServerItem(itemData)
	if q.isEmpty(itemData) then return {} end
	local itemInfo = {}
	
	itemInfo.itemConfig = itemData
	itemInfo.isFree = false
	if itemData.price == 0 or itemData.price == nil then
		itemInfo.isFree = true
	end
	itemInfo.sellout = false
	local maxBuyNum = itemData.max_buy_num or 0
	local serverInfo = self:getServerGiftInfoById(itemData.id)
	if q.isEmpty(serverInfo) == false then
		itemInfo.curItemList = self:getServerGiftInfoItemByIdType(itemData.id,1)
		local buyNums = serverInfo.awardCount or 0
		local completeCount = serverInfo.completeCount or 0
		itemInfo.buyNums = buyNums
		itemInfo.completeCount = completeCount
		itemInfo.btnState = QActivityCustomShop.NOTCUSTOM_ACTION
		if serverInfo.currItem and serverInfo.currItem ~= "" then
			if (itemData.price == 0 or itemData.price == nil) or itemData.type == 2 then
				itemInfo.btnState = QActivityCustomShop.FREEGET_ACTION
			else
				if buyNums < completeCount then
					itemInfo.btnState = QActivityCustomShop.FREEGET_ACTION
				else
					itemInfo.btnState = QActivityCustomShop.RECHARGE_ACTION
				end
			end
		end

		if buyNums >= maxBuyNum then
			itemInfo.sellout = true
		end
	end

	return itemInfo
end

--[[
	id--
	typeStr 1:当前记录 2:历史记录
]]
function QActivityCustomShop:getServerGiftInfoItemByIdType(id,typeStr)
	local currItems = {}
	for _,v in pairs(self._giftInfo or {}) do
		local analyItemStr = nil
		if typeStr == 1 then
			analyItemStr = v.currItem or ""
		elseif typeStr == 2 then
			analyItemStr = v.historyItem or ""
		end
		if v.giftId == id and analyItemStr ~= "" then
			local alltbl = string.split(analyItemStr,";")
			for _,str in pairs(alltbl) do
				local tbl = string.split(str,",")
				local itemStr = tbl[1] or ""
				local poolId = tonumber(tbl[2]) or 0
				local chooseItemInfo = {}
				chooseItemInfo.itemData = {}
				chooseItemInfo.poolId = poolId

				if itemStr or itemStr ~= "" then
		    		local v2 = string.split(itemStr, "^")
		    		if v2 ~= nil and table.nums(v2) > 1 then
		    			local typeName = remote.items:getItemType(v2[1])
		    			if typeName == nil then
		    				typeName = ITEM_TYPE.ITEM
		    				chooseItemInfo.itemData = {id = tonumber(v2[1]), typeName = typeName, count = tonumber(v2[2])}
		    			else
		    				chooseItemInfo.itemData = {typeName = v2[1], count = tonumber(v2[2])}
		    			end
		    		end
				end
				table.insert(currItems,chooseItemInfo)
			end
		end
	end 

	table.sort(currItems,function(a,b)
		return a.poolId < b.poolId
	end)
	return currItems
end

-- 加入到活動數據裡，讓主界面顯示icon
function QActivityCustomShop:_loadActivity()
    if self.isOpen then
        local activities = {}
        local themeInfo = db:getActivityThemeInfoById(QActivity.THEME_ACTIVITY_CUSTOM_SHOP) or {}
        table.insert(activities, {
            activityId = self.activityId, 
            title = (themeInfo.title or "尚未配表"), 
            roundType = "CUSTOM_SHOP",
            start_at = self.startAt * 1000, 
            end_at = self.endAt * 1000,
            award_at = self.startAt * 1000, 
            award_end_at = self.showEndAt * 1000, 
            weight = 20, 
            targets = {}, 
            subject = QActivity.THEME_ACTIVITY_CUSTOM_SHOP})
        remote.activity:setData(activities)
    else
        remote.activity:removeActivity(self.activityId)
    end
end

-----------------request--------------------------
function QActivityCustomShop:responseHandler( response, successFunc, failFunc )

	if response.CustomShopInfoResponse and response.CustomShopInfoResponse.userInfo then
		for _,v in pairs(response.CustomShopInfoResponse.userInfo.giftInfo or {}) do
			self._giftInfo[v.giftId] = v
		end
	end

	remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_UPDATE})

    if successFunc then 
        successFunc(response) 
        return
    end

    if failFunc then 
        failFunc(response)
    end
end

--请求主界面信息
function QActivityCustomShop:requestMyCustomInfo( success, fail, status )
    local request = { api = "CUSTOM_SHOP_MAIN_INFO"}
    app:getClient():requestPackageHandler("CUSTOM_SHOP_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--选取礼包
function QActivityCustomShop:customShopChooseGiftRequest(typeId,giftId,currItem,success, fail, status)
    local request = { api = "CUSTOM_SHOP_CHOOSE_GIFT",CustomShopChooseGiftRequest = {typeId = typeId,giftId = giftId,currItem = currItem}}
    app:getClient():requestPackageHandler("CUSTOM_SHOP_CHOOSE_GIFT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--领取礼包
function QActivityCustomShop:customShopReceiveGiftRequest(typeId,giftId,success, fail, status)
    local request = { api = "CUSTOM_SHOP_RECEIVE_GIFT",CustomShopReceiveGiftRequest = {typeId = typeId,giftId = giftId}}
    app:getClient():requestPackageHandler("CUSTOM_SHOP_RECEIVE_GIFT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QActivityCustomShop