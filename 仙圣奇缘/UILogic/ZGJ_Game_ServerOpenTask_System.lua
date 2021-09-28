SOTSystem = class("SOTSystem")
SOTSystem.__index = SOTSystem

-- //具体任务的状态  值大小为客户端排序依据
-- enum ServerOpenTaskState
-- {
-- 	SOTS_END = 0;					//领奖完了，任务结束
-- 	SOTS_DOING = 1;					//正在进行中
-- 	SOTS_FINISHED_WAIT_REWARD = 2;	//完整任务，等领奖
--  SOTS_TIMEOUT = 3;               //任务过期 
-- };

function SOTSystem:getFinishedTasks()
	local nCount = 0
	for i = 1, #self.tbTaskList do
		for j = 1, #self.tbTaskList[i] do
			if common_pb.SOTS_END == self.tbTaskList[i][j].nState then
				nCount = nCount + 1
			end
		end
	end
	return nCount
end

function SOTSystem:getBubble(id)
	return self.tbBubble[id] or 0
	-- if not self.tbBubble[id] then
	-- 	return 0
	-- end
	-- if self.tbBubble[id] > 0 then
	-- 	return self.tbBubble[id]
	-- else
	-- 	for k, v in ipairs(self.tbTaskList[id]) do
	-- 		if common_pb.SOTS_DOING == v.nState then
	-- 			return 1
	-- 		end
	-- 	end
	-- end
	-- return 0
end

function SOTSystem:setBubble(id, value)
	self.tbBubble[id] = value
end

function SOTSystem:getTotalBubbles()
	local nCount = 0
	for k, v in pairs(self.tbBubble) do
		nCount = nCount + self:getBubble(k)
	end
	return nCount
	-- local nCount = 0
	-- for k, v in pairs(self.tbBubble) do
	-- 	nCount = nCount + v
	-- end
	-- return nCount
end

--false 活动时间结束
function SOTSystem:getRemainTime()
	local nRemainTime = self.nEndTime - g_GetServerTime()
	if nRemainTime <= 0 then
		return false
	end
	local nDays = math.floor(nRemainTime / 86400)
	local nHours = math.floor(nRemainTime % 86400 / 3600)
	local nMins = math.floor(nRemainTime % 86400 % 3600 / 60)
	local nSecs = math.floor(nRemainTime % 86400 % 3600 % 60)
	return nDays, nHours, nMins, nSecs
end

function SOTSystem:isWholeRewardEnabled()
	return not self.bGetWholeReward and not self:getRemainTime()
end

--判断活动关闭
function SOTSystem:isEnable()
	return not self.bGetWholeReward
end

--任务组是否开启
function SOTSystem:isOpen(nGroup)
	return nGroup <= math.ceil((g_GetServerTime() - self.nOpenTime) / 86400)
end

function SOTSystem:getTask(id)
	return self.tbTaskList[id]
	-- self.tbTaskList = {}
	-- for i = 1, 10 do
	-- 	self.tbTaskList[i] = {nTaskLevel = i, nState = 1, nProgress = 0}
	-- end
	-- return self.tbTaskList
end

--单任务领取请求 服务器index从0开始
function SOTSystem:singleRewardRequest(taskType, key, nIndex)
	local msg = zone_pb.ServerOpenTaskRewardReq()
    msg.task_type = taskType
	msg.key = key
	msg.index = nIndex - 1
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SERVER_OPEN_TASK_REWARD_REQ, msg)
end

--单任务领取响应
function SOTSystem:singleRewardResponse(tbMsg)
	local msg = zone_pb.ServerOpenTaskRewardRsp()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	self.tbTaskList[msg.key][msg.index + 1].nState = common_pb.SOTS_END
	self.tbBubble[msg.key] = self.tbBubble[msg.key] - 1
	g_FormMsgSystem:PostFormMsg(FormMsg_ServerOpenTask_Reward)
end

--总奖励领取请求
function SOTSystem:allRewardRequest()
	if not self.bGetWholeReward then
		g_MsgMgr:sendMsg(msgid_pb.MSGID_SERVER_OPEN_TASK_WHOLE_REWARD_REQ)
	end
end

--总奖励领取响应
function SOTSystem:allRewardResponse(tbMsg)
	self.bGetWholeReward = true
end

--登录通知 服务器index从0开始
function SOTSystem:loginNotifyResponse(tbMsg)
	local msg = zone_pb.ServerOpenTaskLoginNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	self.nWholeState = msg.state
	self.nProgress = msg.whole_num
	self.bGetWholeReward = msg.is_get_whole_reward

	self.nOpenTime = msg.open_time
	local nDays = g_DataMgr:getCsvConfigByTwoKey("GlobalCfg", 88, "Data")
	self.nEndTime =  self.nOpenTime + nDays * 86400

	self.tbTaskList = {}
	self.tbBubble = {}
    local taskDiscount = ConfigMgr["ActivityTaskDiscount"]    --折扣活动
    local taskEvent = ConfigMgr["ActivityTaskEvent"]          --充值福利活动
	for k, v in ipairs(msg.task) do
		self.tbTaskList[v.key] = self.tbTaskList[v.key] or {}
		self.tbTaskList[v.key][v.index + 1] = {nTaskLevel = v.index + 1, nState = v.state, nProgress = v.num}
		self.tbBubble[v.key] = self.tbBubble[v.key] or 0
        --普通任务打点
		if common_pb.SOTS_FINISHED_WAIT_REWARD == v.state then 
			self.tbBubble[v.key] = self.tbBubble[v.key] + 1
		end
        
        --每日福利充值打点
        if taskEvent[v.key] 
            and taskEvent[v.key][v.index + 1]["TaskType"] == 17 
            and common_pb.SOTS_DOING == v.state then   --任务正在进行中
            self.tbBubble[v.key] = self.tbBubble[v.key] + 1
        end

        --每日超低折扣打点
        if taskDiscount[v.key]
            and common_pb.SOTS_END ~= v.state then   --购买次数还没达上线
            self.tbBubble[v.key] = self.tbBubble[v.key] + 1
        end
	end
end

--更新通知  服务器index从0开始
function SOTSystem:updateNotifyResponse(tbMsg)
	local msg = zone_pb.ServerOpenTaskRefresh()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	-- body
	self.nState = msg.state
	self.nProgress = msg.whole_num
	self.tbTaskList = self.tbTaskList or {}
    local taskEvent = ConfigMgr["ActivityTaskEvent"]          --每日福利活动
    local taskDiscount = ConfigMgr["ActivityTaskDiscount"]    --每日折扣活动

    if msg.zero_reset == 1 then
        --0点重置后清除每日福利打点，因为每日福利会过期
        for i, v in pairs(taskEvent) do
            if self.tbBubble[i] then
                 self.tbBubble[i] = 0    
            end
        end        
    end

	for k, v in ipairs(msg.task) do
		self.tbTaskList[v.key] = self.tbTaskList[v.key] or {}
		self.tbTaskList[v.key][v.index + 1] = {nTaskLevel = v.index + 1, nState = v.state, nProgress = v.num}
        self.tbBubble[v.key] = self.tbBubble[v.key] or 0
		if common_pb.SOTS_FINISHED_WAIT_REWARD == v.state then
			self.tbBubble[v.key] = self.tbBubble[v.key] + 1
		end

        if msg.zero_reset == 1 then
            --每日福利充值打点
            if taskEvent[v.key] 
                and taskEvent[v.key][v.index + 1]["TaskType"] == 17 
                and common_pb.SOTS_DOING == v.state then   --任务正在进行中
                self.tbBubble[v.key] = self.tbBubble[v.key] + 1
            end

            --每日超低折扣打点
            if taskDiscount[v.key]
                and common_pb.SOTS_END ~= v.state then   --购买次数还没达上线
                self.tbBubble[v.key] = self.tbBubble[v.key] + 1
            end    
        end
	end
    
    g_FormMsgSystem:PostFormMsg(FormMsg_ServerOpenTask_Reward)
end

function SOTSystem:ctor()
	-- MSGID_SERVER_OPEN_TASK_LOGIN_NOTIFY = 871;		//开服狂欢 登陆通知 ServerOpenTaskLoginNotify
	-- MSGID_SERVER_OPEN_TASK_REFRESH = 872;		    //开服狂欢 刷新通知 ServerOpenTaskRefresh
	-- MSGID_SERVER_OPEN_TASK_REWARD_REQ = 873;		//开服狂欢 任务领奖请求 ServerOpenTaskRewardReq
	-- MSGID_SERVER_OPEN_TASK_REWARD_RSP = 874;		//开服狂欢 任务领奖响应 ServerOpenTaskRewardRsp  奖励物品走掉落
	-- MSGID_SERVER_OPEN_TASK_WHOLE_REWARD_REQ = 876;	//开服狂欢 整体任务领奖请求 N/A
	-- MSGID_SERVER_OPEN_TASK_WHOLE_REWARD_RSP = 877;	//开服狂欢 整体任务领奖响应 N/A  奖励物品走掉落
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_OPEN_TASK_LOGIN_NOTIFY,handler(self,self.loginNotifyResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_OPEN_TASK_REFRESH,handler(self,self.updateNotifyResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_OPEN_TASK_REWARD_RSP,handler(self,self.singleRewardResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_OPEN_TASK_WHOLE_REWARD_RSP,handler(self,self.allRewardResponse))
end

g_SOTSystem = SOTSystem.new()