--
-- Author: Your Name
-- Date: 2015-07-15 11:39:38
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityFund = class("QUIWidgetActivityFund", QUIWidget)

local QUIWidgetActivityFundItem = import("..widgets.QUIWidgetActivityFundItem")
local QScrollContain = import("..QScrollContain")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")

QUIWidgetActivityFund.TAB_FUND = "TAB_FUND"
QUIWidgetActivityFund.TAB_WEAL = "TAB_WEAL"

QUIWidgetActivityFund.WEAL_TYPE = 521

function QUIWidgetActivityFund:ctor(options)
	local ccbFile = "ccb/Widget_Fund.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
  		{ccbCallbackName = "onTriggerFund", callback = handler(self, self._onTriggerFund)},
  		{ccbCallbackName = "onTriggerWeal", callback = handler(self, self._onTriggerWeal)},
  		{ccbCallbackName = "onTriggerPay", callback = handler(self, self._onTriggerPay)},
  		{ccbCallbackName = "onTriggerBuyLink", callback = handler(self, self._onTriggerBuyLink)},
  	}
	QUIWidgetActivityFund.super.ctor(self,ccbFile,callBacks,options)

	self._needVip = 0
end

function QUIWidgetActivityFund:initListView(  )
    if type(self._selectInfo) ~= "table" then
        self._selectInfo = {}
    end
    local cfg = {
        renderItemCallBack = function( list, index, info )
            -- body
            local isCacheNode = true
            local item = list:getItemFromCache()

            local data = self._selectInfo[index]
            if not item then
                item = QUIWidgetActivityFundItem.new()
                isCacheNode = false
            end
            item:setInfo(self._info.activityId, data, self)
            info.item = item
            info.size = item:getContentSize()

            list:registerBtnHandler(index, "btn_ok", "_onTriggerConfirm", nil, true)

            item:registerItemBoxPrompt(index,list)
            return isCacheNode
        end,
        spaceY = 2,
        enableShadow = false,
        totalNumber = #self._selectInfo,
    }  
    self._infoListView = QListView.new(self._ccbOwner.menu_sheet_layout,cfg)
end

function QUIWidgetActivityFund:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote.user)
    self._remoteProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._remoteUpdateHandler))
    app:getClient():buyFundCountRequest(function ()
    	if self:safeCheck() then
    		self:redTips()
    	end
    end)
end

function QUIWidgetActivityFund:onExit()
    if self._remoteProxy ~= nil then
    	self._remoteProxy:removeAllEventListeners()
    	self._remoteProxy = nil
    end
end

function QUIWidgetActivityFund:isBuy()
	if remote.user.fundStatus ~= 1 then
		self._ccbOwner.node_buy:setVisible(true)
		if QVIPUtil:VIPLevel() > self._needVip and remote.user.token > self._payMoney then
			self._ccbOwner.buy_tips:setVisible(true)
		else
			self._ccbOwner.buy_tips:setVisible(false)
		end
	else
		self._ccbOwner.node_buy:setVisible(false)
	end
	self._ccbOwner.sp_buy:setVisible(remote.user.fundStatus == 1)
	self._ccbOwner.vip_level:setString("VIP "..QVIPUtil:VIPLevel())
	self._ccbOwner.tf_vip_contidion:setString("VIP"..self._needVip)
	self._ccbOwner.node_status1:setVisible(remote.user.fundStatus ~= 1)
	self._ccbOwner.node_status2:setVisible(remote.user.fundStatus == 1)
	-- self._ccbOwner.node_status2:removeAllChildren()
	if remote.user.fundStatus == 1 then
		local getToken = 0
		local willToken = 0
		for _,value in pairs(self._info.targets) do
			if value.type ~= QUIWidgetActivityFund.WEAL_TYPE then
				local items = string.split(value.awards, ";") 
				local count = #items
				for i=1,count,1 do
		            local obj = string.split(items[i], "^")
		            if #obj == 2 then
		            	if remote.items:getItemType(obj[1]) == ITEM_TYPE.TOKEN_MONEY then
		            		if value.completeNum == 3 then
		            			getToken = getToken + tonumber(obj[2])
		            		else
		            			willToken = willToken + tonumber(obj[2])
		            		end
		            	end
		            end
				end
			end
		end
		self._ccbOwner.alreadyGetGold:setString(getToken.."钻石")
		self._ccbOwner.willGetGold:setString(willToken.."钻石")
	end

	self:showNum(remote.user.fundBuyCount or 0)
	if self._isBuy == nil then
		self._isBuy = remote.user.fundStatus == 1
	elseif self._isBuy == false and remote.user.fundStatus == 1 then
		self._isBuy = remote.user.fundStatus == 1
		if self._selelctTabeName == QUIWidgetActivityFund.TAB_FUND then
			self:selectTab(QUIWidgetActivityFund.TAB_FUND)
		end
	end
end

function QUIWidgetActivityFund:setInfo(info)
	self._info = info
	local param = string.split(self._info.params, ",")
	if #param == 2 then
		self._needVip = tonumber(param[1])
		self._payMoney = tonumber(param[2])
	end
	if self._selelctTabeName ~= nil then
		self:selectTab(self._selelctTabeName)
	else
		self:selectTab(QUIWidgetActivityFund.TAB_FUND)
	end
	self:isBuy()
	self:redTips()
end

function QUIWidgetActivityFund:redTips()
	local fundTips = false
	local wealTips = false
	for _,value in pairs(self._info.targets) do
		if value.type == QUIWidgetActivityFund.WEAL_TYPE then

			if wealTips == false and value.completeNum == 2 then
				wealTips = true	
			end
		else
			if fundTips == false and ((QVIPUtil:VIPLevel() >= self._needVip and remote.user.fundStatus ~= 1) or (value.completeNum == 2 and remote.user.fundStatus == 1)) then
				fundTips = true
			end
		end
	end
	self._ccbOwner.fund_tips:setVisible(fundTips)
	self._ccbOwner.weal_tips:setVisible(wealTips)
end

function QUIWidgetActivityFund:showNum(num)
	for i=4,1,-1 do
		self._ccbOwner["tf_num"..i]:setString(num%10)
		num = math.floor(num/10)
	end
end

function QUIWidgetActivityFund:selectTab(typeName)
	self._selelctTabeName = typeName
	self._selectInfo = {}
    local offsetY = 10
	if typeName == QUIWidgetActivityFund.TAB_FUND then
		self:isSelectFund(true)
		for _,value in pairs(self._info.targets) do
			if value.type ~= QUIWidgetActivityFund.WEAL_TYPE then
				local info = clone(value)
				if remote.user.fundStatus ~= 1 then
					info.completeNum = 1
				end
				table.insert(self._selectInfo, info)
			end
		end
	elseif typeName == QUIWidgetActivityFund.TAB_WEAL then
		self:isSelectFund(false)
		for _,value in pairs(self._info.targets) do
			if value.type == QUIWidgetActivityFund.WEAL_TYPE then
				table.insert(self._selectInfo, value)
			end
		end
	end

	if not self._infoListView then
		self:initListView()
	else
		self._infoListView:reload({totalNumber = #self._selectInfo})
	end
end

function QUIWidgetActivityFund:isSelectFund(b)
	self._ccbOwner.btn_fund:setEnabled(not b)
	self._ccbOwner.btn_fund:setHighlighted(b)
	self._ccbOwner.btn_weal:setEnabled(b)
	self._ccbOwner.btn_weal:setHighlighted(not b)
	self._ccbOwner.node_fund:setVisible(b)
	self._ccbOwner.node_weal:setVisible(not b)
	self._ccbOwner.bg1:setVisible(b)
	self._ccbOwner.bg2:setVisible(not b)

	if remote.user.fundStatus == 1 and not b then
		self._ccbOwner.node_link_btn:setVisible(false)
	end
end

function QUIWidgetActivityFund:_onTriggerBuy(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")
	if self._needVip ~= nil and self._payMoney ~= nil then
		if QVIPUtil:VIPLevel() < self._needVip then
			local text = "VIP达到"..self._needVip.."级可购买，是否前往充值提升VIP等级？"
			app:vipAlert({content=text}, false)
			return
		end
		if remote.user.token < self._payMoney then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			return
		end
		app:getClient():buyFundRequest(function (data)
			remote.activity:refreshActivity()
			remote.activity:dispatchEvent({name = remote.activity.EVENT_CHANGE})
			remote.user:update({fundBuyCount = remote.user.fundBuyCount+1})
			self:isBuy()
		end)
	end
end

function QUIWidgetActivityFund:_onTriggerFund()
    app.sound:playSound("common_menu")
	self:selectTab(QUIWidgetActivityFund.TAB_FUND)
end

function QUIWidgetActivityFund:_onTriggerWeal()
    app.sound:playSound("common_menu")
	self:selectTab(QUIWidgetActivityFund.TAB_WEAL)
end

function QUIWidgetActivityFund:_onTriggerPay()
    app.sound:playSound("common_small")
	if ENABLE_CHARGE() then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
	end
end

function QUIWidgetActivityFund:_onTriggerBuyLink( event )
    if q.buttonEventShadow(event, self._ccbOwner.buyLinkBtn) == false then return end
	self:_onTriggerFund()
end

function QUIWidgetActivityFund:_remoteUpdateHandler(event)
	if event.name == remote.user.EVENT_USER_PROP_CHANGE then
		self:isBuy()
	end
end


function QUIWidgetActivityFund:isTAB_FUND(  )
	if self._selelctTabeName then
		return self._selelctTabeName == QUIWidgetActivityFund.TAB_FUND
	end
	return true
end

return QUIWidgetActivityFund