--------------------------------------------------------------------------------------
-- 文件名:	HJW_SaoDangData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------
SaoDangData = class("SaoDangData")
SaoDangData.__index = SaoDangData

--精英副本
local pageId_ = 1;
local idxId_ = 1;

local nSubEctypeID_ = nil;

ECTYPE_TYPE ={
	COMMON_ECTYPE = 1,
	ELITE_ECTYPE = 2,
	ACTIVITY_ECTYPE = 3,
}

function SaoDangData:ctor()
	self.attackNum = 0 --攻打次数
	self.maxFightNum = 0 --最大的攻打次数
	self.needEnergy = 0 --需要消耗的体力
	
	--扫荡关卡响应
	local order = msgid_pb.MSGID_SWEEP_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestSweepPassResponse))
	
	--精英副本
	local order = msgid_pb.MSGID_SWEEP_JING_YING_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestSweepJingYingEctypeResponse))	
	
end

--普通副本
function SaoDangData:commonEctypSaoDang(nSubEctypeID,nEctypeID)
	nSubEctypeID_ = nSubEctypeID
	--需要消耗的体力
	local CSV_MapEctype =g_DataMgr:getCsvConfigByOneKey("MapEctype",nEctypeID)
	self.needEnergy =  CSV_MapEctype.NeedEnergy
	self.attackNum = g_Hero:getEctypePassStar(nEctypeID).attack_num
	
	--剩余扫荡次数 （最多次数 - 已经打够次数）
	g_VIPBase:setCommonEncryptid(nEctypeID)
	local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
	self.maxFightNum = CSV_MapEctype.MaxFightNums + VIPNum
	
	self:saoDangStart(ECTYPE_TYPE.COMMON_ECTYPE)
	
end

--精英副本
function SaoDangData:eliteEctypSaoDang(pageId,idxId)
	pageId_ = pageId;
	idxId_ = idxId;
	--需要刷新挑战次数
	g_VIPBase:setJYPageIdPageIndex(pageId,idxId)
	
	local csv_JY = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", pageId, idxId)
	
	local types = VipType.VIP_TYPE_JY_ENCRYPT
	local vipAddNum = g_VIPBase:getAddTableByNum(types)
	
	self.attackNum = g_EctypeJY:getAttackNum(pageId,idxId) 
	self.maxFightNum = csv_JY.MaxFightNums + vipAddNum 
	
	self:saoDangStart(ECTYPE_TYPE.ELITE_ECTYPE)
	
end

--活动副本

function SaoDangData:saoDangStart(ectypeType)

	local residueNum = self.maxFightNum - self.attackNum
	if residueNum == 0 then 
		g_ClientMsgTips:showMsgConfirm(_T("通关次数没有了"))
		return
	end
	--按体力计算（每次消耗6点体力） 最多可以扫荡多少次
	local saoDangCount = math.floor(g_Hero:getEnergy() / 6)
	local defaultValue = 5 --初始扫荡次数为5
	--每次扫荡次最大为10
	if saoDangCount > 10 then  saoDangCount = 10 end
	if residueNum < saoDangCount then  saoDangCount = residueNum end
	if saoDangCount < defaultValue then  defaultValue = saoDangCount end
	if saoDangCount == 0 then saoDangCount = 10  end
	
	local ectype = self.needEnergy * 1
	if ectype > g_Hero:getEnergy() then 
		g_buyEnergy()
		return 
	end
	
	g_ClientMsgTips:showConfirmInputNumber(_T("请输入扫荡次数"), saoDangCount, function(count) 
		local ectype = self.needEnergy * count
		if ectype > g_Hero:getEnergy() then 
			g_ClientMsgTips:showMsgConfirm(_T("您的体力不足"))
			return 
		end
		
		if count > residueNum then g_ClientMsgTips:showMsgConfirm(_T("输入的扫荡次数大于今天可战斗的次数")) return end
		if count == 0 then cclog("没有扫荡次数") return end
		
		if ectypeType == ECTYPE_TYPE.COMMON_ECTYPE then
			if nSubEctypeID_ then 
				self:requestSweepPassRequest(nSubEctypeID_, count)
			end
		elseif ectypeType == ECTYPE_TYPE.ELITE_ECTYPE then 
			if pageId_ and idxId_ then 
				self:requestSweepJingYingEctype(pageId_, idxId_, count)
			end
		elseif ectypeType == ECTYPE_TYPE.ACTIVITY_ECTYPE then 
			
		end
	end,function() end,defaultValue)
	
end

--普通副本
--请求扫荡关卡
function SaoDangData:requestSweepPassRequest(subectypeId,sweepTimes)
	cclog("----Game_SaoDang:requestSweepPassRequest-------")
	cclog("----请求扫荡关卡普通-------")
	local rootMsg = zone_pb.SweepPassRequest()
	rootMsg.subectype_id = subectypeId	-- 扫荡子关卡id
	rootMsg.sweep_times = sweepTimes; 	-- 扫荡次数
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SWEEP_REQUEST, rootMsg)
	
	g_MsgNetWorkWarning:showWarningText()

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_SWEEP_REQUEST)
	
end

--扫荡关卡响应普通
function SaoDangData:requestSweepPassResponse(tbMsg)
	cclog("---------requestSweepPassResponse-------------")
	cclog("---------扫荡关卡响应--普通-----------")
	local msgDetail = zone_pb.SweepPassResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	-- local nMasterCardLevel = msgDetail.lv --更新玩家等级
	-- local nMasterCardExp = msgDetail.exp --更新玩家经验
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_SaoDang") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	local param = {
		id =  msgDetail.subectype_id, --扫荡子关卡id
		sweepResult =  msgDetail.sweep_result, --
		sweepTimes =  msgDetail.sweep_times, --战斗数据
		types = ECTYPE_TYPE.COMMON_ECTYPE,
	}
	g_WndMgr:showWnd("Game_SaoDang",param)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_SWEEP_REQUEST, msgid_pb.MSGID_SWEEP_RESPONSE)
end
--精英副本
--请求扫荡关卡
function SaoDangData:requestSweepJingYingEctype(pageId, idxId, sweepTimes)
	cclog("----Game_SaoDang:requestSweepJingYingEctype-------")
	cclog("----请求扫荡关卡精英-------")
	local rootMsg = zone_pb.SweepJingYingEctypeRequest()
	rootMsg.page_id = pageId;
	rootMsg.idx_id = idxId;
	rootMsg.sweep_times = sweepTimes;

	g_MsgMgr:sendMsg(msgid_pb.MSGID_SWEEP_JING_YING_REQUEST, rootMsg)
	
	g_MsgNetWorkWarning:showWarningText()

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_SWEEP_JING_YING_REQUEST)
	
end

--扫荡关卡响应精英
function SaoDangData:requestSweepJingYingEctypeResponse(tbMsg)
	cclog("---------requestSweepJingYingEctypeResponse-------------")
	cclog("---------扫荡关卡响应---精英----------")
	local msgDetail = zone_pb.SweepJingYingEctypeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	
	local nMasterCardLevel = msgDetail.lv --更新玩家等级
	local nMasterCardExp = msgDetail.exp --更新玩家经验
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_SaoDang") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	local param = {
		id =  msgDetail.subectype_id, --扫荡子关卡id
		sweepResult =  msgDetail.sweep_result, ----战斗数据
		sweepTimes =  msgDetail.attack_num, --总攻打次数
		pageId = msgDetail.page_id,
		idxId = msgDetail.idx_id,
		types = ECTYPE_TYPE.ELITE_ECTYPE,
	}
	g_WndMgr:showWnd("Game_SaoDang",param)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_SWEEP_JING_YING_REQUEST, msgid_pb.MSGID_SWEEP_JING_YING_RESPONSE)
end

g_SaoDangData = SaoDangData.new()