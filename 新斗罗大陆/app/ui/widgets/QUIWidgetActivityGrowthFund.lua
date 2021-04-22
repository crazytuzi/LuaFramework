--
-- Kumo.Wang
-- 成长基金界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityGrowthFund = class("QUIWidgetActivityGrowthFund", QUIWidget)

local QUIWidgetActivityGrowthFundCell = import("..widgets.QUIWidgetActivityGrowthFundCell")
local QScrollContain = import("..QScrollContain")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")

QUIWidgetActivityGrowthFund.TAB_FUND = "TAB_FUND"
QUIWidgetActivityGrowthFund.TAB_WELFARE = "TAB_WELFARE"

function QUIWidgetActivityGrowthFund:ctor(options)
	local ccbFile = "ccb/Widget_GrowthFund.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
  		{ccbCallbackName = "onTriggerFund", callback = handler(self, self._onTriggerFund)},
  		{ccbCallbackName = "onTriggerWeal", callback = handler(self, self._onTriggerWeal)},
  		{ccbCallbackName = "onTriggerBuyLink", callback = handler(self, self._onTriggerBuyLink)},
  	}
	QUIWidgetActivityGrowthFund.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityGrowthFund:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote.user)
    self._remoteProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.setInfo))

    self._growthFundProxy = cc.EventProxy.new(remote.growthFund)
    self._growthFundProxy:addEventListener(remote.growthFund.EVENT_UPDATE, handler(self, self.setInfo))

    app:getClient():buyFundCountRequest(function()
    	if self:safeCheck() then
    		self:_updateRedTips()
    	end
    end)
end

function QUIWidgetActivityGrowthFund:onExit()
    if self._remoteProxy ~= nil then
    	self._remoteProxy:removeAllEventListeners()
    	self._remoteProxy = nil
    end

    if self._growthFundProxy ~= nil then
    	self._growthFundProxy:removeAllEventListeners()
    	self._growthFundProxy = nil
    end
end

function QUIWidgetActivityGrowthFund:setInfo()
	self._needVip, self._payMoney = remote.growthFund:getBuyFundCondition()

	if self._selelctTabeName ~= nil then
		self:_selectTab(self._selelctTabeName)
	else
		self:_selectTab(QUIWidgetActivityGrowthFund.TAB_FUND)
	end

	self:_updateFundBuyInfo()
	self:_updateRedTips()
end

function QUIWidgetActivityGrowthFund:_updateFundBuyInfo()
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

	if remote.user.fundStatus == 1 then
		local getToken, willToken = remote.growthFund:getFundTokenInfo()
		self._ccbOwner.alreadyGetGold:setString(getToken.."钻石")
		self._ccbOwner.willGetGold:setString(willToken.."钻石")
	end

	self:_showNum(remote.user.fundBuyCount or 0)
end

function QUIWidgetActivityGrowthFund:_updateRedTips()
	self._ccbOwner.fund_tips:setVisible(remote.growthFund:checkFundRedTips())
	self._ccbOwner.weal_tips:setVisible(remote.growthFund:checkWelfareRedTips())
end

function QUIWidgetActivityGrowthFund:_showNum(num)
	for i=4,1,-1 do
		self._ccbOwner["tf_num"..i]:setString(num%10)
		num = math.floor(num/10)
	end
end

function QUIWidgetActivityGrowthFund:_selectTab(typeName)
	self._selelctTabeName = typeName
	self._listData = {}

	if typeName == QUIWidgetActivityGrowthFund.TAB_FUND then
		self:_isSelectFund(true)
		self._listData = remote.growthFund:getFundListData()
	elseif typeName == QUIWidgetActivityGrowthFund.TAB_WELFARE then
		self:_isSelectFund(false)
		self._listData = remote.growthFund:getWelfareListData()
	end

	if not self._listView then
		self:_initListView()
	else
		self._listView:reload({totalNumber = #self._listData})
	end
end

function QUIWidgetActivityGrowthFund:_initListView(  )
    if type(self._listData) ~= "table" then
        self._listData = {}
    end
    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local item = list:getItemFromCache()

            local data = self._listData[index]
            if not item then
                item = QUIWidgetActivityGrowthFundCell.new()
                isCacheNode = false
            end
            item:setInfo(data, self)
            info.item = item
            info.size = item:getContentSize()

            list:registerBtnHandler(index, "btn_ok", "_onTriggerOK", nil, true)

            item:registerItemBoxPrompt(index,list)
            return isCacheNode
        end,
        spaceY = 2,
        enableShadow = false,
        totalNumber = #self._listData,
    }  
    self._listView = QListView.new(self._ccbOwner.menu_sheet_layout,cfg)
end

function QUIWidgetActivityGrowthFund:_isSelectFund(b)
	self._ccbOwner.btn_fund:setEnabled(not b)
	self._ccbOwner.btn_fund:setHighlighted(b)
	self._ccbOwner.btn_weal:setEnabled(b)
	self._ccbOwner.btn_weal:setHighlighted(not b)
	self._ccbOwner.node_fund:setVisible(b)
	self._ccbOwner.node_weal:setVisible(not b)
	self._ccbOwner.bg1:setVisible(b)
	self._ccbOwner.bg2:setVisible(not b)

	if not b then
		self._ccbOwner.node_link_btn:setVisible(remote.user.fundStatus ~= 1)
	end
end

function QUIWidgetActivityGrowthFund:_onTriggerBuy(event)
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
			remote.activity:dispatchEvent({name = remote.activity.EVENT_CHANGE})
			remote.user:update({fundBuyCount = remote.user.fundBuyCount+1})
			self:_updateFundBuyInfo()
		end)
	end
end

function QUIWidgetActivityGrowthFund:_onTriggerFund()
    app.sound:playSound("common_menu")
	self:_selectTab(QUIWidgetActivityGrowthFund.TAB_FUND)
end

function QUIWidgetActivityGrowthFund:_onTriggerWeal()
    app.sound:playSound("common_menu")
	self:_selectTab(QUIWidgetActivityGrowthFund.TAB_WELFARE)
end

function QUIWidgetActivityGrowthFund:_onTriggerBuyLink( event )
    if q.buttonEventShadow(event, self._ccbOwner.buyLinkBtn) == false then return end
	self:_onTriggerFund()
end

return QUIWidgetActivityGrowthFund