--
-- Author: xurui
-- Date: 2015-04-27 11:43:21
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSystemNotice = class("QUIWidgetSystemNotice", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetSystemNotice.SHOW_NOTICE_ON_CHAT = "SHOW_NOTICE_ON_CHAT"
QUIWidgetSystemNotice.NO_MORE_NOTICE = "NO_MORE_NOTICE"

function QUIWidgetSystemNotice:ctor(options)
	local ccbFile = "ccb/Widget_SystemNotice.ccbi"
	local callBack = {}
	QUIWidgetSystemNotice.super.ctor(self, ccbFile, callBack, options)

	self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
  	self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height
  	self._pageContent = CCNode:create()

  	local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
  	local ccclippingNode = CCClippingNode:create()
  	layerColor:setPositionX(self._ccbOwner.sheet_layout:getPositionX())
  	layerColor:setPositionY(self._ccbOwner.sheet_layout:getPositionY())
  	ccclippingNode:setStencil(layerColor)
  	ccclippingNode:addChild(self._pageContent)

  	self._ccbOwner.sheet:addChild(ccclippingNode)
end

function QUIWidgetSystemNotice:disappear()
	if self._ccbView ~= nil then
		self:removeChild(self._ccbView, true)
		self._ccbOwner = nil
		self._ccbView = nil
	end
	if self._runAction ~= nil then
		self._pageContent:stopAction(self._runAction)
	end
end

function QUIWidgetSystemNotice:setNoticeInfo(noticeInfo)
	if self._runAction ~= nil then
		self._pageContent:stopAction(self._runAction)
		self._runAction = nil
	end
	self._pageContent:removeAllChildren()
	self._pageContent:setPositionX(0)

	self.startPosition = ccp(self._pageWidth/2, 0)
	self.noticeContentWidth = 0
	self.noticeText = ""
	self.chatText = ""
	self.chatColors = {}
	self.chatDefaultColour = "white"
	self._mineId = nil

	self.noticeType = noticeInfo.type
	
	local consortiaId = nil
	local from = nil
	if self.noticeType ~= 10000 then
		local noticeContent = db:getNoticeContentByNoticeIndex(noticeInfo.type)
		if noticeContent == nil then
			self:noticeRunEnd()
			return
		end
		 
		-- 开服时间限制
		if noticeContent.show_day then
			-- 开服时间段
			local showDay = string.split(noticeContent.show_day, ",")
			if remote:checkOpenServerDays(tonumber(showDay[1]), tonumber(showDay[2])) then
				self:noticeRunEnd()
				return
			end
		end

		self.colors = string.split(noticeContent.colour, ";")
		if nil ~= noticeContent.chat_colour then
			self.chatColors = string.split(noticeContent.chat_colour, ";")
		end
		if nil ~= noticeContent.chat_default_colour then
			self.chatDefaultColour = noticeContent.chat_default_colour
		end
		local contents = string.split(noticeContent.content, "#")
		local tbl = string.split(noticeInfo.content, ";")
		if noticeInfo.showType == app.notice.UNION_TYPE or noticeInfo.showType == app.notice.SURPER_TYPE or 
			noticeInfo.showType == app.notice.UNION_NORMAL_TYPE then
			consortiaId = table.remove(tbl, 1)
		end
		local names = tbl
		self._mineId = self:createColorLabel(contents, names)
		from = "系统公告"
	else
		if noticeInfo.content ~= nil then
			self:createLabel(noticeInfo.content, "variable")
    		self:setChatMessage(noticeInfo.content, "variable")
			from = "系统公告"
		end
	end 

	-- 聊天显示
	if noticeInfo.showType == app.notice.CHAT_TYPE then
		self:showNoticeOnChat(from)
		app.notice:playNextNotice()
	-- 聊天+跑马灯
	elseif noticeInfo.showType == app.notice.CHAT_NORMAL_TYPE then
		self:showNoticeOnChat(from)
		self:noticeRunAnimaiton(self.startPosition, self.noticeContentWidth)
	-- 跑马灯
	elseif noticeInfo.showType == app.notice.NORMAL_TYPE then
		self:noticeRunAnimaiton(self.startPosition, self.noticeContentWidth)
	-- 宗门聊天
	elseif noticeInfo.showType == app.notice.UNION_TYPE then
		self:showNoticeOnChatWithChannelId(from, CHANNEL_TYPE.UNION_CHANNEL, consortiaId, noticeInfo.type, self._mineId)
		app.notice:playNextNotice()
	-- 聊天+宗门聊天+跑马灯
	elseif noticeInfo.showType == app.notice.SURPER_TYPE then
		self:showNoticeOnChat(from)
		self:showNoticeOnChatWithChannelId(from, CHANNEL_TYPE.UNION_CHANNEL, consortiaId, noticeInfo.type)
		self:noticeRunAnimaiton(self.startPosition, self.noticeContentWidth)
	-- 宗门聊天+跑马灯
	elseif noticeInfo.showType == app.notice.UNION_NORMAL_TYPE then
		self:showNoticeOnChatWithChannelId(from, CHANNEL_TYPE.UNION_CHANNEL, consortiaId, noticeInfo.type, self._mineId)
		if remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId == consortiaId then
			self:noticeRunAnimaiton(self.startPosition, self.noticeContentWidth)
		else
			app.notice:playNextNotice()
		end
	end
end

function QUIWidgetSystemNotice:createColorLabel(contents, names)
	local index = 1
	local mineId = nil
	for i = 1, #contents, 1 do
		local color = "white"
        if i % 2 == 0 and names[index] ~= nil then
        	color = self.colors[index]

        	if (contents[i] == "player_name" or contents[i] == "player_name_1") and names[index] == "" then
        		names[index] = "尚未取名"
        	elseif contents[i] == "item_name" or contents[i] == "equipped_name" then
        		names[index], color = self:getItemColor(names[index])
        	elseif contents[i] == "hero_name" then
        		names[index], color = self:getHeroColor(names[index])
        	elseif contents[i] == "break_through" then
        		names[index], color = self:getHeroBreakthough(tonumber(names[index]))
        	elseif contents[i] == "condition_type" then
        		names[index] = self:getCurrencyByType(names[index])
        	elseif contents[i] == "hero_character" then
        		names[index], color = self:getHeroCharater(names[index])
        	elseif contents[i] == "gemstone_name" then
        		names[index], color = self:getGemstoneColor(names[index])
        	elseif contents[i] == "grade_level" then
        		names[index], color = self:getHeroGradeColor(names[index])
        	elseif contents[i] == "target_item" then  
        		names[index], color = self:getAwardsColor(names[index])
        	elseif contents[i] == "artifact_breakthtough" then
				local level,colorIndex = remote.artifact:getBreakThroughLevel(tonumber(names[index]))
				names[index] = q.convertColorToWord(EQUIPMENT_QUALITY[colorIndex])
        	elseif contents[i] == "forest_name" then
        		mineId = tonumber(names[index])
				local mineConfig = remote.silverMine:getMineConfigByMineId( mineId )
				names[index] = remote.silverMine:getMineCNNameByQuality(mineConfig.mine_quality)
			elseif contents[i] == "hall_name" then
				local hallConfig = remote.consortiaWar:getHallConfigByHallId( names[index] )
				names[index] = hallConfig.name
        	end

        	self:createLabel(names[index], color)
    		self:setChatMessage(names[index], self.chatColors[index])

			self.noticeText = self.noticeText .. names[index]
        	index = index + 1
        else
        	self:createLabel(contents[i], color)
    		self:setChatMessage(contents[i], self.chatDefaultColour)

			self.noticeText = self.noticeText .. contents[i]
        end
	end

	return mineId
end

function QUIWidgetSystemNotice:getCurrencyByType(itemType)
	local currencyInfo = remote.items:getWalletByType(itemType)
	if currencyInfo then
		return currencyInfo.nativeName
	else
		return "未知"
	end
end

function QUIWidgetSystemNotice:getItemColor(itemId)
	local itemIds = string.split(itemId, "^")
	local itemType = remote.items:getItemType(tostring(itemIds[1]))
	if itemType ~= nil and  itemType ~= ITEM_TYPE.ITEM then
		local itemInfo = remote.items:getWalletByType(itemType)
		return itemInfo.nativeName, "purple"
	else
		if #itemIds == 2 then
		local breakInfo= remote.herosUtil:getEquipeBreakInfo(tostring(itemIds[2]), tonumber(itemIds[1]))
		local level,index = remote.herosUtil:getBreakThroughLevel(breakInfo.breakthrough_level or 0)
		local color = EQUIPMENT_QUALITY[index]
		if color == nil then
    		color = "yellow"
    	end
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(tostring(itemIds[1]))
    	return itemInfo.name, color
		else
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(tostring(itemId))
			return itemInfo.name, EQUIPMENT_QUALITY[itemInfo.colour]
		end
	end
end

function QUIWidgetSystemNotice:getHeroColor(heroName)
	local heroInfo = string.split(heroName, "^")

	if #heroInfo == 2 then
    	local level,color = remote.herosUtil:getBreakThrough(tonumber(heroInfo[2])) 
    	if color == nil then
    		color = "yellow"
    	end
    	return heroInfo[1], color
	else
		local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(heroName)
		local name, color = self:getHeroCharater(heroInfo.aptitude)
    	return heroInfo.name, color or "green"
	end
end

function QUIWidgetSystemNotice:getHeroBreakthough(breakthroughLevel)
    local level,color = remote.herosUtil:getBreakThrough(tonumber(breakthroughLevel)) 
    local word = ""
    local offsetLevel = level > 0 and ("+"..level) or ""
    if color == "green" then
    	word = "绿色"..offsetLevel
    elseif color == "blue" then
    	word = "蓝色"..offsetLevel
    elseif color == "purple" then
    	word = "紫色"..offsetLevel
    elseif color == "orange" then
    	word = "橙色"..offsetLevel
    elseif color == "red" then
    	word = "红色"..offsetLevel
    end
    return word, color
end

function QUIWidgetSystemNotice:getHeroCharater(aptitude)
	local name = ""
	local color = "white"
	aptitude = tonumber(aptitude) or 0
	if aptitude > 100 then
		local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(aptitude)
		aptitude = heroInfo.aptitude
		name = heroInfo.name
	end

	for _,value in ipairs(HERO_SABC) do
        if value.aptitude == aptitude then
			color = value.color
			if name == "" then
				name = value.qc
			end
        end
    end
	return name, color
end

function QUIWidgetSystemNotice:getGemstoneColor(gemstoneId)
	local itemInfo = db:getItemByID(tonumber(gemstoneId))
	for _,value in ipairs(HERO_SABC) do
        if value.aptitude == tonumber(itemInfo.gemstone_quality) then
			return itemInfo.name, value.color
        end
    end
	return "未知", "white"
end

function QUIWidgetSystemNotice:getHeroGradeColor(gradeLevel)
	local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(tonumber(gradeLevel))
	return level..gardeName, "orange"
end

function QUIWidgetSystemNotice:getAwardsColor(awards)
	local awards = string.split(awards, "^")

	if #awards == 2 then
		if tonumber(awards[1]) then
			local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(tostring(awards[1]))
			local name = awards[2] ~= nil and itemInfo.name.."*"..awards[2] or itemInfo.name
			return name, EQUIPMENT_QUALITY[itemInfo.colour]
		else
			local currencyInfo = remote.items:getWalletByType(awards[1])
			if currencyInfo then
				local name = awards[2] ~= nil and currencyInfo.nativeName.."*"..awards[2] or currencyInfo.nativeName
				return name, EQUIPMENT_QUALITY[currencyInfo.colour]
			else
				return "未知"
			end
		end
	else
		local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(tostring(awards[1]))
		return itemInfo.name, EQUIPMENT_QUALITY[itemInfo.colour]
	end
end

function QUIWidgetSystemNotice:createLabel(content, color)
	if color == "variable" or color == nil then
		color = "white"
	end

    if self.noticeType == 10000 then 
    	content = "系统公告：" .. content
    end

	local noticeInfo = CCLabelTTF:create()
	noticeInfo:setFontSize(24)
	noticeInfo:setAnchorPoint(ccp(0, 0.5))
	noticeInfo:setFontName(global.font_name)

	noticeInfo:setString(content)
	noticeInfo:setPosition(self.startPosition)
	-- printInfo("color is :" .. color)
	noticeInfo:setColor(UNITY_COLOR_LIGHT[color])
	self._pageContent:addChild(noticeInfo)
	-- noticeInfo = setShadow(noticeInfo, 2)

	-- self._pageContent:getChildren()
	self.startPosition.x = self.startPosition.x + noticeInfo:getContentSize().width
	self.noticeContentWidth = self.noticeContentWidth + noticeInfo:getContentSize().width
end

-- show notice content on chat
function QUIWidgetSystemNotice:setChatMessage(content, color)
	if nil ~= color then
		if color == "green" then
			color = "g"
		elseif color == "blue" then
			color = "b"
		elseif color == "purple" then
			color = "p"
		elseif color == "orange" then
			color = "o"
		elseif color == "yellow" then
			color = "y"
		elseif color == "red" then
			color = "r"
		elseif color == "white" then
			color = "w"
		elseif color == "variable" then
			color = "w"
		end
		self.chatText = self.chatText .. "##" .. color ..content
	else
		self.chatText = self.chatText .. content
	end
end 

function QUIWidgetSystemNotice:showNoticeOnChat(from)
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetSystemNotice.SHOW_NOTICE_ON_CHAT, from = from, message = self.chatText})
end

function QUIWidgetSystemNotice:showNoticeOnChatWithChannelId(from, channelId, consortiaId, index, mineId)
	if remote.user.userConsortia.consortiaId == nil then
		return 
	end
	if remote.user.userConsortia.consortiaId == consortiaId then
		local severChatData = app:getServerChatData()
	    severChatData:_onMessageReceived(channelId, from, from, self.chatText, q.OSTime(), {nickName = from, type = "admin", index = index, mineId = mineId})
	end
end

function QUIWidgetSystemNotice:noticeRunAnimaiton(startPosition, noticeContentWidth)
	local speed = 200
	local distance = (noticeContentWidth + self._pageWidth * 1.5)
	local time = distance / speed


	local moveTo = CCMoveTo:create(time, ccp(self._pageWidth/2 - distance, startPosition.y))
	local callFunc = CCCallFunc:create(function()
		self:noticeRunEnd()
		end)
	local action = CCArray:create()
    action:addObject(moveTo)
    action:addObject(callFunc)
	self._runAction = self._pageContent:runAction(CCSequence:create(action))
end

function QUIWidgetSystemNotice:noticeRunEnd( ... )
	if not next(app.notice:getNoticeList()) then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetSystemNotice.NO_MORE_NOTICE})
	end			
	app.notice:playNextNotice()
end

return QUIWidgetSystemNotice