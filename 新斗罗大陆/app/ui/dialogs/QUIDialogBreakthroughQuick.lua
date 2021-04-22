
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBreakthroughQuick = class("QUIDialogBreakthroughQuick", QUIDialog)
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText") 
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIDialogBreakthroughQuick.TYPE_SHOW = "TYPE_SHOW"
QUIDialogBreakthroughQuick.TYPE_QUICKWAY = "TYPE_QUICKWAY"

function QUIDialogBreakthroughQuick:ctor(options)
 	local ccbFile = "ccb/Dialog_HeroBreak_yijian.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerBreak", callback = handler(self, self._onTriggerBreak)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
    }
    QUIDialogBreakthroughQuick.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._actorId = options.actorId

    self._ccbOwner.frame_tf_title:setString("一键突破")
    local heroModel = remote.herosUtil:getUIHeroByID(self._actorId)
    local items = options.items
    local needItems = options.needItems
    local canBreak = options.canBreak
    local breakLevel = options.breakLevel
    if options == nil or items == nil or needItems == nil or canBreak == nil or breakLevel == nil then
    	items, needItems, canBreak, breakLevel = heroModel:getHeroMaxBreakLevelNeedItems()
    else
    	options.items = nil
    	options.needItems = nil
    	options.canBreak = nil
    	options.breakLevel = nil
    end
    self._items = items
    self._needItems = needItems

    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    self._ccbOwner.node_break:setVisible(false)
	self._ccbOwner.node_btn_confirm:setVisible(false)

    self._heroInfo = heroInfo
    self._showType = QUIDialogBreakthroughQuick.TYPE_SHOW
	self._data = {}
	self._showItems = nil
	self._targetLevel = breakLevel
	local titleTbl = {}
	if breakLevel > 0 then
        table.insert(titleTbl, {oType = "font", content = "消耗以下资源可以进阶到",size = 24,color = COLORS.k})
	    local breakthroughLevel = 0
		local color = nil
		if heroInfo ~= nil then
			breakthroughLevel, color = remote.herosUtil:getBreakThrough(heroInfo.breakthrough + breakLevel)
		end
		local colorName =  q.convertColorToWord(color) or ""
		if breakthroughLevel > 0 then
			colorName = colorName.."+"..breakthroughLevel
		end
		local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
		local shadowColor = getShadowColorByFontColor(fontColor)
        table.insert(titleTbl, {oType = "font", content = colorName, size = 24, color = fontColor, strokeColor = shadowColor})           
		table.insert(self._data,{oType = "title", info = titleTbl})
		self._showItems = items
    	self._showType = QUIDialogBreakthroughQuick.TYPE_SHOW
    	self._ccbOwner.node_break:setVisible(true)
	else
		if table.nums(needItems) > 0 then
			table.insert(titleTbl, {oType = "font", content = "突破魂师还缺少以下资源，点击图标可以前往获取资源",size = 24,color = COLORS.k})
			self._showItems = needItems
    		self._showType = QUIDialogBreakthroughQuick.TYPE_QUICKWAY
			table.insert(self._data,{oType = "title", info = titleTbl})
		elseif not canBreak then
			app.tip:floatTip("战队等级不足，无法突破到下一级~")
		end
		self._ccbOwner.node_btn_confirm:setVisible(true)
	end
	if self._showItems ~= nil then
		local showItems = {}
		for k,v in pairs(self._showItems) do
			local itemId = k
			local count = v
			local itemType = remote.items:getItemType(itemId)
			if itemType ~= nil then
				itemId = nil
			else
				itemType = ITEM_TYPE.ITEM
			end
			table.insert(showItems, {id = itemId, itemType = itemType, count = count})
		end
		table.sort(showItems, function (a,b)
			local itemConfigA = QStaticDatabase:sharedDatabase():getItemByID(a.id)
			local itemConfigB = QStaticDatabase:sharedDatabase():getItemByID(b.id)
			if itemConfigA ~= nil and itemConfigB ~= nil then
				if (itemConfigA.exp or 0) ~= (itemConfigB.exp or 0) then
					return (itemConfigA.exp or 0) > (itemConfigB.exp or 0)
				end
			end
			if a.itemType == ITEM_TYPE.MONEY then
				return true
			end
			if b.itemType == ITEM_TYPE.MONEY then
				return false
			end
			if itemConfigA ~= nil and itemConfigB ~= nil then
				if itemConfigA.colour ~= itemConfigB.colour then
					return (itemConfigA.colour or 0) > (itemConfigB.colour or 0)
				end
				return a.id < b.id
			end
			if a.id ~= b.id then
				return (a.id or 0) > (b.id or 0)
			end
			return a.itemType < b.itemType
		end)
		local index = 1
		local tbl = {}
		for _,v in ipairs(showItems) do
			table.insert(tbl, v)
			index = index + 1
			if index > 5 then
				index = 1       
				table.insert(self._data,{oType = "item", info = tbl})
				tbl = {}
			end
		end
		if index > 1 then
			table.insert(self._data,{oType = "item", info = tbl})
		end
	end
end

function QUIDialogBreakthroughQuick:viewAnimationInHandler()
	self:initListView()	
end

function QUIDialogBreakthroughQuick:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "title" then
	            		item = self:madeTitleNode()
            		elseif itemData.oType == "item" then
            			item = self:getItemNode()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "title" then
	            	item:setInfo(itemData.info or {})
	            elseif itemData.oType == "item" then
	            	item:setInfo(itemData.info or {})
	            end
	           
	            info.item = item
	            info.size = item:getContentSize()
				if itemData.oType == "item" then
					for i,v in ipairs(item.items) do
						list:registerItemBoxPrompt(index, i, v, nil, handler(self, self.showItemInfo))
					end
				end
	            return isCacheNode
	        end,
	        curOriginOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

--生成一个标题节点
function QUIDialogBreakthroughQuick:madeTitleNode()
	local node = CCNode:create()
	node:setContentSize(CCSize(667, 44))

	node.tf_title = QRichText.new()
	node.tf_title:setAnchorPoint(ccp(0.5,0.5))
	node.tf_title:setPosition(315,-22)
	node:addChild(node.tf_title)

	node.setInfo = function (node, info)
		node.tf_title:setString(info)
	end
	return node
end

--生成一个物品节点
function QUIDialogBreakthroughQuick:getItemNode()
	local node = CCNode:create()
	node.items = {}
	node.itemsTF = {}
	node.setInfo = function (node, info)
		local hight = 110
		for index,item in ipairs(info) do
			if node.items[index] == nil then
				node.items[index] = QUIWidgetItemsBox.new()
				node.items[index]:setPosition((index - 1) * 130 + 60, -100/2)
				node.itemsTF[index] = CCLabelTTF:create("20/20", global.font_default, 24)
				node.itemsTF[index]:setPosition((index - 1) * 130 + 60, -115)
				node:addChild(node.items[index])
				node:addChild(node.itemsTF[index])
			end
			local box = node.items[index]
			local haveCount = remote.items:getNumByIDAndType(item.id, item.itemType)
			node.itemsTF[index]:setScale(1)
			if self._showType == QUIDialogBreakthroughQuick.TYPE_QUICKWAY then
				box:showBoxEffect("ccb/effects/keshouji.ccbi", true, 0, -28)
				box:setGoodsInfo(item.id, item.itemType, 0)
				node.itemsTF[index]:setColor(COLORS.m)
				local num1,unit1 = q.convertLargerNumber(haveCount)
				local num2,unit2 = q.convertLargerNumber(item.count + haveCount)
				node.itemsTF[index]:setString(string.format("%s/%s", num1..(unit1 or ""), num2..(unit2 or "")))
				hight = 140
			else
				box:removeEffect()
				box:setGoodsInfo(item.id, item.itemType, item.count)
				node.itemsTF[index]:setString("")
			end
			local width = node.itemsTF[index]:getContentSize().width
			if width > 100 then
				node.itemsTF[index]:setScale(100/width)
			end
		end
		node:setContentSize(667, hight)
	end
	node:setContentSize(667, 140)
	return node
end

function QUIDialogBreakthroughQuick:showItemInfo(x, y, itemBox, listView)
	if self._showType == QUIDialogBreakthroughQuick.TYPE_QUICKWAY then
		local itemId = itemBox:getItemId()
		local itemType = itemBox:getItemType()
		local itemCount = self._showItems[itemId] or 0
		local needCount = itemCount + remote.items:getNumByIDAndType(itemId, itemType)
		if itemType ~= ITEM_TYPE.ITEM then
			QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, itemType, needCount)
		else
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, itemId, needCount)
		end
	elseif self._showType == QUIDialogBreakthroughQuick.TYPE_SHOW then
		app.tip:itemTip(itemBox._itemType, itemBox._itemID)
	end
end

function QUIDialogBreakthroughQuick:_onTriggerConfirm(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_confirm) == false then return end
	self:_onTriggerClose()
end

function QUIDialogBreakthroughQuick:_onTriggerClose()
    app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBreakthroughQuick:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogBreakthroughQuick:_onTriggerPreview()
    app.sound:playSound("common_small")
    local targetLevel = self._targetLevel
    if targetLevel == 0 then
	    local characterInfo = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	    local breakthroughInfo = QStaticDatabase:sharedDatabase():getBreakthroughByTalentLevel(characterInfo.talent, self._heroInfo.breakthrough + 1)
    	if breakthroughInfo == nil then
        	app.tip:floatTip("已经突破到顶级")
        	return
    	end
    	targetLevel = 1
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBreakthroughPreview", 
        options = {actorId = self._actorId, targetLevel = targetLevel}})
end

function QUIDialogBreakthroughQuick:_onTriggerBreak(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_break) == false then return end
    app.sound:playSound("common_small")
    
    local oldHeroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	app:getClient():heroBreakthroughOneKeyRequest(self._actorId, self._heroInfo.breakthrough + self._targetLevel, function (data)
		if data.heroBreakthroughOneKeyResponse ~= nil then
			if data.heroBreakthroughOneKeyResponse.breakcount ~= nil and data.heroBreakthroughOneKeyResponse.breakcount > 0 then
				remote.user:addPropNumForKey("todayEquipBreakthroughCount", data.heroBreakthroughOneKeyResponse.breakcount)
			end
			if data.heroBreakthroughOneKeyResponse.useExpCount ~= nil and data.heroBreakthroughOneKeyResponse.useExpCount > 0 then
				remote.user:addPropNumForKey("todayHeroExpCount", data.heroBreakthroughOneKeyResponse.useExpCount)
			end
		end

		self:popSelf()
		remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_HERO_BREAK_BY_ONEKEY, oldHeroInfo = oldHeroInfo})
	end)
end

return QUIDialogBreakthroughQuick