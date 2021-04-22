--
-- Kumo.Wang
-- 時裝繪卷主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFashionCombinationMain = class("QUIDialogFashionCombinationMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")
local QActorProp = import("...models.QActorProp")

local QUIWidgetFashionCombinationMainMenu = import("..widgets.QUIWidgetFashionCombinationMainMenu")

QUIDialogFashionCombinationMain.VIEW_ON = 1
QUIDialogFashionCombinationMain.VIEW_OFF = -1

function QUIDialogFashionCombinationMain:ctor(options)
	local ccbFile = "ccb/Dialog_Fashion_Combination_Main.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
        {ccbCallbackName = "onTriggerActive", callback = handler(self, self._onTriggerActive)},
        {ccbCallbackName = "onTriggerShareSDK", callback = handler(self, self._onTriggerShareSDK)},
    }
    QUIDialogFashionCombinationMain.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	CalculateUIBgSize(self._ccbOwner.node_bg, 1432)
	
	q.setButtonEnableShadow(self._ccbOwner.btn_active)
	q.setButtonEnableShadow(self._ccbOwner.btn_share)
    if options then
    	self._selectedFashionCombinationId = options.selectedFashionCombinationId -- 指定繪卷id
    end

    self:_init()
end

function QUIDialogFashionCombinationMain:viewDidAppear()
	QUIDialogFashionCombinationMain.super.viewDidAppear(self)

	self:addBackEvent(true)

	-- self._ccbOwner.node_touch:removeAllChildren()
 --    local touchNode = CCNode:create()
 --    touchNode:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
 --    touchNode:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
 --    touchNode:setTouchSwallowEnabled(true)
 --    self._ccbOwner.node_touch:addChild(touchNode)
 --    self._touchNode = touchNode
 --    self._touchNode:setTouchEnabled(true)
 --    self._touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouch))

	self:_initMenuListView()
	self:_doInfoViewEffect()
	self:_doListViewEffect()
end

function QUIDialogFashionCombinationMain:viewWillDisappear()
  	QUIDialogFashionCombinationMain.super.viewWillDisappear(self)

	self:removeBackEvent()

	if self._touchNode ~= nil then
		self._touchNode:setTouchEnabled( false )
		self._touchNode:removeFromParent()
		self._touchNode = nil
	end
end

function QUIDialogFashionCombinationMain:_getOneFashionCombinationId(combinationDataList)
	for _, config in ipairs(combinationDataList) do
		if config.character_skins then
			local tbl = string.split(config.character_skins, ";")
			local isActived = false
			if tbl and #tbl > 0 then
				for _, skinId in ipairs(tbl) do
					if remote.fashion:checkSkinActivityBySkinId(skinId) then
						isActived = true
					else
						isActived = false
						break
					end
				end
			end

			if isActived then
				return config.id
			end
		end
	end

	return combinationDataList[1].id
end

function QUIDialogFashionCombinationMain:_init()
	print("[QUIDialogFashionCombinationMain:_init()] ", self._selectedFashionCombinationId)

	local combinationDataList = remote.fashion:getCombinationDataList()
	if q.isEmpty(combinationDataList) then
		return 
	end
	if not self._selectedFashionCombinationId then
		-- 第一個可以激活的，或者第一個
		self._selectedFashionCombinationId = self:_getOneFashionCombinationId(combinationDataList)
	end

	self._isAllON = self.VIEW_ON
	self._isInfoON = self._isAllON
	self._isListON = self._isAllON
    self._canActive = false -- 是否可以激活

    self:_update()
end

-- function QUIDialogFashionCombinationMain:_onTouch(event)
-- 	if event.name == "began" then
-- 		return true
-- 	elseif event.name == "ended" then
-- 		self._isAllON = - self._isAllON
-- 		self._isInfoON = self._isAllON
-- 		self._isListON = self._isAllON
-- 		self:_doInfoViewEffect(true)
-- 		self:_doListViewEffect(true)
-- 	end
-- end

function QUIDialogFashionCombinationMain:_update()
	if not self._selectedFashionCombinationId then return end

	local combinationDataList = remote.fashion:getCombinationDataList()
	if q.isEmpty(combinationDataList) then
		return 
	end

	self._menuData = combinationDataList

	if self._menuBtnListView then
		self._menuBtnListView:clear(true)
		self._menuBtnListView = nil
	end

	self:_initMenuListView()
end

function QUIDialogFashionCombinationMain:_initMenuListView()
	if not self._menuData then return end

	if not self._menuBtnListView then
		for index, data in ipairs(self._menuData) do
			if tostring(data.id) == tostring(self._selectedFashionCombinationId) then
				self._menuPos = index
        		self:_updateCombinationView()
			end
		end

		local cfg = {
			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local itemData = self._menuData[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetFashionCombinationMainMenu.new()
            		item:addEventListener(QUIWidgetFashionCombinationMainMenu.EVENT_CLICK, handler(self, self._menuBtnClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()

	            if item.getInfo and item.setSelect then
	            	local info = item:getInfo()
	            	if self._selectedFashionCombinationId and tostring(info.id) == tostring(self._selectedFashionCombinationId) then
	            		item:setSelect(true)
	            		self._selectMenuItem = item
	            	else
	            		item:setSelect(false)
	            	end
	            end

                list:registerBtnHandler(index, "btn_menu", "onTriggerClick")
	            return isCacheNode
	        end,
	        isVertical = false,
	        spaceX = 0,
	        enableShadow = false,
	      	ignoreCanDrag = false,
	      	autoCenter =  true,
	        totalNumber = #self._menuData,
		}
		self._menuBtnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
	else
		self._menuBtnListView:reload({totalNumber = #self._menuData})
	end

	self:_startScrollToSelected()
end

function QUIDialogFashionCombinationMain:_startScrollToSelected()
    if self._menuPos and self._menuPos > 0 then
        self._menuBtnListView:startScrollToIndex(self._menuPos, false, 100)
    end
end

function QUIDialogFashionCombinationMain:_menuBtnClickHandler(event)
	app.sound:playSound("common_small")
	local itemData = event.info
	local index = self._menuBtnListView:getCurTouchIndex()
	local item = self._menuBtnListView:getItemByIndex(index)
	if not itemData then
		if item.getInfo then
			itemData = item:getInfo()
		else
			itemData = self._menuData[index]
		end
	end

	if not itemData then return end

	QKumo(itemData)

	if not self._selectMenuItem or (item.setSelect and self._selectMenuItem.setSelect and self._selectedFashionCombinationId ~= itemData.id) then
		if self._selectMenuItem then
			self._selectMenuItem:setSelect(false)
		end
		self._selectedFashionCombinationId = itemData.id
		self:getOptions().selectedFashionCombinationId = self._selectedFashionCombinationId

		item:setSelect(true)
		self._selectMenuItem = item

	    self:_updateCombinationView()
    end
end

function QUIDialogFashionCombinationMain:_updateCombinationView()
	if not self._selectedFashionCombinationId and not self._selectMenuItem then return end

	local itemData
	if self._selectMenuItem and self._selectMenuItem.getInfo then
		itemData = self._selectMenuItem:getInfo()
	elseif self._selectedFashionCombinationId then
		for _, v in ipairs(self._menuData) do
			if v.id == self._selectedFashionCombinationId then
				itemData = v
			end
		end
	end

	if q.isEmpty(itemData) then
		return
	end

	self:_updateInfo(itemData)
	self:_updatePicture(itemData)
end

-- "skin_display_2": "2;62;100;0;1;1;0",
function QUIDialogFashionCombinationMain:_updatePicture(itemData)
	if not itemData then return end
	self._ccbOwner.node_bg:removeAllChildren()

	self._ccbOwner.sp_tips_diancang:setVisible(itemData.type == 2)
	self._ccbOwner.sp_tips_jieri:setVisible(false)
	self._ccbOwner.sp_tips_zhenpin:setVisible(itemData.type == 3)
	
	if itemData.sp_bg then
		local sprite = CCSprite:create(itemData.sp_bg)
		if sprite then
			self._ccbOwner.node_bg:addChild(sprite)
		end
	end

	local index = 1
	local figureList = {}
	while true do
		local str = itemData["skin_display_"..index]
		if str then
			local tbl = string.split(str, ";")
			local widgetTbl = {}
			for i = 8, #tbl, 1 do
				table.insert(widgetTbl, tbl[i])
			end
			table.insert(figureList, {index = tonumber(tbl[1]), skinId = tbl[2], x = tonumber(tbl[3]), y = tonumber(tbl[4]), scale = tonumber(tbl[5]), isturn = tonumber(tbl[6]), rotation = tonumber(tbl[7]), widgets = widgetTbl})
			index = index + 1
		else
			break
		end
	end
	table.sort(figureList, function(a, b)
		if tonumber(a.skinId) and not tonumber(b.skinId) then
			return true
		elseif not tonumber(a.skinId) and tonumber(b.skinId) then
			return false
		else
			return a.index < b.index
		end
	end)
	QKumo(figureList)
	local isAllActivity = true
	if #figureList > 0 then
		local grayWidgets = {}
		for _, info in ipairs(figureList) do
			local skinId = info.skinId
			local path = ""
			local isActivity = true
			print("skinId = ", skinId, tonumber(skinId), tostring(skinId))
			if tonumber(skinId) then
				-- 主体人物
				skinId = tonumber(skinId)
				local skinConfig = remote.fashion:getSkinConfigDataBySkinId(skinId)
				if skinConfig then
					path = skinConfig.combination_card or skinConfig.fightEnd_card

					if not remote.fashion:checkSkinActivityBySkinId(skinId) then
						isAllActivity = false
						isActivity = false
						for _, widget in ipairs(info.widgets) do
							table.insert(grayWidgets, widget)
						end
					end
				end
			else
				-- 主体人物的挂件
				skinId = tostring(skinId)
				path = itemData[skinId]
				for _, widget in ipairs(grayWidgets) do
					if widget == skinId then
						isAllActivity = false
						isActivity = false
						break
					end
				end
			end

			if path and path ~= "" then
				print("path = ", path)
				local sprite = CCSprite:create(path)
				if sprite then
					local z = #figureList - info.index + 1
					self._ccbOwner.node_bg:addChild(sprite, z)

					sprite:setPositionX(info.x)
					sprite:setPositionY(info.y)
					sprite:setScaleX(info.isturn * info.scale)
					sprite:setScaleY(info.scale)
					sprite:setRotation(info.rotation)

					if not isActivity then
						isAllActivity = false
						makeNodeFromNormalToGray(sprite)
					end
				end
			end
		end
	end

	-- if itemData.sp_fg and isAllActivity then
	if itemData.sp_fg then
		local sprite = CCSprite:create(itemData.sp_fg)
		if sprite then
			self._ccbOwner.node_bg:addChild(sprite, #figureList + 1)
		end
	end
end

function QUIDialogFashionCombinationMain:_updateInfo(itemData)
	if not itemData then return end

	-- 称号
	self._ccbOwner.node_title:removeAllChildren()
	if itemData.head_default then
		local titleBox = QUIWidgetHeroTitleBox.new()
		titleBox:setTitleId(itemData.head_default)
		self._ccbOwner.node_title:addChild(titleBox)
	end

	-- 进度
	self._ccbOwner.tf_progress:setString("0/0")
	if itemData.character_skins then
		local tbl = string.split(itemData.character_skins, ";")
		local totalNumber = #tbl
		local curNumber = 0
		if totalNumber > 0 then
			for _, id in ipairs(tbl) do
				if remote.fashion:checkSkinActivityBySkinId(id) then
					curNumber = curNumber + 1
				end
			end
			if curNumber >= totalNumber then
				self._canActive = true
			else
				self._canActive = false
			end
			self._ccbOwner.tf_progress:setString(curNumber.."/"..totalNumber)
		end
	end

	-- 皮膚信息
	self._ccbOwner.node_skin_info:removeAllChildren()
	local rtf = QRichText.new(nil, 227)
    rtf:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_skin_info:addChild(rtf)
	self._ccbOwner.node_skin_info:setVisible(true)
	textTbl = {}
	local characterTbl = string.split(itemData.character_skins, ";")
	-- local allCharacterNameStr = ""
	local allCharacterNameStrTbl = {}
	if characterTbl and #characterTbl > 0 then
	 	for _, id in pairs(characterTbl) do
	 		local skinConfig = remote.fashion:getSkinConfigDataBySkinId(id)
	 		if skinConfig then
	 			local nameStr = ""
				if skinConfig and skinConfig.skins_name then
					nameStr = nameStr..skinConfig.skins_name.."·"
				end
				local characterConfig = db:getCharacterByID(skinConfig.character_id)
				if characterConfig then
					if characterConfig.name then
						local aptitudeInfo = db:getSABCByQuality(characterConfig.aptitude)
						table.insert(allCharacterNameStrTbl, characterConfig.name)
						-- if allCharacterNameStr ~= "" then
						-- 	allCharacterNameStr = allCharacterNameStr.." 和 "
						-- end
						-- allCharacterNameStr = allCharacterNameStr--[[..aptitudeInfo.qc]]..characterConfig.name
						nameStr = nameStr..characterConfig.name
					end
				end
				local fontColor = COLORS.f
				if remote.fashion:checkSkinActivityBySkinId(id) then
					fontColor = COLORS.c
				end
				if #textTbl ~= 0 then
	 				table.insert(textTbl, {oType = "wrap"})
	 			end
	 			table.insert(textTbl, {oType = "font", content = nameStr, size = 20, color = fontColor})
	 		end
	 	end
	end
 	rtf:setString(textTbl)

 	-- 描述
	self._ccbOwner.node_prop_desc:removeAllChildren()
	local rt = QRichText.new(nil, 227)
    rt:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_prop_desc:addChild(rt)
	self._ccbOwner.node_prop_desc:setVisible(true)
 	local textTbl = {}
 	for key, value in pairs(itemData) do
 		local propFields = QActorProp:getPropFields()
 		if propFields[key] then
 			if #textTbl ~= 0 then
 				table.insert(textTbl, {oType = "wrap"})
 			end
 			local nameStr = propFields[key].uiName or propFields[key].name
 			local num = tonumber(value)
 			if propFields[key].isPercent then
 				num = (num * 100).."%"
 			end
 			if key == "enter_rage" then
 				if not q.isEmpty(allCharacterNameStrTbl) then
 				-- if allCharacterNameStr and allCharacterNameStr ~= "" then
 					for i, heroName in ipairs(allCharacterNameStrTbl) do
 						if i > 1 then
 							table.insert(textTbl, {oType = "wrap"})
 						end
	 					table.insert(textTbl, {oType = "font", content = heroName..nameStr.."增加："..num, size = 16, color = COLORS.a})
 					end
	 				-- table.insert(textTbl, {oType = "font", content = allCharacterNameStr, size = 20, color = COLORS.a})
	 				-- table.insert(textTbl, {oType = "wrap"})
	 			end
 				-- table.insert(textTbl, {oType = "font", content = nameStr.."增加："..num, size = 20, color = COLORS.a})
 			else
 				table.insert(textTbl, {oType = "font", content = "全队"..nameStr.."："..num, size = 20, color = COLORS.a})
 			end
 		end
 	end
 	rt:setString(textTbl)

 	local totalHeight = math.abs(self._ccbOwner.node_skin_info:getPositionY() - self._ccbOwner.s9s_info_bg:getPositionY()) + rtf:getContentSize().height + 60

 	self._ccbOwner.node_btn_active:setPositionY(self._ccbOwner.node_skin_info:getPositionY() - rtf:getContentSize().height - 30)
 	self._ccbOwner.sp_actived:setPositionY(self._ccbOwner.node_skin_info:getPositionY() - rtf:getContentSize().height - 30)

 	self._ccbOwner.s9s_info_bg:setPreferredSize(CCSize(270, totalHeight + 20))

	self:_updateButtonState()
end

function QUIDialogFashionCombinationMain:_updateButtonState()
	-- 按钮状态
	self._ccbOwner.node_btn_active:setVisible(true)
	self._ccbOwner.sp_actived:setVisible(false)
	self._ccbOwner.node_share:setVisible(false)
	if self._canActive then
		if remote.fashion:checkActivedPictureId(self._selectedFashionCombinationId) then
			self._ccbOwner.node_btn_active:setVisible(false)
			self._ccbOwner.sp_actived:setVisible(true)
			if remote.shareSDK:checkIsOpen() then
				self._ccbOwner.node_share:setVisible(true)
			end
		else
			self._ccbOwner.tf_btn_active:enableOutline()
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn_active)
			self._ccbOwner.ccb_btn_effect:setVisible(true)
		end
	else
		self._ccbOwner.tf_btn_active:disableOutline()
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_active)
		self._ccbOwner.ccb_btn_effect:setVisible(false)
	end
	self._shareInfo = remote.shareSDK:getShareConfigById(self._selectedFashionCombinationId,remote.shareSDK.SKINTIRED)
	if q.isEmpty(self._shareInfo) then
		self._ccbOwner.node_share:setVisible(false)
	end
end

function QUIDialogFashionCombinationMain:_onTriggerActive()
	app.sound:playSound("common_small")
	if not self._canActive then
		app.tip:floatTip("激活条件未满足！")
		return 
	end

	if not self._selectedFashionCombinationId and not self._selectMenuItem then return end

	local itemData
	if self._selectMenuItem and self._selectMenuItem.getInfo then
		itemData = self._selectMenuItem:getInfo()
	elseif self._selectedFashionCombinationId then
		for _, v in ipairs(self._menuData) do
			if v.id == self._selectedFashionCombinationId then
				itemData = v
			end
		end
	end

	remote.fashion:userSkinPictureActiveRequest(itemData.id, function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionSuccess", 
	        	options = {id = itemData.id, type = remote.fashion.FUNC_TYPE_FASHION_COMBINATION, callback = function()
	        		if self:safeCheck() then
						self:_updateButtonState()
					end
	        	end}})
		end)
end

function QUIDialogFashionCombinationMain:_onTriggerShareSDK( event)
    app.sound:playSound("common_small")
    
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
        options = {shareInfo = self._shareInfo}}, {isPopCurrentDialog = false})     
end

function QUIDialogFashionCombinationMain:_onTriggerInfo()
    app.sound:playSound("common_small")
	self._isInfoON = - self._isInfoON
	self:_doInfoViewEffect(true)
end

function QUIDialogFashionCombinationMain:_doInfoViewEffect(isAnimation)
    self._ccbOwner.node_info:stopAllActions()
    local posX = -37 -- off
    if self._isInfoON == self.VIEW_ON then
    	posX = 220 -- on
    end
    if isAnimation then
    	local actions = CCArray:create()
    	actions:addObject( CCMoveTo:create(0.2, ccp(posX, 0)) )
    	actions:addObject( CCCallFunc:create(function()
            if self._isInfoON == self.VIEW_ON then
		    	self._ccbOwner.tf_direction:setScaleX(-1)
		    else
		    	self._ccbOwner.tf_direction:setScaleX(1)
		    end
        end) )
    	self._ccbOwner.node_info:runAction( CCSequence:create(actions) )
	else
    	self._ccbOwner.node_info:setPositionX(posX)
    	if self._isInfoON == self.VIEW_ON then
	    	self._ccbOwner.tf_direction:setScaleX(-1)
	    else
	    	self._ccbOwner.tf_direction:setScaleX(1)
	    end
	end
end

function QUIDialogFashionCombinationMain:_doListViewEffect(isAnimation)
    self._ccbOwner.node_list:stopAllActions()
    local posY = -80 -- off
    if self._isListON == self.VIEW_ON then
    	posY = 0 -- on
    end
    if isAnimation then
    	local actions = CCArray:create()
    	actions:addObject( CCMoveTo:create(0.2, ccp(0, posY)) )
    	self._ccbOwner.node_list:runAction( CCSequence:create(actions) )
	else
    	self._ccbOwner.node_list:setPositionY(posY)
	end
end
return QUIDialogFashionCombinationMain
