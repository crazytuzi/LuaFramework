--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	flamehong
-- 日  期:	2014-4-7 21:59
-- 版  本:	1.0
-- 描  述:	装备
-- 应  用:  
---------------------------------------------------------------------------------------

--Class_Fate
Class_Fate = class("Class_Fate",  function() return Class_GameObj:new() end)
Class_Fate.__index = Class_Fate

--初始化异兽数据
function Class_Fate:initFateData(tbFate)
	if(not tbFate)then
		cclog("Class_Fate:initFateData is nil")
	end	
	self.nServerID = tbFate.fate_id								--异兽id
	self.nCsvID = tbFate.fate_config_id or 0					--异兽配置id  CardFate.csv
	self.nFateLevel = tbFate.fate_star_lv or 1					--异兽星级
	self.nFateExp = tbFate.fate_exp or 0						--异兽经验
	self.nOwnerID = tbFate.owner_card_id or 0				--所属伙伴id
	self.nFateLevel = math.min(self.nFateLevel, 10)
	self.tbCsvBase = g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel)
	if(not self.tbCsvBase)then
        cclog("初始化异兽 出错:"..self.nServerID..' '..self.nCsvID..' '..self.nCsvID)
        return 0, nil
    end
		
	cclog("初始化异兽"..self.nServerID.."所属伙伴:"..self.nOwnerID)
	
	return self.nServerID, self.nOwnerID
end

--初始化异兽数据
function Class_Fate:initFateDropData(tbFate)
	if(not tbFate)then
		cclog("Class_Fate:initFateDropData")
	end
	
	self.nServerID = tbFate.drop_item_id					--异兽id
	self.nCsvID = tbFate.drop_item_config_id		--异兽配置id  CardFate.csv
	self.nFateLevel = tbFate.drop_item_star_lv			--异兽星级
	self.nFateExp = 0
	self.nOwnerID = tbFate.drop_owner_id or 0
	
	self.tbCsvBase = g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel)
	
	if self.nFateLevel > 1 then
		local tbFrontData = g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel-1)
		local nFateExp = tbFrontData.FullLevelExp
		self.nFateExp = nFateExp or 0
	end	
		
	cclog(self.nServerID.."初始化异兽"..self.nCsvID.."星级:"..self.nFateLevel)
	return self.nServerID, self.nOwnerID
end

function Class_Fate:getServerId()
	return self.nServerID
end

function Class_Fate:getCfgID()
	return self.nCsvID
end

function Class_Fate:getFateExp()
	return self.nFateExp
end

function Class_Fate:getCurLevFateExp()
	return self.nFateExp - self:getFateMaxExpLastLev()
end

function Class_Fate:getCurLevFateExpString()
	return _T("经验").." "..self:getCurLevFateExp().."/"..self:getCurLevFateFullExp()
end

function Class_Fate:setFateExp(nFateExp)
	self.nFateExp = math.min(nFateExp, self:getFateMaxLevMaxExp())
end

function Class_Fate:getFateMaxExp()
	return g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel).FullLevelExp
end

function Class_Fate:getFateMaxExpLastLev()
	return g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel - 1).FullLevelExp --新的数据层会有Default Table
end

function Class_Fate:getCurLevFateFullExp()
	return self:getFateMaxExp() - self:getFateMaxExpLastLev()
end

function Class_Fate:getFateMaxLevMaxExp()
	return g_DataMgr:getCardFateCsv(self.nCsvID, self:getFateMaxLevel()).FullLevelExp
end

function Class_Fate:getFateRemainExp()
	return self:getFateMaxLevMaxExp() - self.nFateExp
end

function Class_Fate:checkIsExpFull()
	return self.nFateExp >= self:getFateMaxLevMaxExp()
end

function Class_Fate:checkIsExpFullByAddExp(nAddFateExp)
	return self.nFateExp + nAddFateExp >= self:getFateMaxLevMaxExp()
end

function Class_Fate:getAddExp()
	return self.nFateExp + self.tbCsvBase.AddExp
end

function Class_Fate:getFateLevel()
	return self.nFateLevel
end

function Class_Fate:getFateLevelString()
	return _T("Lv.")..self.nFateLevel
end

function Class_Fate:getFateLevelStringInColor(Label_Level)
	if Label_Level then
		g_SetWidgetColorBySLev(Label_Level, self.tbCsvBase.ColorType)
	end
	return self:getFateLevelString()
end

function Class_Fate:getFateLevelStringByLev(nFateLevel)
	return _T("Lv.")..nFateLevel
end

function Class_Fate:getFateLevelStringInColorByLev(nFateLevel, Label_Level)
	if Label_Level then
		g_SetWidgetColorBySLev(Label_Level, self.tbCsvBase.ColorType)
	end
	return self:getFateLevelStringByLev(nFateLevel)
end

function Class_Fate:getFateNameWithLevel()
	return self.tbCsvBase.Name.." ".._T("Lv.")..self.nFateLevel
end

function Class_Fate:getFateNameWithLevelInColor(Label_Name)
	return self:getFateNameInColor(Label_Name).." ".._T("Lv.")..self.nFateLevel
end

function Class_Fate:getFateNameInColor(Label_Name)
	if Label_Name then
		g_SetWidgetColorBySLev(Label_Name, self.tbCsvBase.ColorType)
	end
	return self.tbCsvBase.Name
end

function Class_Fate:getFateMaxLevel()
	return 10
end

function Class_Fate:setFateLevel(nFateLevel)
	self.nFateLevel = math.min(nFateLevel, self.getFateMaxLevel())
	self.tbCsvBase = g_DataMgr:getCardFateCsv(self.nCsvID, self.nFateLevel)
end

function Class_Fate:getFateNewLevByAddExp(nAddFateExp)
	local nNewFateExp = nAddFateExp + self.nFateExp
	local nNewFateLevel = self.nFateLevel
	local nMaxFateLevel = self:getFateMaxLevel()
	for nFateLevel = self.nFateLevel, nMaxFateLevel do
		local CSV_CardFate = g_DataMgr:getCardFateCsv(self.nCsvID, nFateLevel)
		if nNewFateExp > CSV_CardFate.FullLevelExp then
			nNewFateLevel = nFateLevel + 1
			if nNewFateLevel >= nMaxFateLevel then --不能超过最大等级
				nNewFateLevel = nMaxFateLevel
				break
			end
		else
			break
		end
	end
	return nNewFateLevel
end

--设置宿主伙伴
function Class_Fate:setOwnerID(nOwnerID)
	self.nOwnerID = nOwnerID
end

function Class_Fate:getOwnerID()
	return self.nOwnerID or 0
end

function Class_Fate:checkOwnerIsInBattle()
	if self.nOwnerID and self.nOwnerID <= 0 then
		return false
	else
		local tbOwnerCard = g_Hero:getCardObjByServID(self.nOwnerID)
		if tbOwnerCard then
			return tbOwnerCard:checkIsInBattle()
		else
			return false
		end
	end
end

--异兽更换、装备
function Class_Fate:equipToOwner(GameObj_CardOwner, nPosIndex)
	local nTargetFateID = GameObj_CardOwner:getFateIDByPos(nPosIndex)
	if nTargetFateID > 0 then
		local GameObj_FateOld = g_Hero:getFateInfoByID(nTargetFateID)
		GameObj_CardOwner:setFatePosIndexInType(GameObj_FateOld:getCardFateCsv().Type, nPosIndex)
		GameObj_FateOld:setOwnerID(0)
		
		GameObj_CardOwner:setFateID(nPosIndex, self.nServerID)
		GameObj_CardOwner:setFatePosIndexInType(self:getCardFateCsv().Type, nPosIndex)
		self:setOwnerID(GameObj_CardOwner:getServerId())
		GameObj_CardOwner:reCalculateFateProps("Exchange", GameObj_FateOld, self)
	else
		GameObj_CardOwner:setFateID(nPosIndex, self.nServerID)
		GameObj_CardOwner:setFatePosIndexInType(self:getCardFateCsv().Type, nPosIndex)
		self:setOwnerID(GameObj_CardOwner:getServerId())
		GameObj_CardOwner:reCalculateFateProps("Dress", nil, self)
	end
end

--异兽卸载
function Class_Fate:equipFromOwner(GameObj_CardOwner, nPosIndex)
	GameObj_CardOwner:setFateID(nPosIndex, 0)
	GameObj_CardOwner:setFatePosIndexInType(self:getCardFateCsv().Type, 0)
	self:setOwnerID(0)
	GameObj_CardOwner:reCalculateFateProps("Undress", self)
end

--异兽升级
function Class_Fate:setFateLevelAndExp(nFateLevel, nFateExp)
	self:setFateLevel(nFateLevel)
	self:setFateExp(nFateExp)
end

function Class_Fate:getCardFateCsv()
	return self.tbCsvBase
end

function Class_Fate:getFateBaseByLev(nFateLevel)
	return g_DataMgr:getCardFateCsv(self.nCsvID, nFateLevel)
end

--返回个数 异兽不是叠加物品
function Class_Fate:getNum()
	return 1
end

function Class_Fate:updateOwnerCardProps()
    if self.nOwnerID and self.nOwnerID > 0 then
        local GameObj_CardOwner = g_Hero:getCardObjByServID(self.nOwnerID)
        if GameObj_CardOwner then
			GameObj_CardOwner:reCalculateFateProps("Upgrade", self)
        end
    end
end

function Class_Fate:getPropValueString()
	return self:getPropName().." +"..self:getPropValue()
end

function Class_Fate:getPropValue()
	return self.tbCsvBase.PropValue
end

function Class_Fate:getPropName()
	return g_tbFatePropName[self.tbCsvBase.Type]
end

--检查异兽是否可以被一键吞噬
function Class_Fate:checkCanBeOneKeyConsumed(tbFateTarget)
	return (
		self.tbCsvBase.ColorType < 5
		and self.tbCsvBase.ColorType <= tbFateTarget.tbCsvBase.ColorType
		and self.nServerID ~= tbFateTarget.nServerID
	)
end

function Class_Fate:checkCanBeConsumedExcludeSelf(tbFateTarget)
	return (
		self.tbCsvBase.ColorType <= tbFateTarget.tbCsvBase.ColorType
		and self.nServerID ~= tbFateTarget.nServerID
	)
end

function Class_Fate:checkCanBeConsumed(tbFateTarget)
	return self.tbCsvBase.ColorType <= tbFateTarget.tbCsvBase.ColorType
end

function Class_Fate:checkIsCanBeEquiped(tbTargetCard)
	if not tbTargetCard then return end
	
	return not tbTargetCard:checkFateTypeIsInLay(self:getCardFateCsv().Type)
end