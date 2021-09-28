--------------------------------------------------------------------------------------
-- 文件名:	BaXianPary.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:	
---------------------------------------------------------------------------------------

BaXianPary = class("BaXianPary")
BaXianPary.__index = BaXianPary

local activityBaXianIncense = g_DataMgr:getCsvConfig("ActivityBaXianIncense")
local activityBaXianLevel = g_DataMgr:getCsvConfig("ActivityBaXianLevel")

function BaXianPary:ctor()
	--注册消息
	--打开神像界面返回最新的神像信息
	local order = msgid_pb.MSGID_BAXIAN_GOD_INFO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestBaXianGodInfoResponse)) 

	--神像上香返回
	local order = msgid_pb.MSGID_BAXIAN_GOD_INCENSE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestBaXianInsenceResponse)) 
	
	self.godLevel_  = 1;
	self.gExp_ = 0
	self.tbTog_ = nil
	self.baXianTag_ = 0
	self.func = nil
	
end

-- 打开神像界面请求最新的神像信息
function BaXianPary:msgidBaxianGodInfoRequest()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_GOD_INFO_REQUEST)
end


--打开神像界面返回最新的神像信息
function BaXianPary:requestBaXianGodInfoResponse(tbMsg)
	local msgDetail = zone_pb.BaXianGodInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)

	local godInfo = msgDetail.god_info
	local nExp = godInfo.exp --神像累计获得的经验
	local level = godInfo.level --神像等级
	
	self:setGodLevel(level)
	self:setGodExp(nExp)

	local logs = msgDetail.logs --今天的上香日志
	local tblog = {}
	for i = 1,#logs do 
		local t = {}
		t.Id = logs[i].Id
		t.Type = logs[i].Type
		t.Time = logs[i].Time
		t.Name = logs[i].Name
		t.uin = logs[i].uin
		table.insert(tblog,t)
	end
	
	local function sortLog(one, two)
		return one.Time > two.Time
	end
	table.sort(tblog, sortLog)
	
	self:setBaXianLog(tblog)
	g_WndMgr:showWnd("Game_BaXianPray")
	
end

-- 请求神像上香 
function BaXianPary:requestBaXianInsenceRequest(types)
	self:setBaXianTagType(types)
	local msg = zone_pb.BaXianInsenceRequest()
	msg.type = types --上香类型
	g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_GOD_INCENSE_REQUEST,msg)
end

--神像上香返回
function BaXianPary:requestBaXianInsenceResponse(tbMsg)
	local msgDetail = zone_pb.BaXianInsenceResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog("神像上香返回=================")
	cclog(tostring(msgDetail))
	
	local coupons =  msgDetail.coupons --更新玩家的元宝
	local yuanBao = g_Hero:getYuanBao() - coupons
	if yuanBao > 0 then
		local itemType = nil
		if self.baXianTag_ == 2 then 
			itemType = TDPurchase_Type.TDP_WorshipStorax 
		elseif self.baXianTag_ == 3 then 
			itemType = TDPurchase_Type.TDP_WorshipSkyTimber 
		end
		gTalkingData:onPurchase(itemType, 1, yuanBao)
	end

	local godInfo = msgDetail.god_info
	local nExp = godInfo.exp --神像累计获得的经验
	local level = godInfo.level --神像等级
	
	self:setGodLevel(level)
	self:setGodExp(nExp)
	
	local prestige = msgDetail.prestige -- 更新玩家的声望
	local knowledge = msgDetail.knowledge -- 更新玩家的阅历

	g_Hero:setPrestige(prestige)
	g_Hero:setKnowledge(knowledge)
	g_Hero:setYuanBao(coupons)

	local logs = msgDetail.log --当次的log返回
	local t = {}
	t.Time = logs.Time
	t.Name = logs.Name
	t.Type = logs.Type
	t.Id = logs.Id
	t.uin = logs.uin
	self:setTodayInsence(logs.Type)
	table.insert(self.tbTog_,t)
	
	local function sortLog(one, two)
		return one.Time > two.Time
	end
	table.sort(self.tbTog_, sortLog)
	
	if self.func then 
		self.func()
		self.func = nil
	end
	self.baXianTag_ = 0
end

function BaXianPary:InsenceResponseFunc(f)
	self.func = f
end

function BaXianPary:setBaXianTagType(types)
	self.baXianTag_ = types 
end
--香火的品质
function BaXianPary:getActivityBaXianIncense(key)
	return activityBaXianIncense[key]
end

function BaXianPary:getActivityBaXianLevel()
	return activityBaXianLevel
end

--神像的最高等级
function BaXianPary:maxBaXianLevel()
	return #activityBaXianLevel
end

--神像等级
function BaXianPary:getGodLevel()
	return self.godLevel_
end

function BaXianPary:setGodLevel(gLevel)
	self.godLevel_ = gLevel 
end

--神像经验
function BaXianPary:getGodExp()
	return self.gExp_ or 0
end

function BaXianPary:setGodExp(gExp)
	self.gExp_ = gExp
end

function BaXianPary:getBaXianLog()
	return self.tbTog_
end

function BaXianPary:setBaXianLog(tbLog)
	if not self.tbTog_ then self.tbTog_ = {} end
	self.tbTog_ = tbLog
end

function BaXianPary:setTodayInsence(insence)
	if not insence then 
		SendError("insence上香类型数据为空==="..insence)
	end
	self.insence = insence or 0
end
function BaXianPary:getTodayInsence()
	return self.insence
end
--玩家上香类型
function BaXianPary:getBaXianlogType()
	local types = self:getTodayInsence()
	return types
end

---------------------------------------------------------------------------------
g_BaXianPary = BaXianPary.new()
