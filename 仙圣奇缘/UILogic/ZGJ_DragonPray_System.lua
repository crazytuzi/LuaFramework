DragonPray = class("DragonPray")
DragonPray.__index = DragonPray

Enum_DragonPrayShaiZi =
{
	[1] = _T("福"),
	[2] = _T("禄"),
	[3] = _T("寿"),
	[4] = _T("喜"),
	[5] = _T("财"),
	[6] = _T("吉"),
}

Enum_DragonPraySkill =
{
	[1] = _T("福如东海"),
	[2] = _T("高官厚禄"),
	[3] = _T("寿比南山"),
	[4] = _T("喜从天降"),
	[5] = _T("财源广进"),
	[6] = _T("吉星高照"),
}

function DragonPray:isBuyEnabled()
	local nTime, nMax = self:getPrayTime()
	if nMax ==  g_DataMgr:getCsvConfigByTwoKey("GlobalCfg", 80, "Data") + g_VIPBase:getVipValue("DragonPrayExCnt") then
		return false
	end
	return true
end

function DragonPray:getPrayCost()
	local nTime, nMax = self:getPrayTime()

	if nTime < nMax then
		return 0
	end
	if nTime < nMax + g_VIPBase:getVipValue("DragonPrayExCnt") - g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_DragonPrayTimes) then
		return g_VIPBase:getVipValue("DragonPrayExCost")
	end
	return false
end

function DragonPray:getPrayTime()
	return g_Hero:getDailyNoticeByType(macro_pb.DT_DragonPrayTimes), g_DataMgr:getCsvConfigByTwoKey("GlobalCfg", 80, "Data") + g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_DragonPrayTimes)
end

function DragonPray:getChangeCost()
	local nTime, nMax = self:getChangeTime()
	if nTime < nMax then
		return 0
	end
	return g_VIPBase:getVipValue("DragonChangeCost")
end

function DragonPray:getChangeTime()
	return g_Hero:getDailyNoticeByType(macro_pb.DT_DragonFreeChangeTimes), g_VIPBase:getVipValue("DragonFreeChangeCnt")
end

function DragonPray:getDragonLv()
	return self.nDragonLv or 0
end

function DragonPray:getDragonExp()
	local nDragonExp = self.nDragonExp or 0
	local CSV_ActivityDragonPrayLevel = g_DataMgr:getCsvConfigByOneKey("ActivityDragonPrayLevel", self.nDragonLv)
	return nDragonExp, CSV_ActivityDragonPrayLevel.DragonExp
end

function DragonPray:getSkillRewardIncrease()
	local CSV_ActivityDragonPrayLevel = g_DataMgr:getCsvConfigByOneKey("ActivityDragonPrayLevel", self.nDragonLv)
	return CSV_ActivityDragonPrayLevel.SkillRewardIncrease
end

function DragonPray:getSkillRewardIncreaseNext()
	local CSV_ActivityDragonPrayLevel = g_DataMgr:getCsvConfigByOneKey("ActivityDragonPrayLevel", self.nDragonLv + 1)
	return CSV_ActivityDragonPrayLevel.SkillRewardIncrease
end


function DragonPray:getDragonBall()
	local nCount_Ji = self.nCount_Ji or 0
    return g_DataMgr:getCsvConfig_FirstKeyData("ActivityDragonPrayEvent", nCount_Ji + 1).DragonBall or 0
end

function DragonPray:getYueli()
	local nCount_Ji = self.nCount_Ji or 0
    return g_DataMgr:getCsvConfig_FirstKeyData("ActivityDragonPrayEvent", nCount_Ji + 1).Knowledge or 0
end

function DragonPray:getAddDragonExp()
	local nCount_Ji = self.nCount_Ji or 0
    return g_DataMgr:getCsvConfig_FirstKeyData("ActivityDragonPrayEvent", nCount_Ji + 1).AddDragonExp or 0
end

function DragonPray:getDiceType(nIndex)
	if self.tbDiceType and self.tbDiceType[nIndex] then
		return self.tbDiceType[nIndex]
	end
	return macro_pb.DiceType_Ji
end

function DragonPray:getState()
	return self.state
end

function DragonPray:calcReward()
	self.nCount_Ji = 0
	for k, v in ipairs(self.tbDiceType) do
		if macro_pb.DiceType_Ji == v then
			self.nCount_Ji = self.nCount_Ji + 1
		end
	end
end

function DragonPray:requestInitInfo()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DRAGON_BALL_INFO_REQUEST, nil)
end

function DragonPray:requestInitInfoResponse(tbMsg)
	local msg = zone_pb.DragonBallInfoResponse()
	msg:ParseFromString(tbMsg.buffer)

	local dragon_pray = msg.dragon_pray
	self.tbDiceType = dragon_pray.type_list
	self.state = dragon_pray.state
	self.nDragonLv = dragon_pray.dragon_lv
	self.nDragonExp = dragon_pray.dragon_exp

	self:calcReward()
	if macro_pb.DragonState_WaitPray == self.state then
		self.nCount_Ji = 0
	end

	g_WndMgr:openWnd("Game_DragonPray")
	--g_FormMsgSystem:PostFormMsg(FormMsg_DragonPray_Info)
	
end

function DragonPray:requestPray()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DRAGON_BALL_PRAY_REQUEST)
end

function DragonPray:requestPrayResponse(tbMsg)
	local msg = zone_pb.DragonBallPrayResponse()
	msg:ParseFromString(tbMsg.buffer)

	self.tbDiceType = msg.type_list
	self:calcReward()
	-- self.add_knowledge = msg.add_knowledge
	-- self.add_dragon_ball = msg.add_dragon_ball
	-- self.add_coin = msg.add_coin
	-- self.add_dragon_exp = msg.add_dragon_exp

	
	g_Hero:incDailyNoticeByType(macro_pb.DT_DragonPrayTimes)

	if msg.add_coin > 0 then
		g_Timer:pushTimer(1.5, function() g_ShowSysTipsWord({text = _T("获得")..msg.add_coin.._T("铜钱"), ccsColor = ccs.COLOR.BRIGHT_GREEN, y = 340}) end)
	end

	self.state = macro_pb.DragonState_WaitConfirm
	g_FormMsgSystem:PostFormMsg(FormMsg_DragonPray_Info)
end

function DragonPray:requestChange()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DRAGON_BALL_CHANGE_REQUEST)
end

function DragonPray:requestChangeResponse(tbMsg)
	local msg = zone_pb.DragonBallChangeResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog("------------------------改运后"..tostring(msg))
	self.tbDiceType = msg.type_list
	local times = msg.times --改运次数
		
	self:calcReward()
	if msg.cur_yuanbao == g_Hero:getYuanBao() then
		g_Hero:incDailyNoticeByType(macro_pb.DT_DragonFreeChangeTimes)
	end
	g_Hero:setYuanBao(msg.cur_yuanbao)
	
	
	if self:getChangeCost() > 0 then 
		--神龙上供改运 记录
		gTalkingData:onPurchase(TDPurchase_Type.TDP_DRAGON_PRAY_CHANGE_LIFE,1,self:getChangeCost())
		--消耗元宝的时候记录消耗次数
		echoj(">>>消耗元宝的时候记录消耗次数")
		g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_DragonChangeCost, times)
		
	end
	g_FormMsgSystem:PostFormMsg(FormMsg_DragonPray_Info)
end

function DragonPray:requestConfirm()
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DRAGON_BALL_CONFIRM_REQUEST)
end

function DragonPray:requestConfirmResponse(tbMsg)
	local msg = zone_pb.DragonBallConFirmResponse()
	msg:ParseFromString(tbMsg.buffer)

	self.tbDiceType = msg.type_list

	g_Hero:addKnowledge(msg.add_knowledge)
	g_Hero:addDragonBall(msg.add_dragon_ball) 
	g_Hero:addCoins(msg.add_coin) 
	
	local fTimeStart = -0.5
	local nStartPosY = 300
	local nCount = 0
	if msg.add_dragon_ball > 0 then
		fTimeStart = fTimeStart + 0.5
		g_Timer:pushTimer(fTimeStart, function()
			g_ShowSysTipsWord({text = _T("神龙上供成功，获得")..msg.add_dragon_ball.._T("个神龙令"), ccsColor = ccs.COLOR.GOLD, y = nStartPosY + nCount * 30})
			nCount = nCount + 1
		end)
	end
	if msg.add_knowledge > 0 then
		fTimeStart = fTimeStart + 0.5
		g_Timer:pushTimer(fTimeStart, function()
			g_ShowSysTipsWord({text = _T("神龙上供成功，获得")..msg.add_knowledge.._T("点阅历"), ccsColor = ccs.COLOR.DARK_SKY_BLUE, y = nStartPosY + nCount * 30})
			nCount = nCount + 1
		end)
	end
	if msg.add_coin > 0 then
		fTimeStart = fTimeStart + 0.5
		g_Timer:pushTimer(fTimeStart, function()
			g_ShowSysTipsWord({text = _T("神龙上供成功，获得")..msg.add_coin.._T("铜钱"), ccsColor = ccs.COLOR.DARK_ORANGE, y = nStartPosY + nCount * 30})
			nCount = nCount + 1
		end)
	end
	if msg.cur_dragon_lv == self.nDragonLv then
		fTimeStart = fTimeStart + 0.5
		g_Timer:pushTimer(fTimeStart, function()
			g_ShowSysTipsWord({text = _T("神龙增加了")..msg.add_dragon_exp.._T("点经验"), ccsColor = ccs.COLOR.BRIGHT_GREEN, y = nStartPosY + nCount * 30})
			nCount = nCount + 1
		end)
	else
		fTimeStart = fTimeStart + 0.5
		g_Timer:pushTimer(fTimeStart, function()
			g_ShowSysTipsWord({text = _T("神龙增加了")..msg.add_dragon_exp.._T("点经验, 等级提升到了")..msg.cur_dragon_lv.._T("级"), ccsColor = ccs.COLOR.BRIGHT_GREEN, y = nStartPosY + nCount * 30})
			nCount = nCount + 1
		end)
		self.nDragonLv = msg.cur_dragon_lv
	end

	self.nDragonExp = self.nDragonExp + msg.add_dragon_exp
	

	--信息清零
	self.state = macro_pb.DragonState_WaitPray
	self.nCount_Ji = 0
	
	g_FormMsgSystem:PostFormMsg(FormMsg_DragonPray_Info)
	
	--神龙改运价格
	g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_DragonChangeCost,0)
end


function DragonPray:ctor()
	-- MSGID_DRAGON_BALL_INFO_REQUEST = 811;				//请求初始化信息	N/A
	-- MSGID_DRAGON_BALL_INFO_RESPONSE = 812;				//响应		DragonBallInfoResponse
	-- MSGID_DRAGON_BALL_PRAY_REQUEST = 813;				//请求上供	N/A
	-- MSGID_DRAGON_BALL_PRAY_RESPONSE = 814;				//响应		DragonBallPrayResponse
	-- MSGID_DRAGON_BALL_CHANGE_REQUEST = 815;				//请求改		N/A
	-- MSGID_DRAGON_BALL_CHANGE_RESPONSE = 816;			//响应		DragonBallChangeResponse
	-- MSGID_DRAGON_BALL_CONFIRM_REQUEST = 817;			//请求确认	N/A
	-- MSGID_DRAGON_BALL_CONFIRM_RESPONSE = 818;			//响应		N/A DragonBallConFirmResponse
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DRAGON_BALL_INFO_RESPONSE,handler(self,self.requestInitInfoResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DRAGON_BALL_PRAY_RESPONSE,handler(self,self.requestPrayResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DRAGON_BALL_CHANGE_RESPONSE,handler(self,self.requestChangeResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DRAGON_BALL_CONFIRM_RESPONSE,handler(self,self.requestConfirmResponse))
end

g_DragonPray = DragonPray.new()