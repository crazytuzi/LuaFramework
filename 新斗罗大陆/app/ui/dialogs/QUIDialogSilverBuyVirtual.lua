--
-- Author: zxs
-- Date: 2018-07-24 10:58:34
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSilverBuyVirtual = class("QUIDialogSilverBuyVirtual", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBuyVirtualLog = import("..widgets.QUIWidgetBuyVirtualLog")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QVIPUtil = import("...utils.QVIPUtil")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSilverBuyVirtual:ctor(options)
	local ccbFile = "ccb/Dialog_SilverMine_buy.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIDialogSilverBuyVirtual._onTriggerBuy)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSilverBuyVirtual._onTriggerClose)},
	}
	QUIDialogSilverBuyVirtual.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true --是否动画显示

	self._ccbOwner.frame_tf_title:setString("购 买")

	self._typeName = ITEM_TYPE.GOLDPICKAXE_TIMES
end

function QUIDialogSilverBuyVirtual:viewDidAppear()
    QUIDialogSilverBuyVirtual.super.viewDidAppear(self)

    self:refreshInfo()
end

function QUIDialogSilverBuyVirtual:viewWillDisappear()
    QUIDialogSilverBuyVirtual.super.viewWillDisappear(self)

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end

	remote.silverMine:setIsWaitShowChangeAni(false)
end

function QUIDialogSilverBuyVirtual:refreshInfo()
	self._totalNum = QVIPUtil:getBuyVirtualCount(self._typeName)
	self._buyCount = remote.silverMine:getMiningPickBuyCount()
	self._leftNum = self._totalNum - self._buyCount
	if self._leftNum <= 0 then 
		self._leftNum = 0 
		self._needVipAlert = true
	end

	local config = QStaticDatabase:sharedDatabase():getTokenConsume(self._typeName, self._buyCount + 1)
	self._needNum = config.money_num

	self:setSilverMineGoldPickaxeInfo()
	self:updateOutput()
end

function QUIDialogSilverBuyVirtual:setSilverMineGoldPickaxeInfo()
	self._ccbOwner.tf_count:setString("(剩余次数"..self._leftNum.."/"..self._totalNum..")")
	self._ccbOwner.tf_need_num:setString(self._needNum)
	local str = db:getConfigurationValue("huangjinkuanggao_time")
	self._ccbOwner.tf_receive_num:setString(str.."小时")

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
	self:_updateGoldPickaxeTime()
	self._goldPickaxeScheduler = scheduler.scheduleGlobal(self:safeHandler(function() 
			self:_updateGoldPickaxeTime()
		end), 1)
end

function QUIDialogSilverBuyVirtual:_updateGoldPickaxeTime()
	local isOvertime, timeStr, _, isCanBuy = remote.silverMine:updateGoldPickaxeTime(true)
	self._isCanBuyGoldPickaxeTime = isCanBuy
	if isOvertime then
		self._ccbOwner.tf_time:setString("00:00:00")
	else
		self._ccbOwner.tf_time:setString(timeStr)
	end
end

function QUIDialogSilverBuyVirtual:updateOutput()
	local myOccupy = remote.silverMine:getMyOccupy()
	if not myOccupy or not next(myOccupy) then
		self._ccbOwner.tf_income:setString("预计2小时收益：")
		self._ccbOwner.tf_silver_money:setString("0")
		self._ccbOwner.tf_money:setString("0")
		return
	end
	local multi = 1
	if self._buyCount <= 0 then
		self._ccbOwner.tf_income:setString("预计2小时收益：")
	else
		self._ccbOwner.tf_income:setString("预计"..(2*self._buyCount).."小时收益：")
		multi = self._buyCount/2
	end
	local moneyBuff, silverMoneyBuff = remote.silverMine:getOutPutByMineId(myOccupy.mineId, myOccupy.oriOccupyId, nil, myOccupy.consortiaId, true )
	local moneyOutput = math.floor(moneyBuff)
	local silverMineMoneyOutput = math.floor(silverMoneyBuff)
	local numMoney, unitMoney = q.convertLargerNumber( moneyOutput * 12*multi )
	self._ccbOwner.tf_money:setString( numMoney..(unitMoney or "") )
	local numSilvermineMoney, unitSilvermineMoney = q.convertLargerNumber( silverMineMoneyOutput * 12*multi )
	self._ccbOwner.tf_silver_money:setString( numSilvermineMoney..(unitSilvermineMoney or "") )
end

function QUIDialogSilverBuyVirtual:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogSilverBuyVirtual:_onTriggerBuy(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_buy) == false then return end
  	app.sound:playSound("common_confirm")
  	if self._needVipAlert then
		app:vipAlert({title = "诱魂草可购买次数", textType = VIPALERT_TYPE.NOT_ENOUGH, model = VIPALERT_MODEL.SILVERMINE_BUY_GOLDPICKAXECOUNT}, false)
  		return
  	end

	local myOccupy = remote.silverMine:getMyOccupy()
	if myOccupy and next(myOccupy) then
		if not self._isCanBuyGoldPickaxeTime then
			local limit = db:getConfigurationValue("huangjinkuanggao_time_limit") - db:getConfigurationValue("huangjinkuanggao_time")
			app.tip:floatTip("魂师大人，剩余时间低于"..limit.."小时后才能购买哦~")
		else
			remote.silverMine:setIsNeedShowChangeAni(true)
			remote.silverMine:setIsWaitShowChangeAni(true)
			remote.silverMine:silverMineBuyMiningPick(function(data)
				self:refreshInfo()

				app.tip:floatTip("购买成功")
			end)
		end
	else
		app.tip:floatTip("魂师大人，您当前还未狩猎魂兽区，无法购买哦~")
	end
end

function QUIDialogSilverBuyVirtual:_onTriggerVIP()
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip", options = {vipContentLevel = QVIPUtil:VIPLevel()}})
end

function QUIDialogSilverBuyVirtual:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilverBuyVirtual:_updateTime()
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then return end
	
	local curTimeTbl = q.date("*t", q.serverTime())
	local startTime = remote.union:getSocietyDungeonStartTime()
	local endTime = remote.union:getSocietyDungeonEndTime()
	if curTimeTbl.hour < startTime or curTimeTbl.hour >= endTime then
		self._isInTime = false
	else
		self._isInTime = true
	end
end

function QUIDialogSilverBuyVirtual:_updateGoldPickaxeTime()
	local isOvertime, timeStr, _, isCanBuy = remote.silverMine:updateGoldPickaxeTime(true)
	self._isCanBuyGoldPickaxeTime = isCanBuy
	if isOvertime then
		self._ccbOwner.tf_time:setString("00:00:00")
	else
		self._ccbOwner.tf_time:setString(timeStr)
	end
end

return QUIDialogSilverBuyVirtual