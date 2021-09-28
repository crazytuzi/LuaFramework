--DealLoopMsg.lua
--/*-----------------------------------------------------------------
 --* Module:  DealLoopMsg.lua
 --* Author:  seezon
 --* Modified: 2015年8月5日
 --* Purpose: 处理跑马灯
 -------------------------------------------------------------------*/
	
DealLoopMsg = class(nil, Singleton, Timer)

function DealLoopMsg:__init()
    self._loopMsg = {}
    g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 1000)
	print("DealLoopMsg Timer", self._timerID_)
end

function DealLoopMsg:deleMsg(id)
	local msgTb = self._loopMsg[id]
	if msgTb then
		msgTb.times = 0
		self:sendMsg(msgTb)
		self._loopMsg[id] = nil
		updateCommonData(COMMON_DATA_ID_PAOMADENG, self._loopMsg)
	end
end

function DealLoopMsg:onDataPacket(cmdId, loopMsgTb)
	if cmdId == BACKTOOL_LOOPMSG then
		local msgTb = {}
		if loopMsgTb.EndTime < loopMsgTb.BeginTime then
			print("跑马灯时间错误")
			return
		end

		msgTb.startTime= loopMsgTb.BeginTime
		msgTb.endTime = loopMsgTb.EndTime
		msgTb.interval = loopMsgTb.RollingIntervalTime
		msgTb.msg = loopMsgTb.NoticeContent
		msgTb.ID = loopMsgTb.EventId
		msgTb.times = math.floor((msgTb.endTime-msgTb.startTime) / msgTb.interval)
		if os.time() >= msgTb.startTime then
			msgTb.active= true
		else
			msgTb.active= false
		end
		
		self._loopMsg[msgTb.ID] = msgTb
		if msgTb.active then
			self:sendMsg(msgTb)
		end
		updateCommonData(COMMON_DATA_ID_PAOMADENG, self._loopMsg)
	end
end

function DealLoopMsg:onloadLoopMsg(data)
	if data then
		self._loopMsg = unserialize(data)
	end
end

--定时器更新
function DealLoopMsg:update()
	local curTime = os.time()
	for k,v in pairs(self._loopMsg) do 
		if curTime > v.endTime then
			self._loopMsg[k] = nil
			updateCommonData(COMMON_DATA_ID_PAOMADENG, self._loopMsg)
		end

		if curTime > v.startTime and not v.active then
			v.active = true
			self:sendMsg(v)
		end
	end
end

function DealLoopMsg:sendMsg(msgTb)
	local ret = {}
	ret.msgID = msgTb.ID
	ret.message = msgTb.msg
	ret.interval = msgTb.interval
	ret.times = msgTb.times
	boardProtoMessage(CHAT_SC_UPDATE_HORSE_MSG, 'UpdateHorseMsgProtocol', ret)
	if msgTb.times > 0 then
		g_ChatSystem:SystemMsgIntoChat(0,1,msgTb.msg,0,0,0,{})
	end
end

function DealLoopMsg:notify2Client(roleID)
	local ret = {}
	ret.horseMsg = {}
	for id,v in pairs(self._loopMsg) do
		local remianTime = v.endTime - os.time()
		local delay = math.mod(remianTime, v.interval)
		local times = math.floor(remianTime / v.interval)

		local info = {}
		info.msgID = v.ID
		info.message = v.msg
		info.interval = v.interval
		info.times = times
		info.delay = delay
		table.insert(ret.horseMsg, info)
	end

	fireProtoMessage(roleID, CHAT_SC_GET_HORSE_MSG_RET, 'GetHorseMsgRetProtocol', ret)
end

function DealLoopMsg.getInstance()
	return DealLoopMsg()
end

g_dealLoopMsg = DealLoopMsg.getInstance()
