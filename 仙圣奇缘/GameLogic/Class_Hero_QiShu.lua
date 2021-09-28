--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

--初始化奇术
function Class_Hero:initQiShu(tbMasterMsg)
	--布阵列表
    local tbArrayInfo = tbMasterMsg.arrayinfo -- 6 7 8 代表替补
	self.tbCardBattleList = {}
	for nIndex = 1, #tbArrayInfo do
		local tbArrayInfoNode = tbArrayInfo[nIndex]
        self.tbCardBattleList[nIndex] = {nPosIdx = tbArrayInfoNode.posidx, nServerID = tbArrayInfoNode.cardid}
		local nCardID = self.tbCardBattleList[nIndex].nServerID
		local GameObj_Card = self.CardList[nCardID]
		if GameObj_Card then
			GameObj_Card:setBattleIndex(nIndex)
		end
	end

	--阵法列表
	local tbZhenFaMsg = tbMasterMsg.array_method_info
	self.tbZhenFaList = {}
	
    for nZhenFaCsvID = 1, #tbZhenFaMsg do
		self.tbZhenFaList[nZhenFaCsvID] = {}
		self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel = tbZhenFaMsg[nZhenFaCsvID].array_lv
		self.tbZhenFaList[nZhenFaCsvID].tbCsvBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhenfa", nZhenFaCsvID, 1)
	end
	
    self:setCurrentZhenFaCsvID(tbMasterMsg.cur_method_id + 1)
	
	--心法
    self.tbXinFaList = {}
    for nXinFaCsvID = 1, #tbMasterMsg.secret_lvlist do
		self.tbXinFaList[nXinFaCsvID] = {}
		self.tbXinFaList[nXinFaCsvID].nXinFaLevel = tbMasterMsg.secret_lvlist[nXinFaCsvID]
		self.tbXinFaList[nXinFaCsvID].tbCsvBase = g_DataMgr:getCsvConfigByOneKey("QiShuSkill", nXinFaCsvID)
		cclog("========心法等级=========="..self.tbXinFaList[nXinFaCsvID].nXinFaLevel)
    end
	self:setCurZhanShuCsvID(tbMasterMsg.tactics_idx)
-- cclog("=================================初始化 1")
-- cclog("==========消息体失败========"..tostring(tbMasterMsg));
-- echoj(" ===============Class_Hero:initQiShu=================", tbMasterMsg)
-- cclog("=================================初始化 2")
		--战术
	self.tbZhanShuList = {}
	if tbMasterMsg.tactics then
		for nZhanShuCsvID = 1, #tbMasterMsg.tactics do
			self.tbZhanShuList[nZhanShuCsvID] = {}
			self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList = {}
			for nZhenXinCsvID = 1, #tbMasterMsg.tactics[nZhanShuCsvID].heart_lv do
				self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID] = {}
				self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].nZhenXinLevel = tbMasterMsg.tactics[nZhanShuCsvID].heart_lv[nZhenXinCsvID]
				self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu", nZhanShuCsvID, nZhenXinCsvID)
			end	
    	end
	end
	
end

--获取阵法等级
function Class_Hero:getZhenFaLevel(nZhenFaCsvID)
	return self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel
end

--获取阵法策划配置
function Class_Hero:getZhenFaCsvBase(nZhenFaCsvID)
	return self.tbZhenFaList[nZhenFaCsvID].tbCsvBase
end

--获取阵法数量
function Class_Hero:getZhenFaListCount()
	return #self.tbZhenFaList
end

--设置阵法等级
function Class_Hero:setZhenFaLevel(nZhenFaCsvID, nLevel)
	self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel = nLevel
end

--获取阵法的属性值
function Class_Hero:getZhenFaPropValue(nZhenFaCsvID)
	local tbCsvBase = self.tbZhenFaList[nZhenFaCsvID].tbCsvBase
	return tbCsvBase.ZhenFaPropBase+(self:getZhenFaLevel(nZhenFaCsvID)-1)*tbCsvBase.ZhenFaPropGrowth
end

--获取阵法的属性值字符串
function Class_Hero:getZhenFaPropString(nZhenFaCsvID)
	local tbCsvBase = self.tbZhenFaList[nZhenFaCsvID].tbCsvBase
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(tbCsvBase.ZhenFaPropID)
	if bIsPercent then 
		return g_PropName[tbCsvBase.ZhenFaPropID].."+"..string.format("%.2f", self:getZhenFaPropValue(nZhenFaCsvID, tbCsvBase)/100).."%"
	else
		return g_PropName[tbCsvBase.ZhenFaPropID].."+"..self:getZhenFaPropValue(nZhenFaCsvID, tbCsvBase)
	end
end

--获取阵法的每级增加属性
function Class_Hero:getZhenFaPropGrow(nZhenFaCsvID)
	local tbCsvBase = self.tbZhenFaList[nZhenFaCsvID].tbCsvBase
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(tbCsvBase.ZhenFaPropID)
	if bIsPercent then 
		return _T("每级")..g_PropName[tbCsvBase.ZhenFaPropID].."+"..tbCsvBase.ZhenFaPropGrowth
	else
		return _T("每级")..g_PropName[tbCsvBase.ZhenFaPropID].."+"..tbCsvBase.ZhenFaPropGrowth
	end
end

--获取阵法升级所需的阅历
function Class_Hero:getZhenFaNeedKnowledge(nZhenFaCsvID)
	local CSV_QiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost", self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel)
	return math.ceil( CSV_QiShuUpgradeCost.ZhenFaCost*self.tbZhenFaList[nZhenFaCsvID].tbCsvBase.ZhenFaCostFactor/g_BasePercent )
end

--检查阵法解锁
function Class_Hero:checkZhenFaRelease(nZhenFaCsvID)
	local tbCsvBase = self.tbZhenFaList[nZhenFaCsvID].tbCsvBase
	if tbCsvBase.OpenLevel > self:getMasterCardLevel() then --未解锁
		return false
	end
	return true
end

--检查阵法消耗
function Class_Hero:checkZhenFaCost(nZhenFaCsvID)
	local nNeedKnowledge = self:getZhenFaNeedKnowledge(nZhenFaCsvID)
	if nNeedKnowledge > self.tbMasterBase.nKnowlede then --阅历不够
		return false
	end
	return true
end

--检查阵法等级
function Class_Hero:checkZhenFaLevel(nZhenFaCsvID)
	local nZhenFaLevel = self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel
	if nZhenFaLevel < self:getMasterCardLevel() then --等级到上限
		return true
	end
	return false
end

--不能大于主角等级
function Class_Hero:checkZhenFaLevelByMasterLevel(nZhenFaCsvID)
	local nZhenFaLevel = self.tbZhenFaList[nZhenFaCsvID].nZhenFaLevel
	if nZhenFaLevel < g_Hero:getMasterCardLevel() then 
		return true
	end
	return false
end

--检查阵法的状态
function Class_Hero:checkZhenFaEnable(nZhenFaCsvID)
	if not self:checkZhenFaRelease(nZhenFaCsvID) then --未解锁
		return 1
	end
	if not self:checkZhenFaCost(nZhenFaCsvID) then --阅历不够
		return 2
	end
	if not self:checkZhenFaLevel(nZhenFaCsvID) then --等级到上限
		return 3
	end
	return 4 --符合条件
end

--获得当前激活阵法的配置ID
function Class_Hero:getCurrentZhenFaCsvID()
	return self.nCurZhenFaCsvID
end

--设置当前激活的阵法
function Class_Hero:setCurrentZhenFaCsvID(nCurZhenFaCsvID)
	self.nCurZhenFaCsvID = nCurZhenFaCsvID
end

--获取当前激活阵法的阵心配置
function Class_Hero:getCurrentZhenFaCsvByIndex(nZhenXinCsvID)
	return g_DataMgr:getQiShuZhenfaCsv(self.nCurZhenFaCsvID, nZhenXinCsvID)
end

--根据传入的阵法检查是否已激活
function Class_Hero:checkZhenFaIsActivate(nZhenFaCsvID)
	return self.nCurZhenFaCsvID == nZhenFaCsvID
end

--更新玩家阵法的属性
function Class_Hero:updateZhenFaProp(nZhenFaCsvID)
	if self.nCurZhenFaCsvID == nZhenFaCsvID then
		g_Hero:refreshTeamMemberAddProps()
	end
end

--根据九宫格布阵获取阵心的Index
function Class_Hero:getCurZhenFaIndex(nPos)
    if nPos >  9 then return nPos - 10 + 6 end

    local tbZhenFa = g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa", self.nCurZhenFaCsvID)
    for i=1, #tbZhenFa do
        if tbZhenFa[i].BuZhenPosIndex == nPos then
            return tbZhenFa[i].ZhenXinID
        end
    end
end

--根据心法配置ID获取心法的等级
function Class_Hero:getXinFaLevel(nXinFaCsvID)
    return self.tbXinFaList[nXinFaCsvID].nXinFaLevel
end

--根据心法配置ID获取心法的配置
function Class_Hero:getXinFaCsvBase(nXinFaCsvID)
    return self.tbXinFaList[nXinFaCsvID].tbCsvBase
end

--根据心法配置ID获取心法的配置
function Class_Hero:getXinFaListCount()
    return #self.tbXinFaList
end

--根据心法配置ID更新心法的等级
function Class_Hero:updateXinFaLevel(nXinFaCsvID, nXinFaLevel)
	 self.tbXinFaList[nXinFaCsvID].nXinFaLevel = nXinFaLevel
end

--获取心法的属性值
function Class_Hero:getXinFaPropValue(nXinFaCsvID)
	local tbCsvBase = self.tbXinFaList[nXinFaCsvID].tbCsvBase
	return tbCsvBase.PropBase+(self:getXinFaLevel(nXinFaCsvID)-1)*tbCsvBase.PropGrowth
end

--获取心法的属性值字符串
function Class_Hero:getXinFaPropString(nXinFaCsvID)
	local tbCsvBase = self.tbXinFaList[nXinFaCsvID].tbCsvBase
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(tbCsvBase.PropID)
	if bIsPercent then 
		return g_PropName[tbCsvBase.PropID].."+"..self:getXinFaPropValue(nXinFaCsvID)
	else
		return g_PropName[tbCsvBase.PropID].."+"..self:getXinFaPropValue(nXinFaCsvID)
	end
end

--获取心法的每级增加属性
function Class_Hero:getXinFaPropGrow(nXinFaCsvID)
	local tbCsvBase = self.tbXinFaList[nXinFaCsvID].tbCsvBase
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(tbCsvBase.PropID)
	if bIsPercent then 
		return _T("每级")..g_PropName[tbCsvBase.PropID].."+"..tbCsvBase.PropGrowth
	else
		return _T("每级")..g_PropName[tbCsvBase.PropID].."+"..tbCsvBase.PropGrowth
	end
end

local XinFaType = {
	Type_A = 1,--
	Type_B = 2,
}
--获取心法升级所需的阅历
function Class_Hero:getXinFaNeedKnowledge(nXinFaCsvID)
	local CSV_QiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost", self.tbXinFaList[nXinFaCsvID].nXinFaLevel)
	local types =  self.tbXinFaList[nXinFaCsvID].tbCsvBase.Type 
	if types == XinFaType.Type_A then 
		return math.ceil( (CSV_QiShuUpgradeCost.XinFaA * self.tbXinFaList[nXinFaCsvID].tbCsvBase.CostFactorA) / g_BasePercent)
	else
		return math.ceil( (CSV_QiShuUpgradeCost.XinFaB * self.tbXinFaList[nXinFaCsvID].tbCsvBase.CostFactorB) / g_BasePercent)
	end
end

--检查心法解锁
function Class_Hero:checkXinFaRelease(nXinFaCsvID)
	local tbCsvBase = self.tbXinFaList[nXinFaCsvID].tbCsvBase
	if tbCsvBase.OpenLevel > self:getMasterCardLevel() then --未解锁
		return false
	end
	return true
end

--检查心法消耗
function Class_Hero:checkXinFaCost(nXinFaCsvID)
	local nNeedKnowledge = self:getXinFaNeedKnowledge(nXinFaCsvID)
	if nNeedKnowledge > self.tbMasterBase.nKnowlede then --阅历不够
		return false
	end
	return true
end

--检查心法等级
function Class_Hero:checkXinFaLevel(nXinFaCsvID)
	local nXinFaLevel = self.tbXinFaList[nXinFaCsvID].nXinFaLevel
	if nXinFaLevel < self:getMasterCardLevel() then --等级到上限
		return true
	end
	return false
end
local xinFaEnadleType= {
	NOT_UN = 1,		--未解锁
	NOT_COST = 2,	--阅历不够
	NOT_LEVEL = 3,	--等级到上限
	SUCCEED = 4,	--符合条件
}
--检查心法的状态
function Class_Hero:checkXinFaEnable(nXinFaCsvID)
	if not self:checkXinFaRelease(nXinFaCsvID) then 
		return xinFaEnadleType.NOT_UN
	end
	if not self:checkXinFaCost(nXinFaCsvID) then 
		return xinFaEnadleType.NOT_COST
	end
	if not self:checkXinFaLevel(nXinFaCsvID) then 
		return xinFaEnadleType.NOT_LEVEL
	end
	return xinFaEnadleType.SUCCEED
end

--更新玩家阵法的属性
function Class_Hero:updateXinFaProp()
	g_Hero:refreshTeamMemberAddProps()
end

--获取战术阵心升级所需的阅历
function Class_Hero:getZhanShuZhenXinNeedKnowledge(nZhanShuCsvID, nZhenXinCsvID)
	local CSV_QiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost", self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].nZhenXinLevel)
	return math.ceil( CSV_QiShuUpgradeCost.ZhenXinCost*self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase.ZhenXinCostFactor/g_BasePercent )
end

--检查战术解锁
function Class_Hero:checkZhanShuRelease(nZhanShuCsvID)
	local tbCsvBase =  g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu", nZhanShuCsvID, 1)
	if tbCsvBase.OpenLevel > self:getMasterCardLevel() then --未解锁
		return false
	end
	return true
end

--检查战术阵心消耗
function Class_Hero:checkZhanShuZhenXinCost(nZhanShuCsvID, nZhenXinCsvID)
	local nNeedKnowledge = self:getZhanShuZhenXinNeedKnowledge(nZhanShuCsvID, nZhenXinCsvID)
	if nNeedKnowledge > self.tbMasterBase.nKnowlede then --阅历不够
		return false
	end
	return true
end

--检查战术阵心等级
function Class_Hero:checkZhanShuZhenXinLevel(nZhanShuCsvID, nZhenXinCsvID)
	local nZhenXinLevel = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].nZhenXinLevel or 1
	if nZhenXinLevel < self:getMasterCardLevel() then --等级到上限
		return true
	end
	return false
end

--检查战术的状态
function Class_Hero:checkZhanShuEnable(nZhanShuCsvID)
	if not self:checkZhanShuRelease(nZhanShuCsvID) then --未解锁
		return 1
	end
	if not self:checkZhenFaLevelByMasterLevel(nZhenFaCsvID) then 
		return -1
	end
	return 2 --符合条件
end

--设置当前激活的战术CsvID
function Class_Hero:setCurZhanShuCsvID(nZhanShuCsvID)
	self.nCurZhanShuCsvID = nZhanShuCsvID
	return self.nCurZhanShuCsvID
end

--获取当前激活的战术CsvID
function Class_Hero:getCurZhanShuCsvID()
	return self.nCurZhanShuCsvID
end

--获取战术数量
function Class_Hero:getZhanShuListCount()
	return #self.tbZhanShuList
end

--获取当前激活阵法的阵心配置
function Class_Hero:getCurrentZhanShuCsvByIndex(nZhenXinCsvID)
	return self.tbZhanShuList[self.nCurZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
end

--设置战术阵心等级
function Class_Hero:setZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID, nZhenXinLevel)
	if not self.tbZhanShuList[nZhanShuCsvID] then
		self.tbZhanShuList[nZhanShuCsvID] = {}
	end
	if not self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList then
		self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList = {}
	end
	self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].nZhenXinLevel = nZhenXinLevel  
end

function Class_Hero:getZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID)
	return self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].nZhenXinLevel or 1
end

--更新玩家阵法的属性
function Class_Hero:updateZhenXinProp(nZhanShuCsvID)
	if self.nCurZhanShuCsvID == nZhanShuCsvID then
		g_Hero:refreshTeamMemberAddProps()
	end
end

--获取阵心的属性值1
function Class_Hero:getZhenXinPropValue1(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	return tbCsvBase.ZhenXinPropBase1+(self:getZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID)-1)*tbCsvBase.ZhenXinPropGrowth1
end

--获取阵心的属性值2
function Class_Hero:getZhenXinPropValue2(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	return tbCsvBase.ZhenXinPropBase2+(self:getZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID)-1)*tbCsvBase.ZhenXinPropGrowth2
end

--获取心法的属性值字符串
function Class_Hero:getZhenXinPropString(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	local bIsPercent, nBasePercent = g_CheckPropIsPercent(tbCsvBase.ZhenXinPropID1)
	if bIsPercent then
		return g_PropName[tbCsvBase.ZhenXinPropID1].." +"..string.format("%.2f", self:getZhenXinPropValue1(nZhanShuCsvID, nZhenXinCsvID)/100).."%"
	else
		return g_PropName[tbCsvBase.ZhenXinPropID1].." +"..self:getZhenXinPropValue1(nZhanShuCsvID, nZhenXinCsvID)
	end
end

--获取阵心的属性值1
function Class_Hero:getZhenXinPropValueNextLv1(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	return tbCsvBase.ZhenXinPropBase1+(self:getZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID)-1 + 1)*tbCsvBase.ZhenXinPropGrowth1
end

--获取阵心的属性值2
function Class_Hero:getZhenXinPropValueNextLv2(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	return tbCsvBase.ZhenXinPropBase2+(self:getZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinCsvID)-1 + 1)*tbCsvBase.ZhenXinPropGrowth2
end


--获取心法的属性值字符串
function Class_Hero:getZhenXinPropStringNextLv(nZhanShuCsvID, nZhenXinCsvID)
	local tbCsvBase = self.tbZhanShuList[nZhanShuCsvID].tbZhenXinLevelList[nZhenXinCsvID].tbCsvBase
	local bIsPercent, nBasePercent = g_CheckPropIsPercent(tbCsvBase.ZhenXinPropID1)
	if bIsPercent then
		return g_PropName[tbCsvBase.ZhenXinPropID1].." +"..string.format("%.2f", self:getZhenXinPropValueNextLv1(nZhanShuCsvID, nZhenXinCsvID)/100).."%"
	else
		return g_PropName[tbCsvBase.ZhenXinPropID1].." +"..self:getZhenXinPropValueNextLv1(nZhanShuCsvID, nZhenXinCsvID)
	end
end


