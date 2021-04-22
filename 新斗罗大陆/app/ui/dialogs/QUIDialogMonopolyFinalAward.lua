--
-- Author: Kumo.Wang
-- 大富翁终极大奖主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyFinalAward = class("QUIDialogMonopolyFinalAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogMonopolyFinalAward:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_reward1.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIDialogMonopolyFinalAward.super.ctor(self, ccbFile, callBack, options)
	q.setButtonEnableShadow(self._ccbOwner.btn_OK)
	self._callBack = options.callBack
    self:resetAll()
end

function QUIDialogMonopolyFinalAward:viewDidAppear()
	QUIDialogMonopolyFinalAward.super.viewDidAppear(self)

	self._monopolyProxy = cc.EventProxy.new(remote.monopoly)
    self._monopolyProxy:addEventListener(remote.monopoly.NEW_DAY, handler(self, self._monopolyProxyHandler))
end

function QUIDialogMonopolyFinalAward:viewWillDisappear()
	QUIDialogMonopolyFinalAward.super.viewWillDisappear(self)

    self._monopolyProxy:removeAllEventListeners()
end

function QUIDialogMonopolyFinalAward:_monopolyProxyHandler(event)
    print("QUIDialogMonopolyFinalAward:_monopolyProxyHandler(event)", event.name)
    if event.name == remote.monopoly.NEW_DAY then
       self:_resetRewardInfo()
    end
end

function QUIDialogMonopolyFinalAward:resetAll()
	self:_resetAllSelect()

	self:_resetRewardInfo()

	if remote.monopoly.monopolyInfo.removePoisonCount >= #remote.monopoly.formulaTbl then
		self._ccbOwner.tf_btnOK:setString("领取奖励")
	else
		self._ccbOwner.tf_btnOK:setString("关  闭")
	end
end

function QUIDialogMonopolyFinalAward:_resetRewardInfo()
	self._finalRewardTbl = remote.monopoly:getFinalRewardLuckyDrawKey()
	local i = 1
	for _, luckyDrawKey in ipairs(self._finalRewardTbl) do
		local rewardInfo = clone(remote.monopoly:getLuckyDrawByKey(luckyDrawKey))
		local node = self._ccbOwner["icon_reward"..i]
		if node and rewardInfo then
			local itemBox = QUIWidgetItemsBox.new()
			if rewardInfo.id_1 == remote.monopoly.mainHeroItemId then
				rewardInfo.id_1 = remote.monopoly:getMainHeroSoulItemId()
			end
			itemBox:setGoodsInfo(rewardInfo.id_1, rewardInfo.type_1, rewardInfo.num_1)
			itemBox:setPromptIsOpen(true)
			node:removeAllChildren()
			node:addChild(itemBox)
			node:setVisible(true)
			i = i + 1
		end
	end
end

function QUIDialogMonopolyFinalAward:_resetAllSelect()
	for i = 1, 6, 1 do
		if remote.monopoly.monopolyInfo.removePoisonCount >= #remote.monopoly.formulaTbl then
			self._ccbOwner["btn_select_"..i]:setVisible(true)
			self._ccbOwner["btn_select_"..i]:setEnabled(true)
		else
			self._ccbOwner["btn_select_"..i]:setVisible(false)
			self._ccbOwner["btn_select_"..i]:setEnabled(false)
		end
	end
	self._ccbOwner.node_nike:removeAllChildren()
	self._ccbOwner.node_nike:setVisible(true)
	self._curSelectIndex = 0
end

function QUIDialogMonopolyFinalAward:_onTriggerSelect(event, target)
	app.sound:playSound("common_small")
	self:_resetAllSelect()
	for i = 1, 6, 1 do
		if target == self._ccbOwner["btn_select_"..i] then
			local nikeImg = remote.monopoly:getNikeImg()
            self._ccbOwner.node_nike:addChild(nikeImg)
            local pos = ccp(self._ccbOwner["btn_select_"..i]:getPosition())
            nikeImg:setPosition(pos)
			self._curSelectIndex = i
		end
	end
end

function QUIDialogMonopolyFinalAward:_onTriggerOK()
    app.sound:playSound("common_small")
    if remote.monopoly.monopolyInfo.removePoisonCount >= #remote.monopoly.formulaTbl then
		if self._curSelectIndex == 0 then
			app.tip:floatTip("请选择奖励")
		else
			remote.monopoly:monopolyGetFinalRewardRequest(self._finalRewardTbl[self._curSelectIndex], self:safeHandler(function(data)
					-- app.tip:floatTip("获得最终大奖")
					self:_onTriggerClose()
					remote.monopoly:showFinalRewardForDialog(data.prizes)
				end))
		end
	else
		self:_onTriggerClose()
	end
end

-- function QUIDialogMonopolyFinalAward:onTriggerBackHandler()
--     self:_onTriggerClose()
-- end

function QUIDialogMonopolyFinalAward:_onTriggerClose()
	self:popSelf()
	if self._callBack then
		self._callBack()
	end
end

return QUIDialogMonopolyFinalAward