--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	装备
-- 应  用:
---------------------------------------------------------------------------------------

--创建Class_Card类
Class_Card = class("Class_Card",  function() return Class_GameObj:new() end)
Class_Card.__index = Class_Card

function Class_Card:ctor()
	self.fight_point = 0									--战力
	self.preattack = 0
	self.nBattleIndex = 0						--出战列表Index
end

--初始化伙伴数据数据
function Class_Card:initCardData(tbCard)
	
	self.nServerID = tbCard.cardid					--伙伴id
	self.nCsvID = tbCard.configid				--伙伴的配置id
	self.nLevel = tbCard.cardlv					--等级
	self.nExp = tbCard.cardexp					--经验


	self.nEvoluteLevel = tbCard.breachlv or 1	--进化等级
	self.nRealmLevel = tbCard.relamlv or 0			--境界等级
	self.nRealmExp = tbCard.relamexp			--境界经验
	self.nStarLevel = tbCard.star_lv			--星等级
	self.tbCsvBase = g_DataMgr:getCardBaseCsv(self.nCsvID, self.nStarLevel)
	self.tbCsvCardRealmLevel = g_DataMgr:getCardRealmLevelCsv(self.nRealmLevel)
	self.tbCsvCardEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self.nEvoluteLevel)
	self.tbFateIdList = {0,0,0,0,0,0,0,0}			--装备异兽信息
	self.tbFatePosIndexInType = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	--根据类型存储对应类型的插槽PosIndex
	self.tbSkillLevel = {0, 0, 0}				--技能等级
	
	local burnInceneseInfo = tbCard.burn_incense_info
	self:shangXingAddData(burnInceneseInfo)
	
	local tbFateIdList = tbCard.fate_idlst
	if(tbFateIdList)then
		for nPosIndex = 1, #tbFateIdList do
			local nFateID = tbFateIdList[nPosIndex]
			if nPosIndex > #self.tbFateIdList then break end
			self.tbFateIdList[nPosIndex] = nFateID
			if nFateID > 0 then
				local tbFateInfo = g_Hero:getFateInfoByID(nFateID)
				if tbFateInfo then
					tbFateInfo:setOwnerID(self.nServerID)
					self.tbFatePosIndexInType[tbFateInfo:getCardFateCsv().Type] = nPosIndex
				end
			end
		end
	end


	local tbSkillLevel = tbCard.skill_lv_list
		if(tbSkillLevel)then
		for i =1, #tbSkillLevel do
			self.tbSkillLevel[i] = tbSkillLevel[i]
		end
	end

	local tbDanyaoLv = tbCard.danyao_lv_list --丹药
	self.tbDanyaoLvList = {
		[1]={0,0,0},[2]={0,0,0},[3]={0,0,0}
	}

	if tbDanyaoLv then
		for i=1, 3 do
			for j=1, 3 do
				local key = ((i-1)*3) + j
				self.tbDanyaoLvList[i][j] = tbDanyaoLv[key] or 0
			end
		end
	end

	self.tbEquipIdList = {0,0,0,0,0,0}				--装备上的装备id
	local tbEquip = tbCard.equip_idlst
	if(tbEquip)then
		for i =1, #tbEquip do
			local nEquipID = tbEquip[i]
			self.tbEquipIdList[i] = nEquipID
		end
	end

    self.groupCombination = {}
    self.groupCsv = {}
	local t = {}
    for groupIndx = 1, 4 do
	    local nCardGroupCsvID = self.tbCsvBase["CardGroupID"..groupIndx]
	    if nCardGroupCsvID > 0 then
            table.insert( self.groupCsv,nCardGroupCsvID)
		    local CSV_CardGroup = g_DataMgr:getCsvConfigByOneKey("CardGroup", nCardGroupCsvID)
	        t = {}
	        for i = 1, 5 do
		        local cardId = CSV_CardGroup["CardID"..i]
		        if cardId ~= 0 then 
                    table.insert(t, cardId)
		        end
	        end
            table.insert(self.groupCombination, t)
        end
    end


    g_Hero.cardGroupList[self.tbCsvBase.ID] = self

	self:initCardPropAll()

	return self.nServerID
end

--初始化掉落伙伴数据数据
function Class_Card:initCardDataDrop(nServerID, nCsvID, nStarLevel, nLevel, nEvoluteLevel)
	self.nServerID = nServerID								--伙伴id
	self.nCsvID = nCsvID						--伙伴的配置id
	self.nLevel = nLevel						--等级
	self.nExp = 0								--经验

	if self.nLevel > 1 then
		local nExp = g_DataMgr:getCardExpCsvExpMax(self.nLevel - 1,false) + 1
		self.nExp = nExp or 0
	end
    if nEvoluteLevel or nEvoluteLevel == 0 then 
        nEvoluteLevel = 1
    end
	self.nEvoluteLevel = nEvoluteLevel 		--进化等级
	
	self.nRealmLevel = 0						--境界等级
	self.nRealmExp = 0							--境界经验
	self.nStarLevel = nStarLevel				--星级等级
	self.tbCsvBase = g_DataMgr:getCardBaseCsv(self.nCsvID, self.nStarLevel)
	self.tbCsvCardRealmLevel = g_DataMgr:getCardRealmLevelCsv(self.nRealmLevel)
	self.tbCsvCardEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self.nEvoluteLevel)
	self.tbFateIdList = {0,0,0,0,0,0,0,0}			--装备的异兽信息
	self.tbFatePosIndexInType = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	--每个类型异兽的数量统计
	self.tbEquipIdList = {0,0,0,0,0, 0}				--装备上的装备id
	self.tbSkillLevel = {0, 0, 0}				--技能等级

	self.restCardBatte = {}

	--丹药
	self.tbDanyaoLvList = {
		[1]={0,0,0},[2]={0,0,0},[3]={0,0,0}
	}
	
	local burn_incense_info = {
	 ["incense_lv"] = 1,
        ["cur_prop_value"]=  {0,0,0,0,0,0,0,},
        ["accu_prop_value"]=  {0,0,0,0,0,0,0,},	
	}
	
	self:shangXingAddData(burn_incense_info)
	

    self.groupCombination = {}
    self.groupCsv = {}
	local t = {}
    for groupIndx = 1, 4 do
	    local nCardGroupCsvID = self.tbCsvBase["CardGroupID"..groupIndx]
	    if nCardGroupCsvID > 0 then
                 table.insert( self.groupCsv,nCardGroupCsvID)
		    local CSV_CardGroup = g_DataMgr:getCsvConfigByOneKey("CardGroup", nCardGroupCsvID)
	        --每一个组合最多5个
            t = {}
	        for i = 1, 5 do
		        local cardId = CSV_CardGroup["CardID"..i]
		        if cardId ~= 0 then 
                     table.insert(t, cardId)
		        end
	        end
            table.insert(self.groupCombination, t)
        end
    end

    g_Hero.cardGroupList[self.tbCsvBase.ID] = self


	--掉落的时候需要重新计算
	self:initCardPropAll()
end

--获取伙伴的唯一ID
function Class_Card:getServerId()
	return self.nServerID
end

--获取当前的星级的CardBase配置
function Class_Card:getCsvBase()
	return self.tbCsvBase
end

function Class_Card:setCsvBase(csvBase)
	self.tbCsvBase = csvBase
end
--获取伙伴的等级
function Class_Card:getLevel()
	return self.nLevel
end

--获取伙伴的等级并设置颜色
function Class_Card:getLevelString(Label_Level)
	if Label_Level then
		g_SetCardNameColorByEvoluteLev(Label_Level, self:getEvoluteLevel())
	end
	return _T("Lv.")..self.nLevel
end

--获取伙伴最大等级
function Class_Card:getMaxLevel()
	if self:checkIsLeader() then
		return g_DataMgr:getGlobalCfgCsv("max_card_lev")
	else
		return g_Hero:getMasterCardLevel()
	end
end

--通过增加的经验计算新的等级预览
function Class_Card:getNewLvByAddExp(nAddExp)
	local nMaxCardLevel = self:getMaxLevel()
	local nNewLevel = self:getLevel()
	local nNewExp = self:getExp() + nAddExp
	for nLevel = nNewLevel, nMaxCardLevel do
		local nExpMax = g_DataMgr:getCardExpCsvExpMax(nLevel, self:checkIsLeader())
		if nNewExp > nExpMax then
			nNewLevel = nLevel + 1
			if nNewLevel >= nMaxCardLevel then --不能超过最大等级
				nNewLevel = nMaxCardLevel
				break
			end
		else
			break
		end
	end
	return nNewLevel
end

--设置伙伴的等级
function Class_Card:setLevel(nLevel)
	self.nLevel = math.min(nLevel, self:getMaxLevel())
	self:reCalculateLevelProps()
end

--获取伙伴经验
function Class_Card:getExp()
	return self.nExp
end

--获取伙伴当前最大经验
function Class_Card:getMaxExp()
	return g_DataMgr:getCardExpCsvExpMax(self.nLevel, self:checkIsLeader())
end

function Class_Card:getCurExpInNewLevByAddExp(nAddExp)
	local nNewLevel = self:getNewLvByAddExp(nAddExp)
	return self.nExp + nAddExp - g_DataMgr:getCardExpCsvExpMax(nNewLevel -1, self:checkIsLeader())
end

function Class_Card:getFullExpInNewLevByAddExp(nAddExp)
	local nNewLevel = self:getNewLvByAddExp(nAddExp)
	return g_DataMgr:getCardExpCsvExpMax(nNewLevel, self:checkIsLeader()) - g_DataMgr:getCardExpCsvExpMax(nNewLevel -1, self:checkIsLeader())
end

--获取伙伴上一等级最大经验
function Class_Card:getMaxExpLastLev()
	return g_DataMgr:getCardExpCsvExpMax(self.nLevel - 1, self:checkIsLeader()) or 0
end

--获取伙伴满级最大经验
function Class_Card:getMaxLevMaxExp()
	return g_DataMgr:getCardExpCsvExpMax(self:getMaxLevel(), self:checkIsLeader())
end

--设置伙伴经验
function Class_Card:setExp(nExp)
	--经验上限, 主角为表的上限, 一般卡牌为主角等级对应的经验上限
	local nExpMax = self:getMaxLevMaxExp()
	-- cclog("============设置经验nExp============="..nExp)
	-- cclog("============设置经验nExpMax============="..nExpMax)
	self.nExp = math.min(nExp, nExpMax)
end

--增加经验让伙伴升级
function Class_Card:addExp(nAddExp)
	local nNewlevel = self:getNewLvByAddExp(nAddExp)
	self:setLevel(nNewlevel)
	local nNewExp = self.nExp + nAddExp
	self:setExp(nNewExp)
end

--增加经验让伙伴升级带主角卡升级事件
function Class_Card:addExpWithHeroEvent(nAddExp, nMasterCardLevel, nMasterCardExp)
	
	local nNewlevel = 0
	if nMasterCardLevel and nMasterCardLevel > 0 then
		nNewlevel = nMasterCardLevel
	else
		nNewlevel = self:getNewLvByAddExp(nAddExp)
	end
	
	if nNewlevel > self.nLevel then
		local nOldLevel = self.nLevel
		gTalkingData:SetLevel(nNewlevel)
		self:setLevel(nNewlevel)
		g_Hero:onLevelUpEvent(nNewlevel)
		g_Hero:showLevelUpAnimation(nOldLevel, true, nNewlevel)

		if CGamePlatform:SharedInstance().submitExtendDataEx then -- G_SubmitData then
			cclog("============玩家升级=============")
			local uid = g_MsgMgr:getZoneUin()
			local ilv = nNewlevel
			local accname = g_Hero:getMasterName()
			local servername = g_ServerList:GetLocalName()

	    	local nyuanbao = 100
	    	if g_Hero then
	    		nyuanbao = g_Hero:getYuanBao()
	    	end 
	    	local accname_new = ""
            if macro_pb.LOGIN_PLATFORM_UC == g_GamePlatformSystem:GetServerPlatformType() then
                local cur_time_server = g_GetServerTime()
                accname_new = accname.."&"..cur_time_server
            end
	    	CGamePlatform:SharedInstance():submitExtendDataEx(uid, accname_new, ilv, servername, nyuanbao, g_ServerList:GetLocalServerID(), 5)
	    end
	else
		local nOldLevel = self.nLevel
		g_Hero:showLevelUpAnimation(nOldLevel, false, nNewlevel)
	end
	
	if nMasterCardExp and nMasterCardExp > 0 then
		cclog("============addExpWithHeroEvent设置经验nExp============="..nMasterCardExp)
		self:setExp(nMasterCardExp)
	else
		self:setExp(self.nExp + nAddExp)
	end
	mainWnd:refreshHomeStatusBar()
end

--增加经验让伙伴升级带主角卡升级事件, 暂时跟上面是一样的逻辑以防后面要用
function Class_Card:addExpWithCallEvent(nAddExp, funcBattleResultEndCall, nMasterCardLevel, nMasterCardExp)

	local nNewlevel = 0
	if nMasterCardLevel and nMasterCardLevel > 0 then
		cclog("==========nMasterCardLevelCCCCCCCCCC============"..nMasterCardLevel)
		nNewlevel = nMasterCardLevel
	else
		nNewlevel = self:getNewLvByAddExp(nAddExp)
	end
	
	self.funcBattleResultEndCall = funcBattleResultEndCall

	if nNewlevel and self.nLevel and nNewlevel > self.nLevel then
		local nOldLevel = self.nLevel
		gTalkingData:SetLevel(nNewlevel)
		self:setLevel(nNewlevel)
		g_Hero:onLevelUpEvent(nNewlevel)
		g_Hero:showLevelUpAnimation(nOldLevel, true, nNewlevel)
	else
		--异常
		local nOldLevel = self.nLevel or 1
		nNewlevel = nNewlevel or 1
		g_Hero:showLevelUpAnimation(nOldLevel, false, nNewlevel)
	end
	
	if nMasterCardExp and nMasterCardExp > 0 then
		cclog("==========nMasterCardExpCCCCCCCCCC============"..nMasterCardExp)
		self:setExp(nMasterCardExp)
	else
		self:setExp(self.nExp + nAddExp)
	end
	mainWnd:refreshHomeStatusBar()
end

--增加经验让伙伴升级带功能开启提示
function Class_Card:addExpWithOpenCheck(nAddExp, nMasterCardLevel, nMasterCardExp)
	local nNewlevel = 0
	if nMasterCardLevel and nMasterCardLevel > 0 then
		nNewlevel = nMasterCardLevel
	else
		nNewlevel = self:getNewLvByAddExp(nAddExp)
	end
	
	if nNewlevel > self.nLevel then
		local nOldLevel = self.nLevel
		gTalkingData:SetLevel(nNewlevel)
		self:setLevel(nNewlevel)
		g_Hero:onLevelUpEvent(nNewlevel)
		g_Hero:showLevelUpAnimation(nOldLevel, true, nNewlevel)
	else
		local nOldLevel = self.nLevel
		g_Hero:showLevelUpAnimation(nOldLevel, false, nNewlevel)
	end
	
	if nMasterCardExp and nMasterCardExp > 0 then
		self:setExp(nMasterCardExp)
	else
		self:setExp(self.nExp + nAddExp)
	end
	
	mainWnd:refreshHomeStatusBar()
end

--获取经验百分比
function Class_Card:getCurExpPrecent()
	local nMaxExp = self:getMaxExp()
	local nMaxExpLastLev = self:getMaxExpLastLev()
	local nExpPercent = math.floor((self.nExp - nMaxExpLastLev)*100/(nMaxExp - nMaxExpLastLev) )
	return nExpPercent
end

--判断经验是否已满
function Class_Card:IsCardExpFull()
	local nMaxExp =  self:getMaxLevMaxExp()
	if self:getExp() >= nMaxExp then
		return true
	else
		return false
	end
end

--获取加入经验后百分比
function Class_Card:getNewExpPrecentByAddExp(nExp)
	local nNewLv = self:getNewLvByAddExp(nExp)
	local nMaxCardLev = self:getMaxLevel()
	nNewLv = math.min(nNewLv, nMaxCardLev)
	local nNewExp = self.nExp + nExp
	local nNewLevFulExp = g_DataMgr:getCardExpCsvExpMax(nNewLv, self:checkIsLeader())
	nNewExp = math.min(nNewExp, nNewLevFulExp)
	local nLastLevFullExp = 0
	if(nNewLv > 1)then
		nLastLevFullExp = g_DataMgr:getCardExpCsvExpMax(nNewLv - 1,self:checkIsLeader())
	end
	local nExpPercent = math.floor((nNewExp - nLastLevFullExp)*100/(nNewLevFulExp - nLastLevFullExp) )
	return nExpPercent
end

--获取伙伴星级
function Class_Card:getStarLevel()
	return self.nStarLevel
end

--获取伙伴最大星级
function Class_Card:getMaxStarLevel()
	return g_DataMgr:getGlobalCfgCsv("max_card_star")
end

--判断伙伴是否可以升星
function Class_Card:checkCanSarUp()
	if self.nStarLevel < self:getMaxStarLevel() then
		local Obj_CardHunPo = g_Hero:getHunPoObj(self.nCsvID)
		if Obj_CardHunPo then
			if Obj_CardHunPo.nNum then
				local nHaveHunPoNum = Obj_CardHunPo.nNum
				local nHaveMaterialNum = g_Hero:getItemNumByCsv(self.tbCsvBase.ReplaceMaterialID, self.tbCsvBase.ReplaceMaterialLevel)
				local nReplaceMaxNum = math.min(nHaveMaterialNum, self.tbCsvBase.ReplaceMaterialMaxNum)
				local nCostHunPoNum = math.min(nHaveHunPoNum, self.tbCsvBase.StarUpHunPoNum - nReplaceMaxNum)
				if (nCostHunPoNum + nReplaceMaxNum) >= self.tbCsvBase.StarUpHunPoNum then
					return true
				end
			end
		end
	end
	return false
end

--获取伙伴星级字符串
function Class_Card:getStarLevelStrValue()
	return g_tbStarLevel[self:getStarLevel()]
end

--获取下一星级
function Class_Card:getNextStarLev()
	local tbCsvBase = g_DataMgr:getCardBaseCsv(self.nCsvID, self.nStarLevel + 1)
	if tbCsvBase then
		return self.nStarLevel + 1
	else
		return self.nStarLevel
	end
end

--设置伙伴的星级
function Class_Card:setStarLevel(nStarLevel)
	self.nStarLevel = nStarLevel
	self.tbCsvBase = g_DataMgr:getCardBaseCsv(self.nCsvID, self.nStarLevel)
	self:initProfessParams()
	self:reCalculateBaseProps()
end

--判断伙伴是否出战
function Class_Card:checkIsInBattle()
	if self.nBattleIndex then
		return self.nBattleIndex > 0
	else
		return false
	end
end

function Class_Card:getBattleIndex()
	return self.nBattleIndex
end

function Class_Card:setBattleIndex(nBattleIndex)
	self.nBattleIndex = nBattleIndex
end

--获取伙伴原画
function Class_Card:getPainting()
	return  self:getCsvBase().SpineAnimation
end

--检查是否是队长
function Class_Card:checkIsLeader()
	return g_Hero:getBattleCardIDByIndex(1) > 0 and self.nServerID == g_Hero:getBattleCardIDByIndex(1)
end

--获取伙伴名字
function Class_Card:getName()
	if self:checkIsLeader() then
		return g_Hero:getMasterName()
	end
	
	return self:getCsvBase().Name
end

--获取伙伴名字
function Class_Card:getHpPos()
	return tonumber(self:getCsvBase().HPBarX), tonumber(self:getCsvBase().HPBarY)
end

--获取伙伴组合
function Class_Card:getCardGroups()
	local tbGroup = {}
	table.insert(tbGroup, tonumber(self:getCsvBase().CardGroupID1))
	table.insert(tbGroup, tonumber(self:getCsvBase().CardGroupID2))
	table.insert(tbGroup, tonumber(self:getCsvBase().CardGroupID3))
	table.insert(tbGroup, tonumber(self:getCsvBase().CardGroupID4))
	return tbGroup
end

--伙伴上香数据
function Class_Card:getCSXiangData()
	return self.CSXiangData
end

--获取伙伴上香增加的数据
function Class_Card:shangXingAddData(burnInceneseInfo)
		--上香属性数据
	self.CSXiangData = Class_ShangXiang.new()
	self.CSXiangData:initData(burnInceneseInfo)
end
--穿在卡牌的装备ID
function Class_Card:getCardEquipID()
	return self.tbEquipIdList
end

function Class_Card:setCardEquipID(index,equipId)
	self.tbEquipIdList[index] = equipId
end

--穿在卡牌的异兽
function Class_Card:getCardFateID()
	return self.tbFateIdList
end

function Class_Card:setCardFateID(index,fateId)
	self.tbFateIdList[index] = fateId
end

function Class_Card:getFatePosIndexInType()
	return self.tbFatePosIndexInType
end

function Class_Card:setFatePosIndexInType(index,indexInType)
	self.tbFatePosIndexInType[index] = indexInType
end


function Class_Card:getCardCsvID()
	return self.nCsvID
end


function Class_Card:setCardCsvID(csvId)
	self.nCsvID = csvId
end

