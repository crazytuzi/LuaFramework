
SummonLogData = class("SummonLogData")
SummonLogData.__index = SummonLogData


function SummonLogData:ctor()
	--高级召唤日志返回
	local order = msgid_pb.MSGID_SUMMON_LOG_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestSummonLogResponse)) 

	self.summonLog_ = {}
end

function SummonLogData:setSummonLogData(key, logData)
	self.summonLog_[key] = logData
end

function SummonLogData:getSummonLogData()
	return self.summonLog_
end

	-- MSGID_SUMMON_LOG_REQUEST = 1038;						// 高级召唤日志请求
	-- MSGID_SUMMON_LOG_RESPONSE = 1039;						// 高级召唤日志返回
-- 高级召唤日志请求
function SummonLogData:requestSummonLogRefresh()
	cclog(" 高级召唤日志请求--requestSummonLogRefresh")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SUMMON_LOG_REQUEST)
	-- g_MsgNetWorkWarning:showWarningText(true)

end

--高级召唤日志返回
function SummonLogData:requestSummonLogResponse(tbMsg)
	cclog("-----高级召唤日志返回---requestSummonLogResponse-------------")
	local msgDetail = zone_pb.SummonLogResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail)) 
	
	local logList =	msgDetail.log_list
	-- logList.time
	-- logList.role_name 
	-- logList.card_name 
	
    for i = 1, #logList do
		local tbCurLog = logList[i]
		local tbData = {}
		tbData.time = tbCurLog.time
		tbData.role_name = tbCurLog.role_name
		tbData.card_name = tbCurLog.card_name
		self:setSummonLogData(i, tbData)
	end

	local function sortLog(one, two)
		return one.time > two.time
	end
	table.sort(self:getSummonLogData(), sortLog)

	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	
	 g_FormMsgSystem:SendFormMsg(FormMsg_Summon_updateData, nil)
	
	
end

g_SummonLogData = SummonLogData.new()