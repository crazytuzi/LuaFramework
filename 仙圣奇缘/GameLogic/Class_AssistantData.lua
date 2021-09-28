--------------------------------------------------------------------------------------
-- 文件名:	Class_AssistantData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	助手  数据
-- 应  用:  
---------------------------------------------------------------------------------------
AssistantData = class("AssistantData")
AssistantData.__index = AssistantData

local CSV_ActivityChengJiu = g_DataMgr:getCsvConfig("ActivityChengJiu")

--保存了成就信息
function AssistantData:setRecordList(tbMsg)

	local msgData = tbMsg
	local state = msgData.state
	local nNum = 0
	self.recordList_ = {}
	for i = 1,#state do 
		local t = {}
		t.reward_state = state[i].reward_state	--奖励领取状态
		if state[i].reward_state == 2 then --可领取
			nNum = nNum + 1
		end
		t.target_num = state[i].target_num		--目标达成数
		t.key1 = state[i].key1
		t.key2 = state[i].key2 
		
		local CSVactivityChengJiu = CSV_ActivityChengJiu[t.key1][t.key2]
		--IsOpen 为零的不显示  服务端没有这个IsOpen字段 客户端处理 筛选数据
		if CSVactivityChengJiu.IsOpen == 1 then 
			table.insert(self.recordList_, t)
		end
	end
end
--
function AssistantData:getRecordList()
	return self.recordList_
end

-- // 成就奖励状态
-- enum ACHIEVEMENT_REWARD_STATE
-- {
	-- ACHIEVEMENT_REWARD_STATE_INIT = 1;				// 初始状态，不可领
	-- ACHIEVEMENT_REWARD_STATE_CAN_RECV = 2;			// 可领取
	-- ACHIEVEMENT_REWARD_STATE_ALREADY_RECV = 3;		// 已经领取
-- }
function AssistantData:setRecordListState(key1,key2,targetNum,rewardState)
	local record = self:getRecordList()
	if not record then return end 
	for i = 1,#record do
		local key = record[i].key1
		if key1 == key then 
			self.recordList_[i].target_num = targetNum
			self.recordList_[i].reward_state = rewardState
			self.recordList_[i].key2 = key2
		end		
	end

end

-- 通知成就系统有数据更新
function AssistantData:requestAchievementUpdateNotifyResponse(tbMsg)
	local msgDetail = zone_pb.AchievementUpdateNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local recordChange = msgDetail.record_change
	for i = 1,#recordChange do 
		local targetNum = recordChange[i].target_num
		local rewardState = recordChange[i].reward_state
		local key1 = recordChange[i].key1
		local key2 = recordChange[i].key2
		self:setRecordListState(key1,key2,targetNum,rewardState)
	end
end

--领取成就奖励请求
function AssistantData:requestAchievementRecvRewardRequest(key1,key2)
	local msg = zone_pb.AchievementRecvRewardRequest()
	msg.key1 = key1
	msg.key2 = key2
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ACHIEVEMENT_RECV_REWARD_REQUEST,msg)
	
	g_MsgNetWorkWarning:showWarningText()
	
end

-- 领取成就奖励响应
function AssistantData:requestAchievementRecvRewardResponse(tbMsg)
	local msgDetail = zone_pb.AchievementRecvRewardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	 
	local result = msgDetail.result -- 领取奖励结果， 0 表示成功，否则失败
	local recordChange = msgDetail.notify.record_change
	
	for i = 1,#recordChange do 
		local targetNum = recordChange[i].target_num
		local rewardState = recordChange[i].reward_state
		local key1 = recordChange[i].key1
		local key2 = recordChange[i].key2
		self:setRecordListState(key1,key2,targetNum,rewardState)
	end
	
	--刷新成就界面上的UI
	setAchievementData()
	
end

function AssistantData:getAchievementNotice()
	local nNoticeNum = 0
	for k, v in pairs (self.recordList_) do
		if v.reward_state ==  macro_pb.ACHIEVEMENT_REWARD_STATE_CAN_RECV then
			nNoticeNum = nNoticeNum + 1
		end
	end
	return nNoticeNum
end

function AssistantData:responseInit()	
	
	--成就更新通知
	local order = msgid_pb.MSGID_ACHIEVEMENT_UPDATE_NOTIFY
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestAchievementUpdateNotifyResponse))		
	
	--领取成就奖励响应
	local order = msgid_pb.MSGID_ACHIEVEMENT_RECV_REWARD_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestAchievementRecvRewardResponse))	
end


---------------------------------------------------------------------------------
g_AssistantData = AssistantData.new()
g_AssistantData:responseInit()





