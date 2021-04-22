--
-- Author: xurui
-- Date: 2015-04-28 14:46:45
--
local QBaseModel = import("..models.QBaseModel")
local QNotice = class("QNotice", QBaseModel)

local QUIWidgetSystemNotice = import("..ui.widgets.QUIWidgetSystemNotice")
local QStaticDatabase = import("..controllers.QStaticDatabase")

QNotice.CHAT_TYPE = 1			-- 聊天显示
QNotice.CHAT_NORMAL_TYPE = 2	-- 聊天+跑马灯
QNotice.NORMAL_TYPE = 3			-- 跑马灯
QNotice.UNION_TYPE = 4			-- 宗门聊天
QNotice.SURPER_TYPE = 5			-- 聊天+宗门聊天+跑马灯
QNotice.UNION_NORMAL_TYPE = 6	-- 宗门聊天+跑马灯

function QNotice:ctor()
	self._noticeList = {}
	self._systemNoticeList = {}
	self._normalNoticeList = {}
	self._lastTime = 0
end

--创建时初始化事件
function QNotice:didappear()
    self._markProxy = cc.EventProxy.new(remote.mark)
    self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.markUpdateHandler))

    if self.notice == nil and app.nociceNode then
		self.notice = QUIWidgetSystemNotice.new()
		-- self.notice:retain()
		self.notice:setPosition(display.width/2, 27)
		app.nociceNode:addChild(self.notice)
		self.notice:setVisible(false)
		self._isRunning = false
	end
end

function QNotice:disappear()
    if self._markProxy then
        self._markProxy:removeAllEventListeners()
    end
    if self.notice ~= nil then
    	self.notice:removeFromParent()
		-- self.notice:release()
    	self.notice = nil
    end
end

function QNotice:markUpdateHandler()
    if remote.mark:getMark(remote.mark.MARK_NOTICE) == 1 then
		app:getClient():getNoticeList(function(data)
			if data.notices ~= nil then
				self:updateNoticeList(data.notices)
			end
		end)
    end
end

function QNotice:getNoticeList()
	return self._noticeList
end

function QNotice:updateNoticeList(notices)
	for i = 1, #notices, 1 do
		local notice = notices[i]
		if notice.type ~= 10000 and notice.startAt > self._lastTime then
			table.insert(self._normalNoticeList, notice)
		elseif notice.type == 10000 then
			self:updateSystemNotice(notice)
		end
	end

	if next(self._normalNoticeList) then
		self._lastTime = self._normalNoticeList[#self._normalNoticeList].startAt
	else
		self._lastTime = q.serverTime()
	end

	if next(self._normalNoticeList) then
		self:startNormalNotice()
	end
end

function QNotice:startNormalNotice()
	for _, value in pairs(self._normalNoticeList) do
		table.insert(self._noticeList, value)
	end	
	self._normalNoticeList = {}
	self:createNotice()
end

function QNotice:createNotice()
	if self.notice ~= nil and self._isRunning == false and self._noticeList[1] ~= nil then
		self._isRunning = true
		self.notice:setVisible(true)
		local notice = table.remove(self._noticeList, 1)
	 	self.notice:setNoticeInfo(notice)

	 	local index = app.tutorial:getRuningStageIndex()
	 	if index and index == 0 then
	 		self.notice:setVisible(false)
	 	end
	end
end

function QNotice:playNextNotice()
	self._isRunning = false
	self.notice:setVisible(false)
	if next(self._noticeList) then
		self:createNotice()
	end
end

function QNotice:updateSystemNotice(data)
	if data == nil then return end
	local time = q.serverTime()
	for _, notice in pairs(self._systemNoticeList) do
		if notice.startAt == data.startAt or notice.loopTime == 0 or notice.loopTime == nil or notice.endAt/1000 <= time then
			return 
		end
	end
	table.insert(self._systemNoticeList, data)
	self:systemHandle(#self._systemNoticeList)
end

-- function QNotice:startSystemNotice()
-- 	self._systemIsUpdate = false
-- 	for i = 1, #self._systemNoticeList, 1 do
-- 		self:systemHandle(i)
-- 	end
-- end

function QNotice:systemHandle(index)
	local time = q.serverTime()
	if self._systemNoticeList[index].endAt/1000 <= time then
		return
	else
		table.insert(self._noticeList, self._systemNoticeList[index])
		self:createNotice()
		self:startSystemTimeHandle(index)
	end 
end

function QNotice:startSystemTimeHandle(index)
	if self["systemTimeHandle"..index] == nil then
		-- printInfo("systemTimeHandle"..index.."is start!!!!!")
		self["systemTimeHandle"..index] = scheduler.performWithDelayGlobal(function()
			self["systemTimeHandle"..index] = nil
			self:systemHandle(index)
		end, self._systemNoticeList[index].loopTime)
	end
end

-- 检查客户端定时公告
function QNotice:checkNativeNotice()
	local notices = QStaticDatabase:sharedDatabase():getNativeNotice()
	for _, notice in pairs(notices) do
		local refreshTime = {}
		if notice.show_day then
			-- 开服时间段
			local showDay = string.split(notice.show_day, ",")
			if remote:checkOpenServerDays(tonumber(showDay[1]), tonumber(showDay[2])) then
				refreshTime = string.split(notice.open_time, ";")
			end
		else
			refreshTime = string.split(notice.open_time, ";")
		end
		-- 展示时间
		for i = 1, #refreshTime do
			if refreshTime[i] ~= "" then
				local timeTbl = string.split(refreshTime[i], ":")
				local showTime = q.getTimeForHMS(timeTbl[1] or 0, timeTbl[2] or 0, timeTbl[3] or 0)
				self:startNativeNoticeTimeHandle(notice, i, showTime)
			end
		end
	end
end

function QNotice:startNativeNoticeTimeHandle(notice, i, showTime)
	local gapTime = math.floor(showTime - q.serverTime())
	local name = "nativeTimeHandle_"..notice.index.."_"..i
	if self[name] == nil and gapTime > 0 then
		self[name] = scheduler.performWithDelayGlobal(function()
			self[name] = nil
			notice.startAt = q.serverTime()
			notice.showType = notice.show_type
			notice.type = notice.index
			notice.link = notice.shortcut
			self:updateNoticeList({notice})
		end, gapTime)
	end
end

return QNotice