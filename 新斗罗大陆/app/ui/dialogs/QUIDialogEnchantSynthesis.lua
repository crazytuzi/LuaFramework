-- @Author: liaoxianbo
-- @Date:   2020-09-21 14:30:01
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-24 17:54:50
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEnchantSynthesis = class("QUIDialogEnchantSynthesis", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")
local QUIWidgetEnchantSynthesis = import("..widgets.QUIWidgetEnchantSynthesis")

QUIDialogEnchantSynthesis.SS = 1
QUIDialogEnchantSynthesis.SSUP = 2

function QUIDialogEnchantSynthesis:ctor(options)
	local ccbFile = "ccb/Dialog_Enchant_Synthesis.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerSS", callback = handler(self, self._onTriggerSS)},
		{ccbCallbackName = "onTriggerSSup", callback = handler(self, self._onTriggerSSup)},
    }
    QUIDialogEnchantSynthesis.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._ccbOwner.frame_tf_title:setString("觉醒合成")

    ui.tabButton(self._ccbOwner.tab_ss, "SS")
    ui.tabButton(self._ccbOwner["tab_ss+"], "SS+")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.tab_ss)
    table.insert(tabs, self._ccbOwner["tab_ss+"])
    self._tabManager = ui.tabManager(tabs)  

    self._curtentTable = QUIDialogEnchantSynthesis.SS
    self:selectTab(self._curtentTable)
end

function QUIDialogEnchantSynthesis:viewDidAppear()
	QUIDialogEnchantSynthesis.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogEnchantSynthesis:viewWillDisappear()
  	QUIDialogEnchantSynthesis.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogEnchantSynthesis:getShopData(tabType)
	local shopItems = remote.exchangeShop:getShopInfoById(SHOP_ID.EnchantSynShop)
	self._shopItems = {}
	local userLevel = remote.user.level or 0
	local vipLevel = QVIPUtil:VIPLevel() or 0	
	for i = 1, #shopItems do
		if shopItems[i].shop_label == tabType and userLevel >= shopItems[i].team_minlevel and 
			userLevel <= shopItems[i].team_maxlevel and vipLevel >= shopItems[i].vip_id then
			self._shopItems[#self._shopItems+1] = shopItems[i]
		end
	end

	table.sort( self._shopItems, function(a,b)
		local beMakeA = (remote.items:getItemsNumByID(a.resource_item_1) >= a.resource_number_1)
		local beMakeB = (remote.items:getItemsNumByID(b.resource_item_1) >= b.resource_number_1)
		if beMakeA ~= beMakeB then
			return beMakeA == true
		end

		return false
	end )
end

function QUIDialogEnchantSynthesis:selectTab(tabType)

	self._curtentTable = tabType

	self:getShopData(tabType)

	if tabType == QUIDialogEnchantSynthesis.SS then
		self._tabManager:selected(self._ccbOwner.tab_ss)
	elseif tabType == QUIDialogEnchantSynthesis.SSUP then
		self._tabManager:selected(self._ccbOwner["tab_ss+"])
	end
	self:_initListView()
end

function QUIDialogEnchantSynthesis:_initListView()

	if self._listViewLayout then
		self._listViewLayout:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listViewLayout:resetTouchRect()
	end
	
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemCallBack),
	        curOriginOffset = 7,
	        contentOffsetX = -2,
	        contentOffsetY = 10,
	        curOffset = 0,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 0,
	      	spaceX = 10,
	      	isVertical = true ,
	        totalNumber = #self._shopItems,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:refreshData() 
	end
end

function QUIDialogEnchantSynthesis:_renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._shopItems[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetEnchantSynthesis.new()
        item:addEventListener(QUIWidgetEnchantSynthesis.EVENT_ENCHANT_MADE, handler(self,self._onClickCookHandler))
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ok", "_onTriggerOK", nil, "true")

    return isCacheNode
end


function QUIDialogEnchantSynthesis:_onClickCookHandler(event)
	QPrintTable(event.info)
	local exchangeInfo = event.info
 	remote.exchangeShop:exchangeShopBuyRequest(exchangeInfo.shop_id, exchangeInfo.grid_id, exchangeInfo.item_number, function(data)
	 		if self:safeCheck() then
 				local awards = {}
				table.insert(awards, {id = exchangeInfo.item_id, typeName = exchangeInfo.item_type , count = exchangeInfo.item_number})
				app.tip:awardsTip(awards, "饰品合成成功",nil)
				self:selectTab(self._curtentTable)
	 		end
	 	end)	
end

function QUIDialogEnchantSynthesis:_onTriggerSS()
	self:selectTab(QUIDialogEnchantSynthesis.SS)
end

function QUIDialogEnchantSynthesis:_onTriggerSSup()
	self:selectTab(QUIDialogEnchantSynthesis.SSUP)
end

function QUIDialogEnchantSynthesis:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogEnchantSynthesis:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogEnchantSynthesis:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogEnchantSynthesis
