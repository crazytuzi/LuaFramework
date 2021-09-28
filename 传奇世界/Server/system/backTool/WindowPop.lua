--WindowPop.lua
--/*-----------------------------------------------------------------
 --* Module:  WindowPop.lua
 --* Author:  seezon
 --* Modified: 2015年8月5日
 --* Purpose: 处理跑马灯
 -------------------------------------------------------------------*/
	
WindowPop = class(nil, Singleton, Timer)

--弹窗时间类型(1为每次登录后弹、2为每天在第一次登录后弹一次、3为整个有效时间周期里只弹一次、4为自定义频率。) */
WINPOPTIMETYPE = {
	TYPE1		= 1,
	TYPE2		= 2,
	TYPE3		= 3,
	TYPE4		= 4,
}

function WindowPop:__init()
    self._popMsg = {}
	self._offPopMsg = {}
    g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
	print("WindowPop Timer", self._timerID_)
end

function WindowPop:deleMsg(id)
	self._popMsg[id] = nil
	updateCommonData(COMMON_DATA_ID_WINPOP, self._popMsg)
end

function WindowPop:onDataPacket(cmdId, popTb)
	if cmdId == BACKTOOL_WINPOP then
		if popTb.EndTime < popTb.BeginTime then
			return
		end

		popTb.ID = popTb.EventId

		if os.time() >= popTb.BeginTime and os.time() <= popTb.EndTime then
			popTb.active= true
		else
			popTb.active= false
		end

		if tonumber(popTb.Frequency) ~= WINPOPTIMETYPE.TYPE4 then
			popTb.CustomFrequency = 0
		else
			popTb.countNum = 0
		end

		self._popMsg[popTb.ID] = popTb
		if popTb.active then
			if tonumber(popTb.Frequency) ~= WINPOPTIMETYPE.TYPE1 and tonumber(popTb.Frequency) ~= WINPOPTIMETYPE.TYPE2 then
				self:sendPop(popTb)
			end
		end
		updateCommonData(COMMON_DATA_ID_WINPOP, self._popMsg)
	end
end

function WindowPop:onloadWindowPop(data)
	if data then
		self._popMsg = unserialize(data)
	end
end

function WindowPop:onloadOneMsgPop(data)
	if data then
		self._offPopMsg = unserialize(data)
	end
end

--玩家上线
function WindowPop:onPlayerLoaded(player)
	self:sendAllPop(player:getID())
end

--定时器更新
function WindowPop:update()
	local curTime = os.time()
	for k,popTb in pairs(self._popMsg) do 
		if curTime > popTb.EndTime then
			self._popMsg[k] = nil
		end

		if curTime > popTb.BeginTime and not popTb.active then
			popTb.active = true
			if tonumber(popTb.Frequency) ~= WINPOPTIMETYPE.TYPE1 or tonumber(popTb.Frequency) ~= WINPOPTIMETYPE.TYPE2 then
				self:sendPop(popTb)
			end
		end

		--按频率弹窗
		if popTb.active and tonumber(popTb.Frequency) == WINPOPTIMETYPE.TYPE4 then
			popTb.countNum = popTb.countNum + 1
			if math.mod(popTb.countNum, tonumber(popTb.CustomFrequency)) == 0 then
				self:sendPop(popTb)
			end
		end
	end
end

function WindowPop:sendAllPop(roleID)
	local popTmp = {}
	for id,msgTb in pairs(self._popMsg) do
		if msgTb.active  and tonumber(msgTb.Frequency) ~= WINPOPTIMETYPE.TYPE4 then
			popTmp[id] = msgTb
		end
	end

	if table.size(popTmp) <= 0 then
		return
	end

	local ret = {}
	ret.timeTick = os.time()
	ret.windowInfo = {}
	for id,msgTb in pairs(popTmp) do
		local info = {}
		info.id = id
		info.windowType = tonumber(msgTb.Frequency)
		info.startTime = tonumber(msgTb.BeginTime)
		info.title = msgTb.PopupTitle or ""
		info.content = msgTb.PopupContent or ""
		info.link = msgTb.Hyperlink or ""
		info.btContent = msgTb.ButtonContent or ""
		table.insert(ret.windowInfo, info)
	end
	fireProtoMessage(roleID, CHAT_SC_POP_ALL_WINDOW, 'PopAllWindowProtocol', ret)
end

function WindowPop:sendPop(msgTb)
	local ret = {}
	ret.timeTick = os.time()
	ret.windowInfo = {}
	local info = {}
	info.id = msgTb.ID
	info.windowType = tonumber(msgTb.Frequency)
	info.startTime = tonumber(msgTb.BeginTime)
	info.title = msgTb.PopupTitle or ""
	info.content = msgTb.PopupContent or ""
	info.link = msgTb.Hyperlink or ""
	info.btContent = msgTb.ButtonContent or ""
	table.insert(ret.windowInfo, info)

	boardProtoMessage(CHAT_SC_POP_ALL_WINDOW, 'PopAllWindowProtocol', ret)
end

function WindowPop.getInstance()
	return WindowPop()
end

g_windowPop = WindowPop.getInstance()
