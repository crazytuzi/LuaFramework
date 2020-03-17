--[[
灵诀组
haohu
2016年1月22日11:33:33
]]

_G.LingJueGroup = {}

LingJueGroup.groupId = nil
LingJueGroup.lingJueList = nil

function LingJueGroup:new(groupId)
	local obj = setmetatable( {}, {__index = self} )
	obj.groupId = groupId
	obj.lingJueList = {}
	return obj
end

function LingJueGroup:GetGroupId()
	return self.groupId
end

function LingJueGroup:AddLingJue( lingJue )
	if not lingJue then return end
	self.lingJueList[ lingJue:GetTid() ] = lingJue
end

function LingJueGroup:GetLingJue( tid )
	return self.lingJueList[tid]
end

function LingJueGroup:GetCfg(level)
	local linkLevel = level or self:GetGroupLevel()
	local configKey = self.groupId * 100 + linkLevel
	return t_lingjuegroup[configKey]
end

function LingJueGroup:GetAttrTotal()
	local attrList1 = self:GetLingJueAttr()
	local attrList2 = self:GetGroupAttr()
	return LingJueUtils:AttrAdd( attrList1, attrList2 )
end

function LingJueGroup:GetLingJueAttr()
	local attrList = {}
	for _, lingJue in pairs(self.lingJueList) do
		attrList = LingJueUtils:AttrAdd( attrList, lingJue:GetAttrTotal() )
	end
	return attrList
end

function LingJueGroup:GetGroupAttr(level)
	local cfg = self:GetCfg(level)
	return cfg and AttrParseUtil:Parse(cfg.attr) or {}
end

function LingJueGroup:GetSortedLingJueList()
	local list = {}
	for _, lingJue in pairs(self.lingJueList) do
		table.push(list, lingJue)
	end
	table.sort( list, function( A, B )
		return A:GetTid() < B:GetTid()
	end )
	return list
end

function LingJueGroup:GetNameUrl()
	return ResUtil:GetLingJueGroupUrl(self.groupId)
end

function LingJueGroup:GetListUIData()
	local tab = {}
	local list = self:GetSortedLingJueList()
	for _, lingJue in ipairs(list) do
		table.push( tab, lingJue:GetUIData() )
	end
	return table.concat( tab, "*" )
end

function LingJueGroup:GetUIData()
	local vo = {}
	vo.groupId = self.groupId
	vo.nameUrl = self:GetNameUrl()
	local currentGroupLevel = self:GetGroupLevel()
	local completed = currentGroupLevel > 0
	local level = completed and currentGroupLevel or currentGroupLevel + 1
	local label = completed and StrConfig['lingjue7'] or StrConfig['lingjue8']
	local color = completed and "#00FF00" or "#FF0000"
	vo.textLink = string.format( StrConfig['lingjue9'], level, color, self:CalcLevelProgress(level), self:GetLength(), label )
	vo.textAttr = self:GetAttrStr(level)
	return UIData.encode(vo) .. "*" .. self:GetListUIData()
end

function LingJueGroup:GetAttrStr(level)
	local tab = {}
	if not level then
		level = self:GetGroupLevel()
	end
	local attr = self:GetGroupAttr(level)

	for _, vo in ipairs(attr) do
		table.push( tab, string.format( "<font color='#D5B772'>%s</font><font color='#00FF00'> +%s</font>", enAttrTypeName[ vo.type ], vo.val ) )
	end
	return table.concat( tab, "<br/>" )
end

function LingJueGroup:GetGroupLevel()
	local minLevel = 0
	for _, lingJue in pairs(self.lingJueList) do
		if minLevel == 0 then
			minLevel = lingJue:GetLevel()
		else
			minLevel = math.min( lingJue:GetLevel(), minLevel )
		end
	end
	--
	local linkLevel = 0
	for _, cfg in pairs(t_lingjuegroup) do
		if cfg.gourp_id == self.groupId then
			if cfg.common_lv <= minLevel then
				linkLevel = math.max( cfg.level, linkLevel )
			end
		end
	end
	return linkLevel
end

function LingJueGroup:CalcLevelProgress(linkLevel)
	local key = self.groupId * 100 + linkLevel
	local cfg = t_lingjuegroup[key]
	if not cfg then return end
	local doneNum = 0
	for _, lingJue in pairs(self.lingJueList) do
		doneNum = doneNum + ( ( lingJue:GetLevel() > cfg.common_lv ) and 1 or 0 )
	end
	return doneNum
end

function LingJueGroup:GetLength()
	return getTableLen(self.lingJueList)
end

function LingJueGroup:GetMaxGroupLevel()
	local linkLevel = 0
	for _, cfg in pairs(t_lingjuegroup) do
		if cfg.gourp_id == self.groupId then
			print(cfg.level, linkLevel)
			linkLevel = math.max( cfg.level, linkLevel )
		end
	end
	return linkLevel
end

function LingJueGroup:GetNextGroupLevel()
	local currentLevel = self:GetGroupLevel()
	local maxLevel = self:GetMaxGroupLevel()
	return currentLevel < maxLevel and currentLevel + 1 or nil
end

function LingJueGroup:ShowPromptTips()
	local tips = ""
	print(self:GetMaxGroupLevel())
	local currentGroupLevel = self:GetGroupLevel()
	if currentGroupLevel >= self:GetMaxGroupLevel() then
		tips = StrConfig['lingjue10']
	else
		local nextLevel = currentGroupLevel + 1
		tips = tips .. StrConfig['lingjue11']
		tips = tips .. string.format( "<p><img width='100' height='1' align='baseline' src='%s'/></br></p>", ResUtil:GetTipsLineUrl() )
		tips = tips .. string.format( StrConfig['lingjue12'], nextLevel )
		local doneNum = self:CalcLevelProgress(nextLevel)
		tips = tips .. string.format( StrConfig['lingjue13'], doneNum, self:GetLength() )
		tips = tips .. StrConfig['lingjue14']
		tips = tips .. self:GetAttrStr(nextLevel)
	end
	TipsManager:ShowBtnTips(tips, TipsConsts.Dir_RightDown)
end