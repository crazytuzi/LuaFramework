--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-4
-- 版  本:	1.0
-- 描  述:	运营活动Form
-- 应  用:  
---------------------------------------------------------------------------------------
Class_ActivityCenter = class("Class_ActivityCenter")
Class_ActivityCenter.__index = Class_ActivityCenter

--活动中心任务状态
ActState =
{
	INVALID = 0,	--无效或 完成已领取
	DOING = 1,		--进行中
	FINISHED = 2,   --完成，可以领奖状态
    INACTIVATED = 3,--任务未激活 或 当前不可完成
}


function Class_ActivityCenter:getBubbleTotal()
	local total = 0
	for k, v in pairs(self.tbBubble) do
		if v then
			total = total + v
		end
	end
	return total
end

function Class_ActivityCenter:getBubbleByID(id)
	return self.tbBubble[id] or 0
end

function Class_ActivityCenter:incBubbleByID(id)
	if self.tbBubble[id] then
		self.tbBubble[id] = self.tbBubble[id] + 1
		local HomeWnd = g_WndMgr:getWnd("Game_Home")
		if HomeWnd ~= nil then
			HomeWnd:addNoticeAnimation_ActivityCenter()
		end
	end
end

function Class_ActivityCenter:decBubbleByID(id)
	if self.tbBubble[id] and self.tbBubble[id] > 0 then
		self.tbBubble[id] = self.tbBubble[id] - 1
	end
end

function Class_ActivityCenter:getActCurNumByID(id)
    return self.tbActCurNum[id]
end

function Class_ActivityCenter:getActValueByID(id)
    return self.tbActValue[id]
end

function Class_ActivityCenter:getActEndTimeByID(id)
    return self.tbActEndTime[id]
end

function Class_ActivityCenter:getMissionsByID(id)
	return self.tbActivity[id]
end

function Class_ActivityCenter:setMission(nActivityID, nMissionID, value)
	if not nActivityID or not nMissionID then return end

	if not self.tbActivity or not self.tbActivity[nActivityID]  then
		return 
	end

	self.tbActivity[nActivityID][nMissionID] = value
end

function Class_ActivityCenter:setRewardResponseCB(func)
	self.rewardResponseCB = func
end

--需要特殊打点的活动，每次登陆最少保证打一个点(点开活动页面后正常打点)
local actBubbleTable = {
    [11] = 1,        --单笔充值活动
    [13] = 1,        --节日单笔充值活动
    [23] = 1,        --开服七天充值
    [27] = 1,        --节日七天充值活动
    [16] = 1,        --节日累计充值
    [21] = 1,        --开服累计充值
    [28] = 1,        --开服累计召唤
    [19] = 1,        --节日累计召唤
    [22] = 1,        --开服累计消耗
    [25] = 1,        --节日累计消耗
    [24] = 1,        --战力大比拼
    [20] = 1,        --节日高级召唤返利
    [10] = 1,        --VIP玩家专属特权礼包
    [12] = 1,        --VIP专属周特权礼包
    [18] = 1,        --节日每日清仓大甩卖
    [30] = 1,        --折扣兑换
}

--点开活动界面后不打点 (点开活动前如需打一个点，请在actBubbleTable中配置该id)
local actBubbleTableBuy = {
    [10] = 1,        --VIP玩家专属特权礼包
    [12] = 1,        --VIP专属周特权礼包
    [18] = 1,        --节日每日清仓大甩卖 
    [30] = 1,        --折扣兑换
}

function Class_ActivityCenter:resetBubbleById(id)
    --重新计算单个活动中可领取的子活动的个数，主要用来清除特殊打点的活动
    if self.tbActivity[id] and id ~= common_pb.AOLT_KAIFU_JIJIN then
        self.tbBubble[id] = 0
        if not actBubbleTableBuy[id] then
            for key,val in ipairs(self.tbActivity[id]) do
                if ActState.FINISHED == val then --可领取
		            self.tbBubble[id] = self.tbBubble[id] + 1
		        end
	        end
        end
    end
end

function Class_ActivityCenter:loginNotifyResponse(tbMsg)
	local msg = zone_pb.AOLLoginNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local activity_online = msg.activity_online
	self.online_reward_start_time = activity_online.online_reward_start_time
	local tbActivity = activity_online.big_type_data
    local csvConfig = g_DataMgr:getCsvConfig("ActivityOnline")

	for k, v in ipairs(tbActivity) do
		local tb = {}
        local tbCurNum = {}
        local tbValue = {}
        self.tbBubble[v.type] = 0
		for key,val in ipairs(v.mission) do
			tb[val.mission_id] = val.state
            tbCurNum[val.mission_id] = val.cur_num
            tbValue[val.mission_id] = val.value
			if ActState.FINISHED == val.state and not actBubbleTableBuy[v.type] and g_Hero:getMasterCardLevel() >= csvConfig[v.type].OpenLevel then --可领取
				if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
					if k == ENUM_ActivityOnline_ID.MonthlyCard then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.DuiHuanMa then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.KaiFuJiJin then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.KaiFuJiJinFuli then
						--donothing
					else
						self.tbBubble[v.type] = self.tbBubble[v.type] + 1
					end
				else
					self.tbBubble[v.type] = self.tbBubble[v.type] + 1
				end
			end
		end
        if actBubbleTable[v.type] == 1 and self.tbBubble[v.type] <= 0 and g_Hero:getMasterCardLevel() >= csvConfig[v.type].OpenLevel then
            self.tbBubble[v.type] = 1
        end
		self.tbActivity[v.type] = tb
        self.tbActCurNum[v.type] = tbCurNum
        self.tbActValue[v.type] = tbValue
        self.tbActEndTime[v.type] = v.close_time or 0
		if common_pb.AOLT_ONLINE == v.type then -- 处理在线时间活动
			self:dealWithAct_OnlineTime(self.online_reward_start_time)
		end
	end
	
	--开服基金
	if Act_KaiFuJiJin then
		Act_KaiFuJiJin.bBuy = activity_online.is_jijin_buy
		if not Act_KaiFuJiJin.bBuy and self.tbBubble[common_pb.AOLT_KAIFU_JIJIN] then
			self.tbBubble[common_pb.AOLT_KAIFU_JIJIN] = self.tbBubble[common_pb.AOLT_KAIFU_JIJIN] + 1
		end
	end

	--7天登录需特殊处理(服务器未改)
	if Act_ContinueLogin then
		self.tbActivity[common_pb.AOLT_7DAY_LOGIN], self.tbBubble[common_pb.AOLT_7DAY_LOGIN] = Act_ContinueLogin:convertMsg()
	end
end

--7天登录24点刷新特殊处理
function Class_ActivityCenter:refreshContinueDay()
	if Act_ContinueLogin then
		Act_ContinueLogin:refreshContinueDay()
		self.tbActivity[common_pb.AOLT_7DAY_LOGIN], self.tbBubble[common_pb.AOLT_7DAY_LOGIN] = Act_ContinueLogin:convertMsg()
	end

    --O点后请求战斗力排行榜
    self:fightRankListRequest()
end

function Class_ActivityCenter:updateNotifyResponse(tbMsg)
	local msg = zone_pb.AOLUpdateNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
    local csvConfig = g_DataMgr:getCsvConfig("ActivityOnline")
	local tbActivity = msg.big_type_data
	for k,v in ipairs(tbActivity) do
		self.tbActivity[v.type] = self.tbActivity[v.type] or {}
        self.tbActCurNum[v.type] = self.tbActCurNum[v.type] or {}
        self.tbActValue[v.type] = self.tbActValue[v.type] or {}
		for key,val in ipairs(v.mission) do
			self.tbActivity[v.type][val.mission_id] = val.state
            self.tbActCurNum[v.type][val.mission_id] = val.cur_num
            self.tbActValue[v.type][val.mission_id] = val.value
		end
        --计算可领取的活动个数
        self.tbBubble[v.type] = 0
        for key,val in ipairs(self.tbActivity[v.type]) do
			if ActState.FINISHED == val and not actBubbleTableBuy[v.type] and g_Hero:getMasterCardLevel() >= csvConfig[v.type].OpenLevel then --可领取
				if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
					if k == ENUM_ActivityOnline_ID.MonthlyCard then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.DuiHuanMa then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.KaiFuJiJin then
						--donothing
					elseif k == ENUM_ActivityOnline_ID.KaiFuJiJinFuli then
						--donothing
					else
						self.tbBubble[v.type] = self.tbBubble[v.type] + 1
					end
				else
					self.tbBubble[v.type] = self.tbBubble[v.type] + 1
				end
			end
		end
	end
    
end

function Class_ActivityCenter:invalidNotifyResponse(tbMsg)
	local msg = zone_pb.AOLBigClassInvalidNotify()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	self.tbActivity[msg.type] = nil
	self.tbBubble[msg.type] = nil
    self.tbActCurNum[msg.type] = nil
    self.tbActValue[msg.type] = nil
    self.tbActEndTime[msg.type] = -1
end

function Class_ActivityCenter:rewardRequest(nType, nIndex)
	local msg = zone_pb.AOLRewardRequest()
	msg.type = nType
	msg.mission_id = nIndex
	g_MsgMgr:sendMsg(msgid_pb.MSGID_AOL_REWARD_REQUEST,msg)
end

function Class_ActivityCenter:rewardResponse(tbMsg)
	local msg = zone_pb.AOLRewardResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	self.tbActivity[msg.type][msg.mission_id] = msg.state
    self.tbActValue[msg.type][msg.mission_id] = msg.value
	if self.tbBubble[msg.type] > 0 then
		self.tbBubble[msg.type] = self.tbBubble[msg.type] - 1
	end
	if self.rewardResponseCB then
		self:rewardResponseCB()
	end
end

--请求战斗力排行榜
function Class_ActivityCenter:fightRankListRequest()
    g_MsgMgr:sendMsg(msgid_pb.MSGID_FIGHT_RANK_NAME_LIST_REQUEST, nil)
end
--请求战斗力排行榜响应
function Class_ActivityCenter:fightRankListResponse(tbMsg)
    local msg = zone_pb.FightRankNameResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
    for i,v in ipairs(msg.name) do
         self.mfightRankList[i] = v
    end
end
--按排名获取玩家昵称
function Class_ActivityCenter:getFightRankListByIndex(index)
    return self.mfightRankList[index]
end

function Class_ActivityCenter:ctor(tbMsg)
	self.tbActivity = {}
	self.tbBubble = {}
    self.tbActCurNum = {}    --任务的当前完成情况
    self.tbActValue = {}     --任务扩展字段，用来存放当前购买次数等
    self.tbActEndTime = {}   --活动的结束时间
    self.mfightRankList = {}
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_AOL_LOGIN_NOTIFY,handler(self,self.loginNotifyResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_AOL_UPDATE_NOTIFY,handler(self,self.updateNotifyResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_AOL_BIG_CLASS_INVALID_NOTIFY,handler(self,self.invalidNotifyResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_AOL_REWARD_RESPONSE,handler(self,self.rewardResponse))
    g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_FIGHT_RANK_NAME_LIST_RESPONSE,handler(self,self.fightRankListResponse))
end

function Class_ActivityCenter:dealWithAct_ContinueLogin()
	if Act_ContinueLogin then
		local nBubble = Act_ContinueLogin:noticeNum()
        self.tbBubble[1] = nBubble
	end
end

function Class_ActivityCenter:dealWithAct_OnlineTime(nSec)
	if Act_OnlineTime then
		Act_OnlineTime:initTime(nSec)
	end
end

if not g_act then
    g_act = Class_ActivityCenter.new()
else
	g_act:ctor()
	-- g_act:dealWithAct_OnlineTime(g_act.online_reward_start_time)
	-- if Act_ContinueLogin then
	-- 	Act_ContinueLogin:convertMsg()
	-- end
end