--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

----------------------------------基础信息----------------------------------
function Class_Hero:getMasterName()
	if g_BattleTeachSystem:IsTeaching()then
		return _T("景华派掌门")
	end

	return self.tbMasterBase.szName
end

--获取主角名字带突破等级后缀
function Class_Hero:getMasterNameSuffix(Label_Name)
	local tbCardLeader = self:getBattleCardByIndex(1)
	if Label_Name then
		g_SetCardNameColorByEvoluteLev(Label_Name, tbCardLeader:getEvoluteLevel())
	end
	if g_BattleTeachSystem:IsTeaching()then
		return _T("景华派掌门")
	end
	return getFormatSuffixLevel(self.tbMasterBase.szName, tbCardLeader:getEvoluteSuffix())
end

--设置主角名称颜色
function Class_Hero:setMasterNameWidgetColor(Label_Name)
	if Label_Name then
		local tbCardLeader = self:getBattleCardByIndex(1)
		
		if tbCardLeader then
			g_SetCardNameColorByEvoluteLev(Label_Name, tbCardLeader:getEvoluteLevel())
		end
	end
end

--1是男2是女
function Class_Hero:getMasterSex()
	if not self.tbMasterBase then return 1 end
	return self.tbMasterBase.nSex or 1
end

----------------------------------主角卡等级----------------------------------
--获取玩家的等级
function Class_Hero:getMasterCardLevel()
	local tbCardLeader = self:getBattleCardByIndex(1)

	if not tbCardLeader then return 1 end

	return tbCardLeader:getLevel()
end

----------------------------------主角卡经验----------------------------------
function Class_Hero:getMasterCardExp(nAddExp)
	local nAddExp = nAddExp or 0
	local tbCardLeader = self:getBattleCardByIndex(1)
	if not tbCardLeader then return 1 end
	cclog("==========打印经验=========="..tbCardLeader:getExp() + nAddExp)
	return tbCardLeader:getExp() + nAddExp
end


function Class_Hero:getMasterCardCurExpInNewLevByAddExp(nAddExp)
	local nAddExp = nAddExp or 0
	local tbCardLeader = self:getBattleCardByIndex(1)
	if not tbCardLeader then return 1 end

	return tbCardLeader:getCurExpInNewLevByAddExp(nAddExp)
end

function Class_Hero:getMasterCardMaxExp()
	local tbCardLeader = self:getBattleCardByIndex(1)
	if not tbCardLeader then return 1 end

	return tbCardLeader:getMaxExp()
end

function Class_Hero:addMasterCardExp(nAddExp, nMasterCardLevel, nMasterCardExp)
	local tbCardLeader = self:getBattleCardByIndex(1)
	if not tbCardLeader then return 1 end

	-- 注意此函数加经验要传0，因为以前加经验跟服务端不同步，然后以服务端的传值为准，但是为快速改代码就这样搞了
	return tbCardLeader:addExpWithHeroEvent(0, nMasterCardLevel, nMasterCardExp)
end

function Class_Hero:getMasterCardFullExpInNewLevByAddExp(nAddExp)
	local nAddExp = nAddExp or 0
	local tbCardLeader = self:getBattleCardByIndex(1)
	if not tbCardLeader then return 1 end

	return tbCardLeader:getFullExpInNewLevByAddExp(nAddExp)
end



----------------------------------体力----------------------------------
-- function Class_Hero:getEnergy(nAddEnergy)
-- 	local nAddEnergy = nAddEnergy or 0
-- 	return self.tbMasterBase.nEnergy + nAddEnergy
-- end

function Class_Hero:getEnergy()
	return self.tbMasterBase.nEnergy
end

function Class_Hero:getEnergyString(nAddEnergy)
	local nAddEnergy = nAddEnergy or 0
	return g_ResourceValueFormat(self.tbMasterBase.nEnergy + nAddEnergy)
end

function Class_Hero:getMaxEnergy()
	local physicalMaxNum = g_VIPBase:getVipValue("PhysicalMaxNum")
	return g_DataMgr:getGlobalCfgCsv("max_init_energy") + physicalMaxNum
end

function Class_Hero:getEnergyPercent()
	return self.tbMasterBase.nEnergy * 100 / self:getMaxEnergy()
end

--在再一的地方赋值 此函数废掉
function Class_Hero:setEnergy(nEnergy)
	
end

--唯一在响应里面设置当前体力
function Class_Hero:setCurEnergy(nEnergy)
	if not nEnergy then nEnergy = 0 end
	
	if not self.tbMasterBase then return end
	
	self.tbMasterBase.nEnergy = nEnergy

	g_HeadBar:refreshHeadBar()
end

--在再一的地方赋值 此函数废掉
function Class_Hero:addEnergy(nAddEnergy)
	
end


function Class_Hero:recoverEnergy(msgDetail)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nEnergy = msgDetail.total_energy
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getBuyEnergyTimes()
	return self.nBuyEenergyTimes
end

function Class_Hero:setBuyEnergyTimes(nBuyEenergyTimes)
	self.nBuyEenergyTimes = nBuyEenergyTimes
end



----------------------------------元宝----------------------------------
function Class_Hero:getYuanBao(nAddYuanBao)
	local nAddYuanBao = nAddYuanBao or 0
	return self.tbMasterBase.nYuanBao + nAddYuanBao
end

function Class_Hero:getYuanBaoString(nAddYuanBao)
	local nAddYuanBao = nAddYuanBao or 0
	return self.tbMasterBase.nYuanBao + nAddYuanBao
end

function Class_Hero:addYuanBao(nAddYuanBao)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nYuanBao = self.tbMasterBase.nYuanBao + nAddYuanBao
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:delYuanBao(nDelYuanBao)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nYuanBao = self.tbMasterBase.nYuanBao - nDelYuanBao
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:setYuanBao(nYuanBao)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nYuanBao = nYuanBao
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getTotalChargeYuanBao()
	return self.tbMasterBase.nTotalChargeYuanBao
end

function Class_Hero:setTotalChargeYuanBao(nYuanBao)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nTotalChargeYuanBao = nYuanBao
end

function Class_Hero:getTotalChargeYuanBaoJR()
    return self.tbMasterBase.nTotalChargeYuanBaoJR
end

function Class_Hero:setTotalChargeYuanBoaJR(nYuanBao)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalChargeYuanBaoJR = nYuanBao
end

function Class_Hero:getTotalCostYuanBao()
    return self.tbMasterBase.nTotalCostYuanBao
end

function Class_Hero:setTotalCostYuanBao(nYuanBao)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalCostYuanBao = nYuanBao
end

function Class_Hero:getTotalCostYuanBaoJR()
    return self.tbMasterBase.nTotalCostYuanBaoJR
end

function Class_Hero:setTotalCostYuanBaoJR(nYuanBao)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalCostYuanBaoJR = nYuanBao
end

function Class_Hero:getTotalSummon()
    return self.tbMasterBase.nTotalSummon
end

function Class_Hero:setTotalSummon(nSummon)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalSummon = nSummon
end

function Class_Hero:getTotalSummonJR()
    return self.tbMasterBase.nTotalSummonJR
end

function Class_Hero:setTotalSummonJR(nSummon)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalSummonJR = nSummon
end

function Class_Hero:setTotalSysDays(nday)
    if not self.tbMasterBase then return end
    self.tbMasterBase.nTotalSysDays = nday
end

function Class_Hero:getTotalSysDays()
    return self.tbMasterBase.nTotalSysDays
end


 --本次登录充值的元宝
function Class_Hero:getChargeYuanBao()
	return self.nChargeYuanBao or 0
end

function Class_Hero:addChargeYuanBao(nYuanBao)
	self.nChargeYuanBao = self.nChargeYuanBao or 0
	self.nChargeYuanBao = self.nChargeYuanBao + nYuanBao
end


----------------------------------铜钱----------------------------------
function Class_Hero:delCoins(nDelCoins)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nCoins = self.tbMasterBase.nCoins - nDelCoins
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:setCoins(nCoins)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nCoins = nCoins
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getCoins(nAddCoins)
	local nAddCoins = nAddCoins or 0
	return self.tbMasterBase.nCoins + nAddCoins
end

function Class_Hero:getCoinsString(nAddCoins)
	local nAddCoins = nAddCoins or 0
	return g_ResourceValueFormat(self.tbMasterBase.nCoins + nAddCoins)
end

function Class_Hero:addCoins(nAddCoins)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nCoins = self.tbMasterBase.nCoins + nAddCoins
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getZhaoCaiCoins()
	local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", self:getMasterCardLevel())
	return CSV_PlayerExp.ZhaoCaiCoins
end

----------------------------------VIP等级----------------------------------
function Class_Hero:getVIPLevel()
	return g_VIPBase:getCvsVipLevel()
end

function Class_Hero:getVIPLevelID()
	return g_VIPBase:getVIPLevelId()
end

function Class_Hero:getVIPLevelMaxNumZhaoCai()
	return g_DataMgr:getCsvConfigByOneKey("VipLevel", self:getVIPLevel()).ZhaoCaiMaxNum
end

----------------------------------声望----------------------------------
function Class_Hero:addPrestige(nAddPrestige)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nPrestige = self.tbMasterBase.nPrestige + nAddPrestige
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getPrestige(nAddPrestige)
	local nAddPrestige = nAddPrestige or 0
	return self.tbMasterBase.nPrestige + nAddPrestige
end

function Class_Hero:getPrestigeString(nAddPrestige)
	local nAddPrestige = nAddPrestige or 0
	return self.tbMasterBase.nPrestige + nAddPrestige
end

function Class_Hero:getPrestigeLevel()
	for nPrestigeLevel = 1, #g_PrestigeLevel do
		if self.tbMasterBase.nPrestige <= g_PrestigeLevel[nPrestigeLevel] then
			return nPrestigeLevel
		end
	end
	return #g_PrestigeLevel
end

function Class_Hero:setPrestige(nPrestige)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nPrestige = nPrestige
	g_HeadBar:refreshHeadBar()
end



----------------------------------灵力----------------------------------
function Class_Hero:getEssence(nAddEssence)
	local nAddEssence = nAddEssence or 0
	return self.tbMasterBase.nEssence + nAddEssence
end

function Class_Hero:getEssenceString(nAddEssence)
	local nAddEssence = nAddEssence or 0
	return self.tbMasterBase.nEssence + nAddEssence
end

function Class_Hero:setEssence(nEssence)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nEssence = nEssence
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addEssence(nAddEssence)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nEssence = self.tbMasterBase.nEssence + nAddEssence
	g_HeadBar:refreshHeadBar()
end



----------------------------------阅历----------------------------------
function Class_Hero:addKnowledge(nAddKnowledge)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nKnowlede = self.tbMasterBase.nKnowlede + nAddKnowledge
	g_HeadBar:refreshHeadBar()
end

--更新知识
function Class_Hero:setKnowledge(nKnowlede)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nKnowlede = nKnowlede
	g_HeadBar:refreshHeadBar()
end

--获取知识
function Class_Hero:getKnowledge(nAddKnowledge)
	local nAddKnowledge = nAddKnowledge or 0
	return self.tbMasterBase.nKnowlede + nAddKnowledge
end

--获取知识
function Class_Hero:getKnowledgeString(nAddKnowledge)
	local nAddKnowledge = nAddKnowledge or 0
	return g_ResourceValueFormat(self.tbMasterBase.nKnowlede + nAddKnowledge)
end



----------------------------------天榜排名----------------------------------
function Class_Hero:setRank(nRank)
    self.nRank = nRank
end

function Class_Hero:getRank()
	return self.nRank
end



----------------------------------天榜官阶----------------------------------
function Class_Hero:setOffcialRank(nRank)
    self.nOfficialRank = nRank
end

function Class_Hero:getOffcialRank()
	return self.nOfficialRank
end



----------------------------------香贡----------------------------------
function Class_Hero:getIncense(nAddIncense)
	local nAddIncense = nAddIncense or 0
	return self.tbMasterBase.nIncense + nAddIncense
end


function Class_Hero:getIncenseString(nAddIncense)
	local nAddIncense = nAddIncense or 0
	return self.tbMasterBase.nIncense + nAddIncense
end

function Class_Hero:setIncense(nIncense)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nIncense = nIncense
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addIncense(nAddIncense)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nIncense = self.tbMasterBase.nIncense + nAddIncense
	g_HeadBar:refreshHeadBar()
end



----------------------------------神力----------------------------------
function Class_Hero:getGodPower(nAddGodePower)
	local nAddGodePower = nAddGodePower or 0
	return self.tbMasterBase.nGodPower + nAddGodePower
end

function Class_Hero:getGodPowerString(nAddGodePower)
	local nAddGodePower = nAddGodePower or 0
	return g_ResourceValueFormat(self.tbMasterBase.nGodPower + nAddGodePower)
end

function Class_Hero:setGodPower(nGodPower)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nGodPower = nGodPower
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addGodPower(nAddGodePower)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nGodPower = self.tbMasterBase.nGodPower + nAddGodePower
	g_HeadBar:refreshHeadBar()
end



----------------------------------仙令----------------------------------
function Class_Hero:getXianLing(nAddXianLing)
	local nAddXianLing = nAddXianLing or 0
	return self.tbMasterBase.nXianLing + nAddXianLing
end

function Class_Hero:getXianLingString(nAddXianLing)
	local nAddXianLing = nAddXianLing or 0
	return g_ResourceValueFormat(self.tbMasterBase.nXianLing + nAddXianLing)
end

function Class_Hero:setXianLing(nXianLing)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nXianLing = nXianLing
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addXianLing(nAddXianLing)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nXianLing = self.tbMasterBase.nXianLing + nAddXianLing
	g_HeadBar:refreshHeadBar()
end


----------------------------------神龙令----------------------------------
function Class_Hero:getDragonBall(nAddDragonBall)
	local nAddDragonBall = nAddDragonBall or 0
	return self.tbMasterBase.nDragonBall + nAddDragonBall
end

function Class_Hero:getDragonBallString(nAddDragonBall)
	local nAddDragonBall = nAddDragonBall or 0
	return g_ResourceValueFormat(self.tbMasterBase.nDragonBall + nAddDragonBall)
end


function Class_Hero:setDragonBall(nDragonBall)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nDragonBall = nDragonBall
end

function Class_Hero:addDragonBall(nAddDragonBall)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nDragonBall = self.tbMasterBase.nDragonBall + nAddDragonBall
end

----------------------------------消除技能----------------------------------
local tbIndex = {
	[macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY] = 1,
	[macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE] = 2,
	[macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO] = 3,
	[macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN] = 4,
	[macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO] = 5,
}

function Class_Hero:addXiaoChuSkill(nAddValue, nType)	
	local numValue = g_XianMaiInfoData:getTbXianmaiSkillNum(tbIndex[nType])
	g_XianMaiInfoData:setTbXianmaiSkillNum(tbIndex[nType] ,numValue + nAddValue)
end


function Class_Hero:getXiaoChuSkill(nAddValue, nType)
	local nAddValue = nAddValue or 0

	local numValue = g_XianMaiInfoData:getTbXianmaiSkillNum(tbIndex[nType])
	 
	if nType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then
		return numValue + nAddValue
	elseif nType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then
		return numValue + nAddValue
	elseif nType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then
		return numValue + nAddValue
	elseif nType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then
		return numValue + nAddValue
	elseif nType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then
		return numValue + nAddValue
	end
	
	return nAddValue
end



----------------------------------友情点----------------------------------
function Class_Hero:getFriendPoints(nAddFriendPoints)
	local nAddFriendPoints = nAddFriendPoints or 0
	return self.tbMasterBase.nFriendPoints + nAddFriendPoints
end

function Class_Hero:getFriendPointsString(nAddFriendPoints)
	local nAddFriendPoints = nAddFriendPoints or 0
	return g_ResourceValueFormat(self.tbMasterBase.nFriendPoints + nAddFriendPoints)
end

function Class_Hero:setFriendPoints(nFriendPoints)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nFriendPoints = nFriendPoints
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addFriendPoints(nAddFriendPoints)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nFriendPoints = self.tbMasterBase.nFriendPoints + nAddFriendPoints
	g_HeadBar:refreshHeadBar()
end

-- 初始化爱心赠送数据
function Class_Hero:initSendFriendPointsStatus(tbMsg)
	self:setSendFriendPointsStatus(tbMsg)
end

-- 初始化爱心获取数据
function Class_Hero:initReceiveFriendPointsStatus(tbMsg)
	for i,v in ipairs(tbMsg)do
		self:setReceiveFriendPointsStatusByUin(v.sender_uin, v.gain_flag)
	end
end

-- 好友友情点收取数据
function Class_Hero:getReceiveFriendPointsStatus()
	self.tbReceiveFriendPointsStatus = self.tbReceiveFriendPointsStatus or {}
	return self.tbReceiveFriendPointsStatus
end

function Class_Hero:getReceiveFriendPointsStatusByUin(uin)
	self.tbReceiveFriendPointsStatus = self.tbReceiveFriendPointsStatus or {}
	return self.tbReceiveFriendPointsStatus[uin]
end

function Class_Hero:setReceiveFriendPointsStatusByUin(uin, tag)
	self.tbReceiveFriendPointsStatus = self.tbReceiveFriendPointsStatus or {}
	if tag == macro_pb.FriendHeartRecvState_CanRecv and ( self.tbReceiveFriendPointsStatus[uin] ~= macro_pb.FriendHeartRecvState_CanRecv ) then
		g_Hero:setBubbleNotify("heart", g_Hero:getBubbleNotify("heart") + 1)
	end
	self.tbReceiveFriendPointsStatus[uin] = tag
	return self.tbReceiveFriendPointsStatus[uin]
end

function Class_Hero:setReceiveFriendPointsStatus(tbMsg)
	self.tbReceiveFriendPointsStatus = self.tbReceiveFriendPointsStatus or {}
	for i,v in ipairs(tbMsg)do
		self.tbReceiveFriendPointsStatus[v] = 1
	end
	g_Hero:setBubbleNotify("heart", g_Hero:getBubbleNotify("heart") - #tbMsg)
	return self.tbReceiveFriendPointsStatus
end

--好友友情点赠送数据
function Class_Hero:getSendFriendPointsStatus()
	self.tbSendFriendPointsStatus = self.tbSendFriendPointsStatus or {}
	return self.tbSendFriendPointsStatus
end

function Class_Hero:getSendFriendPointsStatusByUin(uin)
	self.tbSendFriendPointsStatus = self.tbSendFriendPointsStatus or {}
	return self.tbSendFriendPointsStatus[uin]
end

function Class_Hero:setSendFriendPointsStatus(tbMsg)
	self.tbSendFriendPointsStatus = self.tbSendFriendPointsStatus or {}
	if not tbMsg then
		cclog("====tbMsg is nil===")
		return
	end
	for i,v in ipairs(tbMsg)do
		self.tbSendFriendPointsStatus[v] = 1
	end
	return self.tbSendFriendPointsStatus
end

--当删除好友，或者被好友删除事更新数据
function Class_Hero:OnFriendDelete(uin)
    --接收数据相关
    self.tbReceiveFriendPointsStatus = self.tbReceiveFriendPointsStatus or {}
    if self.tbReceiveFriendPointsStatus[uin] ~= nil and self.tbReceiveFriendPointsStatus[uin] == macro_pb.FriendHeartRecvState_CanRecv then
        g_Hero:setBubbleNotify("heart", g_Hero:getBubbleNotify("heart") - 1)
    end
    self.tbReceiveFriendPointsStatus[uin] = nil

    --发送数据相关
    self.tbSendFriendPointsStatus = self.tbSendFriendPointsStatus or {}
    self.tbReceiveFriendPointsStatus[uin] = nil

end

----------------------------------天榜挑战次数----------------------------------
function Class_Hero:getArenaTimes(nAddArenaTimes)
	local nAddArenaTimes = nAddArenaTimes or 0
	-- local types = VipType.VipBuyOpType_ArenaChallegeTimes
	return self.tbMasterBase.nArenaTimes + nAddArenaTimes
end

function Class_Hero:getArenaTimesString(nAddArenaTimes)
	local nAddArenaTimes = nAddArenaTimes or 0
	
		
	-- local types = VipType.VipBuyOpType_ArenaChallegeTimes
	-- local addNum = g_VIPBase:getAddTableByNum(types)
	
	local num = self.tbMasterBase.nArenaTimes + nAddArenaTimes
	
	return g_ResourceValueFormat(num)
end

function Class_Hero:setArenaTimes(nArenaTimes)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nArenaTimes = nArenaTimes
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addArenaTimes(nAddArenaTimes)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nArenaTimes = self.tbMasterBase.nArenaTimes + nAddArenaTimes
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:getBuyArenaTimes()
	return self.nBuyArenaTimes
end

function Class_Hero:setBuyArenaTimes(nBuyArenaTimes)
	self.nBuyArenaTimes = nBuyArenaTimes
	g_HeadBar:refreshHeadBar()
end



----------------------------------七天登陆----------------------------------
function Class_Hero:getContinuousLoginDate()
	return self.nContinuousLoginDate
end

function Class_Hero:setContinuousLoginDate(_login)
	self.nContinuousLoginDate = _login
	return self.nContinuousLoginDate
end



----------------------------------背包上限----------------------------------
function Class_Hero:getMaxFateNum()
	local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", self:getMasterCardLevel())
	return g_VIPBase:getVipValue("MaterialMaxNum") + self.tbExtraSpace[macro_pb.ITEM_TYPE_FATE]
end

function Class_Hero:getMaxEquipNum()
	local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", self:getMasterCardLevel())
	return g_VIPBase:getVipValue("EquipMaxNum") + self.tbExtraSpace[macro_pb.ITEM_TYPE_EQUIP]
end

function Class_Hero:getMaxCardNum()
	return g_VIPBase:getVipValue("CardMaxNum") + self.tbExtraSpace[macro_pb.ITEM_TYPE_CARD]
end

----------------------------------将魂石----------------------------------
function Class_Hero:getJiangHunShi(nAddJiangHunShi)
	local nAddJiangHunShi = nAddJiangHunShi or 0
	return self.tbMasterBase.nJiangHunShi + nAddJiangHunShi
end

function Class_Hero:getJiangHunShiString(nAddJiangHunShi)
	local nAddJiangHunShi = nAddJiangHunShi or 0
	return g_ResourceValueFormat(self.tbMasterBase.nJiangHunShi + nAddJiangHunShi)
end

function Class_Hero:setJiangHunShi(nJiangHunShi)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nJiangHunShi = nJiangHunShi
	g_HeadBar:refreshHeadBar()
end

function Class_Hero:addJiangHunShi(nAddJiangHunShi)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nJiangHunShi = self.tbMasterBase.nJiangHunShi + nAddJiangHunShi
	g_HeadBar:refreshHeadBar()
end

----------------------------------刷新令----------------------------------
function Class_Hero:getRefreshToken(nAddRefreshToken)
	local nAddRefreshToken = nAddRefreshToken or 0
	return self.tbMasterBase.nRefreshToken + nAddRefreshToken
end

function Class_Hero:getRefreshTokenString(nAddRefreshToken)
	local nAddRefreshToken = nAddRefreshToken or 0
	return g_ResourceValueFormat(self.tbMasterBase.nRefreshToken + nAddRefreshToken)
end

function Class_Hero:setRefreshToken(nRefreshToken)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nRefreshToken = nRefreshToken
    g_HeadBar:refreshHeadBar()
end

function Class_Hero:addRefreshToken(nAddRefreshToken)
	if not self.tbMasterBase then return end
	self.tbMasterBase.nRefreshToken = self.tbMasterBase.nRefreshToken + nAddRefreshToken
    g_HeadBar:refreshHeadBar()
end

