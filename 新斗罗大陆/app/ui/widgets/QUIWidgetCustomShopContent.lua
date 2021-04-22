-- @Author: liaoxianbo
-- @Date:   2020-10-25 11:33:16
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-11-04 12:23:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetCustomShopContent = class("QUIWidgetCustomShopContent", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCustomShopItemBox = import("..widgets.QUIWidgetCustomShopItemBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QPayUtil = import("..utils.QPayUtil")
local QQuickWay = import("....utils.QQuickWay")
local QRichText = import("....utils.QRichText")

local ITEM_BOX_POS = {
	{ccp(32,-108)},
	{ccp(-20,-108),ccp(80,-108)},
	{ccp(32,-58),ccp(-20,-158),ccp(80,-158)},
	{ccp(-20,-58),ccp(80,-58),ccp(-20,-158),ccp(80,-158)},
}

function QUIWidgetCustomShopContent:ctor(options)
	local ccbFile = "ccb/Widget_Custom_Shop_content.ccbi"
    local callBacks = {
    }
    QUIWidgetCustomShopContent.super.ctor(self, ccbFile, callBacks, options)
  
    self._ccbOwner.sp_mask:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_mask:setColor(ccc3(0, 0, 100))
    self._ccbOwner.sp_mask:setOpacity(0.3 * 255)

	self._customShopModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.CUSTOM_SHOP)

	self._sellout = false
	self._showItem = {} --展示已选择的物品
	self._itemPool = {}
	self._currItemList = {}
	self._completeState = self._customShopModule.NOTCUSTOM_ACTION 
	
    self._richText = QRichText.new({}, 200, {autoCenter = true})
    self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_title:addChild(self._richText)

end

function QUIWidgetCustomShopContent:onEnter()
end

function QUIWidgetCustomShopContent:onExit()
end

function QUIWidgetCustomShopContent:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end


function QUIWidgetCustomShopContent:resetAll( )
	self._ccbOwner.node_gift:removeAllChildren()

	self._ccbOwner.sp_red_tips:setVisible(false)
	self._ccbOwner.sp_yishoukong:setVisible(false)

	self:changeBtnRes(self._customShopModule.NOTCUSTOM_ACTION)

end

-- customShop_button_res
function QUIWidgetCustomShopContent:changeBtnRes(btnType)
	self._completeState = btnType
	local name = "订制礼包"
	self._ccbOwner.sp_token:setVisible(false)
	self._ccbOwner.sp_Rmb:setVisible(false)
	self._ccbOwner.btn_buy:setLabelAnchorPoint(ccp(0.5, 0.92))
	if btnType == self._customShopModule.RECHARGE_ACTION then
		local rechageInfo = self._customShopModule:getRechargeInfo(self._info.price)
		if q.isEmpty(rechageInfo) == false then
			name = (rechageInfo.RMB or 0)
		end
		self._ccbOwner.btn_buy:setLabelAnchorPoint(ccp(0.2, 0.92))
		self._ccbOwner.sp_Rmb:setVisible(true)
	elseif btnType == self._customShopModule.FREEGET_ACTION then
		if self._info.type == 2 then
			name = self._info.price or 0
			self._ccbOwner.sp_token:setVisible(true)
			self._ccbOwner.btn_buy:setLabelAnchorPoint(ccp(0.3, 0.92))
		else
			name = "立即领取"
		end
	end
    self._ccbOwner.btn_buy:setTitleForState(CCString:create(name), CCControlStateNormal)
    self._ccbOwner.btn_buy:setTitleForState(CCString:create(name), CCControlStateHighlighted)
    self._ccbOwner.btn_buy:setTitleForState(CCString:create(name), CCControlStateDisabled)

end

function QUIWidgetCustomShopContent:setInfo(info)
	if q.isEmpty(info) then return end
	self:resetAll()

	self._customContenInfo = info

	self._info = self._customContenInfo.itemConfig or {}

	local currItemList = self._customContenInfo.curItemList or {}

	local buyNums = self._customContenInfo.buyNums or 0
	local completeCount = self._customContenInfo.completeCount or 0
	if self._customContenInfo.isFree then
		self._ccbOwner.tf_gift_price:setString(self._info.name or "")
		self._richText:setString("")
	else
		if self._info.type == 1 then
			self._ccbOwner.tf_gift_price:setString("")
			self._richText:setString({
		            {oType = "img", fileName = "icon/Tap_icon_g/Tap_rmb_g.png",scale = 0.5,offsetY = 1.5,offsetX = 2},
		            {oType = "font", content = self._info.name or "", size = 24, color = GAME_COLOR_SHADOW.stress,strokeColor = ccc3(124,87,206)},	
			})
		else
			local tokenConfig =  remote.items:getWalletByType(ITEM_TYPE.TOKEN_MONEY)
			self._richText:setString({
		            {oType = "img", fileName = tokenConfig.alphaIcon,scale = 0.55,offsetY = 1.5},
		            {oType = "font", content = self._info.name or "", size = 22, color = GAME_COLOR_SHADOW.stress,strokeColor = ccc3(124,87,206)},			
			})
			self._ccbOwner.tf_gift_price:setString("")
		end
	end
	self._ccbOwner.tf_buynums:setString(buyNums.."/"..(self._info.max_buy_num or 0))

	self._sellout = self._customContenInfo.sellout or false

	self._ccbOwner.sp_yishoukong:setVisible(self._sellout)
	self._ccbOwner.node_btn:setVisible(not self._sellout)

	self._ccbOwner.sp_mask:setVisible(self._sellout)

	local custom_item = self._info.custom_item or ""
	local customItemTbl = string.split(custom_item,",")
	self._itemPool = {}
	for _,v in pairs(customItemTbl) do
		if v and v ~= "" then
			self._itemPool[#self._itemPool + 1] = v
		end
	end

	self:changeBtnRes(self._customContenInfo.btnState)

	local isPool = true
	local itemBoxNum = 3
	local itemList = self._itemPool
	if q.isEmpty(currItemList) == false then
		itemList = currItemList
		isPool = false
	end

	itemBoxNum  = #itemList
	if itemBoxNum > 4 then
		itemBoxNum = 4
	end
	for ii=1,itemBoxNum do
		local itemBox = QUIWidgetCustomShopItemBox.new()
		self._ccbOwner.node_gift:addChild(itemBox)
		itemBox:setPosition(ITEM_BOX_POS[itemBoxNum][ii])
		self:setItemInfo(itemBox,itemList[ii],isPool)
	end

	self:checkRedTips()
end

function QUIWidgetCustomShopContent:setItemInfo(item,data,isPool)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setPosition(ccp(50, 50))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(100, 100))
	end
	if isPool then
		item._itemBox:isShowPlus(true)
	else
		local itemData = data.itemData or {}

		item._itemBox:setGoodsInfo(itemData.id or 0,itemData.typeName, itemData.count)
	end
end

function QUIWidgetCustomShopContent:checkRedTips( )
	if q.isEmpty(self._customContenInfo) then 
		self._ccbOwner.sp_red_tips:setVisible(false)
	end

	if self._customContenInfo.isFree and not self._sellout then
		self._ccbOwner.sp_red_tips:setVisible(true)
	end

	if self._customContenInfo.btnState == self._customShopModule.FREEGET_ACTION and self._info.type ~= 2 then
		self._ccbOwner.sp_red_tips:setVisible(true)
	end
end

function QUIWidgetCustomShopContent:fastBuy(price,rechageType,rechargeBuyProductid)
	if price == nil or price == 0 then return end
	app.sound:playSound("common_small")

	if ENABLE_CHARGE_BY_WEB and CHARGE_WEB_URL then
		QPayUtil.payOffine(price, rechageType,rechargeBuyProductid)
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
			QPayUtil:hjPayOffline(price, rechageType, rechargeBuyProductid)
		else
			QPayUtil:pay(price, rechageType, rechargeBuyProductid)
		end
	end
end

function QUIWidgetCustomShopContent:onTriggerBuy()
	
	local closeTipsFun = function( )
		if self._customShopModule.isOpen == false then
			remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_ACTIVITY_CLOSE})
			return true
		end
		return false
	end

	if q.isEmpty(self._customContenInfo.curItemList) then
		self:onTriggerClick()
		return
	end

	local requestGiftFunc = function()
		self._customShopModule:customShopReceiveGiftRequest(self._info.type,self._info.id,function(data)
			--弹恭喜获得
			local awards = {}
			local prizes = data.prizes or {}
			for _,item in pairs(prizes) do
	            local typeName = remote.items:getItemType(item.type)
	            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
    				if self._customShopModule:checkCustomIsOpen() then
    					self._customShopModule:requestMyCustomInfo()
    				end
    				closeTipsFun()
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得以下订制商品")
		end)
	end

	if self._customContenInfo.curItemList then
		if self._completeState == self._customShopModule.FREEGET_ACTION then
			if self._info.type == 2 then
				local costValue = self._info.price or 0
			    if costValue > remote.user.token then
			        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			        return
			    end

			    local tipStr = string.format("##n消耗##e%s钻石##n购买##e%s##n，确认购买?",costValue, self._info.name or "")
			    app:alert({content = tipStr, title = "系统提示", 
			        callback = function(callType)
			            if callType == ALERT_TYPE.CONFIRM then
			                requestGiftFunc()
			            end
			        end, isAnimation = true, colorful = true}, true, true)   

			else
				requestGiftFunc()
			end
			
		else
			if closeTipsFun() then
				return
			end
			local rechageInfo = self._customShopModule:getRechargeInfo(self._info.price)
			if q.isEmpty(rechageInfo) == false then
				self:fastBuy(rechageInfo.RMB,rechageInfo.type,rechageInfo.recharge_buy_productid)
			end
		end
	else
		self:onTriggerClick()
	end	
end

function QUIWidgetCustomShopContent:onTriggerClick( )
	if self._sellout then 
		app.tip:floatTip("商品订制已达最大次数")
		return 
	end
	if self._completeState == self._customShopModule.FREEGET_ACTION  and self._info.type == 1 and self._customContenInfo.isFree == false then
		app.tip:floatTip("商品已经订制，请先领取")
		return 
	end

	if self._customShopModule.isOpen == false then
		remote.activityRounds:dispatchEvent({name = remote.activityRounds.CUSTOM_SHOP_ACTIVITY_CLOSE})
		return true
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChosseCustomGift", 
		options = {itemPool = self._itemPool,info = self._info}})	
end

return QUIWidgetCustomShopContent
