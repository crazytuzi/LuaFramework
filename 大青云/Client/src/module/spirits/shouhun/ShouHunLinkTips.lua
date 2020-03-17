--[[
灵兽魂魄 连锁
2016年1月14日15:22:35
haohu
]]

_G.ShouHunLinkTips = {}

function ShouHunLinkTips:GetTips()
	local str1, str2
	local currentlevel, nextLevel = self:GetLinkConfigLevel()
	if currentlevel > 0 then
		str1 = self:GetShouHunLink(currentlevel)
	end
	if nextLevel then
		str2 = self:GetShouHunLink(nextLevel)
	end
	if str1 and str2 then
		return str1 .. "\n" .. str2
	end
	return str1 or str2 or ""
end

function ShouHunLinkTips:GetLinkConfigLevel()
	local linkLevel = ShouHunModel:GetShouHunLinkLevel()
	local levelList = {}
	for level, cfg in pairs(t_lingshousoulheti) do
		table.push( levelList, cfg )
	end
	table.sort( levelList, function(A, B)
		return A.id < B.id
	end)
	local currentIndex = 0
	local currentLevel = 0
	local nextLevel = 0
	for i = #levelList, 1, -1 do
		if linkLevel >= levelList[i].id then
			currentLevel = levelList[i].id
			currentIndex = i
			break
		end
	end
	nextLevel = levelList[currentIndex + 1] and levelList[currentIndex + 1].id
	return currentLevel, nextLevel
end

function ShouHunLinkTips:GetShouHunLink(level)
	local linkLevel = ShouHunModel:GetShouHunLinkLevel()
	local isActive = linkLevel >= level
	local activeStr = isActive and StrConfig['shouhun18'] or StrConfig['shouhun19']
	local color = isActive and "#00FF00" or "#FF0000"
	local shouHunNum = ShouHunModel:GetShouHunLinkNum(level)
	return string.format( StrConfig['shouhun17'], level, color, shouHunNum, ShouHunConsts.MaxShouHunNum,
		activeStr, self:GetAttrStr(level) )
end

function ShouHunLinkTips:GetAttrStr(level)
	local str = ""
	local cfg = t_lingshousoulheti[level]
	local attrList = cfg and AttrParseUtil:Parse(cfg.attr)
	local linkLevel = ShouHunModel:GetShouHunLinkLevel()
	local color = linkLevel >= level and "#d5b772" or "#5a5a5a"
	if attrList then
		for i, vo in ipairs(attrList) do
			str = str.. string.format( "<font color='%s'>%s +%s</font>\n", color, _G.enAttrTypeName[vo.type], getAtrrShowVal(vo.type, vo.val) )
		end
	end
	str = str .. string.format( StrConfig['shouhun24'], color, 100 * self:GetAttrTimes(level) )
	return str
end

function ShouHunLinkTips:GetAttrTimes(level)
	local cfg = t_lingshousoulheti[level]
	return cfg and cfg.name
end
