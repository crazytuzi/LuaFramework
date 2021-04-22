-- @Author: xurui
-- @Date:   2019-12-30 20:36:53
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-02 20:39:03
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialoTotemChallengeWeekAward = class("QUIDialoTotemChallengeWeekAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialoTotemChallengeWeekAward:ctor(options)
	local ccbFile = "ccb/Dialog_totemChallenge_weekAward.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
    }
    QUIDialoTotemChallengeWeekAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_recive)
    self._ccbOwner.frame_tf_title:setString("圣柱挑战结算")

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
    end

    self._itemsBox = {}
end

function QUIDialoTotemChallengeWeekAward:viewDidAppear()
	QUIDialoTotemChallengeWeekAward.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialoTotemChallengeWeekAward:viewWillDisappear()
  	QUIDialoTotemChallengeWeekAward.super.viewWillDisappear(self)
end

function QUIDialoTotemChallengeWeekAward:setInfo()
	self._awardInfo = remote.totemChallenge:getTotemChallengeWeekAward()
	local totalNum = self._awardInfo.rivalPos or 1
	local config = remote.totemChallenge:getDungeonConfigById(totalNum)
	if config then
		local floor = tonumber(config.level)
		local dungeon = tonumber(config.wave)
		self._ccbOwner.tf_desc:setString(string.format("您上周的通关层数是%s-%s，本周请继续加油哦！", floor, dungeon))
	else
		self._ccbOwner.tf_desc:setString("您上周的通关结算奖励，本周请继续加油哦！")
	end

	local awardStr = self._awardInfo.reward or "3^10;4^20;5^30"
	self._awards = {}
	remote.items:analysisServerItem(awardStr, self._awards)
	for i, value in ipairs(self._awards) do
		if self._itemsBox[i] == nil then
			self._itemsBox[i] = QUIWidgetItemsBox.new()
	    	self._itemsBox[i]:setPromptIsOpen(true)
			self._ccbOwner.node_item:addChild(self._itemsBox[i])
			local contentSize = self._itemsBox[i]:getContentSize()
			self._itemsBox[i]:setPositionX((contentSize.width + 40) * (i - 1) + contentSize.width/2)
		end

		self._itemsBox[i]:setGoodsInfo(value.id, value.typeName, value.count)
	end
end

function QUIDialoTotemChallengeWeekAward:_onTriggerRecive(event)
	app.sound:playSound("common_small")

	remote.totemChallenge:requestTotemChallengeWeekAwards(self._awardInfo.dateYmd, function()
		remote.totemChallenge:setTotemChallengeWeekAward({})
		self:popSelf()
		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
			options = {awards = self._awards, callback = function()
            	if self._callback then
            		self._callback()
            	end
	        end}}, {isPopCurrentDialog = false})
	    dialog:setTitle("恭喜您获得圣柱挑战结算奖励")
	end)
end

return QUIDialoTotemChallengeWeekAward
