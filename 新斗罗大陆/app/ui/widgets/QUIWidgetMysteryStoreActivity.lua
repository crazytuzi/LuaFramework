




local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMysteryStoreActivity = class("QUIWidgetMysteryStoreActivity", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QRichText = import("...utils.QRichText")


QUIWidgetMysteryStoreActivity.EVENT_GET_REWARD ="QUIWidgetMysteryStoreActivity.EVENT_GET_REWARD"
QUIWidgetMysteryStoreActivity.EVENT_CLICK ="QUIWidgetMysteryStoreActivity.EVENT_CLICK"

QUIWidgetMysteryStoreActivity.AWARD_TYPE_AND =1
QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR = 2




function QUIWidgetMysteryStoreActivity:ctor(options)
	local ccbFile = "ccb/Widget_Activity_MysteryStore.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
	}
	QUIWidgetMysteryStoreActivity.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_get)
	-- makeNodeFromNormalToGray(self._ccbOwner.sp_ishave)
	-- makeNodeFromNormalToGray(self._ccbOwner.sp_sellOut)
	self._awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_AND
end

function QUIWidgetMysteryStoreActivity:resetAll()
    self._ccbOwner.node_limit:removeAllChildren()
    self._ccbOwner.node_desc:removeAllChildren()

	self._ccbOwner.tf_buy_cost:setString("")


	self._ccbOwner.node_dazhe:setVisible(false)
	self._ccbOwner.sp_star:setVisible(false)

	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_buy:setVisible(false)
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.sp_sellOut:setVisible(false)

end 

function QUIWidgetMysteryStoreActivity:setInfo(info)
	self:resetAll()
	self._info = info

	local num = 0
	local progressData = remote.activity:getActivityTargetProgressDataById(self._info.activityId, self._info.activityTargetId)
	local showBtn = false
	local showGetBtn = false
	if progressData then
		-- QPrintTable(progressData)
		num = progressData.awardCount or 0
		if tonumber(progressData.awardCount or 0) >= tonumber(self._info.repeatCount) then
			showBtn = false
		else
			showBtn = true
		end
		if tonumber(progressData.completeCount or 0) > tonumber(progressData.awardCount or 0) then
			showGetBtn = true
		else
			showGetBtn = false
		end

	end



	local descTargetTable={}
	local descriptionTable={}


	if self._info.type == remote.activity.ACTIVITY_TARGET_TYPE.FREE_GET_DALIY then
		self._ccbOwner.node_dazhe:setVisible(true)
		self._ccbOwner.sp_star:setVisible(false)
		table.insert(descTargetTable,{oType = "font", content = "每日免费(",size = 18,color = COLORS.A})
		table.insert(descTargetTable,{oType = "font", content = self._info.repeatCount - num ,size = 18,color = COLORS.A})
		-- if num == 0 then
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.m})
		-- else
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.A})
		-- end
		table.insert(descTargetTable,{oType = "font", content = "/"..self._info.repeatCount..")" ,size = 18,color = COLORS.A})

		self._ccbOwner.node_get:setVisible(showBtn)
		self._ccbOwner.sp_ishave:setVisible(not showBtn)
		
		table.insert(descriptionTable,{oType = "font", content = self._info.description ,size = 18,color = COLORS.A})
	elseif self._info.type == remote.activity.ACTIVITY_TARGET_TYPE.FREE_RECHARGE_DALIY then
		self._ccbOwner.sp_star:setVisible(false)
		self._ccbOwner.node_dazhe:setVisible(true)

		table.insert(descTargetTable,{oType = "font", content = "每日限购(",size = 18,color = COLORS.A})
		table.insert(descTargetTable,{oType = "font", content = self._info.repeatCount - num ,size = 18,color = COLORS.A})
		-- if num == 0 then
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.m})
		-- else
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.A})
		-- end
		table.insert(descTargetTable,{oType = "font", content = "/"..self._info.repeatCount..")" ,size = 18,color = COLORS.A})


		local rechargeConfig = remote.activity:getRechargeConfigByRechargeBuyProductId(self._info.value3)
		if rechargeConfig then
			self._ccbOwner.tf_buy_cost:setString((rechargeConfig.RMB or 0).."元")
		end
		self._ccbOwner.node_buy:setVisible(showBtn and not showGetBtn)
		self._ccbOwner.node_get:setVisible(showBtn and showGetBtn)
		self._ccbOwner.sp_sellOut:setVisible(not showBtn)
		local strsTbl = string.split(self._info.description, tostring(rechargeConfig.RMB))
		if #strsTbl >= 2 then
			table.insert(descriptionTable,{oType = "font", content = strsTbl[1],size = 18,color = COLORS.A})
			table.insert(descriptionTable,{oType = "font", content = tostring(rechargeConfig.RMB),size = 18,color = COLORS.a})
			table.insert(descriptionTable,{oType = "font", content = strsTbl[2],size = 18,color = COLORS.A})
		else
			table.insert(descriptionTable,{oType = "font", content = self._info.description ,size = 18,color = COLORS.A})
		end

	elseif self._info.type == remote.activity.ACTIVITY_TARGET_TYPE.RECHARGE_PURCHASE then
		self._ccbOwner.sp_star:setVisible(true)
		self._ccbOwner.node_dazhe:setVisible(false)


		table.insert(descTargetTable,{oType = "font", content = "本次限购(",size = 18,color = COLORS.A})
		table.insert(descTargetTable,{oType = "font", content = self._info.repeatCount - num ,size = 18,color = COLORS.A})
		-- if num == 0 then
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.m})
		-- else
		-- 	table.insert(descTargetTable,{oType = "font", content = num ,size = 18,color = COLORS.A})
		-- end
		table.insert(descTargetTable,{oType = "font", content = "/"..self._info.repeatCount..")" ,size = 18,color = COLORS.A})

		local rechargeConfig = remote.activity:getRechargeConfigByRechargeBuyProductId(self._info.value3)
		if rechargeConfig then
			self._ccbOwner.tf_buy_cost:setString((rechargeConfig.RMB or 0).."元")
		end
		self._ccbOwner.node_buy:setVisible(showBtn and not showGetBtn)
		self._ccbOwner.node_get:setVisible(showBtn and showGetBtn)
		self._ccbOwner.sp_sellOut:setVisible(not showBtn)

		local strsTbl = string.split(self._info.description, tostring(rechargeConfig.RMB))
		if #strsTbl >= 2 then
			table.insert(descriptionTable,{oType = "font", content = strsTbl[1],size = 18,color = COLORS.A})
			table.insert(descriptionTable,{oType = "font", content = tostring(rechargeConfig.RMB),size = 18,color = COLORS.a})
			table.insert(descriptionTable,{oType = "font", content = strsTbl[2],size = 18,color = COLORS.A})
		else
			table.insert(descriptionTable,{oType = "font", content = self._info.description ,size = 18,color = COLORS.A})
		end

	end

	local richText = QRichText.new(nil, 300, {stringType = 1,defaultColor = COLORS.A,defaultSize = 18})
	richText:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_desc:addChild(richText)
	richText:setString(descriptionTable)

	local targetText = QRichText.new(nil, 150, {stringType = 1,defaultColor = COLORS.A,defaultSize = 18})
	targetText:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_limit:addChild(targetText)
	targetText:setString(descTargetTable)

	self:handleData()
	self:_initListView()
end

function QUIWidgetMysteryStoreActivity:handleData()
	self._awards = {}
	local awardString = self._info.awards
	local awardsTbl ={}
	if string.find(awardString, "#") then
		awardsTbl = string.split(self._info.awards, "#")
		self._awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR
	else
		awardsTbl = string.split(self._info.awards, ";")
		self._awardType = QUIWidgetMysteryStoreActivity.AWARD_TYPE_AND
	end
    local awardseffectTbl = self._info.effectItemIdList 

    for i, v in pairs(awardsTbl) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            local specialAwards = false
            if awardseffectTbl then
            	for _,awardsEf in pairs(awardseffectTbl) do
            		if tonumber(reward[1]) ~= nil and tonumber(reward[1]) == tonumber(awardsEf) then
            			specialAwards = true
            			break
            		end
            	end
            end
            if not q.isEmpty(self._awards) and self._awardType ==  QUIWidgetMysteryStoreActivity.AWARD_TYPE_OR then
            	table.insert(self._awards, {oType = "separate", id = QResPath("sp_new_word_or"), width = 30})
            end
            table.insert(self._awards, {oType = "item", id = reward[1], typeName = itemType, count = tonumber(reward[2]),specialAwards = specialAwards})
        end
    end
	-- QPrintTable(self._awards)

end

function QUIWidgetMysteryStoreActivity:onTouchListView( event )
	if not event then
		return
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetMysteryStoreActivity:_initListView()

	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._awards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item, data, index)
	            info.item = item
				info.size = item._ccbOwner.parentNode:getContentSize()
				
				--注册事件
                list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)

	            return isCacheNode
	        end,
	        spaceX = 10,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._awards,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView, cfg)
	else
		self._listView:reload({totalNumber = #self._awards , isCleanUp = true})
	end 

end

function QUIWidgetMysteryStoreActivity:setItemInfo( item, data ,index)
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.75)
			item._itemBox:setPosition(ccp(45, 38))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(75, 75))

		end
		local id = data.id 
		local count = tonumber(data.count)
		-- local itemType = remote.items:getItemType(id)
		local itemType = data.typeName 

		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, count)
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			if data.isNeedShowItemCount then
				local num = remote.items:getItemsNumByID(id) or 0
				item._itemBox:setItemCount(string.format("%d/%d",num, count))
			end
		end
		if data.specialAwards then
			item._itemBox:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
			-- item._itemBox:showBoxEffect("effects/Auto_Skill_light.ccbi",true, 0, -5, 1.2)
		end

		local isNeed = remote.stores:checkMaterialIsNeed(tonumber(id), count)
        item._itemBox:showGreenTips(isNeed) 
	elseif data.oType == "separate" then
		if not item._separate then
			local sprite = CCSprite:create(data.id)
			item._separate = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = QSpriteFrameByPath(data.id)
			if frame then
				item._separate:setDisplayFrame(frame)
			end
		end
		local width = 30
		if data.width then
			width = data.width
		end 
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(10, 75))
		item._separate:setPosition(width/2, 37.5)
	end
end

function QUIWidgetMysteryStoreActivity:_onTriggerGet(event)
	self:dispatchEvent({name = QUIWidgetMysteryStoreActivity.EVENT_GET_REWARD, info = self._info })
end

function QUIWidgetMysteryStoreActivity:_onTriggerBuy(event)
	self:dispatchEvent({name = QUIWidgetMysteryStoreActivity.EVENT_CLICK, info = self._info})
end

function QUIWidgetMysteryStoreActivity:getContentSize( ... )
	return cc.size(self._ccbOwner.cellSize:getContentSize().width + 2 ,self._ccbOwner.cellSize:getContentSize().height )
end

function QUIWidgetMysteryStoreActivity:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetMysteryStoreActivity:onExit()
	--代码
	self._isExit = nil
    if self._timerScheduler ~= nil then
    	scheduler.unscheduleGlobal(self._timerScheduler)
    	self._timerScheduler = nil
    end
end

return QUIWidgetMysteryStoreActivity