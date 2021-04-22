--
-- Author: xurui
-- Date: 2015-04-20 15:41:58
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMall = class("QUIDialogMall", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QShop = import("...utils.QShop")
local QUIViewController = import("..QUIViewController")
local QUIWidgetStoreBoss = import("..widgets.QUIWidgetStoreBoss")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetEnchantOrient = import("..widgets.QUIWidgetEnchantOrient")
local QUIWidgetMountOrient = import("..widgets.mount.QUIWidgetMountOrient")
local QUIWidgetGemstoneOrient = import("..widgets.QUIWidgetGemstoneOrient")
local QUIWidgetMagicHerbOrient = import("..widgets.QUIWidgetMagicHerbOrient")
local QListView = import("...views.QListView")
local QUIWidgetMallVipBox = import("..widgets.QUIWidgetMallVipBox")
local QUIWidgetMallItemBox = import("..widgets.QUIWidgetMallItemBox")
local QUIWidgetMaillButton = import("..widgets.QUIWidgetMaillButton")
local QUIWidgetMallSkinItemBox = import("..widgets.QUIWidgetMallSkinItemBox")

QUIDialogMall.NORMAL_SKIN = 1
QUIDialogMall.GAOJI_SKIN = 2

QUIDialogMall.MALL_BOX_CLICK = "MALL_BOX_CLICK"
QUIDialogMall.MALL_VIP_BOX_ICON_CLICK = "MALL_VIP_BOX_ICON_CLICK"

QUIDialogMall.ITEM_MALL_TYPE = "ITEM_MALL_TYPE"
QUIDialogMall.WEEK_MALL_TYPE = "WEEK_MALL_TYPE"
QUIDialogMall.VIP_MALL_TYPE = "VIP_MALL_TYPE"
QUIDialogMall.ENCHANT_ORIENT_TYPE = "ENCHANT_ORIENT_TYPE"
QUIDialogMall.MOUNT_TYPE = "MOUNT_TYPE"
QUIDialogMall.GEMSTONE_TYPE = "GEMSTONE_TYPE"
QUIDialogMall.MAGICHERB_TYPE = "MAGICHERB_TYPE"
QUIDialogMall.SKINSHOP_TYPE = "SKINSHOP_TYPE"
function QUIDialogMall:ctor(options)
	local ccbFile = "ccb/Dialog_ShopVIP.ccbi"
	local callBacks = {
		{ccbCallbackName = "omTriggerRecharge", callback = handler(self, self._onTriggerRecharge)},
		{ccbCallbackName = "onTriggerGaojiSkin", callback = handler(self, self._onTriggerGaojiSkin)},
		{ccbCallbackName = "onTriggerNormalSkin", callback = handler(self, self._onTriggerNormalSkin)},
		{ccbCallbackName = "onTriggerSelectNoGet", callback = handler(self, self._onTriggerSelectNoGet)},
	}
	QUIDialogMall.super.ctor(self, ccbFile, callBacks, options)
  	self._mainPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
  	self._mainPage._scaling:willPlayHide()
  	self._mainPage:setManyUIVisible(false)
  	
    CalculateUIBgSize(self._ccbOwner.node_bg, 1280)

	self._ccbOwner.enchant_bg:setVisible(false)
	self._ccbOwner.weapon_bg:setVisible(false)
	self._ccbOwner.gemstone_bg:setVisible(false)
	self._ccbOwner.magicHerb_bg:setVisible(false)
	self._ccbOwner.mall_bg:setVisible(false)
	self._ccbOwner.skinshop_bg:setVisible(false)

	self._skinTabIndex = options.skinTalType or QUIDialogMall.GAOJI_SKIN
	if options.tab ~= nil then
		self._tabType = options.tab
		self._itemId = options.itemId 
	else
		if app.unlock:getUnlockEnchant() then
			self._tabType = QUIDialogMall.ENCHANT_ORIENT_TYPE
			self._mainPage.topBar:showWithEnchantOrient()
		else
			self._tabType = QUIDialogMall.ITEM_MALL_TYPE
		end
	end
	self._curSelectBtnIndex = options.curIndex or 1

  	self._shopID = SHOP_ID.itemShop

  	self._chooseShowNotGet = app:getUserOperateRecord():getRecordByType("MALL_SKIN_CHOOSE") or false
  	self._ccbOwner.sp_select:setVisible(self._chooseShowNotGet)

  	self._touchIndex = 1

  	self._ccbOwner.vip_is_null:setVisible(false)

  	local noAuto = false
  	if self._tabType == QUIDialogMall.ENCHANT_ORIENT_TYPE then noAuto = true end
 	
 	local layoutSize = self._ccbOwner.sheet_layout:getContentSize()
 	layoutSize.width = display.width - 390
 	self._ccbOwner.sheet_layout:setContentSize(CCSize(layoutSize.width,layoutSize.height))

  	self:showRechargeBtn(false)

end

function QUIDialogMall:viewDidAppear()
	QUIDialogMall.super.viewDidAppear(self)
 	self._shopEventProxy = cc.EventProxy.new(remote)
  	self._shopEventProxy:addEventListener(remote.STORES_UPDATE_EVENT, handler(self, self.sellItem))
	-- self:addBackEvent(false)
	self:addBackEvent()
	self:reSetAll()
	self:_setTabPosition()
	self:setButtonEnabled()

	local callback = function()
		self:_selectTab(self._tabType)
		self:_checkRedTips()
	end

	app:getClient():getStores(SHOP_ID.itemShop, function(data)
			if self:safeCheck() then
				if self._timeScheduler ~= nil then
					scheduler.unscheduleGlobal(self._timeScheduler)
					self._timeScheduler = nil
				end
				callback()
			end
		end)

end

function QUIDialogMall:viewWillDisappear()
  	QUIDialogMall.super.viewWillDisappear(self)
  	if self._scrollContain ~= nil then
  		self._scrollContain:disappear()
  	end

  	if self._fadeOutHandler ~= nil then
		scheduler.unscheduleGlobal(self._fadeOutHandler)
	end
	if self._checkItemScheduler ~= nil then
		scheduler.unscheduleGlobal(self._checkItemScheduler)
		self._checkItemScheduler = nil
	end

 	self._shopEventProxy:removeAllEventListeners()
	self:removeBackEvent()

	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end



function QUIDialogMall:cleanAllOrient()
	self:cleanEnchantOrient()
	self:cleanMountOrient()
	self:cleanGemstoneOrient()
	self:cleanMagicHerbOrient()
end

function QUIDialogMall:cleanEnchantOrient()
	if self._enchantOrient ~= nil then
		-- self._enchantOrient:removeFromParent()
		-- self._enchantOrient = nil
		self._enchantOrient:setVisible(false)
	end
end

function QUIDialogMall:cleanMountOrient()
	if self._mountOrient ~= nil then
		-- self._mountOrient:removeFromParent()
		-- self._mountOrient = nil
		self._mountOrient:setVisible(false)
	end
end

function QUIDialogMall:cleanGemstoneOrient()
	if self._gemstoneOrient ~= nil then
		-- self._gemstoneOrient:removeFromParent()
		-- self._gemstoneOrient = nil
		self._gemstoneOrient:setVisible(false)
	end
end

function QUIDialogMall:cleanMagicHerbOrient()
	if self._magicHerbOrient ~= nil then
		-- self._magicHerbOrient:removeFromParent()
		-- self._magicHerbOrient = nil
		self._magicHerbOrient:setVisible(false)
	end
end

function QUIDialogMall:reSetAll()
	self._ccbOwner.node_recharge:setVisible(false)
	self._ccbOwner.boss_head:setVisible(false)
	self._ccbOwner.node_skin_label:setVisible(false)
	self._ccbOwner.node_showSelect:setVisible(false)

	if self._listItemView then
		self._listItemView:clear()
		self._listItemView:setVisible(false)
	end
	if self._listView then
		self._listView:clear()
		self._listView:setVisible(false)
	end
	if self._listSkinView then
		self._listSkinView:clear()
		self._listSkinView:setVisible(false)
	end	
end

function QUIDialogMall:showRechargeBtn(flag)
	if flag then
		self._ccbOwner.node_recharge:setVisible(ENABLE_CHARGE())
	else
		self._ccbOwner.node_recharge:setVisible(false)
	end
	self._ccbOwner.boss_head:setVisible(flag)
end

function QUIDialogMall:_selectTab(tab)
	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	self._tabType = tab

	self:getOptions().tab = self._tabType
	self:getOptions().curIndex = self._curSelectBtnIndex

	self._ccbOwner.vip_is_null:setVisible(false)
	self:reSetAll()

	if self._tabType == QUIDialogMall.ITEM_MALL_TYPE then
		self._mainPage.topBar:showWithMainPage()
	  	self._shopID = SHOP_ID.itemShop
   		-- self.bossWord:showSpeakWord("welcome", self._shopID)

		local refreshShop =  remote.stores:checkCanRefreshShop2(self._shopID)
		if refreshShop == true or refreshShop == nil then
			self:getItem()
		end
		self:showRechargeBtn(true)
  		self:_initMallBox()
  	elseif self._tabType == QUIDialogMall.WEEK_MALL_TYPE then
  		self:showRechargeBtn(false)
		self._mainPage.topBar:showWithMainPage()
  		self._shopID = SHOP_ID.weekShop
    	-- self.bossWord:showSpeakWord("welcome", SHOP_ID.vipShop)
  		local refreshShop =  remote.stores:checkCanrefreshWeekMall()
		if refreshShop == true or refreshShop == nil then
	  		self:getItem()
	  	end
  		self:_initMallBox()
  	elseif self._tabType == QUIDialogMall.VIP_MALL_TYPE then
  		self:showRechargeBtn(true)
		self._mainPage.topBar:showWithMainPage()
  		self._shopID = SHOP_ID.vipShop
    	-- self.bossWord:showSpeakWord("welcome", self._shopID)
  		self:_initMallBox()
  	elseif self._tabType == QUIDialogMall.ENCHANT_ORIENT_TYPE then
		self._mainPage.topBar:showWithEnchantOrient()
    	-- self.bossWord:showSpeakWord("welcome", "1002")
    	self:showRechargeBtn(false)
	
  		self._shopID = nil
		self:setButtonEnabled()
	  	self:_setEnchantOrientInfo()
  	elseif self._tabType == QUIDialogMall.MOUNT_TYPE then
  		self:showRechargeBtn(false)
		self._mainPage.topBar:showWithStyle({"money", "token", "stormMoney"})
    	-- self.bossWord:showSpeakWord("welcome", "1002")	
  		self._shopID = nil
		self:setButtonEnabled()
	  	self:_setMountOrientInfo()
  	elseif self._tabType == QUIDialogMall.GEMSTONE_TYPE then
  		self:showRechargeBtn(false)
		self._mainPage.topBar:showWithMainPage()
    	-- self.bossWord:showSpeakWord("welcome", "1002")
  		self._shopID = nil
		self:setButtonEnabled()
	  	self:_setGemstoneOrientInfo()
	elseif self._tabType == QUIDialogMall.MAGICHERB_TYPE then
		self:showRechargeBtn(false)
		self._mainPage.topBar:showWithMainPage()

  		self._shopID = nil
		self:setButtonEnabled()
	  	self:_setMagicHerbOrientInfo()
	elseif self._tabType == QUIDialogMall.SKINSHOP_TYPE then
		self:showRechargeBtn(false)
		self._ccbOwner.boss_head:setVisible(false)
		self._ccbOwner.node_showSelect:setVisible(true)
		self._ccbOwner.node_skin_label:setVisible(true)		
		self._mainPage.topBar:showWithSkinShopPage()		
		self._shopID = SHOP_ID.skinShop
		self:_initSkinMallBox(self._skinTabIndex)	
	end
end

function QUIDialogMall:setSkinbtnLabelState( )
	self._ccbOwner.btn_skin_gaoji:setHighlighted(self._skinTabIndex == QUIDialogMall.GAOJI_SKIN)
	self._ccbOwner.btn_skin_gaoji:setEnabled(self._skinTabIndex ~= QUIDialogMall.GAOJI_SKIN)
	self._ccbOwner.btn_skin_normal:setHighlighted(self._skinTabIndex == QUIDialogMall.NORMAL_SKIN)
	self._ccbOwner.btn_skin_normal:setEnabled(self._skinTabIndex ~= QUIDialogMall.NORMAL_SKIN)	
end

function QUIDialogMall:_initSkinMallBox(subType)
	self._skinTabIndex = subType or QUIDialogMall.GAOJI_SKIN
	self:getOptions().skinTalType = self._skinTabIndex
	self:setSkinbtnLabelState()
	self:setButtonEnabled()
	self:cleanAllOrient()
	local shopItems = remote.exchangeShop:getShopInfoById(self._shopID)
	self._shopItems = {}
	-- not db:checkHeroShields(value.skins_id, SHIELDS_TYPE.SKIN_ID)
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0	
	for i = 1, #shopItems do
		if shopItems[i].shop_label == self._skinTabIndex and userLevel >= shopItems[i].team_minlevel and 
			userLevel <= shopItems[i].team_maxlevel and vipLevel >= shopItems[i].vip_id then
			if self._chooseShowNotGet then
				local skinState = remote.heroSkin:checkItemSkinIsHave(shopItems[i].item_id)
				if skinState == remote.heroSkin.ITEM_SKIN_NORMAL then
					self._shopItems[#self._shopItems+1] = shopItems[i]
				end
			else
				self._shopItems[#self._shopItems+1] = shopItems[i]
			end
			if self._skinTabIndex == QUIDialogMall.NORMAL_SKIN and #self._shopItems >= 4 then --与策划定好了普通皮肤就只显示4个
				break
			end
		end
	end
	if q.isEmpty(self._shopItems) then
		local str = "您已拥有所有高级皮肤。"
		if self._skinTabIndex == 1 then
			str = "您已拥有所有普通皮肤。"
		end
		self._ccbOwner.tf_allSkin_tips:setString(str)
		self._ccbOwner.node_haveAllSkin:setVisible(true)
	else
		self._ccbOwner.node_haveAllSkin:setVisible(false)
	end
	table.sort( self._shopItems, function(a,b)
		return a.show_grid_id < b.show_grid_id
	end )
	self:setSkinItemBox()
end

function QUIDialogMall:setSkinItemBox()
	-- if self._listView then
	-- 	self._listView:clear()
	-- 	self._listView:setVisible(false)
	-- end
	-- if self._listItemView then
	-- 	self._listItemView:clear()
	-- 	self._listItemView:setVisible(false)
	-- end	
	if not self._listSkinView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._shopItems[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetMallSkinItemBox.new()
				    -- item:addEventListener(QUIDialogMall.MALL_BOX_CLICK, handler(self, self._onClickMallBox))
	                isCacheNode = false
	            end
            	item:setItemBox(index,data, self._shopID, self)
	            info.item = item
	            info.tag = data.oType
	            info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_client", "_clickHandBookCellHandler")
                list:registerBtnHandler(index, "btn_buy", "_clickBuyItemHandler",nil,true)                

	            return isCacheNode
	        end,
	        multiItems = 4,
	        ignoreCanDrag = true,
	        spaceX = -15,
	        spaceY = 5,
	        enableShadow = false,
	        totalNumber = #self._shopItems,

	    }  
    	self._listSkinView = QListView.new(self._ccbOwner.sheet_layout2, cfg)
	else
		self._listSkinView:reload({totalNumber = #self._shopItems,tailIndex = self._touchIndex})
	end 
	self._listSkinView:setVisible(true)
end
function QUIDialogMall:_initMallBox()
	self:cleanAllOrient()
	self:setButtonEnabled()


	local shopItems = remote.stores:getStoresById(self._shopID)
	self._shopItems = {}

	if shopItems == nil then
  		self._ccbOwner.vip_is_null:setVisible(true)
		return 
	end
	
	-- 先创建最下面的文字
    -- self:_createWordLabel()

	self._totalHeight = 0
	self._totalWidth = 0
	self.line = 0
	self.row = 1
	self.lineDistance = 7
	self.rowDistance = 7
	self._index = 1

	if self._shopID == SHOP_ID.vipShop or self._shopID == SHOP_ID.weekShop then

		if self._listItemView then
			self._listItemView:clear()
			self._wordLabel = nil
		end
		for i = 1, #shopItems, 1 do
			local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(shopItems[i].good_group_id)
			shopItems[i].vipLevel = goodInfo == nil and 0 or goodInfo.vip_buy

			self._shopItems[#self._shopItems+1] = shopItems[i]
		end

		table.sort( self._shopItems, function(a, b)
				if a.count ~= b.count then
					return a.count > b.count
				else
					return a.vipLevel < b.vipLevel
				end
			end)

		self:setVipItemBox()
	elseif self._shopID == SHOP_ID.itemShop then
		if self._listView then
			self._listView:clear()
		end
		for i = 1, #shopItems do
			local limitLevel = 0
			if shopItems[i].itemType == "item"  then
				limitLevel = QStaticDatabase:sharedDatabase():getItemByID(shopItems[i].id).level
			else
				local currencyInfo = remote.items:getWalletByType(shopItems[i].itemType) or {}
				currencyInfo = QStaticDatabase:sharedDatabase():getItemByID(currencyInfo.item) or {}
				limitLevel = currencyInfo.level or 0
			end

			if ( shopItems[i].id == tonumber(ITEM_TYPE.DRAGON_STONE) or shopItems[i].id == tonumber(ITEM_TYPE.DRAGON_SOUL) ) then
				if app.unlock:checkLock("TUTENG_DRAGON") then
					self._shopItems[#self._shopItems+1] = shopItems[i]
				end
			--魂骨宝箱去掉
			elseif shopItems[i].id == GEMSTONE_SHOP_ID then
			
			elseif limitLevel <= remote.user.level then
				self._shopItems[#self._shopItems+1] = shopItems[i]
			end
		end
		-- self:setItemBox()
		self:setNewItemBox()
	end
end 

function QUIDialogMall:setNewItemBox( ... )
	-- if self._listView then
	-- 	self._listView:clear()
	-- 	self._listView:setVisible(false)
	-- end
	if not self._listItemView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._shopItems[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetMallItemBox.new()
	                item:setScale(0.98)
				    item:addEventListener(QUIDialogMall.MALL_BOX_CLICK, handler(self, self._onClickMallBox))
	                isCacheNode = false
	            end
            	item:setItemBox(index,data, self._shopID, self)
	            info.item = item
	            info.tag = data.oType
	            info.size = item:getContentSize()

                -- list:registerTouchHandler(index,"onTouchListView")
                list:registerBtnHandler(index,"btn_client", "_onTriggerClick")
                list:registerBtnHandler(index,"btn_item", "_onTriggerClickIcon")
                

	            return isCacheNode
	        end,
	        multiItems = 3,
	        curOriginOffset = 10,
	        ignoreCanDrag = true,
	        spaceX = -8,
	        spaceY = -8,
	        enableShadow = false,
	        totalNumber = #self._shopItems,

	    }  
    	self._listItemView = QListView.new(self._ccbOwner.sheet_layout1, cfg)
	else
		self._listItemView:reload({totalNumber = #self._shopItems,tailIndex = self._touchIndex})
	end 
	self._listItemView:setVisible(true)
end


function QUIDialogMall:setVipItemBox()
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._shopItems[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetMallVipBox.new()
				    item:addEventListener(QUIWidgetMallVipBox.MALL_VIP_BOX_ICON_CLICK, handler(self, self._onClickMallBox))
	                isCacheNode = false
	            end
            	item:setInfo(data, self._shopID, self)

	            info.item = item
	            info.tag = data.oType
	            info.size = item:getContentSize()
	            local currVipLevel = QVIPUtil:VIPLevel()
	            local isCanBuy = data.count > 0 and currVipLevel >= data.vipLevel

                list:registerTouchHandler(index,"onTouchListView")
                if isCanBuy then
                	list:registerBtnHandler(index,"btn_ok", "_onTriggerRcive",nil,true)
                else
                	list:registerBtnHandler(index,"btn_ok2", "_onTriggerGoto",nil,true)
                end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        ignoreCanDrag = true,
	        isVertical = false,
	        spaceX = -3,
	        curOffset = 10,
	        enableShadow = false,
	        totalNumber = #self._shopItems,

	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._shopItems})
	end 
	self._listView:setVisible(true)
end

function QUIDialogMall:_setTabPosition()

    local tabType = {
        {index = 1,oType = QUIDialogMall.ENCHANT_ORIENT_TYPE, btnName = "觉 醒", unlock = function() return app.unlock:getUnlockEnchant() end},
        {index = 2,oType = QUIDialogMall.GEMSTONE_TYPE, btnName = "魂 骨", unlock = function() return app.unlock:getUnlockGemStone() end},
        {index = 3,oType = QUIDialogMall.MOUNT_TYPE, btnName = "暗 器", unlock = function() return app.unlock:getUnlockMount() end},
        {index = 4,oType = QUIDialogMall.MAGICHERB_TYPE, btnName = "仙 品", unlock = function() return remote.magicHerb:checkMagicHerbUnlock() end},
		{index = 5,oType = QUIDialogMall.SKINSHOP_TYPE,btnName = "皮 肤",unlock = function() return remote.stores:checkSkinShopUnlock() end},        
        {index = 6,oType = QUIDialogMall.ITEM_MALL_TYPE, btnName = "道 具", unlock = function() return true end},
        {index = 7,oType = QUIDialogMall.VIP_MALL_TYPE, btnName = "vip奖励", unlock = function() return ENABLE_CHARGE() end},
    }
    self._showBtns = {}
    local index = 1
    for k, v in ipairs(tabType) do
        if v.unlock and v.unlock() then
            self._showBtns[index] = v
            index = index + 1
        end
    end

    self:initBtnListView()
end

function QUIDialogMall:onClickBtnItem( x, y, touchNode, listView )
    app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)

    if self._curSelectBtnIndex and self._curSelectBtnIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectBtnIndex)
        if oldItem then
            oldItem:setSelect(false)
        end
    end

    if self._curSelectBtnIndex ~= touchIndex then
        self._curSelectBtnIndex = touchIndex
    end

    if item then
        item:setSelect(true)
        local selectInfo = item:getInfo()
        if q.isEmpty(selectInfo) == false then
        	self:_selectTab(selectInfo.oType)
        end
    end

end


function QUIDialogMall:initBtnListView(  )
    -- body
    if not self._btnListView then
	    local clickBtnItemHandler = handler(self, self.onClickBtnItem)
	    local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._showBtns[index]
	            if not item then
	                item = QUIWidgetMaillButton.new()
	                isCacheNode = false
	            end
	            item:setInfo(data,self)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_click", clickBtnItemHandler)
	            
	            if self._tabType == data.oType then
	            -- if self._curSelectBtnIndex == index then
	            	self._curSelectBtnIndex = index
	                item:setSelect(true)
	                self:_selectTab(data.oType)
	            else
	                item:setSelect(false)
	            end
	            return isCacheNode
	        end,
	        headIndex = self._curSelectBtnIndex,
	        enableShadow = true,
	        topShadow = self._ccbOwner.node_top_arrow,
	        bottomShadow = self._ccbOwner.node_bottom_arrow,
	        ignoreCanDrag = true,
	        totalNumber = #self._showBtns,
	        curOffset = 20,
	        curOriginOffset = 5,
	    }  
	    self._btnListView = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else   
		self._btnListView:reload({totalNumber = #self._showBtns})
	end
end



function QUIDialogMall:_setEnchantOrientInfo()
	self:cleanAllOrient()
	if self._enchantOrient == nil then
		self._enchantOrient = QUIWidgetEnchantOrient.new()
		self._enchantOrient:addEventListener(QUIWidgetEnchantOrient.BUY_SUCCESSED_EVENT, handler(self, self._checkRedTips))
		self._enchantOrient:addEventListener(QUIWidgetEnchantOrient.TIME_TO_REFRESH, handler(self, self._checkRedTips))
		self._ccbOwner.node_client:addChild(self._enchantOrient)
	end
	self._enchantOrient:setVisible(true)

end

function QUIDialogMall:_setMountOrientInfo()

	self:cleanAllOrient()
	if self._mountOrient == nil then
		self._mountOrient = QUIWidgetMountOrient.new()
		self._mountOrient:addEventListener(QUIWidgetMountOrient.BUY_SUCCESSED_EVENT, handler(self, self._checkRedTips))
		self._mountOrient:addEventListener(QUIWidgetMountOrient.TIME_TO_REFRESH, handler(self, self._checkRedTips))
		self._ccbOwner.node_client:addChild(self._mountOrient)
	end
	self._mountOrient:setVisible(true)

end

function QUIDialogMall:_setGemstoneOrientInfo()

	self:cleanAllOrient()

	if self._gemstoneOrient == nil then
		self._gemstoneOrient = QUIWidgetGemstoneOrient.new()
		self._gemstoneOrient:addEventListener(QUIWidgetGemstoneOrient.BUY_SUCCESSED_EVENT, handler(self, self._checkRedTips))
		self._gemstoneOrient:addEventListener(QUIWidgetGemstoneOrient.TIME_TO_REFRESH, handler(self, self._checkRedTips))
		self._ccbOwner.node_client:addChild(self._gemstoneOrient)
	end
	self._gemstoneOrient:setVisible(true)
end

function QUIDialogMall:_setMagicHerbOrientInfo()

	self:cleanAllOrient()

	if self._magicHerbOrient == nil then
		self._magicHerbOrient = QUIWidgetMagicHerbOrient.new()
		self._magicHerbOrient:addEventListener(QUIWidgetMagicHerbOrient.BUY_SUCCESSED_EVENT, handler(self, self._checkRedTips))
		self._magicHerbOrient:addEventListener(QUIWidgetMagicHerbOrient.TIME_TO_REFRESH, handler(self, self._checkRedTips))
		self._ccbOwner.node_client:addChild(self._magicHerbOrient)
	end

	self._magicHerbOrient:setVisible(true)

end

function QUIDialogMall:sellItem()
	-- if self._shopID == SHOP_ID.itemShop then
 --    	self.bossWord:showSpeakWord("purchase", self._shopID)
	-- else
 --    	self.bossWord:showSpeakWord("soldout", SHOP_ID.vipShop)
	-- end
	if self._timeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	if self._tabType == QUIDialogMall.GEMSTONE_TYPE then
		return
	end
	
	self:_initMallBox()
	self:_checkRedTips()
end 

function QUIDialogMall:_checkRedTips()
	self:initBtnListView()
end

function QUIDialogMall:getItem()
	app:getClient():getStores(self._shopID, function(data)
		if self._timeScheduler ~= nil then
			scheduler.unscheduleGlobal(self._timeScheduler)
			self._timeScheduler = nil
		end
	
		-- self:_checkRedTips()
		self:_initMallBox()
	end)
end

function QUIDialogMall:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogMall:_onScrollViewBegan()
	self._isMove = false
end


function QUIDialogMall:setButtonEnabled()
	self._ccbOwner.enchant_bg:setVisible(self._tabType == QUIDialogMall.ENCHANT_ORIENT_TYPE)
	self._ccbOwner.weapon_bg:setVisible(self._tabType == QUIDialogMall.MOUNT_TYPE)
	self._ccbOwner.gemstone_bg:setVisible(self._tabType == QUIDialogMall.GEMSTONE_TYPE)
	self._ccbOwner.magicHerb_bg:setVisible(self._tabType == QUIDialogMall.MAGICHERB_TYPE)
	self._ccbOwner.mall_bg:setVisible(self._tabType == QUIDialogMall.ITEM_MALL_TYPE or self._tabType == QUIDialogMall.VIP_MALL_TYPE)
	self._ccbOwner.skinshop_bg:setVisible(self._tabType == QUIDialogMall.SKINSHOP_TYPE)
end 

function QUIDialogMall:getContentListView()
	return self._listView
end

function QUIDialogMall:getContentItemListView( )
	return self._listItemView
end

function QUIDialogMall:_onTriggerGaojiSkin()
	if self._skinTabIndex == QUIDialogMall.GAOJI_SKIN then return end
	self._skinTabIndex = QUIDialogMall.GAOJI_SKIN
	app.sound:playSound("common_switch")
	self:_selectTab(QUIDialogMall.SKINSHOP_TYPE)
end

function QUIDialogMall:_onTriggerNormalSkin()
	if self._skinTabIndex == QUIDialogMall.NORMAL_SKIN then return end
	self._skinTabIndex = QUIDialogMall.NORMAL_SKIN
	app.sound:playSound("common_switch")

	self:_selectTab(QUIDialogMall.SKINSHOP_TYPE)
end

function QUIDialogMall:_onTriggerSelectNoGet()
	if self._ccbOwner.sp_select:isVisible() then
		self._chooseShowNotGet = false
	else
		self._chooseShowNotGet = true
	end
	app:getUserOperateRecord():setRecordByType("MALL_SKIN_CHOOSE",self._chooseShowNotGet)
	self._ccbOwner.sp_select:setVisible(self._chooseShowNotGet)
	self:_selectTab(QUIDialogMall.SKINSHOP_TYPE)
end

function QUIDialogMall:_onTriggerRecharge(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_recharge) == false then return end
	app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIDialogMall:_onClickMallBox(data)
	if self._isMove then return end
	self._touchIndex = data.index or 1
    app.sound:playSound("common_small")
	local currentVIPLevel = QVIPUtil:VIPLevel()
	if data.shopId == SHOP_ID.itemShop then
		if data.maxNum - data.itemInfo.buy_count == 0 then
			if currentVIPLevel < QVIPUtil:getMaxLevel() then
				app:vipAlert({content="购买次数已达上限，提升VIP等级可提高购买次数上限"}, false)
			else
				app.tip:floatTip("今日的购买次数已用完")
			end
			return
		end
	else
		if data.itemInfo.vipLevel > currentVIPLevel then
			-- app.tip:floatTip("VIP等级不足，不可购买")
			self:_showVipAlert( data.itemInfo.vipLevel )
			return
		elseif data.itemInfo.count == 0 then
			if data.shopId == SHOP_ID.weekShop then
				app.tip:floatTip("本周已购买")
			else
				app.tip:floatTip("购买已达上限")
			end
			return 
		end
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallDetail", 
		options = {shopId = data.shopId, itemInfo = data.itemInfo, maxNum = data.maxNum, pos = data.pos}})
end

function QUIDialogMall:_onClickMallVipBoxIcon(data)
	if self._isMove then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMallVipPreview", options = {itemInfo = data.itemInfo}})
end

function QUIDialogMall:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogMall:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMall:_showVipAlert( vipLevel )
	app:vipAlert({content="VIP等级达到"..vipLevel.."级，方可购买该礼包。"}, false)
end


return QUIDialogMall