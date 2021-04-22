--
-- Kumo.Wang
-- 時裝衣櫃主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFashionMain = class("QUIDialogFashionMain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")
local QUIWidget = import("..widgets.QUIWidget")

local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetFashionMainMenu = import("..widgets.QUIWidgetFashionMainMenu")

QUIDialogFashionMain.SHOW_IMG = 1
QUIDialogFashionMain.SHOW_AVATAR = -1

QUIDialogFashionMain.IS_SHOW_BOOK_EFFECT = false
QUIDialogFashionMain.BOOK_EFFECT_DISTANCE = 880
QUIDialogFashionMain.BOOK_ON = 1
QUIDialogFashionMain.BOOK_OFF = -1

function QUIDialogFashionMain:ctor(options)
	local ccbFile = "ccb/Dialog_Fashion_Main.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerFashionCombination", callback = handler(self, self._onTriggerFashionCombination)},
		{ccbCallbackName = "onTriggerFashionType", callback = handler(self, self._onTriggerFashionType)},
		{ccbCallbackName = "onTriggerSwitch", callback = handler(self, self._onTriggerSwitch)},
		{ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
        {ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
        {ccbCallbackName = "onTriggerActive", callback = handler(self, self._onTriggerActive)},
        {ccbCallbackName = "onTriggerPropInfo", callback = handler(self, self._onTriggerPropInfo)},
        {ccbCallbackName = "onTriggerCardInfo", callback = handler(self, self._onTriggerCardInfo)},
        {ccbCallbackName = "onTriggerShareSDK", callback = handler(self, self._onTriggerShareSDK)},
    }
    QUIDialogFashionMain.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.setManyUIVisible then page:setManyUIVisible() end
	if page and page.topBar and page.topBar.showWithHeroOverView then
    	page.topBar:showWithHeroOverView()
    end

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self._ccbOwner.node_center_top:setVisible(false)

	self._isActionMove = true
	q.setButtonEnableShadow(self._ccbOwner.btn_switch)
	q.setButtonEnableShadow(self._ccbOwner.btn_goto)
	q.setButtonEnableShadow(self._ccbOwner.btn_active)
	q.setButtonEnableShadow(self._ccbOwner.btn_fashion_combination)
	q.setButtonEnableShadow(self._ccbOwner.btn_card_info)
	q.setButtonEnableShadow(self._ccbOwner.btn_prop_info)
	q.setButtonEnableShadow(self._ccbOwner.btn_share)
    if options then
    	--[[
			补充案子里没有的规则：
			1、3个数据互为关联，但，以selectedSkinId、selectedHeroId、selectedSkinQuality为顺序修正
			2、如果3个数据全部缺失，显示QFashion.BEST_QUALITY
    	]]
    	self._selectedSkinId = options.selectedSkinId -- 指定皮肤id
    	self._selectedHeroId = options.selectedHeroId -- 指定英雄id
    	self._selectedSkinQuality = options.selectedSkinQuality -- 指定皮肤品质
    end

    local tabs = {}
    for _, quality in ipairs(remote.fashion.allQuality) do
    	local btn = self._ccbOwner["btn_"..quality]
    	if btn then
    		ui.tabButton(btn, remote.fashion:getQualityCNameByQuality(quality))
    		table.insert(tabs, btn)
    	end
    	local sp = self._ccbOwner["node_tips_"..quality]
    	if sp then
    		sp:setVisible(false)
    	end
    	local scrollEffect = self._ccbOwner["fca_scroll_effect_"..quality]
    	if scrollEffect then
    		scrollEffect:setVisible(false)
    	end
    end
    self._tabManager = ui.tabManager(tabs)

    self._ccbOwner.fca_btn_effect:setVisible(false)
    --先创建遮罩，在init节点
    self._lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), 0, 600)
    local ccclippingNode = CCClippingNode:create()
    self._lyImageMask:setPositionX(self._ccbOwner.node_menu_bg_mask:getPositionX())
    self._lyImageMask:setPositionY(self._ccbOwner.node_menu_bg_mask:getPositionY())
    self._lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.node_menu_bg_mask:isIgnoreAnchorPointForPosition())
    self._lyImageMask:setAnchorPoint(self._ccbOwner.node_menu_bg_mask:getAnchorPoint())
    ccclippingNode:setStencil(self._lyImageMask)
    ccclippingNode:setInverted(false)
    self._ccbOwner.node_root:retain()
    self._ccbOwner.node_root:removeFromParent()
    ccclippingNode:addChild(self._ccbOwner.node_root)
    self._ccbOwner.node_mask_action:addChild(ccclippingNode)
    self._ccbOwner.node_root:release()

    self:_init()
end

function QUIDialogFashionMain:viewDidAppear()
	QUIDialogFashionMain.super.viewDidAppear(self)

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if page and page.setManyUIVisible then page:setManyUIVisible() end
	if page and page.topBar and page.topBar.showWithHeroOverView then
    	page.topBar:showWithHeroOverView()
    end

	self:addBackEvent(true)

	self:_doBookViewEffect()
	self:_initMenuListView()
	self:_initProgressBar()
	self:_updateRedTips()

	local tagetPos = self._ccbOwner.sp_scroll:getPosition()  --(-470,-28)
    local startPosX = self._ccbOwner.sp_scroll:getPositionX()
    self._moveipase = 4.0/3.0*2
    local moveFunc = function(dt)
    	if self._lyImageMask:getContentSize().width >= 1000 then
    		self._isActionMove = false
    		self:updateScrollEffect()
			if self._timeScheduler then
				scheduler.unscheduleGlobal(self._timeScheduler)
				self._timeScheduler = nil
			end
			return
		end
		-- self._moveipase = self._moveipase*0.9
		local startPosX = self._ccbOwner.sp_scroll:getPositionX()
		if startPosX-1000/60*self._moveipase <= -470 then
			self._ccbOwner.sp_scroll:setPositionX(-470)
			self._lyImageMask:setContentSize(CCSize(1000,600))
		else
			self._ccbOwner.sp_scroll:setPositionX(startPosX-1000/60*self._moveipase)
		end
		self._lyImageMask:setContentSize(CCSize(self._lyImageMask:getContentSize().width+ 1000/60*self._moveipase,600))
		-- self._moveipase = self._moveipase + 1
    end
    self._timeScheduler = scheduler.scheduleGlobal(moveFunc, 1/45)
	moveFunc()
end


function QUIDialogFashionMain:viewWillDisappear()
  	QUIDialogFashionMain.super.viewWillDisappear(self)

	self:removeBackEvent()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end	
end

function QUIDialogFashionMain:_init()
	print("[QUIDialogFashionMain:_init()] ", self._selectedSkinId, self._selectedSkinQuality, self._selectedSkinQuality)
	if self._selectedSkinId then
		local skinConfig = remote.fashion:getSkinConfigDataBySkinId(self._selectedSkinId)
		self._selectedHeroId = skinConfig.character_id
		self:getOptions().selectedHeroId = self._selectedHeroId
		self._selectedSkinQuality = skinConfig.quality
		self:getOptions().selectedSkinQuality = self._selectedSkinQuality
    elseif self._selectedHeroId then
    	local skinConfig = remote.fashion:getSkinConfigDataByHeroId(self._selectedHeroId, self._selectedSkinQuality)
    	self._selectedSkinId = skinConfig.skins_id
    	self:getOptions().selectedSkinId = self._selectedSkinId
		self._selectedSkinQuality = skinConfig.quality
		self:getOptions().selectedSkinQuality = self._selectedSkinQuality
    elseif self._selectedSkinQuality then
    	-- nothing to do
    else
    	self._selectedSkinQuality = remote.fashion.TOP_QUALITY
    	self:getOptions().selectedSkinQuality = self._selectedSkinQuality
    end

    if self.IS_SHOW_BOOK_EFFECT and not self._bookClippingNode then
	    -- 書卷遮罩
	    local maskSize = self._ccbOwner.node_book_mask:getContentSize()
		local lyMask = CCLayerColor:create(ccc4(0,0,0,150), maskSize.width, maskSize.height)
		self._bookClippingNode = CCClippingNode:create()
		lyMask:setPositionX(self._ccbOwner.node_book_mask:getPositionX())
		lyMask:setPositionY(self._ccbOwner.node_book_mask:getPositionY())
		lyMask:ignoreAnchorPointForPosition(self._ccbOwner.node_book_mask:isIgnoreAnchorPointForPosition())
		lyMask:setAnchorPoint(self._ccbOwner.node_book_mask:getAnchorPoint())
		self._bookClippingNode:setStencil(lyMask)
		self._bookClippingNode:setInverted(false)
		self._ccbOwner.node_book:retain()
		self._ccbOwner.node_book:removeFromParent()
		self._bookClippingNode:addChild(self._ccbOwner.node_book)
		self._ccbOwner.node_book_view:addChild(self._bookClippingNode)
		self._ccbOwner.node_book:release()
		self._ccbOwner.node_book:setPositionX(self._ccbOwner.node_book_mask:getPositionX())
		self._ccbOwner.node_book:setPositionY(self._ccbOwner.node_book_mask:getPositionY())
		self._ccbOwner.node_book:ignoreAnchorPointForPosition(self._ccbOwner.node_book_mask:isIgnoreAnchorPointForPosition())
		self._ccbOwner.node_book:setAnchorPoint(self._ccbOwner.node_book_mask:getAnchorPoint())
	end

    -- 展示區遮罩
    self._maskSize = self._ccbOwner.node_mask:getContentSize()
	local lyMask = CCLayerColor:create(ccc4(0,0,0,150), self._maskSize.width, self._maskSize.height)
	local ccclippingNode = CCClippingNode:create()
	lyMask:setPositionX(self._ccbOwner.node_mask:getPositionX())
	lyMask:setPositionY(self._ccbOwner.node_mask:getPositionY())
	lyMask:ignoreAnchorPointForPosition(self._ccbOwner.node_mask:isIgnoreAnchorPointForPosition())
	lyMask:setAnchorPoint(self._ccbOwner.node_mask:getAnchorPoint())
	ccclippingNode:setStencil(lyMask)
	ccclippingNode:setInverted(false)
	self._ccbOwner.node_display:retain()
	self._ccbOwner.node_display:removeFromParent()
	ccclippingNode:addChild(self._ccbOwner.node_display)
	self._ccbOwner.node_fashion_view:addChild(ccclippingNode)
	self._ccbOwner.node_display:release()
	self._ccbOwner.node_display:setPositionX(self._ccbOwner.node_mask:getPositionX())
	self._ccbOwner.node_display:setPositionY(self._ccbOwner.node_mask:getPositionY())
	self._ccbOwner.node_display:ignoreAnchorPointForPosition(self._ccbOwner.node_mask:isIgnoreAnchorPointForPosition())
	self._ccbOwner.node_display:setAnchorPoint(self._ccbOwner.node_mask:getAnchorPoint())

	-- -- 校準avatar按鈕
	-- self._ccbOwner.btn_avatar:setPreferredSize(self._maskSize)
	-- self._ccbOwner.btn_avatar:setPosition(ccp(self._ccbOwner.node_mask:getPositionX(), self._ccbOwner.node_mask:getPositionY()))
	-- self._ccbOwner.btn_avatar:ignoreAnchorPointForPosition(self._ccbOwner.node_mask:isIgnoreAnchorPointForPosition())
	-- self._ccbOwner.btn_avatar:setAnchorPoint(self._ccbOwner.node_mask:getAnchorPoint())

	-- 計算ccb展示縮放比
	if not self._ccbScale then
		-- 预设宽高，数据来自于ccb
		local _width = 1136
		local _height = 640
		self._ccbScale = math.min(self._maskSize.width/_width, self._maskSize.height/_height)
	end

	-- 初始化进度条
	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.sp_progress_bar:getPositionX() -- 这个坐标必须sp_progress_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress_bar)
		self._totalStencilWidth = self._ccbOwner.sp_progress_bar:getContentSize().width * self._ccbOwner.sp_progress_bar:getScaleX()
	end

	-- 默认显示原画
	self._showType = self.SHOW_IMG

	self._avatarName = {}
    self._totalRate = 0
    self._canActive = false -- 是否可以激活
    self._isBookON = self.BOOK_ON

    self:_update()
end

function QUIDialogFashionMain:updateScrollEffect( )
	if self._isActionMove then return end
	for _, quality in ipairs(remote.fashion.allQuality) do
		local scrollEffect = self._ccbOwner["fca_scroll_effect_"..quality]
		if scrollEffect then
			if tostring(quality) == tostring(self._selectedSkinQuality) then
	    		scrollEffect:setVisible(true)
	    	else
	    		scrollEffect:setVisible(false)
			end
		end
	end
end

function QUIDialogFashionMain:_update(isDefault)
	if not self._selectedSkinQuality then return end

	local scrollPathList = QResPath("fashionScroll")
	if scrollPathList and #scrollPathList > 0 and scrollPathList[tonumber(self._selectedSkinQuality)] then
		QSetDisplayFrameByPath(self._ccbOwner.sp_scroll, scrollPathList[tonumber(self._selectedSkinQuality)])
	end

	self:updateScrollEffect()

	self._tabManager:selected(self._ccbOwner["btn_"..self._selectedSkinQuality])

	local skinConfigList = remote.fashion:getSkinConfigDataListByQuality(self._selectedSkinQuality)
	if q.isEmpty(skinConfigList) then
		return 
	end
	if not self._selectedSkinId or isDefault then
		self._selectedSkinId = skinConfigList[1].skins_id
		self:getOptions().selectedSkinId = self._selectedSkinId
	end
	if not self._selectedHeroId or isDefault then
		self._selectedHeroId = skinConfigList[1].character_id
		self:getOptions().selectedHeroId = self._selectedHeroId
	end
	self._menuData = skinConfigList

	if self._menuBtnListView then
		self._menuBtnListView:clear(true)
		self._menuBtnListView = nil
	end

	self:_initMenuListView()
end

function QUIDialogFashionMain:_updateSkinView()
	if not self._selectedSkinId or not self._selectedHeroId then return end

	self._ccbOwner.node_display:removeAllChildren()
	self._ccbOwner.node_avatar:removeAllChildren()
	self._avatarName = {} 

	local skinConfig = remote.fashion:getSkinConfigDataBySkinId(self._selectedSkinId)
	if skinConfig then
		if not skinConfig.skins_card or not skinConfig.skins_ccb then
			-- self._ccbOwner.btn_switch:setEnabled(false)
			-- makeNodeFromNormalToGray(self._ccbOwner.btn_switch)
			self._ccbOwner.node_btn_switch:setVisible(false)
			self._ccbOwner.node_btn_goto:setPositionY(172)

		else
			-- self._ccbOwner.btn_switch:setEnabled(true)
			-- makeNodeFromGrayToNormal(self._ccbOwner.btn_switch)
			self._ccbOwner.node_btn_switch:setVisible(true)
			self._ccbOwner.node_btn_goto:setPositionY(109)
	    end
   	end

   	if remote.fashion:checkExistHeroById(self._selectedHeroId) then
		self._ccbOwner.node_btn_goto:setVisible(true)
		self._ccbOwner.node_share:setPositionY(55)
   	else
		self._ccbOwner.node_btn_goto:setVisible(false)
		self._ccbOwner.node_share:setPositionY(111)
   	end

	if self._showType == self.SHOW_IMG then
		self:_showImg()
	else
		self:_showAvatar()
	end

	local nameStr = ""
	if skinConfig and skinConfig.skins_name then
		nameStr = nameStr..skinConfig.skins_name.."·"
	end
	local characterConfig = db:getCharacterByID(self._selectedHeroId)
	if characterConfig then
		q.setAptitudeShow(self._ccbOwner, nil, characterConfig.aptitude)
		if characterConfig.name then
			nameStr = nameStr..characterConfig.name
		end
	end
	self._ccbOwner.tf_name:setString(nameStr)

	self._ccbOwner.btn_card_info:setPositionX(self._ccbOwner.tf_name:getPositionX() + self._ccbOwner.tf_name:getContentSize().width + 20)
end

function QUIDialogFashionMain:_showImg()
	-- self._showType = self.SHOW_IMG

	self._ccbOwner.node_name_view:setVisible(true)
	self._ccbOwner.node_display_frame:setVisible(true)
	self._ccbOwner.btn_card_info:setVisible(true)

	if remote.shareSDK:checkIsOpen() then
		local isActivity = remote.fashion:checkSkinActivityBySkinId(self._selectedSkinId) or false
		self._ccbOwner.node_share:setVisible(isActivity)
	else
		self._ccbOwner.node_share:setVisible(false)
	end

    self._shareInfo = remote.shareSDK:getShareConfigById(self._selectedSkinId,remote.shareSDK.SKIN)
    if q.isEmpty(self._shareInfo) then
    	self._ccbOwner.node_share:setVisible(false)
    end
    
	local spPath = nil
	local ccbPath = nil
	local skinConfig = remote.fashion:getSkinConfigDataBySkinId(self._selectedSkinId)
	if skinConfig then
		if skinConfig.skins_card then
	        spPath = skinConfig.skins_card
	    end
	    if skinConfig.skins_ccb then
	        ccbPath = skinConfig.skins_ccb
	    end
   	end

	local characterConfig = db:getCharacterByID(self._selectedHeroId)
	if characterConfig then
		-- if not spPath and characterConfig.card then
	 --        spPath = characterConfig.card
	 --    end
	    -- if not ccbPath and characterConfig.chouka_show2 then
	    --     ccbPath = characterConfig.chouka_show2
	    -- end

	    if characterConfig.aptitude and (characterConfig.aptitude == APTITUDE.SS or characterConfig.aptitude == APTITUDE.SSR) then
	    	if ccbPath then
	    		print("[QUIDialogFashionMain:_updateSkinView()] ccb", ccbPath)
	            local widget = QUIWidget.new(ccbPath)
	            if widget._ccbOwner.sp_ad then
	                widget._ccbOwner.sp_ad:setVisible(false)
	            end
	            if widget._ccbOwner.sp_hero_introduce then
                    widget._ccbOwner.sp_hero_introduce:setVisible(false)
                end
                widget:setScale(self._ccbScale)
                local width = display.width *self._ccbScale
                local height = display.height *self._ccbScale
                widget:setPosition(ccp(- width/2, - height/2))
	            self._ccbOwner.node_display:addChild(widget)
	            return
	        end
		end
   	end

   	if spPath then
	   	local sprite = CCSprite:create(spPath)
		if sprite then
			print("[QUIDialogFashionMain:_updateSkinView()] sp", spPath)
			local _width = sprite:getContentSize().width
			local _height = sprite:getContentSize().height
			local scale = self._maskSize.width/_width
			scale = math.max(self._maskSize.width/_width, self._maskSize.height/_height)
			sprite:setScale(scale)
			sprite:setPosition(ccp(0, 0))
			self._ccbOwner.node_display:addChild(sprite)
			return
		end
	end

	self:_showAvatar()
end

function QUIDialogFashionMain:_showAvatar()
	-- self._showType = self.SHOW_AVATAR

	self._ccbOwner.node_name_view:setVisible(true)
	self._ccbOwner.node_display_frame:setVisible(false)
	self._ccbOwner.btn_card_info:setVisible(false)
	self._ccbOwner.node_share:setVisible(false)

	local avatarBgList = QResPath("fashionDisplayBg")
	if avatarBgList and #avatarBgList > 0 and avatarBgList[tonumber(self._selectedSkinQuality)] then
		local spPath = avatarBgList[tonumber(self._selectedSkinQuality)]
	   	local sprite = CCSprite:create(spPath)
		if sprite then
			-- local _width = sprite:getContentSize().width
			-- local _height = sprite:getContentSize().height
			-- local scale = self._maskSize.width/_width
			-- sprite:setScale(scale)
			sprite:setPosition(ccp(0, 0))
			self._ccbOwner.node_avatar:addChild(sprite)
		end
	end

	local skinConfig = remote.fashion:getSkinConfigDataBySkinId(self._selectedSkinId)
	if skinConfig then
	    self:_updateAvatarActionList(skinConfig.information_action_skins)
	    self._avatar = QUIWidgetActorDisplay.new(self._selectedHeroId, {heroInfo = {skinId = self._selectedSkinId}})
	    self._ccbOwner.node_avatar:addChild(self._avatar)
	    self._avatar:setScaleX(-1.2)
	    self._avatar:setScaleY(1.2)
	    self._avatar:setPosition(ccp(-20, -120))
	else
		self._avatar = nil
   	end
end

function QUIDialogFashionMain:_updateAvatarActionList(skinActionStr)
	self._avatarName = {}

    local actionStr
    local characterConfig = db:getCharacterByID(self._selectedHeroId)
    if skinActionStr then
        print("[SKIN_ACTION] ", skinActionStr)
        actionStr = skinActionStr
    elseif characterConfig then
        print("[NORMAL_ACTION] ", characterConfig.information_action)
        actionStr = characterConfig.information_action
    end
    if actionStr ~= nil then
        local actionArr = string.split(actionStr, ";")
        if actionArr ~= false then
            for _, value in pairs(actionArr) do
                local arr = string.split(value, ":")
                self._totalRate = self._totalRate + tonumber(arr[2])
                table.insert(self._avatarName, {name = arr[1], rate = tonumber(arr[2])})
            end
        end
    end
end

function QUIDialogFashionMain:_initMenuListView()
	if not self._menuData then return end

	-- QKumo(self._menuData)
	if not self._menuBtnListView then
		for index, data in ipairs(self._menuData) do
			if tostring(data.skins_id) == tostring(self._selectedSkinId) then
				self._menuPos = index
        		self:_updateSkinView()
			end
		end

		local _curOffset = 0
		if #self._menuData < 4 then
			local height = self._ccbOwner.node_menu_list_view:getContentSize().height
			local tmpCell = QUIWidgetFashionMainMenu.new()
			_curOffset = height - tmpCell:getContentSize().height
		end
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local itemData = self._menuData[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetFashionMainMenu.new()
            		item:addEventListener(QUIWidgetFashionMainMenu.EVENT_CLICK, handler(self, self._menuBtnClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()

	            if item.getInfo and item.setSelect then
	            	local info = item:getInfo()
	            	if self._selectedSkinId and tostring(info.skins_id) == tostring(self._selectedSkinId) then
	            		item:setSelect(true)
	            		self._selectMenuItem = item
	            	else
	            		item:setSelect(false)
	            	end
	            end

                list:registerBtnHandler(index, "btn_click", "onTriggerClick")
	            return isCacheNode
	        end,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = false,
	      	topShadow = self._ccbOwner.node_up,
	      	bottomShadow = self._ccbOwner.node_down,
	      	curOffset = _curOffset,
	        totalNumber = #self._menuData,
		}
		self._menuBtnListView = QListView.new(self._ccbOwner.node_menu_list_view, cfg)
	else
		self._menuBtnListView:reload({totalNumber = #self._menuData})
	end

	self:_startScrollToSelected()
end

function QUIDialogFashionMain:_startScrollToSelected()
    if self._menuPos and self._menuPos > 0 then
        self._menuBtnListView:startScrollToIndex(self._menuPos, false, 100)
    end
end

function QUIDialogFashionMain:_menuBtnClickHandler(event)
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

	if not self._selectMenuItem or (item.setSelect and self._selectMenuItem.setSelect and self._selectedSkinId ~= itemData.skins_id) then
		if self._selectMenuItem then
			self._selectMenuItem:setSelect(false)
		end
		self._selectedSkinId = itemData.skins_id
		self:getOptions().selectedSkinId = self._selectedSkinId
		self._selectedHeroId = itemData.character_id
		self:getOptions().selectedHeroId = self._selectedHeroId
		self._selectedSkinQuality = itemData.quality
		self:getOptions().selectedSkinQuality = self._selectedSkinQuality

		item:setSelect(true)
		self._selectMenuItem = item

		self:_updateSkinView()
    end
end

function QUIDialogFashionMain:_initProgressBar()
	self:_updateProgressBar()
end

function QUIDialogFashionMain:_updateProgressBar(isAnimation)
	if not self._percentBarClippingNode then
		self._totalStencilPosition = self._ccbOwner.sp_progress_bar:getPositionX() -- 这个坐标必须sp_progress_bar节点的锚点为(0, 0.5)
		self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_progress_bar)
		self._totalStencilWidth = self._ccbOwner.sp_progress_bar:getContentSize().width * self._ccbOwner.sp_progress_bar:getScaleX()
	end
	local stencil = self._percentBarClippingNode:getStencil()
	stencil:setPositionX(0)
	self._ccbOwner.tf_progress_bar:setString("")
	self._canActive = false -- 是否可以激活
	self._ccbOwner.fca_btn_effect:setVisible(false)

	print("[QUIDialogFashionMain:_updateProgressBar()] ", self._selectedSkinQuality)
	local skinConfigList = remote.fashion:getSkinConfigDataListByQuality(self._selectedSkinQuality)
	if q.isEmpty(skinConfigList) then
		return 
	end
	
	-- 气泡
    if not self._rtfBubble then
    	self._ccbOwner.node_tf_bubble:removeAllChildren()
    	self._rtfBubble = QRichText.new(nil, 200, {autoCenter = true})
        self._rtfBubble:setAnchorPoint(ccp(0.5, 0.5))
        self._ccbOwner.node_tf_bubble:addChild(self._rtfBubble)
		self._ccbOwner.node_bubble:setVisible(true)
    end

	local curConfig, nextConfig = remote.fashion:getActivedWardrobeConfigAndNextConfigByQuality( self._selectedSkinQuality )
	QKumo(nextConfig)
	if not nextConfig then 
		self._rtfBubble:setString({
	            {oType = "font", content = "已收集满", size = 20, color = COLORS.j},
	            -- {oType = "wrap"},
	        })

		stencil:setPositionX(0)
		if curConfig then
			self._ccbOwner.tf_progress_bar:setString(curConfig.condition.."/"..curConfig.condition)
		end
		return 
	else
		if nextConfig.desc then
			local strText = nextConfig.desc or ""
    		local tbl = string.split(strText, "\n")
			local textTbl = {}
		    for _, v in ipairs(tbl) do
		        if #textTbl ~= 0 then
		            table.insert(textTbl, {oType = "wrap"})
		        end
		        table.insert(textTbl, {oType = "font", content = v, size = 18, color = COLORS.j})
		    end
    		self._rtfBubble:setString(textTbl)
       	end
	end

	self._nextConfig = nextConfig

	local needCount = tonumber(nextConfig.condition)
	
	local acvitityCount = 0
	for _, v in ipairs(skinConfigList) do
		local isActivity = remote.fashion:checkSkinActivityBySkinId(v.skins_id)
		if isActivity then
			acvitityCount = acvitityCount + 1
		end
	end

	local curProportion = acvitityCount / needCount
	if curProportion >= 1 then 
		acvitityCount = needCount
		curProportion = 1 
		self._canActive = true
		self._ccbOwner.fca_btn_effect:setVisible(true)
	end

	if isAnimation then
		stencil:stopAllActions()
		stencil:setPositionX(-self._totalStencilWidth)
		local actions = CCArray:create()
		actions:addObject( CCMoveTo:create(0.5, ccp(-self._totalStencilWidth + curProportion * self._totalStencilWidth, 0)) )
    	actions:addObject( CCCallFunc:create(function()
    		if self:safeCheck() then
    			
	    	end
        end) )
    	stencil:runAction( CCSequence:create(actions) )
	else
		stencil:setPositionX(-self._totalStencilWidth + curProportion * self._totalStencilWidth)
	end
	self._ccbOwner.tf_progress_bar:setString(acvitityCount.."/"..needCount)
end

function QUIDialogFashionMain:_updateRedTips()
	self._ccbOwner.sp_red_tips:setVisible(remote.fashion:checkFashionCombinationRedTips())
	for _, quality in ipairs(remote.fashion.allQuality) do
		local sp = self._ccbOwner["node_tips_"..quality]
		if sp then
			sp:setVisible(remote.fashion:checkFashionRedTipByQuality(quality))
		end
	end
end

function QUIDialogFashionMain:_onTriggerFashionCombination()
	app.sound:playSound("common_small")
	remote.fashion:openDialogForFashionCombination()
end

function QUIDialogFashionMain:_onTriggerFashionType(event, target)
	app.sound:playSound("common_small")
	local index = 1
	local isEffect = false
	while true do
		local btn = self._ccbOwner["btn_"..index]
		if btn then
			if btn == target then
				if self._selectedSkinQuality ~= index and self.IS_SHOW_BOOK_EFFECT then
					isEffect = true
				end
				self._selectedSkinQuality = index
				self:getOptions().selectedSkinQuality = self._selectedSkinQuality
				break
			end
			index = index + 1
		else
			break
		end
	end

	if isEffect then
		self._isBookON = self.BOOK_OFF
		self:_doBookViewEffect(true)
	else
		self:_update(true)
		self:_updateProgressBar()
	end
end

function QUIDialogFashionMain:_onTriggerSwitch()
	app.sound:playSound("common_small")
	self._showType = - self._showType
	self:_updateSkinView()
end

function QUIDialogFashionMain:_onTriggerGoto()
	app.sound:playSound("common_small")

	print("[QUIDialogFashionMain:_onTriggerGoto()] self._selectedHeroId : ", self._selectedHeroId)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroSkin", 
        options = {actorId = self._selectedHeroId, skinId = self._selectedSkinId}})
end

function QUIDialogFashionMain:_onTriggerActive()
	app.sound:playSound("common_small")
	if not self._canActive or q.isEmpty(self._nextConfig) or not self._nextConfig.id then
		-- app.tip:floatTip("激活条件未满足！")
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionPropInfo", 
        	options = {quality = self._selectedSkinQuality}})
		return 
	end

	remote.fashion:userSkinWardrobeActiveRequest(self._nextConfig.id, function()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionSuccess", 
	        	options = {id = self._nextConfig.id, type = remote.fashion.FUNC_TYPE_FASHION, callback = function()
	        		if self:safeCheck() then
						self:_update()
						self:_updateProgressBar(true)
						self:_updateRedTips()
					end
	        	end}})
		end)
end

function QUIDialogFashionMain:_onTriggerAvatar()
	if self._showType == self.SHOW_IMG then return end

    self:_randomPlayAvatar()
end

function QUIDialogFashionMain:_randomPlayAvatar()
    if #self._avatarName == 0 or self._totalRate == 0 then return end

    local num = math.random(self._totalRate)
    local rate = 0
    local actionName = nil
    for _,value in pairs(self._avatarName) do
        if num < (rate + value.rate) then
            actionName = value.name
            break
        end
        rate = rate + value.rate
    end
    if actionName ~= nil then
        self:_avatarPlayAnimation(actionName, true)
    end
end

--显示特效
function QUIDialogFashionMain:_avatarPlayAnimation(value, isPalySound, callback)
    if self._avatar ~= nil then
        self._avatar:displayWithBehavior(value)
        self._avatar:setDisplayBehaviorCallback(callback)
        if isPalySound ~= nil or isPalySound == true then
            self:_playSound(value)
        end
    end
end

function QUIDialogFashionMain:_playSound(value)
    if self._avatarSound ~= nil then
        app.sound:stopSound(self._avatarSound)
        self._avatarSound = nil
    end

    local cheer = nil
    local walk = nil
    local skinConfig = remote.fashion:getSkinConfigDataBySkinId(self._selectedSkinId)
    if skinConfig then
        cheer = skinConfig.cheer
        walk = skinConfig.walk
    end

    local characterConfig = db:getCharacterByID(self._selectedHeroId)
    if characterConfig then
	    if not cheer then
	        cheer = characterConfig.cheer
	    end
	    if not walk then
	        walk = characterConfig.walk
	    end
	end

    if value == ANIMATION_EFFECT.VICTORY then
    	if cheer then
        	self._avatarSound = app.sound:playSound(cheer)
        end
    elseif value == ANIMATION_EFFECT.WALK then
    	if walk then
        	self._avatarSound = app.sound:playSound(walk)
        end
    end
end

function QUIDialogFashionMain:_doBookViewEffect(isAnimation)
	self._ccbOwner.node_book:stopAllActions()
    local posX = -833 -- off
    if self._isBookON == self.BOOK_ON then
    	posX = 47 -- on
    end
    if isAnimation then
    	local actions = CCArray:create()
    	actions:addObject( CCMoveTo:create(0.5, ccp(posX, -30)) )
    	actions:addObject( CCCallFunc:create(function()
    		if self:safeCheck() then
    			if self._isBookON == self.BOOK_OFF then
		    		self._isBookON = self.BOOK_ON
		    		self:_doBookViewEffect(true)
		    		self:_update(true)
					self:_updateProgressBar()
	    		end
	    	end
        end) )
    	self._ccbOwner.node_book:runAction( CCSequence:create(actions) )
	else
    	self._ccbOwner.node_book:setPositionX(posX)
	end
end

function QUIDialogFashionMain:_onTriggerPropInfo()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAllFashionPropInfo", 
        options = {}}) 
end

function QUIDialogFashionMain:_onTriggerCardInfo()
	app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHandBookHeroImageCard", 
        options = {actorId = self._selectedHeroId, skinId = self._selectedSkinId}}) 
end

function QUIDialogFashionMain:_onTriggerShareSDK( event )
    app.sound:playSound("common_small")

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogShareSDK", 
        options = {shareInfo = self._shareInfo}}, {isPopCurrentDialog = false}) 
end
return QUIDialogFashionMain
