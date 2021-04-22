local QBaseShopProxy = class("QBaseShopProxy")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")

function QBaseShopProxy:ctor(shopId)
	self.shopId = shopId
	self.db = QStaticDatabase:sharedDatabase()
	self.shopInfo = remote.stores:getShopResousceByShopId(self.shopId)

	self._rowMaxCount = 3
end

function QBaseShopProxy:getRefreshCount()
	local vip = self.db:getVipContnentByVipLevel(QVIPUtil:VIPLevel())
	return vip.gnshop_limit
end

function QBaseShopProxy:getRefreshInfoByCount()
	local refreshedCount = remote.stores:getRefreshCountById(self.shopId) or 0
	
	local payNum, moneyType = remote.stores:getShopRefreshToken(refreshedCount, self.shopInfo.refreshInfo)
	return {id = nil, typeName = moneyType, count = payNum}
end

function QBaseShopProxy:refreshChooseItem()
	self._chooseItem = app:getUserOperateRecord():getShopQuickBuyConfiguration(self.shopId)
end

function QBaseShopProxy:sortFun(a, b)
	if a.id == b.id and a.moneyType ~= b.moneyType then
		return a.moneyType ~= ITEM_TYPE.TOKEN_MONEY
	elseif a.id == b.id and a.moneyType == b.moneyType then
		return a.moneyNum > b.moneyNum
	end

	local itemsInfo1 = self.db:getItemByID(a.id)
	if itemsInfo1 == nil then
		itemsInfo1 = remote.items:getWalletByType(a.itemType)
	end
	local itemsInfo2 = self.db:getItemByID(b.id)
	if itemsInfo2 == nil then
		itemsInfo2 = remote.items:getWalletByType(b.itemType)
	end
	if itemsInfo1.type ~= itemsInfo2.type then
		if itemsInfo1.type == ITEM_CONFIG_TYPE.SOUL then
			return true
		end
		if itemsInfo2.type == ITEM_CONFIG_TYPE.SOUL then
			return false
		end
		if itemsInfo1.type == ITEM_CONFIG_TYPE.MATERIAL then
			return true
		end
		if itemsInfo2.type == ITEM_CONFIG_TYPE.MATERIAL then
			return false
		end
	end

	if itemsInfo1.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId1 = self.db:getActorIdBySoulId(itemsInfo1.id)
		local actorId2 = self.db:getActorIdBySoulId(itemsInfo2.id)
		local characher1 = self.db:getCharacterByID(actorId1)
		local characher2 = self.db:getCharacterByID(actorId2)
		if characher1.aptitude ~= characher2.aptitude then
			return characher1.aptitude > characher2.aptitude
		end
	end

	if itemsInfo1.id == 11000003 or itemsInfo2.id == 11000003 then
		return itemsInfo1.id == 11000003
	elseif itemsInfo1.colour ~= itemsInfo2.colour then
	 	return itemsInfo1.colour > itemsInfo2.colour
	else
		return itemsInfo1.id < itemsInfo2.id
	end
end

--获取可购买信息
function QBaseShopProxy:getBuyInfo(chooseItems)
	local shopItems = clone(remote.stores:getStoresById(self.shopId))
	
	local buyItems = {}
	local buyInfo = {}
	local needInfo = {}
	if shopItems == nil then
		return buyItems, buyInfo, needInfo
	end
	for _, value in pairs(shopItems) do
		local id = value.id
		if value.itemType ~= "item" then 
			id = value.itemType
		end
		local chooseInfo = chooseItems[id]
		local moneyType = remote.items:getItemType(value.moneyType)
		--if value.count > 0 and chooseInfo and ((chooseInfo[1] and chooseInfo[1].moneyType == string.lower(value.moneyType) ) 
			-- or ( chooseInfo[2] and chooseInfo[2].moneyType == string.lower(value.moneyType) ) ) then

		if value.count > 0 and chooseInfo and  (
			 ( chooseInfo[1] and chooseInfo[1].moneyType == string.lower(value.moneyType)  and tostring(chooseInfo[1].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or
			 ( chooseInfo[2] and chooseInfo[2].moneyType == string.lower(value.moneyType)  and tostring(chooseInfo[2].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or
			 ( chooseInfo[3] and chooseInfo[3].moneyType == string.lower(value.moneyType)  and tostring(chooseInfo[3].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) or
			 ( chooseInfo[4] and chooseInfo[4].moneyType == string.lower(value.moneyType)  and tostring(chooseInfo[4].moneyNum) == string.format(tonumber(value.cost)/tonumber(value.count)) ) )then

			local currencyInfo = remote.items:getWalletByType(value.moneyType)
			local money = remote.user[currencyInfo.name] or 0
			
			local useInfo = nil
			local useCount = 0
			for _,v in ipairs(buyInfo) do
				if v.typeName == moneyType then
					useInfo = v
					useCount = v.count
					v.count = v.count + value.cost
					break
				end
			end

			if money >= useCount + value.cost then
				useCount = useCount + value.cost
				buyItems[#buyItems+1] = value
			else
				local isFind = false
				for _,v in ipairs(needInfo) do
					if v.typeName == moneyType then
						v.count = v.count + value.cost
						isFind = true
						break
					end
				end
				if isFind == false then
					table.insert(needInfo, {id = nil, typeName = moneyType, count = value.cost})
				end
			end
			if useInfo == nil then
				table.insert(buyInfo, {id= nil, typeName = moneyType, count = useCount})
			end
		end
	end
	
	return buyItems, buyInfo, needInfo
end


function QBaseShopProxy:getShopData( )

end

function QBaseShopProxy:getResourcesItemId( )
	return nil
end

function QBaseShopProxy:checkSpeckTips( )

end

function QBaseShopProxy:getAwrdsData()
	if self.shopInfo.arawdsId == nil then return end

	local awardsInfo = QStaticDatabase:sharedDatabase():getItemsByShopAwardsId(self.shopInfo.arawdsId) or {}
	for i = 1, #awardsInfo, 1 do
		awardsInfo[i].position = i 
	end

	return self:sortAwardsItem(awardsInfo)
end

function QBaseShopProxy:sortAwardsItem(awardInfos)
	local awards = awardInfos
	local newAwards = {}
	local sellInfo = remote.stores:getAwardsShopById(tostring(self.shopInfo.arawdsId))
	if sellInfo == nil or sellInfo == "" then return awardInfos end
	sellInfo = string.split(sellInfo, ";")

	local index = 1
	for i = 1, #awards, 1 do
		local isSell = false
		for j = 1, #sellInfo, 1 do
			if tonumber(sellInfo[j]) == awards[i].position-1 then
				isSell = true
				table.insert(newAwards, awards[i])
				table.remove(sellInfo, j)
				break
			end
		end
		if not isSell then
			table.insert(newAwards, index, awards[i])
			index = index + 1
		end 
	end
	return newAwards
end

return QBaseShopProxy