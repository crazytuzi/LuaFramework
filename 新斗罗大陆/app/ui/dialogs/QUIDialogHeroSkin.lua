-- @Author: xurui
-- @Date:   2019-01-08 17:43:34
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-05 12:20:59
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSkin = class("QUIDialogHeroSkin", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetHeroSkinClient = import("..widgets.QUIWidgetHeroSkinClient")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

function QUIDialogHeroSkin:ctor(options)
	local ccbFile = "ccb/Dialog_hero_skin.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerChangeSkin", callback = handler(self, self._onTriggerChangeSkin)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerPropInfo", callback = handler(self, self._onTriggerPropInfo)},
    }
    QUIDialogHeroSkin.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	CalculateUIBgSize(self._ccbOwner.sp_bg)

	q.setButtonEnableShadow(self._ccbOwner.btn_prop_info)

    if options then
    	self._callBack = options.callBack
    	self._actorId = options.actorId
    	self._selectSkinId = options.skinId
    end

    self._skinDataList = {}
    self._selectIndex = 1
    self._isAutoMove = false
    self._propriRhTextList = {}

    --设置当前使用的皮肤为选中状态
    if self._selectSkinId == nil then
    	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    	if heroInfo.skinId and heroInfo.skinId ~= 0 then
    		self._selectSkinId = heroInfo.skinId
    	end
    end

    --滑动区域大小适配
    local size = self._ccbOwner.sheet_content:getContentSize()
    local scale = display.width/UI_DESIGN_WIDTH
    self._ccbOwner.sheet_content:setContentSize(CCSize(size.width*scale, size.height))
end

function QUIDialogHeroSkin:viewDidAppear()
	QUIDialogHeroSkin.super.viewDidAppear(self)

	self:updateSkinData()

	self:addBackEvent(true)
end

function QUIDialogHeroSkin:viewWillDisappear()
  	QUIDialogHeroSkin.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogHeroSkin:_renderItemFunc(listView, index, info)
    local isCacheNode = true
    local itemData = self._skinDataList[index]
    local item = listView:getItemFromCache()
    if not item then
		item = QUIWidgetHeroSkinClient.new()
		item:addEventListener(QUIWidgetHeroSkinClient.EVENT_CLICK_HELP, handler(self, self.clickEvent))
		item:addEventListener(QUIWidgetHeroSkinClient.EVENT_CLICK, handler(self, self.clickEvent))
    	isCacheNode = false
    end
    item:setInfo(itemData, index)
    item:setSelectStatus(self._selectIndex == index)
    info.item = item
    info.size = item:getContentSize()

    listView:registerBtnHandler(index, "btn_help", "_onTriggerHelp", nil, true)
    listView:registerBtnHandler(index, "btn_click_avatar", "_onTriggerAvatar")
    listView:registerBtnHandler(index, "btn_click", "_onTriggerClick")

    return isCacheNode
end

function QUIDialogHeroSkin:_initSkinListView()
	local skinNum = #self._skinDataList
	local cacheCond = 4/skinNum
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        isVertical = false,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceX = 5,
	        totalNumber = skinNum,
	        cacheCond = cacheCond,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_content, cfg)
	else
		self._listViewLayout:refreshData()
	end

	--顺序一直在变化，需要计算排序之后的index
	if self._selectSkinId then
		local scrollToIndex
		if self._selectSkinId then
			for i, value in ipairs(self._skinDataList) do
				if value.skins_id == self._selectSkinId then
					scrollToIndex = i
					self._selectIndex = i
					break
				end
			end
		end
		self:updateSelectStatus()
		self._listViewLayout:startScrollToIndex(scrollToIndex, true, 1000)
		self._selectSkinId = nil
	end
end

function QUIDialogHeroSkin:updateSkinData()
	self._skinDataList = remote.heroSkin:getHeroSkinConfigListById(self._actorId)

	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)

	for i, value in ipairs(self._skinDataList) do
		value.isUse = self._heroInfo.skinId == value.skins_id
		value.isActivation = remote.heroSkin:checkSkinIsActivation(value.character_id, value.skins_id)
		if value.is_nature == 0 then
			value.isActivation = true
			if self._heroInfo.skinId == nil or self._heroInfo.skinId == 0 then
				value.isUse = true
			end
		end
	end

	table.sort( self._skinDataList, function(a, b) 
			if a.is_nature ~= b.is_nature then
				return a.is_nature == 0
			elseif a.isActivation ~= b.isActivation then
				return a.isActivation
			else
				return a.skins_id > b.skins_id 
			end
		end )

	local skinNum = #self._skinDataList
	self._ccbOwner.node_arrow_left:setVisible(not (skinNum < 3))
	self._ccbOwner.node_arrow_right:setVisible(not (skinNum < 3))

	self:_initSkinListView()

	self:setChangeButtonStatus()

	self:setTotalProp()
end

function QUIDialogHeroSkin:_autoMove(direction)
	if self._listViewLayout and self._isAutoMove == false then
		local maxSkinNum = #self._skinDataList
		local startIndex = self._listViewLayout:getCurStartIndex()
		local endIndex = self._listViewLayout:getCurEndIndex()
		local startItem = self._listViewLayout:getItemByIndex(startIndex)
		local endItem = self._listViewLayout:getItemByIndex(endIndex)

		local targetIndex 
		if direction == "left" then
			if endItem:isVisible() == false then
				targetIndex = endIndex - 5
			else
				targetIndex = endIndex - 4
			end
		else
			if startItem:isVisible() == false then
				targetIndex = startIndex + 3
			else
				targetIndex = startIndex + 2
			end
		end

		if targetIndex < 1 then
			targetIndex = 1
		elseif targetIndex > maxSkinNum then
			targetIndex = maxSkinNum
		end

		if targetIndex and self._listViewLayout then
			self._isAutoMove = true
			self._listViewLayout:startScrollToIndex(targetIndex, false, 100, function()
					self._isAutoMove = false
				end, -10)
		end
	end
end

function QUIDialogHeroSkin:setChangeButtonStatus()
	local selectSkinInfo = self._skinDataList[self._selectIndex]
	self._ccbOwner.node_have_tips:setVisible(false)

	if q.isEmpty(selectSkinInfo) == false then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn_change)
		self._ccbOwner.btn_change:setHighlighted(false)
		self._ccbOwner.btn_change:setEnabled(true)
		self._ccbOwner.tf_btn_change:disableOutline()
		if selectSkinInfo.isUse == true then
			self._ccbOwner.btn_change:setHighlighted(true)
			self._ccbOwner.btn_change:setEnabled(false)
			self._ccbOwner.tf_btn_change:disableOutline()
			makeNodeFromNormalToGray(self._ccbOwner.node_btn_change)
		elseif selectSkinInfo.isActivation ~= true then
			if selectSkinInfo.skins_item then
				local itemNum = remote.items:getItemsNumByID(selectSkinInfo.skins_item)
				self._ccbOwner.node_have_tips:setVisible(itemNum>0)
			end
		end
	end
end

function QUIDialogHeroSkin:clickEvent(event)
	if event == nil then return end

	local skinInfo = event.skinInfo
	local index = event.index

	if event.name == QUIWidgetHeroSkinClient.EVENT_CLICK_HELP then 
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinTip", 
			options = {skinId = skinInfo.skins_id, heroId = skinInfo.character_id}})
	elseif event.name == QUIWidgetHeroSkinClient.EVENT_CLICK then
		if self._selectIndex == index then return end

		if index then
			self._selectIndex = index
			self:updateSelectStatus()
		end

		self:setChangeButtonStatus()
	end
end

function QUIDialogHeroSkin:updateSelectStatus()
	if self._listViewLayout then
		local startIndex = self._listViewLayout:getCurStartIndex()
		local endIndex = self._listViewLayout:getCurEndIndex()
		for i = startIndex, endIndex do
			local item = self._listViewLayout:getItemByIndex(i)
			item:setSelectStatus(self._selectIndex == i)
		end
	end
end

function QUIDialogHeroSkin:setTotalProp()
	local totalPropDict = remote.heroSkin:getAllHeroSkinProp()

	self._ccbOwner.tf_no_porp:setVisible(false)
	if q.isEmpty(totalPropDict) then
		self._ccbOwner.tf_no_porp:setVisible(true)
	else
		local index = 1
		local width = 0
		local height = 0
		for _, prop in pairs(totalPropDict) do
			
			if self._propriRhTextList[index] == nil then
				self._propriRhTextList[index] = QRichText.new(text, 200, {})
				self._propriRhTextList[index]:setAnchorPoint(0, 1)

		    	self._ccbOwner.node_prop:addChild(self._propriRhTextList[index])
			end
			local strTbl = {
		            {oType = "font", content = prop.name or "",size = 22,color = UNITY_COLOR.white},
		            {oType = "font", content = string.format("+%s", (prop.value or 0)), size = 22,color = ccc3(176, 237, 80)},
		        }
		    if prop.isPercent then
		    	strTbl[2] = {oType = "font", content = string.format("+%s%%", (prop.value or 0)*100), size = 22,color = ccc3(176, 237, 80)}
		    end
			self._propriRhTextList[index]:setString(strTbl)

			self._propriRhTextList[index]:setPosition(width, -height)
			width = width + self._propriRhTextList[index]:getCascadeBoundingBox().size.width + 10
			if index % 4 == 0 then
				height = 28
				width = 0
			end
			index = index + 1
		end
	end
end

function QUIDialogHeroSkin:useSkinItem(itemId)
	if itemId == nil then return end

	app:alert({content = "已拥有皮肤道具，是否立即使用？", title="系统提示", colorful = true,
		callback=function(state)
			if state == ALERT_TYPE.CONFIRM then
				app:getClient():openItemPackage(itemId, 1, function(data)
						if data.heroSkins then
							remote.heroSkin:openRecivedSkinDialog(data.heroSkins)
							if self:safeCheck() then
								self:updateSkinData()
							end
						end
					end)
			end
	end})

end

function QUIDialogHeroSkin:_onTriggerChangeSkin(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	app.sound:playSound("common_small")

	local selectSkinInfo = self._skinDataList[self._selectIndex]

	if q.isEmpty(selectSkinInfo) == false then
		if selectSkinInfo.isActivation then
			remote.heroSkin:changeHeroSkinRequest(self._actorId, selectSkinInfo.skins_id, function()
					if self:safeCheck() then
						self._selectSkinId = selectSkinInfo.skins_id
						self:updateSkinData()
					end
					app.tip:floatTip("更换皮肤成功！")
				end)
		else
			if selectSkinInfo.skins_item then
				local itemNum = remote.items:getItemsNumByID(selectSkinInfo.skins_item)
				if itemNum > 0 then
					self:useSkinItem(selectSkinInfo.skins_item)
					return
				end
			end

			if selectSkinInfo.skins_sell == 2 then
		        app.tip:floatTip("请关注游戏内活动")
		    else
		    	app:alert({content=string.format("是否确认花费##0x5a2d11%d钻石##d购买皮肤", (selectSkinInfo.skins_token_price or 0)), title="系统提示", colorful = true,
				callback=function(state)
					if state == ALERT_TYPE.CONFIRM then
						remote.heroSkin:buyHeroSkinRequest(selectSkinInfo.skins_id, function()
        						app.taskEvent:updateTaskEventProgress(app.taskEvent.ACTIVE_SKIN_EVENT, 1, false, false)

								local skinInfo = remote.heroSkin:getHeroSkinBySkinId(self._actorId, selectSkinInfo.skins_id)
								if skinInfo.skins_ccb then
									app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHandBookHeroImageCard", 
								        options = {actorId = self._actorId, callback = function()
								        	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinBuySuccess", 
												options = {skinInfo = selectSkinInfo, callBack = function()
														if self:safeCheck() then
															self._selectSkinId = selectSkinInfo.skins_id
															self:updateSkinData()
														end
													end}})
								        end}})
								else
									app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkinBuySuccess", 
										options = {skinInfo = selectSkinInfo, callBack = function()
												if self:safeCheck() then
													self._selectSkinId = selectSkinInfo.skins_id
													self:updateSkinData()
												end
											end}})
								end
							end)
					end
				end})
		    end
		end
	end
end

function QUIDialogHeroSkin:_onTriggerRight()
	app.sound:playSound("common_small")

	self:_autoMove("right")
end

function QUIDialogHeroSkin:_onTriggerLeft()
	app.sound:playSound("common_small")

	self:_autoMove("left")
end

function QUIDialogHeroSkin:_onTriggerPropInfo()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAllFashionPropInfo", 
        options = {}}) 
end


return QUIDialogHeroSkin
