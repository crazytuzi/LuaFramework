-- @Author: xurui
-- @Date:   2016-12-19 15:48:11
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-05-27 16:54:15
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPlunderReportClient = class("QUIWidgetPlunderReportClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QReplayUtil = import("...utils.QReplayUtil")

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 10m
local REPLAY_COUNT = 5

function QUIWidgetPlunderReportClient:ctor(options)
	local ccbFile = "ccb/Widget_plunder_zb2.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerShare", callback = handler(self, self._onTriggerShare)},
		{ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetPlunderReportClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetPlunderReportClient:onEnter()
end

function QUIWidgetPlunderReportClient:onExit()
end

function QUIWidgetPlunderReportClient:setInfo(param)
	self._parent = param.parent
	self._userId = param.userId
	self._nickName = param.nickName or ""
	self._level = param.level or ""
	self._avatar = param.avatar 
	self._result = param.result == nil and false or param.result
	self._time = param.time or -1
	self._replayId = param.replay
	self._mineId = param.mineId
	self._score = param.score
	self._reportType = param.reportType  -- 1：狩猎， 2：掠夺
	self._attackState = param.attackState or 1  -- 1: 自己是攻击方， 2: 自己是防守方
	self._gameAreaName = param.gameAreaName or "无"
	self._num = param.lootScore or 0

	self._ccbOwner.node_bg:setVisible(param.bgVisible)
	
	self._ccbOwner.win_flag:setVisible(self._result)
	self._ccbOwner.lose_flag:setVisible(not self._result)

	if self._reportType == 1 then -- 占领
		if self._attackState == 1 then  -- 攻击方
			if self._result then        -- 胜利
				-- self._ccbOwner.tf_success:setString("狩猎成功")
				self._ccbOwner.active1:setString("攻打了")
				-- self._ccbOwner.active2:setString("的魂兽区")
				self._ccbOwner.active2:setString("")
				self._ccbOwner.result:setString("赢得了此魂兽区的所有权")
				self._ccbOwner.wl:setString("占领成功")
				self._ccbOwner.wl:setColor(COLORS.l)
			else 						-- 失败
				-- self._ccbOwner.tf_lose:setString("狩猎失败")
				self._ccbOwner.active1:setString("攻打了")
				-- self._ccbOwner.active2:setString("的魂兽区")
				self._ccbOwner.active2:setString("")
				self._ccbOwner.result:setString("但是失败了")
				self._ccbOwner.wl:setString("占领失败")
				self._ccbOwner.wl:setColor(COLORS.m)
			end
		else 							-- 防守方
			if self._result then        -- 胜利
				-- self._ccbOwner.tf_success:setString("防守成功")
				self._ccbOwner.active1:setString("")
				self._ccbOwner.active2:setString("攻打了您")
				self._ccbOwner.result:setString("但是被您一顿胖揍赶走了")
				self._ccbOwner.wl:setString("防守成功")
				self._ccbOwner.wl:setColor(COLORS.l)
			else 						-- 失败
				-- self._ccbOwner.tf_lose:setString("防守失败")
				self._ccbOwner.active1:setString("")
				self._ccbOwner.active2:setString("攻打了您")
				self._ccbOwner.result:setString("您失去了这块魂兽区的所有权")
				self._ccbOwner.wl:setString("防守失败")
				self._ccbOwner.wl:setColor(COLORS.m)
			end
		end
	else                          -- 掠夺
		if self._attackState == 1 then  -- 攻击方
			if self._result then        -- 胜利
				-- self._ccbOwner.node_green:setVisible(true)
				-- self._ccbOwner.tf_plunder_num_green:setString(self._score or "")
				self._ccbOwner.active1:setString("掠夺了")
				-- self._ccbOwner.active2:setString("的魂兽区")
				self._ccbOwner.active2:setString("")
				self._ccbOwner.result:setString("获得了"..self._num.."冰髓")
				self._ccbOwner.wl:setString("掠夺成功")
				self._ccbOwner.wl:setColor(COLORS.l)
			else 						-- 失败
				-- self._ccbOwner.tf_lose:setString("掠夺失败")
				self._ccbOwner.active1:setString("掠夺了")
				-- self._ccbOwner.active2:setString("的魂兽区")
				self._ccbOwner.active2:setString("")
				self._ccbOwner.result:setString("但失败了")
				self._ccbOwner.wl:setString("掠夺失败")
				self._ccbOwner.wl:setColor(COLORS.m)
			end
		else 							-- 防守方
			if self._result then        -- 胜利
				-- self._ccbOwner.tf_success:setString("防守成功")
				self._ccbOwner.active1:setString("")
				self._ccbOwner.active2:setString("掠夺了您")
				self._ccbOwner.result:setString("但是被您一顿胖揍赶走了")
				self._ccbOwner.wl:setString("防守成功")
				self._ccbOwner.wl:setColor(COLORS.l)
			else 						-- 失败
				-- self._ccbOwner.node_red:setVisible(true)
				-- self._ccbOwner.tf_plunder_num_red:setString(self._score or "")
				self._ccbOwner.active1:setString("")
				self._ccbOwner.active2:setString("掠夺了您")
				self._ccbOwner.result:setString("您损失了"..self._num.."冰髓")
				self._ccbOwner.wl:setString("防守失败")
				self._ccbOwner.wl:setColor(COLORS.m)
			end
		end
	end

	self._ccbOwner.nickName:setString(self._nickName.."（"..self._gameAreaName.."）")
	-- self._ccbOwner.level:setString("LV." .. self._level)
	
	local date, time = self:getDateAndTimeDescription(self._time)
	-- self._ccbOwner.date:setString(date)
	self._ccbOwner.time:setString(time)
	-- self._ccbOwner.node_headPicture:removeAllChildren()
	-- self._ccbOwner.node_headPicture:addChild(QUIWidgetAvatar.new(self._avatar))

	self:_autoPosition()
end

function QUIWidgetPlunderReportClient:getDateAndTimeDescription(time)
	local curTimeTbl = q.date("*t", time/1000)
	-- print("#日期："..curTimeTbl.year.."/"..curTimeTbl.month.."/"..curTimeTbl.day.."#星期："..(curTimeTbl.wday - 1).."#时间："..curTimeTbl.hour..":"..curTimeTbl.min..":"..curTimeTbl.sec)
	return curTimeTbl.month.."-"..curTimeTbl.day, curTimeTbl.hour..":"..curTimeTbl.min
	-- if time == nil or time == -1 then
	-- 	return "N/A"
	-- end

	-- local gap = math.floor((q.serverTime()*1000 - time)/1000 )
	-- if gap > 0 then
	-- 	if gap < 60 * 60 then
	-- 		return math.floor(gap/60) .. "分钟前"
	-- 	elseif gap < 24 * 60 * 60 then
	-- 		return math.floor(gap/(60 * 60)) .. "小时前"
	-- 	elseif gap < 7 * 24 * 60 * 60 then
	-- 		return math.floor(gap/(24 * 60 * 60)) .. "天前"
	-- 	else
	-- 		return "7天前"
	-- 	end
	-- end

	-- return "7天前"
end

function QUIWidgetPlunderReportClient:_autoPosition()
	local x = self._ccbOwner.time:getPositionX()
	local w = self._ccbOwner.time:getContentSize().width
	self._ccbOwner.active1:setPositionX(x + w + 5)

	x = self._ccbOwner.active1:getPositionX()
	w = self._ccbOwner.active1:getContentSize().width
	self._ccbOwner.nickName:setPositionX(x + w + 5)

	x = self._ccbOwner.nickName:getPositionX()
	w = self._ccbOwner.nickName:getContentSize().width
	self._ccbOwner.active2:setPositionX(x + w + 5)
end

function QUIWidgetPlunderReportClient:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

function QUIWidgetPlunderReportClient:_onTriggerReplay(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_record) == false then return end
    app.sound:playSound("common_small")
	QReplayUtil:getReplayInfo(self._replayId, function (data)
		QReplayUtil:downloadReplay(self._replayId, function (replay)
			QReplayUtil:play(replay)
		end, nil, REPORT_TYPE.PLUNDER)
	end, nil, REPORT_TYPE.PLUNDER)
end

function QUIWidgetPlunderReportClient:_onTriggerShare(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_share) == false then return end
    app.sound:playSound("common_small")
	local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySentTime()
	print("replayCount " .. replayCount .. " earliestTime " .. earliestTime .. " serverTime " .. q.serverTime())
	if replayCount >= REPLAY_COUNT and q.serverTime() - earliestTime < REPLAY_CD * 60 then
		app.tip:floatTip(string.format(REPLAY_CD_LIMIT, REPLAY_CD, REPLAY_COUNT, q.timeToHourMinuteSecond(REPLAY_CD * 60 - (q.serverTime() - earliestTime), true)))
		return
	end

	QReplayUtil:getReplayInfo(self._replayId, function (data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayShare", 
			options = {rivalName = self._nickName, replayId = self._replayId, myNickName = remote.user.nickname, replayType = REPORT_TYPE.PLUNDER}}, {isPopCurrentDialog = false})
	end, nil, REPORT_TYPE.PLUNDER)
end

function QUIWidgetPlunderReportClient:_onHead()

end

return QUIWidgetPlunderReportClient