--[[
世界地图地域tips
郝户
20年9月10日10:21:13
]]

_G.MapTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Map, MapTips);

MapTips.tipsVO = nil;

function MapTips:Parse(tipsInfo)
	self.tipsVO = tipsInfo;
	self.str = "";
	self.str = self.str .. self:GetVGap(3);
	--map info
	self.str = self.str .. self:GetHtmlMapPart();
	--monster info
	self.str = self.str .. self:GetHtmlMonsterPart();
	--间距
	self.str = self:SetLineSpace( self.str, 6 );
end

function MapTips:GetShowIcon()
	return false;
end

-- 获取地图信息 html text
function MapTips:GetHtmlMapPart()
	local tipsVO = self.tipsVO;
	local str = "";
	--map name
	str = str .. self:GetHtmlText( tipsVO:GetName(), "#d2a930", 18, false );
	--map allow pk or not
	str = str .. self:GetCanPkHtml( tipsVO:CanPk() );
	--limit level
	str = str .. self:GetLimitLvHtml( tipsVO:GetLimitLvl() );
	--monster level range
	-- str = str .. self:GetHtmlText( string.format( StrConfig["tips200"], tipsVO:GetRecomandLvl() ), TipsConsts.Default_Color, TipsConsts.Default_Size, false );
	return str;
end

function MapTips:GetHtmlMonsterPart()
	local tipsVO = self.tipsVO;
	local str = "";
	local bossInfo = tipsVO:GetBossInfo();
	if bossInfo then
		str = str .. self:GetHtmlAdvPart( bossInfo );
	end
	local eliteInfo = tipsVO:GetEliteInfo();
	if eliteInfo then
		str = str .. self:GetHtmlAdvPart( eliteInfo );
	end
	str = str .. self:GetHtmlNormalMonsterPart();
	return str;
end

function MapTips:GetHtmlAdvPart( monsterInfo )
	local str = "";	
	-- str = str .. self:GetLine(5);--line	
	-- str = str .. self:GetMonsterNameHtml( monsterInfo );--name	
	-- str = str .. self:GetMonsterLvlHtml( monsterInfo );--level	
	-- 屏蔽boss的刷新，boss的出生点，boss的掉落
	-- str = str .. self:GetRefreshTimesHtml( monsterInfo.id );--refresh time list	
	-- str = str .. self:GetNextRefreshHtml( monsterInfo.id );--next refresh time	
	-- str = str .. self:GetDropOutHtml( monsterInfo.title, monsterInfo.id );--掉落
	return str	
end

-- 获取普通Monster信息 html text
function MapTips:GetHtmlNormalMonsterPart()
	local tipsVO = self.tipsVO;
	local monsters = tipsVO:GetNormalMonsterInfo();
	if #monsters == 0 then return "" end
	local str = "";
	--line
	str = str .. self:GetLine(5);
	-- title
	local title = self:GetHtmlText( StrConfig['tips201'], "#22c50b", TipsConsts.Default_Size );
	title = self:SetLineSpace(title, -15);
	str = str .. title;
	-- level
	local level = self:GetHtmlText( string.format( StrConfig['tips202'], tipsVO:GetRecomandLvl() ), "#22c50b", TipsConsts.Default_Size );
	level = self:SetLeftMargin(level, 180);
	str = str ..level;
	-- monster list
	for _, monsterInfo in pairs(monsters) do
		str = str .. self:GetHtmlText( string.format( StrConfig['tips203'], monsterInfo.name, monsterInfo.level ), TipsConsts.Default_Color, TipsConsts.Default_Size );
	end
	return str	
end

-- 获取是否可pk htmltext
function MapTips:GetCanPkHtml( canPk )
	local canPkTxt, canPkColor;
	if canPk then
		canPkTxt, canPkColor = StrConfig['tips204'], "#dc2f2f";
	else
		canPkTxt, canPkColor = StrConfig['tips205'], "#65c47e";
	end
	return self:GetHtmlText( canPkTxt, canPkColor, TipsConsts.Default_Size );
end

-- 获取进入等级限制 htmltext
function MapTips:GetLimitLvHtml( limitLv )
	local playerLevel = MainPlayerModel.humanDetailInfo.eaLevel or 1;
	local limitLvColor = ( playerLevel < limitLv ) and MapConsts.Red or MapConsts.Green;
	local limitLvStr = self:GetHtmlText( limitLv, limitLvColor, TipsConsts.Default_Size, false );
	return self:GetHtmlText( string.format( StrConfig['tips206'], limitLvStr ), TipsConsts.Default_Color, TipsConsts.Default_Size);
end

function MapTips:GetMonsterNameHtml( monsterInfo )
	local str = "";
	str = str .. self:GetHtmlText( string.format( StrConfig['tips207'], monsterInfo.name, monsterInfo.monsterType ), monsterInfo.titleColor, TipsConsts.Default_Size );
	str = self:SetLineSpace(str, -15);
	return str;
end

function MapTips:GetMonsterLvlHtml( monsterInfo )
	local str = "";
	str = str .. self:GetHtmlText( string.format( StrConfig['tips202'], monsterInfo.level ), "#a0a0a0", TipsConsts.Default_Size );
	str = self:SetLeftMargin(str, 180);
	return str;
end

-- 获取refresh time list htmltext
function MapTips:GetRefreshTimesHtml( monsterId )
	local monsterCfg = t_monster[monsterId]
	local birthTimes = split( monsterCfg.birth_time, ',' )
	local birthTimeStr = #birthTimes > 0 and table.concat( birthTimes, '/' ) or "monster cfg.birth_time missing!"
	return string.format( "<font color='%s'>%s</font><br/>", "#5a5a5a", birthTimeStr )
end

-- 获取next refresh time htmltext
function MapTips:GetNextRefreshHtml( monsterId )
	local nextBirthTime = WorldBossUtils:GetNextBirthTime( monsterId )
	local hour, min, sec = CTimeFormat:sec2format( nextBirthTime )
	return string.format( "<font color='%s'>%s</font><font color='%s'>%s:%s</font><br/>", "#a0a0a0", StrConfig['map307'], MapConsts.Green, hour, min );
end

-- 获取掉落物品 htmltext
function MapTips:GetDropOutHtml( monsterClass, monsterId )
	local htmlText = "";
	if monsterClass == MonsterConsts.Boss then
		htmlText = self:GetHtmlText( StrConfig['map308'], TipsConsts.Default_Color, TipsConsts.Default_Size, false );
	elseif monsterClass == MonsterConsts.Elite then
		htmlText = self:GetHtmlText( StrConfig['map309'], TipsConsts.Default_Color, TipsConsts.Default_Size, false );
	end
	local dropNameTable = {}
	local monsterCfg = t_monster[monsterId]
	local dropItems = split( monsterCfg.drop_items, "#" )
	local dropNameStr;
	if #dropItems == 0 then
		dropNameStr = "monster cfg.drop_items missing!"
	else
		for _, itemStr in pairs( dropItems ) do
			local itemInfo = split(itemStr, ',')
			local itemId, num = tonumber( itemInfo[1] ), tonumber( itemInfo[2] )
			local itemCfg = t_item[itemId] or t_equip[itemId]
			local itemName, quality = itemCfg.name, itemCfg.quality
			local itemNameWithColor = string.format( "<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(quality), itemName )
			table.push( dropNameTable, itemNameWithColor )
		end
		dropNameStr = table.concat( dropNameTable, "、" )
	end
	return htmlText .. dropNameStr
end