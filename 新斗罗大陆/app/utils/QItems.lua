--
-- Author: Your Name
-- Date: 2014-06-05 11:13:26
--
local QBaseModel = import("..models.QBaseModel")
local QItems = class("QItems",QBaseModel)

local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")
local QActorProp = import("..models.QActorProp")
local QNavigationController = import("..controllers.QNavigationController")

QItems.EVENT_ITEMS_UPDATE = "EVENT_ITEMS_UPDATE"
QItems.EVENT_ITEMS_TAVERN_UPDATE = "EVENT_ITEMS_TAVERN_UPDATE"

QItems.EXP_ITEMS = {3,4,5,6}

function QItems:ctor(options)
	QItems.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._items = {}
	self._oldItems = {}
	self._composeItems = {}
	self._isInitComposeItem = false
	self._materialItems = nil
	self._rewards = {}
	self._addItems = {}
	self._cnames = {}
	self._itemsAddCount = {}	-- 每次变化增加情况
end

function QItems:init()
	self._itemCrafts = QStaticDatabase:sharedDatabase():getItemCraft()
	self:initMaterialItem()
end

function QItems:setItems(items, api)
	self._itemsAddCount = {}
	local curTime = q.serverTime()
	for _,value in pairs(items) do
		-- 是否屏蔽道具（主要是碎片）
		if db:checkItemShields(value.type) then
			self._items[value.type] = nil
		elseif value.count == 0 then
        	self._items[value.type] = nil
		else
        	self._items[value.type] = value
    	end

    	local expireTime = value.expireTime or 0
    	if expireTime > 0 and (expireTime/1000) < curTime then
	    	self._items[value.type] = nil
	    end
    	self:updateOldItems(value)
    end

    -- 增加道具活动更新
    self:updateActivityAddItems(api)

	local time = q.serverTime()
	self:countComposeItem(items)
    self:dispatchEvent({name = QItems.EVENT_ITEMS_UPDATE})
    printInfo("self:dispatchEvent({name = QRemote.EVENT_ITEMS_UPDATE})")
end

--建立材料和合成对象的反序对应关系
function QItems:initMaterialItem()
	if self._materialItems == nil then
		self._materialItems = {}
		self._itemCrafts = QStaticDatabase:sharedDatabase():getItemCraft()
		for _,item in pairs(self._itemCrafts) do
			local index = 1
			while true do
				local itemId = item["component_id_"..index]
				if itemId == nil then
					break
				end
				if self._materialItems[itemId] == nil then
					self._materialItems[itemId] = {}
				end
				table.insert(self._materialItems[itemId], item)
				index = index + 1
			end
		end
	end
end

--获取材料可合成的物品
function QItems:getItemsByMaterialId(materialId)
	return self._materialItems[materialId]
end

function QItems:getOldItems()
	return self._oldItems
end

function QItems:updateOldItems(value)
	local item = self._oldItems[value.type]
	if item then
		if item.count < value.count then
			self:updateAddItems(value.type, value.count - item.count)
		else
			self:updateDelItems(value.type, item.count - value.count)
		end
		item.count = value.count
	else
		self:updateAddItems(value.type, value.count)
		self._oldItems[value.type] = clone(value)
	end
end

function QItems:updateActivityAddItems(api)
	-- 收集类活动
	remote.activity:updateLocalDataByType(401, self._itemsAddCount)

	if api == "ACITVITY_COMPLETE" or api == "ITEM_OPEN" or api == "ITEM_CHOOSE" then
		-- QActivity.TYPE_ACTIVITY_TARGET_ITEM 类型的活动，需要维护获得道具，但是仅针对几个接口进行维护
		remote.activity:updateLocalDataByType(remote.activity.TYPE_ACTIVITY_TARGET_ITEM, self._itemsAddCount)
	end
end

--[[
@name 提前计算物品的合成信息
@tips 此处忽略装备的前后关系
]]
function QItems:countComposeItem(items)
	self._count = 0
	self._countFun = function (item, useItem)
		local floorCount = nil
		local index = 1
		while true do
			local itemId = item["component_id_"..index]
			local itemCount = 0
			if itemId == nil then
				break
			end
			if useItem[itemId] == nil then useItem[itemId] = 0 end
			itemCount = self:getItemsNumByID(itemId) - useItem[itemId]
			if self._composeItems[itemId] ~= nil then
				itemCount = itemCount + self._composeItems[itemId]
			else
				local childItem = self._itemCrafts[itemId]
				if childItem ~= nil then
					self._composeItems[itemId] = self._countFun(childItem, useItem)
				end
			end
			itemCount = math.floor(itemCount/item["component_num_"..index])
			useItem[itemId] = useItem[itemId] + itemCount * item["component_num_"..index]
			if floorCount == nil then
				floorCount = itemCount
			elseif floorCount > itemCount then
				floorCount = itemCount
			end
			index = index + 1
			self._count = self._count + 1
		end
		return floorCount or 0
	end
	if self._isInitComposeItem == false then
		self._isInitComposeItem = true
		self._composeItems = {}
		for index,item in pairs(self._itemCrafts) do
			if self._composeItems[item.item_id] == nil then
				local useItem = {}
				self._composeItems[item.item_id] = self._countFun(item, useItem)
			end
		end
	else
		local needCountItems = {}
		self._getNeedCountItems = function(items)
			local currentComposeItems = {}
			for _,item in pairs(items) do
				local id = item.type or item.item_id
				local composeItems = self._materialItems[id]
				if composeItems ~= nil then
					for _,value in pairs(composeItems) do
						self._composeItems[value.item_id] = nil
						table.insert(needCountItems, value)
						table.insert(currentComposeItems, value)
					end
				end
			end
			if next(currentComposeItems) ~= nil then
				self._getNeedCountItems(currentComposeItems)
			end
		end
		self._getNeedCountItems(items)
		for _,item in pairs(needCountItems) do
			local useItem = {}
			self._composeItems[item.item_id] = self._countFun(item, useItem)
		end
	end
end

function QItems:updateAddItems(id, count)
	self._itemsAddCount[id] = count
	if self._addItems[id] == nil then
		self._addItems[id] = {type = id, count = count}
	else
		self._addItems[id].count = self._addItems[id].count + count
	end
	--占卜活动 
	if id == 40 then
		local imp = remote.activityRounds:getDivination()
		if imp and imp.isOpen then
			remote.redTips:setTipsStateByName("QUIActivityDialogDivination_DivinationTips", imp:checkDivinationItemRedTips())
		end
	end
end

function QItems:updateDelItems(id,count)
	local activityInfo = remote.activity:getActivityDataByTagetId(202)
	local haveActivityFlag = false
	if activityInfo and activityInfo.targets then	 
		for _,info in pairs(activityInfo.targets) do
			if tonumber(info.value2) ~= nil and tonumber(id) == tonumber(info.value2) then 
				haveActivityFlag = true
			end
		end
	end
	if haveActivityFlag then
		remote.activity:updateLocalDataByType(202, count)
	end
end
--[[
	获取某个物品登陆之后增加的数量
]]
function QItems:getItemAddNumByItemId(id)
	local oldNum = 0
	for _,value in pairs(self._addItems) do
		if value.type == id then
			return value.count
		end
	end
	return 0
end

--[[
	根据item类型（配置表中的）获取物品
]]
function QItems:getItemsByCategory( ... )
	local data = {...}
	local tbl = {}
	local items = clone(self._items)
	
	for key,value in pairs(items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
		assert(itemInfo, string.format("Item %s can't be found in item table", value.type))

		local isHave = false
		for _, value in pairs(data) do
			if itemInfo.category == value then
				isHave = true
				break
			end
		end
        if itemInfo and isHave then
			self:_checkItemsByGrids(value,tbl)
        end
    end	
    return tbl
end

--[[
	根据item类型（配置表中的）获取物品
]]
function QItems:getItemsByType(typeName)
	local tbl = {}
	local items = clone(self._items)
	if typeName ~= nil then
		for key,value in pairs(items) do
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
	        if itemInfo ~= nil and itemInfo.type == typeName then
				table.insert(tbl, value)
	        end
	    end
	else
		for _,value in pairs(items) do
			table.insert(tbl, value)
		end
	end
    return tbl
end

--[[
	传入Items队列根据最大值进行分格
]]
function QItems:_checkItemsByGrids(value, tbl)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
	if itemInfo == nil then 
		assert(false, "item id : "..value.type.." can't find in item config, please call terry!!!")
	end
	while true do
		if itemInfo.grid_limit ~= nil and itemInfo.grid_limit < (value.count or 0) then
			local valueTemp = clone(value)
			valueTemp.count = itemInfo.grid_limit
			table.insert(tbl, valueTemp)
			value.count = value.count - itemInfo.grid_limit
		else
			table.insert(tbl, value)
			break
		end
	end
end

-- 检测是否有礼包类型的道具
function QItems:checkHaveGiftItems(  )
	-- body
	local itemCount = {}
	for _,value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
	    if itemInfo ~= nil and itemInfo.type == 6 or itemInfo.type == 7 or itemInfo.type == 8 or itemInfo.type == 11 then
	    	table.insert(itemCount, itemInfo.id)
	    end
	end
	if #itemCount >= 5 then
		return itemCount[1]
	end
end

-- 检测有道具过期
function QItems:updateOverdueItems( )
	-- body
	local needUpdate = false
	local curTime = q.serverTime()
	for id, value in pairs(self._items) do
    	local expireTime = value.expireTime or 0
	    if expireTime > 0 and (expireTime/1000) < curTime then
	    	self._items[id] = nil
	    	needUpdate = true
	    end
	end

	if needUpdate then
    	self:dispatchEvent({name = QItems.EVENT_ITEMS_UPDATE})
	end
end

-- 检测有道具过期
function QItems:checkOverdueItems( )
	-- body
	local overdue = false
	local curTime = q.serverTime()
	for id, value in pairs(self._items) do
    	local expireTime = value.expireTime or 0
	    if expireTime > 0 then
	    	local diffTime = (expireTime/1000) - curTime
	    	if diffTime <= DAY then
	    		self._items[id].overdue = true
	    		overdue = true
	    	end 
	    end
	end

	return overdue
end

--[[
	得到所有可以觉醒的物品
]]
function QItems:getAllEnchantMaterial()
	local tbl = {}
	for key,value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.enchant_value ~= nil and itemInfo.enchant_value > 0 then
        	value.item_type = itemInfo.type
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的物品
]]
function QItems:getAllRecycleMaterial()
	local tbl = {}
	for key,value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.MATERIAL and (itemInfo.soul_recycle or 0) > 0 then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的碎片
]]
function QItems:getAllRecycleFragment()
	local tbl = {}
	for key,value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.SOUL and (itemInfo.soul_recycle or 0) > 0 and itemInfo.colour ~= ITEM_QUALITY_INDEX.RED then
        	table.insert(tbl, value)
        end
    end
    return tbl
end


--[[
	得到所有可以回收的觉醒
]]
function QItems:getAllRecycleEnchant()
	local tbl = {}
	for key,value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and (itemInfo.score_recyle or 0) > 0 then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的宝石碎片
]]
function QItems:getAllGemFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的暗器碎片
]]
function QItems:getAllMountFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.ZUOQI and itemInfo.gemstone_quality ~= APTITUDE.SSR then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的晶石碎片
]]
function QItems:getAllSparFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.SPAR_PIECE then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的神器碎片
]]
function QItems:getAllGodarmFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
        if itemInfo and itemInfo.category == ITEM_CONFIG_CATEGORY.GODARM_PIECE and itemInfo.gemstone_quality ~= APTITUDE.SS then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的真身精华
]]
function QItems:getAllArtifactFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = db:getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.ARTIFACT_PIECE and itemInfo.id == 14000000 then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以回收的魂灵碎片
]]
function QItems:getAllSoulSpiritFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = db:getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以升星SS魂师的碎片
]]
function QItems:getAllSuperGradeFragment()
	local tbl = {}
	for key, value in pairs(self._items) do
		local itemInfo = db:getItemByID(value.type)
        if itemInfo and itemInfo.type == ITEM_CONFIG_TYPE.SOUL and itemInfo.colour == 5 then
        	table.insert(tbl, value)
        end
    end
    return tbl
end

--[[
	得到所有可以重生的觉醒饰品及本地量表信息
]]
function QItems:getAllAwakeningRebirth()
	local tbl = {}
	for key, value in pairs(self._items) do
		if value.count > 0 then
			local itemInfo = db:getItemByID(value.type)
			if itemInfo and itemInfo.item_recycle and itemInfo.score_recyle then
				local decompose = self:analysisServerItem(itemInfo.item_recycle)
				table.insert(tbl, {
					id = value.type, 
					count = value.count,
					selectedCount = 0,
					decompose = decompose
				})
			end
		end
	end
	table.sort(tbl, function(x, y)
        return x.id < y.id
    end)
    return tbl
end

--[[
@name 获取物品数量
@param id 物品的ID
]]

function QItems:getItemsNumByID(id)
	if id == nil then
		return 0
	end
	id = tonumber(id)
	if self._items[id] then
		return self._items[id].count or 0
	end
	return 0
end

--[[
@name 获取物品信息
@param id 物品的ID
]]

function QItems:getItemByID(id)
	if id == nil then
		return nil
	end
	id = tonumber(id)
	return self._items[id]
end

--[[
@name 获取物品合成数量
@param id 物品的ID
]]
function QItems:getItemsComposeNumByID(id)
	if id == nil then
		return 0
	end
	id = tonumber(id)
	local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(id)
	local composeCount = nil
	if itemCraftConfig ~= nil then
		if itemCraftConfig.money_type ~= nil then
			composeCount = self:getItemMoneyIsHaveNumByID(id)
		end
		if itemCraftConfig.component_id_1 == nil then
			return composeCount or 0
		end
	end
	if self._composeItems ~= nil then
		if composeCount == nil then
			return self._composeItems[id] or 0
		else
			return composeCount > (self._composeItems[id] or 0) and (self._composeItems[id] or 0) or composeCount
		end
	end
end

-- @param dispatchEvent 是否dispatch EVENT_ITEMS_UPDATE, 不填为true  Author:xurui   
function QItems:removeItemsByID(id, count, dispatchEvent)
	id = tonumber(id)
	local isDispatch = true
	if dispatchEvent ~= nil then isDispatch = dispatchEvent end

	for _,itemInfo in pairs(self._items) do
		if itemInfo.type == id then
			if (itemInfo.count - count) >= 0 then
				itemInfo.count = itemInfo.count - count
				if isDispatch then
    				self:dispatchEvent({name = QItems.EVENT_ITEMS_UPDATE})
    			end
				return true
			else
				return false
			end
		end
	end 
	return false
end

--检查是否拥有指定ID和数量的物品 检查合成的材料
--@param id  物品ID
--@param num 所需数量
--@param isOnlyComposite 仅检查合成
function QItems:getItemIsHaveNumByID(id,num,isOnlyComposite)
	local haveNum = 0
	local compositeNum = 0
	-- local isEnough = true
	if id ~= nil then 
		--获取拥有成品数量
		if isOnlyComposite ~= true then
			haveNum = self:getItemsNumByID(id)
		end
		compositeNum = self:getItemsComposeNumByID(id)
	end

	if haveNum >= num then
		return true,false
	end
	if (haveNum+compositeNum) >= num then
		return true,true
	end 
	return false,compositeNum > 0
end

--检查指定物品合成所需的货币是否齐全非金魂币
--@param id  物品ID
function QItems:getItemMoneyIsHaveNumByID(id)
	local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(id)
	if itemCraftConfig.money_type ~= nil then
		local typeName = self:getWalletByType(itemCraftConfig.money_type).name
		return math.floor((remote.user[typeName] or 0)/itemCraftConfig.money_num)
	end
	return nil
end

--检查物品或者物品碎片是否可以打关卡掉落
function QItems:getItemIsCanDrop(id)
	local dropInfo = remote.instance:getDropInfoByItemId(id, DUNGEON_TYPE.ALL)
	for _,value in pairs(dropInfo) do
		if value.map.isLock == true and remote.user.level >= (value.map.unlock_team_level or 0) then
			local isPass = false
			if value.map.info ~= nil and value.map.info.lastPassAt ~= nil and value.map.info.lastPassAt > 0 then
				isPass = true
			end
			return true,isPass
		end
	end
	return false,false
end

--检查物品是否可以打关卡掉落 检查合成碎片
function QItems:getComposeItemIsCanDrop(itemId, needCount)
	local isCanDrop = false
	local isPass = false
	if needCount ~= nil then
		if self:getItemsNumByID(itemId) >= needCount then
			return isCanDrop,isPass
		end
	end
	local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(itemId)
	if itemCraftConfig == nil then
		isCanDrop,isPass = remote.items:getItemIsCanDrop(itemId)
		if isCanDrop and isPass then
			return isCanDrop,isPass
		end
	else
		local index = 0
		while true do
			index = index + 1
			local materialId = itemCraftConfig["component_id_"..index]
			if materialId == nil then break end
			if QStaticDatabase:sharedDatabase():getItemCraftByItemId(materialId) ~= nil then
				local isCanDrop1,isPass1 = self:getComposeItemIsCanDrop(materialId, (itemCraftConfig["component_num_"..index] or 0))
				if isCanDrop1 then
					isCanDrop = isCanDrop1
					if isPass1 == true then
						isPass = isPass1
						return isCanDrop,isPass
					end
				end
			else
				local isCanDrop1,isPass1 = remote.items:getItemIsCanDrop(materialId)
				if remote.items:getItemsNumByID(materialId) < itemCraftConfig["component_num_"..index] and isCanDrop1 then
					isCanDrop = isCanDrop1
					if isPass1 == true then
						isPass = isPass1
						return isCanDrop,isPass
					end
				end
			end
		end
	end
	return isCanDrop,isPass
end

--通过物品ID和物品强化等级、物品觉醒等级获取属性
function QItems:getItemAllPropByitemId(itemId, streng, magic, actorId)
    local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
    -- TOFIX: SHRINK
    itemInfo = q.cloneShrinkedObject(itemInfo)
    local enhance = QStaticDatabase:sharedDatabase():getTotalEnhancePropByLevel(itemInfo.enhance_data, streng)
    local enchant = QStaticDatabase:sharedDatabase():getTotalEnchantPropByLevel(itemId, magic, actorId)
    enchant = q.cloneShrinkedObject(enchant)
    for name,value in pairs(QActorProp._field) do
        if value.magicType ~= nil then
            if enchant[name] ~= nil then
                enchant[value.magicType] = enchant[name] * streng
                enchant[name] = 0
            end
        end
    end
    for prop, value in pairs(enhance) do 
        if itemInfo[prop] ~= nil and type(value) == "number" then
           	itemInfo[prop] = itemInfo[prop] + (enhance[prop] or 0)
        end
    end
    for prop, value in pairs(enchant) do 
        if type(value) == "number" then
        	itemInfo[prop] = (itemInfo[prop] or 0) + (enchant[prop] or 0)
        end
    end
    return itemInfo
end

--计算装备的属性包括成长值
function QItems:countEquipmentPropForHeroLevel(itemInfo, level)
	itemInfo.hp = (itemInfo.hp or 0) + (itemInfo.hp_grow or 0) * level
	itemInfo.attack = (itemInfo.attack or 0) + (itemInfo.attack_grow or 0) * level
	itemInfo.hit_rating = (itemInfo.hit_rating or 0) + (itemInfo.hit_rating_grow or 0) * level
	itemInfo.dodge_rating = (itemInfo.dodge_rating or 0) + (itemInfo.dodge_rating_grow or 0) * level
	itemInfo.critical_rating = (itemInfo.critical_rating or 0) + (itemInfo.critical_rating_grow or 0) * level
	itemInfo.block_rating = (itemInfo.block_rating or 0) + (itemInfo.block_rating_grow or 0) * level
	itemInfo.haste_rating = (itemInfo.haste_rating or 0) + (itemInfo.haste_rating_grow or 0) * level
	itemInfo.armor_physical = (itemInfo.armor_physical or 0) + (itemInfo.armor_physical_grow or 0) * level
	itemInfo.armor_magic = (itemInfo.armor_magic or 0) + (itemInfo.armor_magic_grow or 0) * level
	return itemInfo
end

-- 获取到物品或者魂师提示
function QItems:getRewardItemsTips(items,oldHeros,cost,againBack,tokenType,freeNum,tavernType,confirmBack,isAgain)
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog.class.__cname == "QUIDialogTavernAchieve" and not isAgain then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end

	local options = {}
	options.cost = cost
	options.againBack = againBack
	options.tokenType = tokenType
	options.freeNum = freeNum
	options.items = items
	options.oldHeros = oldHeros
	options.tavernType = tavernType
	options.confirmBack = confirmBack
	options.isAgain = isAgain

	if isAgain then
		self:dispatchEvent({name = QItems.EVENT_ITEMS_TAVERN_UPDATE, options = options})
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernAchieve", 
			options=options}, {isPopCurrentDialog = false})
	end
end

--将物品整理为出售的格式
function QItems:itemSort(items)
  if next(items) == nil then return end
  local sortItems = {}
  for k, value in pairs(items) do
  	table.insert(sortItems,{type = value.type, count = value.count})
  end
  return sortItems
end

--获取物品的类型
--为了统一各种配置不同为前端所用比如money，MONEY，1 均可以返回MONEY
function QItems:getItemType(typeName)
  	if typeName == "item" or typeName == "ITEM" then
  		return ITEM_TYPE.ITEM
  	end
  	if typeName == "hero" or typeName == "HERO" then
  		return ITEM_TYPE.HERO
  	end
  	if typeName == "zuoqi" or typeName == "ZUOQI" then
  		return ITEM_TYPE.ZUOQI
  	end
  	if typeName == "energy" or typeName == "ENERGY" then
  		return ITEM_TYPE.ENERGY
  	end
  	if typeName == "team_exp" or typeName == "TEAM_EXP" then
  		return ITEM_TYPE.TEAM_EXP
  	end
  	if typeName == "achieve_point" or typeName == "ACHIEVE_POINT" then
  		return ITEM_TYPE.ACHIEVE_POINT
  	end
  	if typeName == "sweep" or typeName == "SWEEP" then
  		return ITEM_TYPE.SWEEP
  	end
  	if typeName == "vip" or typeName == "VIP" then
  		return ITEM_TYPE.VIP
  	end
  	if typeName == "gemstone_piece" then
  		return ITEM_TYPE.GEMSTONE_PIECE
  	end
  	if typeName == "gemstone" then
  		return ITEM_TYPE.GEMSTONE
  	end
  	if typeName == "spar" then
  		return ITEM_TYPE.SPAR
  	end
  	if typeName == "sparPiece" then
  		return ITEM_TYPE.SPAR_PIECE
  	end
  	if typeName == "magicherb" or typeName == "magicHerb" or typeName == "Magicherb" or typeName == "MAGICHERB" then
  		return ITEM_TYPE.MAGICHERB
  	end
  	--检查钱包
  	local wallet = self:getWalletByType(typeName)
  	if wallet ~= nil then
  		return wallet.name, wallet.nativeName
  	end
  	return nil
end

--获取物品的ICON 路径
function QItems:getURLForId(itemId, flag)
	if flag == nil then flag = "icon" end
	local typeName = self:getItemType(itemId)
	if typeName == nil then
		local config = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		if flag ~= "icon" and config.icon_1 ~= nil then
			return config.icon_1, config.name
		else
			return config.icon, config.name
		end
	else
		return self:getURLForItem(typeName, flag)
	end
end

--获取非物品的ICON URL
function QItems:getURLForItem(typeName, flag)
	if flag == nil then flag = "icon" end
	typeName = self:getItemType(typeName)
  	--检查钱包
  	local wallet = self:getWalletByType(typeName)
  	if wallet ~= nil then
  		if wallet[flag] ~= nil then
  			return wallet[flag],wallet.nativeName
  		end
  		return wallet.icon,wallet.nativeName
  	end
  	return nil
end

--通过类型获取钱包
function QItems:getWalletByType(typeName)
	local wallet = QStaticDatabase:sharedDatabase():getResource()
  	for _,value in pairs(wallet) do
  		if typeName == value.name then
  			return value
  		end
  		if value.cname ~= nil then
	  		if self._cnames[value.cname] == nil then
	  			self._cnames[value.cname] = string.split(value.cname, ",")
	  		end
			for _,cname in pairs(self._cnames[value.cname]) do
				if cname ~= nil and cname ~= "" and cname == typeName then
					return value
				end
			end
		end
  	end
  	return nil
end

function QItems:checkJewelryStrengthenItem(items)
	if next(items) == nil then return false end
	for i = 1, #items, 1 do
		if self:getItemsNumByID(items[i]) > 0 then
			return true
		end
	end
	return false
end

--解析后台的item字符串
function QItems:analysisServerItem(itemStr, tbl)
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
	    			local typeName = self:getItemType(v2[1])
	    			if typeName == nil then
	    				typeName = ITEM_TYPE.ITEM
	    				table.insert(tbl, {id = tonumber(v2[1]), typeName = typeName, count = tonumber(v2[2])})
	    			else
	    				table.insert(tbl, {typeName = typeName, count = tonumber(v2[2])})
	    			end
	    		end
	    	end
    	end
    end
    return tbl
end

--解析后台的item字符串
function QItems:analysisServerItemBySperate(itemStr, tbl ,sperate)
	if tbl == nil then tbl = {} end
	if itemStr == nil or itemStr == "" then
		return tbl
	end
	local items = string.split(itemStr, sperate)
    if items and table.nums(items) > 0 then
    	for _,v1 in ipairs(items) do
    		if v1 ~= nil and v1 ~= "" then
	    		local v2 = string.split(v1, "^")
	    		if v2 ~= nil and table.nums(v2) > 1 then
	    			local typeName = self:getItemType(v2[1])
	    			if typeName == nil then
	    				typeName = ITEM_TYPE.ITEM
	    				table.insert(tbl, {id = tonumber(v2[1]), typeName = typeName, count = tonumber(v2[2])})
	    			else
	    				table.insert(tbl, {typeName = typeName, count = tonumber(v2[2])})
	    			end
	    		end
	    	end
    	end
    end
    return tbl
end


function QItems:checkItemRedTips()
	if remote.gemstone:checkBackPackTips() then
		return true
	end
	if remote.spar:checkBackPackTips() then
		return true
	end
	if remote.mount:checkBackPackTips() then
		return true
	end
	if remote.artifact:checkBackPackTips() then
		return true
	end

	if self:checkItemRedTipsByCategory(ITEM_CONFIG_CATEGORY.MATERIAL, ITEM_CONFIG_CATEGORY.SOUL, ITEM_CONFIG_CATEGORY.CONSUM)then
		return true
	end

	return false
end

function QItems:checkItemRedTipsByCategory(...)
	local data = {...}
	local tbl = {}
	local items = self._items
	
	for key,value in pairs(items) do
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(value.type)
		assert(itemInfo, string.format("Item %s can't be found in item table", value.type))

		local isHave = false
		for _, category in pairs(data) do
			if itemInfo.category == category then
				isHave = true
				break
			end
		end
        if itemInfo and isHave then
			if itemInfo.red_dot and itemInfo.red_dot == 1 then
				return true
			end
        end
    end	
    return false
end

-- 道具屏蔽
function QItems:checkHeroSwitch(itemId)
	if not itemId then
		return false
	end

	local heros = db:getHeroSwitch()
	for i, hero in pairs(heros) do
        if hero.is_shields and hero.is_shields == 1 then
        	if hero.type == ITEM_TYPE.ITEM and hero.shield_id == tonumber(itemId) then
        		local openTime = q.getDateTimeByStandStr(hero.start_at)
        		if openTime > q.serverTime() then
        			return true
        		end
            end
        end
    end

    return false
end

function QItems:getSellMoneyItem()
	local sellItems = self:getItemsByType(ITEM_CONFIG_TYPE.CONSUM_MONEY)

	if next(sellItems) ~= nil then
		for i = 1, #sellItems, 1 do
			for j = i + 1, #sellItems, 1 do 
				if sellItems[i].type > sellItems[j].type then
					local var = sellItems[i]
					sellItems[i] = sellItems[j]
					sellItems[j] = var
				end
			end
		end
	end

	return sellItems
end

--[[
	获取数量无论ID还是类型
]]
function QItems:getNumByIDAndType(id, typeName)
	local count = 0
	if typeName == ITEM_TYPE.ITEM then
		count = remote.items:getItemsNumByID(id)
	else
		count = remote.user[typeName] or 0
	end
	return count
end

-- 根据lucky_draw id找对应的物品ID（下午茶茶道具要自动打开，但是预览又只是食材盒子，所以这样找）
function QItems:getItemIdByLuckyDrawId(luckydrawId)
	local itemTbl = db:getStaticByName("item") or {}
	for _,v in pairs(itemTbl) do
		if v.content == luckydrawId then
			return v.id
		end
	end
	return nil
end
return QItems