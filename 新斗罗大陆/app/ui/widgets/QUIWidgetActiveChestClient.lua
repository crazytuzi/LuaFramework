-- @Author: xurui
-- @Date:   2016-11-10 11:18:22
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-06-12 19:26:45
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActiveChestClient = class("QUIWidgetActiveChestClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetActiveChestClient.CHEST_IS_DONE = "CHEST_IS_DONE"

function QUIWidgetActiveChestClient:ctor(options)
	local ccbFile = "ccb/Widget_society_juntuanchoujiang.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerChest", callback = handler(self, self._onTriggerChest)},
	}
	QUIWidgetActiveChestClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.sp_isDone:setVisible(false)
    self._ccbOwner.node_btn_chest:setVisible(false)
end

function QUIWidgetActiveChestClient:onEnter()
end

function QUIWidgetActiveChestClient:onExit()
    if self._comingDownScheduler ~= nil then
        scheduler.unscheduleGlobal(self._comingDownScheduler)
        self._comingDownScheduler = nil
    end
end

function QUIWidgetActiveChestClient:setInfo()
    remote.union.unionActive:requestGetUnionActiveWeekInfo(function(data)
            self:setClientInfo()
        end)
end

function QUIWidgetActiveChestClient:setClientInfo()
	self._info = remote.union.unionActive:getUnionActiveInfo()

    self._ccbOwner.tf_title:setString("各位勇士们，这是我们上周共同努力的“宗门币”福利，大家快去抽取吧！")

	self._ccbOwner.tf_last_money:setString("剩余宗门币："..self._info.weekAddUpConsortiaMoney or 0)
	self._ccbOwner.tf_num:setString("抽奖人数："..(self._info.drawMemberCount or 0).."/"..(self._info.totalDrawMemberCount or 0))

	local isUnlock, lockTime = remote.union.unionActive:checkUnionWeekChestIsOpen()
	self:setCountDownForBossComming(lockTime, self._ccbOwner.tf_last_time)

    -- set btn state 
    self._canTakenAward = remote.union.unionActive:checkEnterUnionTime() 
    self._ccbOwner.sp_isDone:setVisible(false)
    self._ccbOwner.node_btn_chest:setVisible(true)
    if (self._info.totalDrawMemberCount or 0) < 1 then
        self._ccbOwner.node_btn_chest:setVisible(false)
    else
        if self._canTakenAward == false and remote.union.unionActive:getCanTakenChestAward() == false then
            self._ccbOwner.node_btn_chest:setVisible(false)
            self._ccbOwner.sp_isDone:setVisible(true)
        end
    end
end

function QUIWidgetActiveChestClient:setCountDownForBossComming(unlockTime, node)
    if self._comingDownScheduler ~= nil then
        scheduler.unscheduleGlobal(self._comingDownScheduler)
        self._comingDownScheduler = nil
    end

    local schedulerFunc
    schedulerFunc = function()
        if self._comingDownScheduler ~= nil then
            scheduler.unscheduleGlobal(self._comingDownScheduler)
            self._comingDownScheduler = nil
        end
        local nowTime = q.serverTime()
        if unlockTime >= nowTime then
            if node then
                node:setString("剩余时间："..q.timeToHourMinuteSecond(unlockTime-nowTime))
            end
            self._comingDownScheduler = scheduler.scheduleGlobal(schedulerFunc, 1)
        else
        	self:dispatchEvent({name = QUIWidgetActiveChestClient.CHEST_IS_DONE})
        end
    end
    schedulerFunc()
end


function QUIWidgetActiveChestClient:_onTriggerChest()
    app.sound:playSound("common_small")
	if self._canTakenAward == false then
		remote.union.unionActive:requestGetUnionActiveWeekAward(function(data)
                remote.union.unionActive:setCanTakenChestAward(false)

                if data.consortiaTakeWeekRewardResponse then
                    self._info.weekAddUpConsortiaMoney = data.consortiaTakeWeekRewardResponse.remainConsortiaMoney
                end
                self._info.drawMemberCount = self._info.drawMemberCount + 1

                remote.union.unionActive:setUnionActiveInfo(self._info)
				self:setInfo()

                local awards = {}
                local prizes = data.prizes or {}
                for _,item in pairs(prizes) do
                    local typeName = remote.items:getItemType(item.type)
                    table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
                end
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                    options = {awards = awards, callBack = function ()
                        remote.user:checkTeamUp()
                    end}},{isPopCurrentDialog = false} )
                dialog:setTitle("恭喜您获得军团抽奖奖励")
			end)
	else
		app.tip:floatTip("魂师大人，您没有资格参加军团抽奖")
	end
end

return QUIWidgetActiveChestClient