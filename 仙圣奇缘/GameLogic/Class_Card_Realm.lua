--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	卡牌境界等级业务层逻辑
-- 应  用:
---------------------------------------------------------------------------------------

--获取伙伴境界等级
function Class_Card:getRealmLevel()
	return self.nRealmLevel
end

-- function Class_Card:setRealmLevel(realmLv)
	-- self.nRealmLevel = realmLv
-- end
--获取伙伴境界父等级
function Class_Card:getRealmMainLev()
	return math.ceil(self.nRealmLevel/8)
end

--获取伙伴境界子等级
function Class_Card:getRealmSubLev()
	if self.nRealmLevel < 1 then
		return 0
	end
	return (self.nRealmLevel-1)%8+1
end

--获取伙伴境界子等级x/8后缀
function Class_Card:getRealmSubLevSuffix()
	local nRealmLevel = self:getRealmLevel()
	if nRealmLevel < 1 then
		return ""
	end
	return self:getRealmSubLev().."/8"
end

--通过预览等级获得境界父等级
function Class_Card:getRealmMainLevByNewLv(nNewRealmLevel)
	return math.ceil(nNewRealmLevel/8)
end

--通过预览等级获取伙伴境界子等级
function Class_Card:getRealmSubLevByNewLv(nNewRealmLevel)
	if nNewRealmLevel < 1 then
		return 0
	end
	return (nNewRealmLevel-1)%8+1
end

--通过预览等级获取伙伴境界子等级x/8后缀
function Class_Card:getRealmSubLevSuffixByNewLv(nNewRealmLevel)
	if nNewRealmLevel < 1 then
		return ""
	end
	return self:getRealmSubLevByNewLv(nNewRealmLevel).."/8"
end

--获取伙伴境界名称：炼气初期、炼气中期
function Class_Card:getRealmName()
	return g_tbRealmName[self:getRealmMainLev()]
end

--通过预览等级获取伙伴境界名称：炼气初期、炼气中期
function Class_Card:getRealmNameByNewLv(nNewRealmLevel)
	return g_tbRealmName[self:getRealmMainLevByNewLv(nNewRealmLevel)]
end

--获取伙伴带x/8后缀的名称
function Class_Card:getRealmNameWithSuffix(Label_Name)
	if Label_Name then
		g_SetWidgetColorBySLev(Label_Name, self:getRealmColorType())
	end
	return self:getRealmName()..self:getRealmSubLevSuffix()
end

--通过预览等级获取伙伴带x/8后缀的名称
function Class_Card:getRealmNameWithSuffixByNewLv(nNewRealmLevel, Label_Name)
	if Label_Name then
		g_SetWidgetColorBySLev(Label_Name, self:getRealmColorTypeByNewLv(nNewRealmLevel))
	end
	return self:getRealmNameByNewLv(nNewRealmLevel)..self:getRealmSubLevSuffixByNewLv(nNewRealmLevel)
end

--获取伙伴境界颜色类型
function Class_Card:getRealmColorType()
	return g_GetCardColorTypeByEvoLev(self.tbCsvCardRealmLevel.NeedEvoluteLevel)
end

--通过预览等级获取伙伴境界颜色类型
function Class_Card:getRealmColorTypeByNewLv(nNewRealmLevel)
	return g_GetCardColorTypeByEvoLev(g_DataMgr:getCardRealmLevelCsv(nNewRealmLevel).NeedEvoluteLevel)
end

--获取下一境界等级
function Class_Card:getNextRealmLev()
	return math.min(self.nRealmLevel + 1, g_DataMgr:getCardRealmLevelCsvMaxLevel())
end

--通过增加的境界经验计算新的境界等级预览
function Class_Card:getNewRealmLvByAddExp(nAddExp)
	local nNewLv = self.nRealmLevel
	local nNewExp = nAddExp + self.nRealmExp
    local nMaxLev = g_DataMgr:getCardRealmLevelCsvMaxLevel()
	for i = nNewLv, nMaxLev do
		local tbRealmProp = g_DataMgr:getCardRealmLevelCsv(i)
		if nNewExp > tbRealmProp.RealmPointsMax then
			nNewLv = i + 1
		else
			break
		end
	end
	return math.max(math.min(nNewLv, nMaxLev),1)
end

--获取伙伴境界经验
function Class_Card:getRealmExp()
	return self.nRealmExp
end

function Class_Card:setRealmExp(realmExp)
	self.nRealmExp = realmExp 
end


--获取当前境界圆满所需的经验
function Class_Card:getRealmFullNeedExp()
	local nMainLev = self:getRealmMainLev()
	local nRealmFullLevel = nMainLev * 8
	return g_DataMgr:getCardRealmLevelCsv(nRealmFullLevel).RealmPointsMax - self.nRealmExp
end

--通过增加的境界经验获得新的境界经验百分比预览
function Class_Card:getRealmExpPercent()
	local nCurLevFullExp = self.tbCsvCardRealmLevel.RealmPointsMax
	local nLastLevFullExp = g_DataMgr:getCardRealmLevelCsv(self.nRealmLevel-1).RealmPointsMax
	local nExpPercent = math.floor((self.nRealmExp - nLastLevFullExp)*100/(nCurLevFullExp - nLastLevFullExp) )
	return nExpPercent
end

--通过增加的境界经验获得新的境界经验百分比预览
function Class_Card:getNewRealmExpPercentByAddExp(nExp)
	local nFutureExp = self.nRealmExp + nExp
	local nNewLv = self:getNewRealmLvByAddExp(nExp)
	local tbRealmProp = g_DataMgr:getCardRealmLevelCsv(nNewLv)
    if not tbRealmProp then return 1 end

	local nCurLevFullExp = tbRealmProp.RealmPointsMax
	local nLastLevFullExp = 0
	if(nNewLv > 1)then
		local tbLastLevRealmprop = g_DataMgr:getCardRealmLevelCsv(nNewLv-1)
		nLastLevFullExp = tbLastLevRealmprop.RealmPointsMax
	end
	local nExpPercent = math.floor((nFutureExp - nLastLevFullExp)*100/(nCurLevFullExp - nLastLevFullExp) )
	return nExpPercent
end

--判断当前境界经验是否已满
function Class_Card:IsCardRealmExpFull()
	return self.nRealmExp > self.tbCsvCardRealmLevel.RealmPointsMax
end

--判断当前境界是否达到顶级
function Class_Card:IsCardRealmLevMax()
	if self.nRealmLevel >= g_DataMgr:getCardRealmLevelCsvMaxLevel() then
		return true
	end
	return false
end

--判断当前等级是否可以渡劫
function Class_Card:IsCardDuJieLevQualified()
	if self:getCardRealmLevelCsvNextLev().NeedLevel <= self.nLevel then
		return true
	end
	return false
end

--获取境界增加的HPMax
function Class_Card:getRealmHPMax(Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorType())
	end
	return self.tbCsvCardRealmLevel.HPMax
end

--获取境界增加的ForcePoints
function Class_Card:getRealmForcePoints(Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorType())
	end
	return self.tbCsvCardRealmLevel.ForcePoints
end

--获取境界增加的MagicPoints
function Class_Card:getRealmMagicPoints(Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorType())
	end
	return self.tbCsvCardRealmLevel.MagicPoints
end

--获取境界增加的SkillPoints
function Class_Card:getRealmSkillPoints(Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorType())
	end
	return self.tbCsvCardRealmLevel.SkillPoints
end

--通过预览等级获取境界增加的HPMax
function Class_Card:getRealmHPMaxByNewLv(nNewRealmLevel, Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorTypeByNewLv(nNewRealmLevel))
	end
	return self:getCardRealmLevelCsvByNewLv(nNewRealmLevel).HPMax
end

--通过预览等级获取境界增加的ForcePoints
function Class_Card:getRealmForcePointsByNewLv(nNewRealmLevel, Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorTypeByNewLv(nNewRealmLevel))
	end
	return self:getCardRealmLevelCsvByNewLv(nNewRealmLevel).ForcePoints
end

--通过预览等级获取境界增加的MagicPoints
function Class_Card:getRealmMagicPointsByNewLv(nNewRealmLevel, Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorTypeByNewLv(nNewRealmLevel))
	end
	return self:getCardRealmLevelCsvByNewLv(nNewRealmLevel).MagicPoints
end

--通过预览等级获取境界增加的SkillPoints
function Class_Card:getRealmSkillPointsByNewLv(nNewRealmLevel, Label_Prop)
	if Label_Prop then
		g_SetWidgetColorBySLev(Label_Prop, self:getRealmColorTypeByNewLv(nNewRealmLevel))
	end
	return self:getCardRealmLevelCsvByNewLv(nNewRealmLevel).SkillPoints
end

--判断是否需要渡劫
function Class_Card:IsNeedDujie()
	return self.nRealmLevel == 0 or (self.nRealmLevel % 8 == 0 and self:IsCardRealmExpFull())
end

--获取当前的境界等级的RealmProp配置
function Class_Card:getCardRealmLevelCsv()
	return self.tbCsvCardRealmLevel
end

--获取下一等级的RealmProp配置
function Class_Card:getCardRealmLevelCsvNextLev()
	return g_DataMgr:getCardRealmLevelCsv(self:getRealmLevel() + 1)
end

--通过预览等级获取当前的境界等级的RealmProp配置
function Class_Card:getCardRealmLevelCsvByNewLv(nNewRealmLevel)
	return g_DataMgr:getCardRealmLevelCsv(nNewRealmLevel)
end

--设置伙伴的境界等级和经验
function Class_Card:setReleamProp(nRealmLevel, nRealmExp)
	self.nRealmLevel = nRealmLevel				--境界等级
	self.nRealmExp = nRealmExp					--境界经验
	self.tbCsvCardRealmLevel = g_DataMgr:getCardRealmLevelCsv(self.nRealmLevel)
	self:reCalculateBaseProps()
end

--获取下一境界等级的基础属性
function Class_Card:getNextRealmLevBaseProps()
	local nNextRealmLev = self:getNextRealmLev()
	--下一境界等级配置
	local tbRealmProp = g_DataMgr:getCardRealmLevelCsv(nNextRealmLev)
	local tbProps = {}
	--计算武力
	nData = self:getCsvBase().ForcePoints*
	(g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent + tbRealmProp.ForcePoints
	table.insert(tbProps, math.floor(nData))
	--计算法术
	nData = self:getCsvBase().MagicPoints*
	(g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent + tbRealmProp.MagicPoints
	table.insert(tbProps, math.floor(nData))
	--计算绝技
	nData = self:getCsvBase().SkillPoints*
	(g_BasePercent + self.tbCsvCardEvoluteProp.BasePropPercent)/g_BasePercent + tbRealmProp.SkillPoints
	table.insert(tbProps, math.floor(nData))

	return tbProps
end

function Class_Card:getCardRealmParam()
	return g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls", self.tbCsvBase.Profession, self.nStarLevel)
end

