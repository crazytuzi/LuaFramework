
-- @Author: liaoxianbo
-- @Date:   2019-05-31 17:06:53
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-10 18:02:25
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityCrystalShop = class("QUIWidgetActivityCrystalShop", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetActivityCrystalShopClient = import("..widgets.QUIWidgetActivityCrystalShopClient")
local QPayUtil = import("...utils.QPayUtil")

function QUIWidgetActivityCrystalShop:ctor(options)
	local ccbFile = "ccb/Widget_crystal_shop.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClickHelp", callback = handler(self, self._onTriggerClickHelp)},
		{ccbCallbackName = "onTriggerRedPacket", callback = handler(self,self._onTriggerRedPacket)},
		{ccbCallbackName = "onTriggerCrystalShop", callback = handler(self,self._onTriggerCrystalShop)},
		{ccbCallbackName = "onTriggerAutoRecharge", callback = handler(self,self._onTriggerAutoRecharge)},
    }
    QUIWidgetActivityCrystalShop.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._crystalGift = {}
	self._allCrygifts = db:getCrystalGift() or {}
	self._freeGift = {}
	self._crystalGiftBox = {}
	self._isReciveFreegift = false

    self._ccbOwner.node_shop:setPositionX(display.ui_width/2)
    self._ccbOwner.node_tf_time:setPositionY(-display.height/2)

    self:addEvent()
	remote.crystal:requestGetCrystalGiftState()
end

function QUIWidgetActivityCrystalShop:onEnter()
end

function QUIWidgetActivityCrystalShop:onExit()
    if self._crystalProxy ~= nil then 
        self._crystalProxy:removeAllEventListeners()
        self._crystalProxy = nil
    end	
end

function QUIWidgetActivityCrystalShop:addEvent( ... )
    self._crystalProxy = cc.EventProxy.new(remote.crystal)
    self._crystalProxy:addEventListener(remote.crystal.EVENT_RECHARGE, handler(self, self.rechargedSucess))
    self._crystalProxy:addEventListener(remote.crystal.EVENT_GET_USER_DAILY_GIFT_INFO, handler(self, self.setInfo))
end

function QUIWidgetActivityCrystalShop:setInfo()
    if self._crystalProxy then
        self._crystalProxy:removeEventListener(remote.crystal.EVENT_GET_USER_DAILY_GIFT_INFO)
    end
	self:initData()
	self:showBtnState()
	self._ccbOwner.sp_redtip:setVisible(remote.crystal:checkCrystalShopRedTips())
	self._ccbOwner.tf_crystal_piece:setString(remote.user.crystalPiece or 0)

	for i = 1, 3 do
		if self._crystalGift[i] then
			if  self._crystalGiftBox[i] == nil then
                self._crystalGiftBox[i] = QUIWidgetActivityCrystalShopClient.new()
                self._crystalGiftBox[i]:addEventListener(QUIWidgetActivityCrystalShopClient.EVENT_FASTBUY, handler(self, self._onItemClick))
            	self._crystalGiftBox[i]:addEventListener(QUIWidgetActivityCrystalShopClient.EVENT_FASTGET, handler(self, self._onItemClick))
            	self._ccbOwner["node_item_"..i]:addChild(self._crystalGiftBox[i])
            end
            self._crystalGiftBox[i]:setDataInfo(self._crystalGift[i], self._lastDay)

		end
	end
end

function QUIWidgetActivityCrystalShop:initData()

	self._crystalGift = {}
	self._allCrygifts = db:getCrystalGift() or {}
	self._freeGift = {}
	self._isReciveFreegift = false

	for _,v in pairs(self._allCrygifts) do
		v.rechargeState = remote.crystal:checkGiftRechargeStateById(v.gifts_id)
		v.reciveState = remote.crystal:checkGiftReciveStateById(v.gifts_id)

		if v.prize ~= 0 then
			table.insert(self._crystalGift,v)
		else
			table.insert(self._freeGift,v)
		end
	end

	table.sort( self._crystalGift, function(a,b)
		return a.prize < b.prize
	end )

	
	for _,free in pairs(self._freeGift) do
		if remote.crystal:checkGiftReciveStateById(free.gifts_id) then
			self._isReciveFreegift = true
			break
		end
	end
end

function QUIWidgetActivityCrystalShop:showBtnState()
	self._ccbOwner.node_packetRedtip:setVisible(not self._isReciveFreegift)

	self._lastDay = remote.crystal:getAutoGetGiftUntilDay()
	local showLastDay = self._lastDay
	print("剩余激活天数lastDay=",self._lastDay)
	if self._lastDay > 0 then
		self._ccbOwner.node_lastTime:setVisible(true)
		self._ccbOwner.tf_lastTime:setString("自动激活剩余:"..(showLastDay-1).."天")
		self._ccbOwner.node_autorecharge:setVisible(false)
		self._ccbOwner.btn_autorecharge:setEnabled(false)
	else
		self._ccbOwner.node_lastTime:setVisible(false)
		self._ccbOwner.node_autorecharge:setVisible(true)
		self._ccbOwner.btn_autorecharge:setEnabled(true)
	end

	if self._isReciveFreegift then
		makeNodeFromNormalToGray(self._ccbOwner.btn_redpacket)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.btn_redpacket)
	end
end

function QUIWidgetActivityCrystalShop:rechargedSucess( event)
	local prize = event.value 
	local itemInfo = db:getCrystalGiftInfoByPrize(prize)

	if itemInfo and itemInfo.reward then
		local rewardId = itemInfo.reward
		local rewardTbl = self:switchAwards(itemInfo.reward,itemInfo.high_light)
		remote.crystal:requestMyCryStalShopDailyGift(itemInfo.gifts_id,function(data)
			self:setInfo()
	        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	        options = {awards = rewardTbl}},{isPopCurrentDialog = false} )
	        dialog:setTitle("")	
		end)
	elseif prize == 60 then
		remote.crystal:requestGetCrystalGiftState(function( )
			self:setInfo()
			app.tip:floatTip("自动激活已开启")
		end)		
	end	
end

function QUIWidgetActivityCrystalShop:switchAwards( giftList,highlight )
	if giftList == nil then return {} end
	local a = string.split(giftList, ";")
	local awardseffectTbl = string.split(highlight,";")
    local tbl = {}
    local awardList = {}
    for _, value in pairs(a) do
        tbl = {}
        local s, e = string.find(value, "%^")
        local idOrType = string.sub(value, 1, s - 1)
        local itemCount = tonumber(string.sub(value, e + 1))
        local itemType = remote.items:getItemType(idOrType)
        if itemType == nil then
            itemType = ITEM_TYPE.ITEM
        end        
        local showEffect = false
        if awardseffectTbl then
        	for _,awardsEf in pairs(awardseffectTbl) do
        		if idOrType == awardsEf then
        			showEffect = true
        			break
        		end
        	end
        end
		table.insert(awardList, {id = idOrType, typeName = itemType, count = itemCount,showEffect = showEffect})
    end
    return awardList
end

function QUIWidgetActivityCrystalShop:fastBuy(price,itemId)
	if price == nil or price == 0 then return end
	app.sound:playSound("common_small")

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(price, 5,itemId)
	else
		app:showLoading()
	    if self._rechargeProgress then
	    	scheduler.unscheduleGlobal(self._rechargeProgress)
	    	self._rechargeProgress = nil
	    end
		self._rechargeProgress = scheduler.performWithDelayGlobal(function ( ... )
			app:hideLoading()
		end, 5)
		if FinalSDK.isHXIOS() then
			QPayUtil:hjPayOffline(price, 5, nil,itemId)
		else
			QPayUtil:pay(price, 5, nil,itemId)
		end
	end
end

function QUIWidgetActivityCrystalShop:_onItemClick(event)
	if event.name == QUIWidgetActivityCrystalShopClient.EVENT_FASTBUY then
		self:fastBuy(event.prize,event.id)
	elseif event.name == QUIWidgetActivityCrystalShopClient.EVENT_FASTGET then
		remote.crystal:requestMyCryStalShopDailyGift(event.id,function(data)


            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = event.awards,callBack = function()
            	self:setInfo()
            end}},{isPopCurrentDialog = false} )
            dialog:setTitle("")	
        end)		
	end
end
function QUIWidgetActivityCrystalShop:_onTriggerClickHelp(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogCrystalHelp", 
		options = {helpType = "help_crystal_gifts"}})
end

function QUIWidgetActivityCrystalShop:_onTriggerRedPacket( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_redpacket) == false then return end
	app.sound:playSound("common_small")
	if self._isReciveFreegift then
		app.tip:floatTip("今日已领取")
		return 
	end
	local itemInfo = db:getCrystalGiftInfoByPrize(0)
	-- local awards = db:getluckyDrawById(itemInfo.reward)
	remote.crystal:requestMyCryStalShopDailyGift(itemInfo.gifts_id,function(data)
		local awards = {}
		if data.userDailyGiftCompleteResponse and data.userDailyGiftCompleteResponse.luckyDraw then
			awards = data.userDailyGiftCompleteResponse.luckyDraw.prizes or {}
		end
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards,callBack = function()
        	self:setInfo()
        end}},{isPopCurrentDialog = false} )
        dialog:setTitle("随机福袋有几率开出10或666钻石")	
    end)	
end

function QUIWidgetActivityCrystalShop:_onTriggerCrystalShop( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_crystal_shop) == false then return end
    app.sound:playSound("common_small")
    app:getUserOperateRecord():recordeCurrentTime("activity_cryStalShop")
    remote.stores:openShopDialog(SHOP_ID.crystalShop)
end

function QUIWidgetActivityCrystalShop:_onTriggerAutoRecharge( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_autorecharge) == false then return end
    app.sound:playSound("common_small")

    self:fastBuy(60)
end

function QUIWidgetActivityCrystalShop:getContentSize()
end

return QUIWidgetActivityCrystalShop
