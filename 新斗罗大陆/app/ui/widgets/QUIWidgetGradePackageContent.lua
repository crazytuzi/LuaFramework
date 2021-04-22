-- @Author: liaoxianbo
-- @Date:   2019-07-08 12:18:33
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-02-25 15:51:29
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGradePackageContent = class("QUIWidgetGradePackageContent", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetGradePackageContent.UPDATE_BUYSTATE = "UPDATE_BUYSTATE"

function QUIWidgetGradePackageContent:ctor(options)
	local ccbFile = "ccb/Widget_Activity_GradePackageclient.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerItemClick", callback = handler(self, self.onTriggerItemClick)},
    }
    QUIWidgetGradePackageContent.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._nameMaxSize = 176
	self._btnType = 1
	self._stateFlag = true
	self._ccbOwner.sp_received:setVisible(false)
end

function QUIWidgetGradePackageContent:getItemIdAndCount(rewardInfo)
	local id = 0
	local count = 0
	if rewardInfo then
		local s, e = string.find(rewardInfo, "%^")
	    id = string.sub(rewardInfo, 1, s - 1)
	    count = string.sub(rewardInfo, e + 1)
	end
	return id,tonumber(count)
end

function QUIWidgetGradePackageContent:setContentInfo(info,widgetGradepackage)
	self._widgetGradepackage = widgetGradepackage
	if info == nil then return end
	self._index = index
	self._contentInfo = info

	if self._contentInfo.show_discount then
		self._ccbOwner.ccb_dazhe:setVisible(true)
		self._ccbOwner.discountStr:setString(self._contentInfo.show_discount.."折")
	else
		self._ccbOwner.ccb_dazhe:setVisible(false)
	end
	self._ccbOwner.item_name:setString(self._contentInfo.item_name or "")
	local nameWidth = self._ccbOwner.item_name:getContentSize().width
	self._ccbOwner.item_name:setScale(1)
	if nameWidth > self._nameMaxSize then
		self._ccbOwner.item_name:setScale(1-(nameWidth - self._nameMaxSize)/self._nameMaxSize)
	end

	local id,count = self:getItemIdAndCount(self._contentInfo.reward)
	self:setItemInfo(id,count)

	-- local rewardId = self._contentInfo.reward
	-- if rewardId then
	-- 	local s, e = string.find(rewardId, "%^")
	--     local id = string.sub(rewardId, 1, s - 1)
	--     local count = string.sub(rewardId, e + 1)
	-- 	self:setItemInfo(id,count)
	-- end

	self._ccbOwner.icon_node1:removeAllChildren()
	self._ccbOwner.icon_node2:removeAllChildren()
	if self._contentInfo.type == 1 then --领取
		self._btnType = 1
		self._ccbOwner.node_exchange:setVisible(false)
		self._ccbOwner.tf_btn:setString("领 取")
	elseif self._contentInfo.type == 2 then	--购买
		self._btnType = 2
		self._ccbOwner.node_exchange:setVisible(true)
		self._ccbOwner.price2:setString(self._contentInfo.much_num.."元")
		self._ccbOwner.price2:setPositionX(20)
		local discount = tonumber(self._contentInfo.show_discount)
		if discount and discount > 0 then
			self._ccbOwner.price1:setString(math.floor(tonumber(self._contentInfo.much_num)*10/discount).."元")	
			self._ccbOwner.price1:setPositionX(20)
		end

		if self._contentInfo.recharged and self._contentInfo.recharged == 1 and self._contentInfo.received ~= 1 then
			self._btnType = 1
			self._ccbOwner.tf_btn:setString("领 取")
		else
			self._ccbOwner.tf_btn:setString("立即购买")
		end
	elseif self._contentInfo.type == 3 then --兑　换
		self._btnType = 3
		self._ccbOwner.node_exchange:setVisible(true)	
		self._ccbOwner.price2:setString(self._contentInfo.much_num)
		self._ccbOwner.price2:setPositionX(40)
		local discount = tonumber(self._contentInfo.show_discount)
		if discount and discount > 0 then
			self._ccbOwner.price1:setString(math.floor(tonumber(self._contentInfo.much_num)*10/discount))	
			self._ccbOwner.price1:setPositionX(40)
		end
		self._ccbOwner.tf_btn:setString("兑 换")
		local currencyInfo = remote.items:getWalletByType(self._contentInfo.much_type)
		if currencyInfo then
		   	local path = currencyInfo.alphaIcon
		  	if path ~= nil then
			    local icon1 = CCSprite:create()
			    icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
			    self._ccbOwner.icon_node1:addChild(icon1)

			    local icon2 = CCSprite:create()
			    icon2:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
			    self._ccbOwner.icon_node2:addChild(icon2)
		  	end
		end
	end

	self:checkPackageState()

end

function QUIWidgetGradePackageContent:checkPackageState()

	if remote.user.level >= self._contentInfo.level then
		if self._contentInfo.received == 1 then
			self:setItemState(false)
		else
			self:setItemState(true)
		end
	else
		self:setItemIstGet(false)
	end
end

function QUIWidgetGradePackageContent:setItemState(stateFlag)
	self._stateFlag = stateFlag
	if stateFlag then
		if self._contentInfo.type == 1 or self._btnType == 1 then
			self._ccbOwner.red_tips:setVisible(true)
		else
			self._ccbOwner.red_tips:setVisible(false)
		end
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.sp_received:setVisible(false)		
	else
		self._ccbOwner.red_tips:setVisible(false)	
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.sp_received:setVisible(true)			
	end
end

function QUIWidgetGradePackageContent:setItemIstGet(flag)
	self._stateFlag = flag
	
	if flag then
		if self._contentInfo.type == 1 then
			self._ccbOwner.red_tips:setVisible(true)
		else
			self._ccbOwner.red_tips:setVisible(false)
		end
		makeNodeFromGrayToNormal(self._ccbOwner.btn_config)
		makeNodeFromGrayToNormal(self._ccbOwner.tf_btn)	
		self._ccbOwner.tf_btn:enableOutline() 
	else
		self._ccbOwner.red_tips:setVisible(false)
		makeNodeFromNormalToGray(self._ccbOwner.btn_config)
		makeNodeFromNormalToGray(self._ccbOwner.tf_btn)
		self._ccbOwner.tf_btn:disableOutline() 			
	end
end
function QUIWidgetGradePackageContent:setItemInfo( itemid, count)
	self._ccbOwner.item_node:removeAllChildren()

	local itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.item_node:addChild(itemBox)

	local id = itemid 
	local count = tonumber(count)
	local itemType = remote.items:getItemType(id)
	self._itemID = itemid
	self._awards = {}
	
	-- self._awards = {id = id, typeName = itemType, count = count}
	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		itemBox:setGoodsInfo(id, itemType, count)
		table.insert(self._awards, {id = id, typeName = itemType, count = count})
	else
		itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
		table.insert(self._awards, {id = id, typeName = ITEM_TYPE.ITEM, count = count})
	end
	self._itemType = itemBox:getItemType()
end

function QUIWidgetGradePackageContent:_onTriggerConfirm( event )
	if self._stateFlag then
		if self._contentInfo.haveExchangeNum > 1 then
			local id,count = self:getItemIdAndCount(self._contentInfo.reward)
			local itemType = remote.items:getItemType(id)

		    app.sound:playSound("common_small")
		    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyGradePackageAwards",options = {maxNum = self._contentInfo.haveExchangeNum,
		    	itemInfo = {itemId = id,itemType = itemType or ITEM_TYPE.ITEM,itemCount = count,resource_1 = self._contentInfo.much_type,resource_number_1 = self._contentInfo.much_num }, callback = function(buynum)
		    	for _,awards in pairs(self._awards) do
		    		awards.count = awards.count*buynum
		    	end
				self:dispatchEvent({name = QUIWidgetGradePackageContent.UPDATE_BUYSTATE,type = self._btnType, id = self._contentInfo.id,
				count = buynum,awards = self._awards,much_num = self._contentInfo.much_num})
			end} })				
		else
			self:dispatchEvent({name = QUIWidgetGradePackageContent.UPDATE_BUYSTATE,type = self._btnType, id = self._contentInfo.id,
			count = self._contentInfo.haveExchangeNum,awards = self._awards,much_num = self._contentInfo.much_num})
		end
	else
	    if self._contentInfo.level > remote.user.level then
	    	app.tip:floatTip("当前等级还未开启功能，快去提升等级吧！")
	    end		
	end
end
function QUIWidgetGradePackageContent:onTriggerItemClick( event )
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemID)
	if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
		local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemID)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", options = {actorId = actorId}}, {isPopCurrentDialog = false})
	else
		app.tip:itemTip(self._itemType, self._itemID)
	end
end

function QUIWidgetGradePackageContent:onEnter()
end

function QUIWidgetGradePackageContent:onExit()
end

function QUIWidgetGradePackageContent:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetGradePackageContent
