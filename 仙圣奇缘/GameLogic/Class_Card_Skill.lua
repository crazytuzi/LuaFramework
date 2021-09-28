--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	卡牌技能和丹药业务层逻辑
-- 应  用:
---------------------------------------------------------------------------------------

--技能等级
function Class_Card:getTbSkillLevel()
    return self.tbSkillLevel
end

--技能等级
function Class_Card:getSkillLevel(nIndex)
	local nLevel = self.tbSkillLevel[nIndex]
	if nLevel == 0 then nLevel = 1 end
    return nLevel
end

function Class_Card:setSkillLevel(nIndex,nSkillLevel)
	self.tbSkillLevel[nIndex] = nSkillLevel
end

function Class_Card:getSkillBase(nIndex)
	local itemBase = self:getCsvBase()
    return g_DataMgr:getSkillBaseCsv(itemBase["PowerfulSkillID"..nIndex])
end

--获取伙伴技能名字带突破等级后缀
function Class_Card:getSkillNameWithSuffix(nIndex, Label_Name,nextLevel)
	if not nextLevel then nextLevel = 0 end
	if Label_Name then
		g_SetCardNameColorByEvoluteLev(Label_Name, self:getSkillLevel(nIndex)+nextLevel)
	end
	return getFormatSuffixLevel(self:getSkillBase(nIndex).Name, self:getSkillEvoluteSuffixByNextLevel(nIndex,nextLevel))
end

--获取当前伙伴的突破等级对应的ColorType
function Class_Card:getSkillColorType(nIndex)
	local nSkillLevel = self:getSkillLevel(nIndex)
	local tbEvoluteProp = g_DataMgr:getCardEvolutePropCsv(nSkillLevel)
	return tbEvoluteProp.ColorType
end

--获取当前伙伴的突破等级后缀
function Class_Card:getSkillEvoluteSuffix(nIndex)
	local tbEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self:getSkillLevel(nIndex))
	return tbEvoluteProp.EvoluteSuffix
end

--获取当前伙伴的突破等级后缀 下一等级
function Class_Card:getSkillEvoluteSuffixByNextLevel(nIndex,nextLevel)
	local tbEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self:getSkillLevel(nIndex)+nextLevel)
	return tbEvoluteProp.EvoluteSuffix
end

--获取丹药列表
function Class_Card:getDanyaoLvList()
	return self.tbDanyaoLvList
end

--获取丹药等级
function Class_Card:getDanyaoLevel(nSkillIndex, nDanYaoIndex)
	return self.tbDanyaoLvList[nSkillIndex][nDanYaoIndex]
end

--设置丹药列表
function Class_Card:setDanyaoLvList(nSkillIndex, nDanYaoIndex, value)
	self.tbDanyaoLvList[nSkillIndex][nDanYaoIndex] = value
	self:reCalculateDanYaoProps(nSkillIndex, nDanYaoIndex)
end

--丹药最大等级
function Class_Card:getDanyaoMaxLevel()
	local CardEvoluteDanYao =  g_DataMgr:getCsvConfig("CardEvoluteDanYao")
	local nNum = 0
	for key,value in ipairs(CardEvoluteDanYao) do
		for key2,value2 in ipairs(value) do
			if value2.Level > nNum then 
				nNum = value2.Level
			end
		end
	end
	return nNum
end