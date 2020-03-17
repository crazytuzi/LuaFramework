--[[
OperactivitiesController
2015-10-12 11:44:42
liyuan
]]
---------------------------------------------------------

_G.OperactivitiesController = setmetatable( {}, {__index = IController} )
OperactivitiesController.name = "OperactivitiesController"

function OperactivitiesController:Create()	
	MsgManager:RegisterCallBack(MsgType.SC_PartySimpleInfo,self,self.OnPartySimpleInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_PartyListResult,self,self.OnPartyListResult);
	MsgManager:RegisterCallBack(MsgType.SC_PartyStatListResult,self,self.OnPartyStatListResult);
	MsgManager:RegisterCallBack(MsgType.SC_GetPartyAwardResult,self,self.OnGetPartyAwardResult);
	MsgManager:RegisterCallBack(MsgType.SC_PartyPowerRank,self,self.OnPartyPowerRankResult);
	MsgManager:RegisterCallBack(MsgType.SC_PartyGroupPurchase,self,self.OnPartyGroupPurchase);
	MsgManager:RegisterCallBack(MsgType.SC_PartyInfo,self,self.OnPartyInfoResult);
	MsgManager:RegisterCallBack(MsgType.WC_PartyBuy,self,self.OnPartyBuyResult);
	MsgManager:RegisterCallBack(MsgType.SC_PartyGroupCharge,self,self.OnPartyGroupCharge);
	OperactivitiesModel:init()	
	
end

--请求运营活动信息
function OperactivitiesController:ReqPartyList(btnid)	
	local msg = ReqPartyListMsg:new()
	msg.btnid = btnid
	
	FTrace(msg, '请求运营活动信息')
	MsgManager:Send(msg)
end

-- 通知服务器抽奖
function OperactivitiesController:ReqYunYingDraw()
	local msg = ReqYunYingDrawMsg:new()
	MsgManager:Send(msg)
end

-- 请求活动的活动状态
function OperactivitiesController:ReqPartyStatList(btnid)
	local msg = ReqPartyStatListMsg:new()
	msg.btnid = btnid
	
	FTrace(msg, '请求活动的活动状态')
	MsgManager:Send(msg)
end

--获得运营活动奖励
function OperactivitiesController:ReqGetPartyAward(id, index)	
	local msg = ReqGetPartyAwardMsg:new()
	msg.id = id
	msg.index = index
	
	FTrace(msg, '获得运营活动奖励')
	MsgManager:Send(msg)
end

--请求战力运营排行
function OperactivitiesController:ReqPartyRank(groupId)	
	local msg = ReqPartyRankMsg:new()
	msg.id = groupId
	FTrace(msg, '请求战力运营排行')
	MsgManager:Send(msg)
end

--团购购买
function OperactivitiesController:ReqPartyBuy(actId)	
	local msg = ReqPartyBuyMsg:new()
	msg.id = actId
	FTrace(msg, '团购购买')
	MsgManager:Send(msg)
end

--请求团购信息
function OperactivitiesController:ReqPartyGroupPurchase(groupId)	
	local msg = ReqPartyGroupPurchaseMsg:new()
	msg.id = groupId
	FTrace(msg, '请求团购')
	MsgManager:Send(msg)
end

--请求首冲团购信息
function OperactivitiesController:ReqPartyGroupPurchaseFirst(groupId)	
	local msg = ReqPartyGroupChargeMsg:new()
	msg.id = groupId
	FTrace(msg, '请求首冲团购信息')
	MsgManager:Send(msg)
end

--请求单个活动信息
function OperactivitiesController:RespPartyInfo(groupId)	
	local msg = ReqPartyInfoMsg:new()
	msg.groupid = groupId
	
	msg.version = OperactivitiesModel:GetOperActIndex(groupId)
	
	FTrace(msg, '请求单个活动信息')
	MsgManager:Send(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回运营活动基本信息
function OperactivitiesController:OnPartySimpleInfoResult(msg)
	FTrace(msg, '返回运营活动基本信息')
	
	-- debug.debug()
	OperactivitiesModel:UpdateOperActBtnState(msg)
end

-- 运营活动返回
function OperactivitiesController:OnPartyListResult(msg)
	FTrace(msg, '运营活动返回')	
	-- FPrint('运营活动返回'..msg.ret)	
	-- if msg.ret == 0 then
		-- Notifier:sendNotification(NotifyConsts.OperActivityInitInfo);
		-- return
	-- end
	OperactivitiesModel:InitOperactivities(msg)
end

-- 运营活动状态返回
function OperactivitiesController:OnPartyStatListResult(msg)
	-- FTrace(msg, '运营活动状态返回')
	FPrint('运营活动状态返回')	
	OperactivitiesModel:UpdateOperActState(msg)
end

-- 返回单个活动信息
function OperactivitiesController:OnPartyInfoResult(msg)
	FTrace(msg, '返回单个活动信息')
	-- FPrint('返回单个活动信息')	
	if msg.ret == 0 then
		Notifier:sendNotification(NotifyConsts.UpdateGroupInfo, {groupId = msg.groupid});
		return
	end
	OperactivitiesModel:UpdateOperactGroupInfo(msg)
end

-- 获得运营活动奖励返回
function OperactivitiesController:OnGetPartyAwardResult(msg)
	FTrace(msg, '获得运营活动奖励返回')
	
	OperactivitiesModel:UpdateOperActAwardState(msg)
end

-- 返回战力运营排行
function OperactivitiesController:OnPartyPowerRankResult(msg)
	FTrace(msg, '返回战力运营排行')
	
	OperactivitiesModel:UpdatePowerRanking(msg)
end

-- 返回团购信息
function OperactivitiesController:OnPartyGroupPurchase(msg)
	FTrace(msg, '返回团购信息')
	
	OperactivitiesModel:UpdateTeamBuyInfo(msg)
end

-- 返回首冲团购信息
function OperactivitiesController:OnPartyGroupCharge(msg)
	FTrace(msg, '返回首冲团购信息')
	
	OperactivitiesModel:UpdateTeamBuyFirstInfo(msg)
end

-- 团购购买返回
function OperactivitiesController:OnPartyBuyResult(msg)
	FTrace(msg, '团购购买返回')
	
	OperactivitiesModel:UpdateTeamBuyResult(msg)
end