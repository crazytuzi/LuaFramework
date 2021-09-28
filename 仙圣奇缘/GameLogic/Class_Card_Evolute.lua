--------------------------------------------------------------------------------------
-- 文件名:	Class_Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-2-21 11:24
-- 版  本:	1.0
-- 描  述:	卡牌突破相关的业务逻辑
-- 应  用:
---------------------------------------------------------------------------------------

--获取伙伴进化等级
function Class_Card:getEvoluteLevel()
	return self.nEvoluteLevel
end

--获取当前伙伴的突破等级对应的ColorType
function Class_Card:getColorType()
	return self.tbCsvCardEvoluteProp.ColorType or 1
end

--获取当前伙伴的突破等级后缀
function Class_Card:getEvoluteSuffix()
	return self.tbCsvCardEvoluteProp.EvoluteSuffix or 0
end

--获取下一突破等级
function Class_Card:getNextEvoluteLev()
	local tbEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self.nEvoluteLevel + 1)
	if tbEvoluteProp then
		return self.nEvoluteLevel + 1
	else
		return self.nEvoluteLevel
	end
end

--设置伙伴的进化等级
function Class_Card:setEvoluteLevel(nEvoluteLevel)
	self.nEvoluteLevel = nEvoluteLevel
	self.tbCsvCardEvoluteProp = g_DataMgr:getCardEvolutePropCsv(self.nEvoluteLevel)
	self:reCalculateBaseProps()
end

--获取当前的突破等级的CardEvoluteProp配置
function Class_Card:getCardEvolutePropCsv()
	return self.tbCsvCardEvoluteProp
end

--获取下一突破等级的CardEvoluteProp配置
function Class_Card:getNextEvoluteProp()
	local nEvoluteLevel = self:getNextEvoluteLev()
	return g_DataMgr:getCardEvolutePropCsv(nEvoluteLevel)
end

function g_GetCardColorTypeByEvoLev(nEvoluteLevel)
	local CSV_EvoluteProp = g_DataMgr:getCardEvolutePropCsv(nEvoluteLevel)
	return CSV_EvoluteProp.ColorType or 1
end

function g_GetCardEvoluteSuffixByEvoLev(nEvoluteLevel)
	local CSV_EvoluteProp = g_DataMgr:getCardEvolutePropCsv(nEvoluteLevel)
	return CSV_EvoluteProp.EvoluteSuffix or 0
end

--获取伙伴名字带突破等级后缀并设置颜色
function g_GetCardNameWithSuffix(CSV_CardBase, nEvoluteLevel, Label_Name)
	if Label_Name then
		g_SetWidgetColorBySLev(Label_Name, g_GetCardColorTypeByEvoLev(nEvoluteLevel))
	end
	return getFormatSuffixLevel(CSV_CardBase.Name, g_GetCardEvoluteSuffixByEvoLev(nEvoluteLevel))
end

--获取伙伴名字带突破等级后缀
function Class_Card:getNameWithSuffix(Label_Name, leadName)
	if Label_Name then
		g_SetCardNameColorByEvoluteLev(Label_Name, self:getEvoluteLevel())
	end
	if self:checkIsLeader() then
        if leadName then
            return getFormatSuffixLevel(leadName, self:getEvoluteSuffix())
        else 
		    return getFormatSuffixLevel(g_Hero:getMasterName(), self:getEvoluteSuffix())
        end
	else
		return getFormatSuffixLevel(self:getCsvBase().Name, self:getEvoluteSuffix())
	end
	
end

