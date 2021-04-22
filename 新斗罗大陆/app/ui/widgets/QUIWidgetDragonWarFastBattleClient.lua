-- @Author: xurui
-- @Date:   2017-04-28 14:28:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-06-12 19:25:39
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDragonWarFastBattleClient = class("QUIWidgetDragonWarFastBattleClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetDragonWarFastBattleClient:ctor(options)
	local ccbFile = "ccb/Widget_EliteBattleAgain_julongsaodang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerWinBuffer", callback = handler(self, self._onTriggerWinBuffer)},
		{ccbCallbackName = "onTriggerHolyBuffer", callback = handler(self, self._onTriggerHolyBuffer)},
	}
	QUIWidgetDragonWarFastBattleClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetDragonWarFastBattleClient:onEnter()
end

function QUIWidgetDragonWarFastBattleClient:onExit()
end

function QUIWidgetDragonWarFastBattleClient:setClientInfo(itemInfos)
	-- set item box
	for index,item in ipairs(itemInfos) do
		if self._ccbOwner["node_item_"..index] then
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setPromptIsOpen(true)
			self._ccbOwner["node_item_"..index]:addChild(itemBox)
			local id = tonumber(item.id)
			local typeName = remote.items:getItemType(item.id)
			if typeName ~= nil then
				id = nil
			else
				typeName = ITEM_TYPE.ITEM
				id = tonumber(id)
			end
			itemBox:setGoodsInfo(id, typeName, tonumber(item.count))
			itemBox:setAwardName(item.title)
		end
	end

	self._myInfo = remote.unionDragonWar:getMyInfo() or {}
	-- set hurt
	local currentHurt = self._myInfo.todayMaxPerHurt or 0
	local num, word = q.convertLargerNumber(currentHurt)
	self._ccbOwner.tf_current_damage:setString(num..word)
	local totalHurt = self._myInfo.todayHurt or 0
	num, word = q.convertLargerNumber(totalHurt)
	self._ccbOwner.tf_total_damage:setString(num..word)

	if remote.playerRecall:isOpen() then
        local sp = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
        local node = self._ccbOwner.tf_current_damage:getParent()
        sp:setAnchorPoint(ccp(0, 0.5))
        sp:setPositionX(self._ccbOwner.tf_current_damage:getPositionX() + self._ccbOwner.tf_current_damage:getContentSize().width)
        sp:setPositionY(self._ccbOwner.tf_current_damage:getPositionY())
        node:addChild(sp)
    end
    
	-- set Buffer
	self._myFighterInfo = remote.unionDragonWar:getMyDragonFighterInfo()

	local myHolyBuffer, endAt = remote.unionDragonWar:checkMyHolyBuffer()
	self._ccbOwner.btn_holy_buffer:setVisible(myHolyBuffer)

	local myStreakWin = self._myFighterInfo.streakWin or 0
	self._ccbOwner.node_win_buffer:setVisible(myStreakWin > 1) 

	myStreakWin = myStreakWin > 5 and 5 or myStreakWin
	local iconPath = QResPath("dragon_war_win_buffer")[myStreakWin]
	if iconPath ~= nil then
    	local iconFrame = QSpriteFrameByPath(iconPath)
    	self._ccbOwner.sp_win_buffer:setDisplayFrame(iconFrame)
	end
end

function QUIWidgetDragonWarFastBattleClient:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetDragonWarFastBattleClient:_onTriggerWinBuffer()
    app.sound:playSound("common_small")

	local myStreakWin = self._myFighterInfo.streakWin or 1
	local data = remote.unionDragonWar:getUnionDragonWinBuffer(myStreakWin)
	if data == nil then return end

    app.tip:floatTip("您的宗门连胜"..myStreakWin.."场，您接下来的每次伤害均可获得"..tostring(data).."%的提升")
end

function QUIWidgetDragonWarFastBattleClient:_onTriggerHolyBuffer()
    app.sound:playSound("common_small")

	local myInfo = self._myInfo
    local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
    local data = configuration["sociaty_dragon_holy_bonous"].value or 0
    local endAt = (myInfo.holyStsEndAt or 0)/1000 - q.serverTime()
    app.tip:floatTip("您的宗主为您开启了武魂祝福，在"..q.timeToHourMinuteSecond(endAt).."分内每次伤害均可获得"..(data*100).."%提升")
end

return QUIWidgetDragonWarFastBattleClient