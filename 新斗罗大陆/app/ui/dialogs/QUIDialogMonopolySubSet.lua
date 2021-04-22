-- @Author: liaoxianbo
-- @Date:   2019-05-05 10:39:12
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-25 11:10:54
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolySubSet = class("QUIDialogMonopolySubSet", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetQuickOpenBoxSetting = import("..widgets.QUIWidgetQuickOpenBoxSetting")
local QUIWidgetQuickCaiQuanSetting = import("..widgets.QUIWidgetQuickCaiQuanSetting")
local QUIWidgetQuickFlowerSetting = import("..widgets.QUIWidgetQuickFlowerSetting")
local QUIWidgetSecretarySettingTitle = import("..widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetFinalAwards = import("..widgets.QUIWidgetFinalAwards")

function QUIDialogMonopolySubSet:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_setting.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
    }
    QUIDialogMonopolySubSet.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._setId = options.setId
    if options then
    	self._callBack = options.callBack
    end

	self:initScrollView()
	self:initSettingLayer()
	self._ccbOwner.tf_tips:setVisible(false)
end

function QUIDialogMonopolySubSet:viewDidAppear()
	QUIDialogMonopolySubSet.super.viewDidAppear(self)
end

function QUIDialogMonopolySubSet:viewWillDisappear()
  	QUIDialogMonopolySubSet.super.viewWillDisappear(self)

	if self._widgetOpen then
		self._widgetOpen:removeFromParentAndCleanup(true)
		self._widgetOpen = nil
	end

	if self._widgetCaiquan then
		self._widgetCaiquan:removeFromParentAndCleanup(true)
		self._widgetCaiquan = nil
	end

	if self._widgetBuyNum then
		self._widgetBuyNum:removeFromParentAndCleanup(true)
		self._widgetBuyNum = nil
	end

	if self._widgetflower and next(self._widgetflower) ~= nil then
		for i,widget in pairs(self._widgetflower) do
			widget:removeFromParentAndCleanup(true)
		end	
		self._widgetflower = nil
	end	

end

function QUIDialogMonopolySubSet:initScrollView()
	self._sheetSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._sheetSize, {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
end

function QUIDialogMonopolySubSet:initSettingLayer()
	local setConfig = remote.monopoly:getSettingByMonoplyId(self._setId)
	local totalHeight = 0
	if setConfig.tabId == remote.monopoly.ZIDONG_OPEN then
		self._ccbOwner.frame_tf_title:setString("自动开箱")
		self._widgetOpen = QUIWidgetQuickOpenBoxSetting.new()
		self._widgetOpen:setBoxInfo(self._setId)
		self._widgetOpen:setPositionY(-totalHeight)
		local height = self._widgetOpen:getContentSize().height
		self._scrollView:addItemBox(self._widgetOpen)
		totalHeight = totalHeight+height
	elseif setConfig.tabId == remote.monopoly.ZIDONG_LEVELUP then
		self._ccbOwner.frame_tf_title:setString("自动升级")	
		local widget = QUIWidgetSecretarySettingTitle.new()
		widget:setInfo("仙品升级设置")
		widget:setPositionY(-totalHeight)
		local height = widget:getContentSize().height
		self._scrollView:addItemBox(widget)
		totalHeight = totalHeight+height
		local flowerconfig = remote.monopoly:getMonpolyXianPingConfigList()
		self._widgetflower = {}
	    for i, config in pairs(flowerconfig) do
        	local flowerwidget = QUIWidgetQuickFlowerSetting.new()
			flowerwidget:setBoxInfo(self._setId,config)
			flowerwidget:setPositionY(-totalHeight)
			local height = flowerwidget:getContentSize().height
			self._scrollView:addItemBox(flowerwidget)
			table.insert(self._widgetflower,flowerwidget)	
			totalHeight = totalHeight+height
    	end
	elseif setConfig.tabId == remote.monopoly.ZIDONG_CAIQUAN then
		self._ccbOwner.frame_tf_title:setString("自动猜拳")
		self._widgetCaiquan = QUIWidgetQuickCaiQuanSetting.new()
		self._widgetCaiquan:setBoxInfo(self._setId)
		self._widgetCaiquan:setPositionY(-totalHeight)
		local height = self._widgetCaiquan:getContentSize().height
		self._scrollView:addItemBox(self._widgetCaiquan)
		totalHeight = totalHeight+height
	elseif self._setId == remote.monopoly.MONOPOLY_BUYNUM_CHEAST then
		self._ccbOwner.frame_tf_title:setString("购买次数")	
		self._widgetBuyNum = QUIWidgetQuickOpenBoxSetting.new()
		self._widgetBuyNum:setBoxInfo(self._setId)
		self._widgetBuyNum:setPositionY(-totalHeight)
		local height = self._widgetBuyNum:getContentSize().height
		self._scrollView:addItemBox(self._widgetBuyNum)
	elseif self._setId == remote.monopoly.MONOPOLY_GETAWARS	then
		self._ccbOwner.frame_tf_title:setString("领取奖励")	
		local widget = QUIWidgetSecretarySettingTitle.new()
		widget:setInfo("领取选项")
		widget:setPositionY(-totalHeight)
		local height = widget:getContentSize().height
		self._scrollView:addItemBox(widget)
		totalHeight = totalHeight+height
		self._widgetFinalAward = {}
		local finalRewardTbl = remote.monopoly:getFinalRewardLuckyDrawKey()
	    for i, config in pairs(finalRewardTbl) do
        	local finalwidget = QUIWidgetFinalAwards.new()
			finalwidget:setBoxInfo(i,config)
			finalwidget:addEventListener(QUIWidgetFinalAwards.EVENT_SELECT_CLICK, handler(self, self._selectFinalAwardsEvent))	
			if i % 3 == 0 then
				finalwidget:setPositionY(-totalHeight)
				local height = finalwidget:getContentSize().height
				totalHeight = totalHeight+height
			else
				local width = finalwidget:getContentSize().width
				finalwidget:setPositionX(width*(i%3))
				finalwidget:setPositionY(-totalHeight)
			end
			self._scrollView:addItemBox(finalwidget)
			table.insert(self._widgetFinalAward,finalwidget)	
			
    	end	
	end
	self._scrollView:setRect(0, -totalHeight, 0, self._sheetSize.width)
end

function QUIDialogMonopolySubSet:_onTriggerOk()
    app.sound:playSound("common_switch")

    local setting = {}
    local oneSetting = {}

    local setConfig = remote.monopoly:getSettingByMonoplyId(self._setId)
    if setConfig.tabId == remote.monopoly.ZIDONG_OPEN then
		setting.openNum = self._widgetOpen:getCurNum()
		if remote.monopoly:getIsSettingOpen(setConfig.tabId) then
			oneSetting.openNum = self._widgetOpen:getCurNum()
		else
			oneSetting.openNum = 1
		end
		remote.monopoly:updateMonoplyOneSetting(setConfig.oneSetId,oneSetting)
	elseif setConfig.tabId == remote.monopoly.ZIDONG_LEVELUP then
		setting.flowerUp = {}
		for i,widget in pairs(self._widgetflower) do
			local onsetId = widget:getFlowerOneSetId()
			setting.flowerUp[i] = widget:getChooseState()
			oneSetting.levelUp = widget:getChooseState()
			remote.monopoly:updateMonoplyOneSetting(onsetId,oneSetting)
		end

	elseif setConfig.tabId == remote.monopoly.ZIDONG_CAIQUAN then
		setting.caiQuanNum = self._widgetCaiquan:getCurNum()
		if remote.monopoly:getIsSettingOpen(setConfig.tabId) then
			oneSetting.caiQuanNum = self._widgetCaiquan:getCurNum()
		else
			oneSetting.caiQuanNum = 1
		end
		remote.monopoly:updateMonoplyOneSetting(setConfig.oneSetId,oneSetting)	

	elseif self._setId == remote.monopoly.MONOPOLY_BUYNUM_CHEAST then
		oneSetting.buyNum = self._widgetBuyNum:getCurNum()
		remote.monopoly:updateMonoplyOneSetting(2,oneSetting)
	elseif self._setId == remote.monopoly.MONOPOLY_GETAWARS then
		if self._widgetFinalAward and next(self._widgetFinalAward) ~= nil then
			for i,widget in pairs(self._widgetFinalAward) do
				if widget:getChooseState() then
					oneSetting.finalAwardIndex = widget:getItemIndex()
					local itemInfo = widget:getItemInfo()
					oneSetting.finalAwardType = itemInfo.type_1
					oneSetting.finalAwardId = itemInfo.id_1
					oneSetting.finalSaveId = widget:getItemSaveInfo()
					break
				end
			end
		end
		remote.monopoly:updateMonoplyOneSetting(1,oneSetting)		
	end
	if self._setId ~= remote.monopoly.MONOPOLY_BUYNUM_CHEAST then
		remote.monopoly:updateMonoplySetting(self._setId, setting)
	end

	app.tip:floatTip("设置已保存~")
    self:playEffectOut()
end

function QUIDialogMonopolySubSet:_selectFinalAwardsEvent(event)
	if event.name == QUIWidgetFinalAwards.EVENT_SELECT_CLICK then
		if self._widgetFinalAward and next(self._widgetFinalAward) ~= nil then
			for i,widget in pairs(self._widgetFinalAward) do
				if i ~= event.index then
					widget:setSelectChoose(false)
				end
			end
		end
	end
end
function QUIDialogMonopolySubSet:_onTriggerCancel()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

function QUIDialogMonopolySubSet:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMonopolySubSet:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMonopolySubSet
