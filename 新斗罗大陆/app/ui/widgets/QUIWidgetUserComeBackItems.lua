--
-- Author: Kumo
-- 老玩家回归奖励按钮
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUserComeBackItems = class("QUIWidgetUserComeBackItems", QUIWidget)
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText") 
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetUserComeBackItems:ctor(options)
	local ccbFile = "Widget_ComeBack_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIWidgetUserComeBackItems.super.ctor(self,ccbFile,callBacks,options)

	self.otherNode = CCNode:create()
	self:addChild(self.otherNode)
end

function QUIWidgetUserComeBackItems:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetUserComeBackItems:setInfo(info, activityPanel)
	if q.isEmpty(info) then
		return
	end
	self._activityPanel = activityPanel
	self._info = info
	self:resetAll()
	self._awards = {}
	if info.typeName == remote.userComeBack.TYPE_AWARD then
		self._ccbOwner.tf_name:setString(string.format("第%d日登录获赠", info.config.day))
		self._ccbOwner.tf_name:setVisible(true)
		local rate = 1
		if self._info.config.special_type == 1 then
			rate = remote.userComeBack:getUserComeBackDurationDays() - 1
		end
		self._awards = self:getAwardsByConfig(info.config, rate)
		if info.isGet == false then
			if info.isCanGet == false then
				self._ccbOwner.notTouch:setVisible(true)
			else
				self._ccbOwner.node_btn_ok:setVisible(true)
				self._ccbOwner.tf_btn_ok:setString("领 取")
			end
		else
			self._ccbOwner.sp_ishave:setVisible(true)
		end
	elseif info.typeName == remote.userComeBack.TYPE_EXCHANGE then
		-- self._ccbOwner.tf_name:setString("")--string.format("%d钻购买%s折", info.config.exchange_much, info.config.show_discount)
		self:showDisCount(info.config.show_discount)
		self._awards = self:getExchangeAwardsByConfig(info.config)
		self._ccbOwner.tf_num:setString(string.format("剩余次数：%d/%d", info.totalCount-info.count, info.totalCount))
		self._ccbOwner.tf_num:setVisible(true)
		self._ccbOwner.tf_btn_ok:setString("兑 换")
		if info.count >= info.totalCount then
			-- self._ccbOwner.tf_btn_ok:setString("已兑换")
			self._ccbOwner.sp_ishave:setVisible(true)
		else
			self._ccbOwner.node_btn_ok:setVisible(true)
		end
	elseif info.typeName == remote.userComeBack.TYPE_PAY then
		if self._info.config.chongzhi_leixing == 1 then
			self._ccbOwner.tf_name:setString(string.format("单笔充值满%d获赠", info.config.chongzhi_jine))
		else
			self._ccbOwner.tf_name:setString(string.format("累计充值满%d获赠", info.config.chongzhi_jine))
		end
		self._ccbOwner.tf_name:setVisible(true)
		self._awards = self:getAwardsByConfig(info.config)
		local payProgress = 0
        if info.config.chongzhi_leixing == 1 then
            payProgress = math.min(remote.userComeBack:getDailyMaxRecharge(), info.config.chongzhi_jine)
        else
            payProgress = math.min(remote.userComeBack:getDailyTotalRecharge(), info.config.chongzhi_jine)
        end
		self._ccbOwner.tf_num:setString(string.format("进度：%d/%d", payProgress, info.config.chongzhi_jine))
		self._ccbOwner.tf_num:setVisible(true)
		if info.isGet == false then
			self._ccbOwner.node_btn_ok:setVisible(true)
			if info.isCanGet == false then
				self._ccbOwner.tf_btn_ok:setString("去充值")
			else
				self._ccbOwner.tf_btn_ok:setString("领 取")
			end
		else
			self._ccbOwner.sp_ishave:setVisible(true)
		end
	elseif info.typeName == remote.userComeBack.TYPE_FEATRUE then
		-- local unlockConfig = app.unlock:getConfigByKey(info.config.unlock)
		-- self._ccbOwner.tf_name:setString(unlockConfig.name)
		-- self._ccbOwner.tf_name:setVisible(true)
		-- self._ccbOwner.node_btn_go:setVisible(true)

		-- local icon = CCNode:create()
		-- local featureIcon = CCSprite:create(unlockConfig.icon)
		-- featureIcon:setScale(0.8)
		-- icon:addChild(featureIcon)
		-- icon:addChild(CCSprite:create(QResPath("rect_normal_frame")[1]))
		-- icon:setPosition(ccp(85,-85))

		-- local richTF = QRichText.new(info.config.miao_shu, 400, {stringType = 1})
		-- richTF:setAnchorPoint(ccp(0,0.5))
		-- richTF:setPosition(ccp(60, 0))
		-- icon:addChild(richTF)

		-- self.otherNode:addChild(icon)
	end
	self._ccbOwner.node_right:setVisible(true)

	self:showAwards()
end

function QUIWidgetUserComeBackItems:showDisCount(discount)
	if discount then
		self._ccbOwner.hongDisCountBg:setVisible(false)
		self._ccbOwner.lanDisCountBg:setVisible(false)
		self._ccbOwner.chengDisCountBg:setVisible(false)
		self._ccbOwner.ziDisCountBg:setVisible(false)
		self._ccbOwner.tf_name:setPositionX(79)
		self._ccbOwner.node_discount:setVisible(true)
		local _discountStr = discount.."折"
		if discount == 11 then
			_discountStr = "限时"
		elseif discount == 12 then
			_discountStr = "火热"
		end
		self._ccbOwner.discountStr:setString(_discountStr)
		local color = "hongDisCountBg"
		if discount >= 4 and discount < 7 then
			color = "ziDisCountBg"
		elseif discount >= 7 and discount < 10  then
			color = "lanDisCountBg"
		end
		self._ccbOwner[color]:setVisible(true)
	end
end

function QUIWidgetUserComeBackItems:showAwards()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			-- body
			local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemBox._itemID)
			if itemConfig and itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
				local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId( itemBox._itemID )
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroDetailInfoNew", options = {actorId = actorId}}, {isPopCurrentDialog = false})
			else
				app.tip:itemTip(itemBox._itemType, itemBox._itemID)
			end
		end

		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._awards[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item,data,index)

	            info.item = item
	            info.tag = data.oType
	            info.size = item._ccbOwner.parentNode:getContentSize()
	            --注册事件
	            if data.oType == "item" then
	            	list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
	            else
	            	item:setZOrder(1)
	           	end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._awards,

	    }  
		self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._awards})
	end 
end

function QUIWidgetUserComeBackItems:setItemInfo( item, data ,index)
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setPosition(ccp(35, 35))
			item._itemBox:setScale(0.7)
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(70, 70))

		end
		local id = data.id 
		local count = tonumber(data.count)
		local itemType = remote.items:getItemType(id)

		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, count)
	
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			if data.isNeedShowItemCount then
				local num = remote.items:getItemsNumByID(id) or 0
				item._itemBox:setItemCount(string.format("%d/%d",num, count))
			end

		end
	elseif data.oType == "separate" then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Activity_game.plist")
		if not item._separate then
			local sprite = CCSprite:createWithSpriteFrameName(data.id)
			item._separate = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(data.id)
			if frame then
				item._separate:setDisplayFrame(frame)
			end
		end
		local width = 50
		if data.width then
			width = data.width
		end 
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width,110))
		item._separate:setPosition(width/2, 75)
	end
end

function QUIWidgetUserComeBackItems:resetAll()
	self._ccbOwner.tf_name:setVisible(false)
	self._ccbOwner.tf_name:setPositionX(49)
	self._ccbOwner.tf_num:setVisible(false)
	self._ccbOwner.node_discount:setVisible(false)

	self._ccbOwner.node_btn_ok:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.alreadyTouch:setVisible(false)
	self._ccbOwner.notTouch:setVisible(false)
	self._ccbOwner.sp_time_out:setVisible(false)
	self._ccbOwner.node_right:setVisible(false)
end

function QUIWidgetUserComeBackItems:getAwardsByConfig(config, rate)
	if rate == nil then
		rate = 1
	end
	local awards = {}
	local index = 1
	while true do
		if config["type_"..index] ~= nil then
			local id = tonumber(config["id_"..index])
			local itemType = config["type_"..index]
			local count = tonumber(config["num_"..index]) * rate
			itemType = remote.items:getItemType(itemType)
			if itemType ~= ITEM_TYPE.ITEM then
				id = itemType
			end
			table.insert(awards, {oType = "item", id = id, count = count, isNotAwawd = true})
		else
			break
		end
		index = index + 1
	end
	return awards
end

function QUIWidgetUserComeBackItems:getAwardsArrayByConfig(config, rate)
	if rate == nil then
		rate = 1
	end
	local awards = {}
	local index = 1
	while true do
		if config["type_"..index] ~= nil then
			local id = tonumber(config["id_"..index])
			local typeName = config["type_"..index]
			local count = tonumber(config["num_"..index]) * rate
			typeName = remote.items:getItemType(typeName)
			if typeName ~= ITEM_TYPE.ITEM then
				id = nil
			end
			table.insert(awards, {typeName = typeName, id = id, count = count})
		else
			break
		end
		index = index + 1
	end
	return awards
end

function QUIWidgetUserComeBackItems:getExchangeAwardsByConfig(config)
	local awards = {}
	local index = 1
	table.insert(awards, {oType = "item", id = ITEM_TYPE.TOKEN_MONEY, count = config.exchange_much, isNotAwawd = true})
	table.insert(awards, {oType = "separate", id = "yellow_denghao.png"})
	while true do
		if config["type_"..index] ~= nil then
			local id = tonumber(config["id_"..index])
			local itemType = config["type_"..index]
			local count = tonumber(config["num_"..index])
			itemType = remote.items:getItemType(itemType)
			if itemType ~= ITEM_TYPE.ITEM then
				id = itemType
			end
			table.insert(awards, {oType = "item", id = id, count = count, isNotAwawd = true})
		else
			break
		end
		index = index + 1
	end
	return awards
end

function QUIWidgetUserComeBackItems:onTouchListView( event )
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetUserComeBackItems:_onTriggerOK()
    app.sound:playSound("common_small")
    if remote.userComeBack:getIsOpen() == false then
    	app.tip:floatTip("活动已经结束")
    	return 
    end
	if self._info.typeName == remote.userComeBack.TYPE_AWARD then
		if self._info.isGet == false then
			if self._info.isCanGet == true then
				local rate = 1
				if self._info.config.special_type == 1 then
					rate = remote.userComeBack:getUserComeBackDurationDays() - 1
				end
				local awards = self:getAwardsArrayByConfig(self._info.config, rate)
				remote.userComeBack:userComeBackTakeLoginRewardRequest(self._info.config.id, function ()
				    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				        options = {awards = awards, callBack = function ()
				        	remote.user:checkTeamUp()
				        end}},{isPopCurrentDialog = false} )
				    dialog:setTitle("恭喜您获得奖励")
				end)
			end
		end
	elseif self._info.typeName == remote.userComeBack.TYPE_EXCHANGE then
		local awards = self:getAwardsArrayByConfig(self._info.config)
		local maxCount = self._info.config.oneday_exchange_num - remote.userComeBack:getExchangeCountById(self._info.config.id)
		if maxCount <= 0 then
			return
		end
		local exchangeFun = function (count)
			remote.userComeBack:userComeBackBuyRewardRequest(self._info.config.id, count, function ()
				for _,v in ipairs(awards) do
					v.count = v.count * count
				end
			    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			        options = {awards = awards}},{isPopCurrentDialog = false} )
			    dialog:setTitle("恭喜您获得奖励")
			end)
		end
		if maxCount > 1 then
			if #awards > 1 then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", options = {awards = awards, 
					confirmText = "兑 换", useLabel = "批量兑换：", maxOpenNum = maxCount, isMultiple = true,chooseType = 3,explainStr="请选择你要兑换的数量",titleText="活动兑换",
		                    okCallback = function (selectCount)
		                  		exchangeFun(selectCount)
		                    end}})
			else
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityBuyMultiple", options = {items = awards[1],
				 maxCount = maxCount, price = self._info.config.exchange_much, moneyType = ITEM_TYPE.TOKEN_MONEY, isItemExchange = (self._info.type == 302), callback = function (count)
		      		exchangeFun(count)
				end}})
			end
		else
			exchangeFun(1)
		end
	elseif self._info.typeName == remote.userComeBack.TYPE_PAY then
		if self._info.isGet == false then
			if self._info.isCanGet == true then
				local awards = self:getAwardsArrayByConfig(self._info.config)
				remote.userComeBack:userComeBackTakeRechargeRewardRequest(self._info.config.id, function ()
				    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
				        options = {awards = awards}},{isPopCurrentDialog = false} )
				    dialog:setTitle("恭喜您获得奖励")
				end)
			else
   				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
			end
		end
	-- elseif self._info.typeName == remote.userComeBack.TYPE_FEATRUE then
	-- 	if self._info.config.shortcut_id ~= nil then
 --   			QQuickWay:clickGoto(QStaticDatabase.sharedDatabase():getShortcutByID(self._info.config.shortcut_id))
 --   		end
	end
end
return QUIWidgetUserComeBackItems