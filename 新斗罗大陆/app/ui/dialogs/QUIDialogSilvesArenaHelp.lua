-- @Author: dsl
-- @Date:   2020-05-29 11:37:25
-- 希尔维斯 帮助界面

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogSilvesArenaHelp = class("QUIDialogSilvesArenaHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")
local QUIViewController = import("..QUIViewController")

--初始化
function QUIDialogSilvesArenaHelp:ctor(options)
	QUIDialogSilvesArenaHelp.super.ctor(self,options)

    self:setShowRule(false)
end

function QUIDialogSilvesArenaHelp:viewAnimationInHandler()
	remote.silvesArena:silvesArenaGetZoneListRequest(function (data)
		if self.class then
			local gameAreaNameList = nil
			if data.silvesArenaInfoResponse.gameArenList then
				gameAreaNameList = data.silvesArenaInfoResponse.gameArenList.gameAreaNameList
			end
			self:initListView(gameAreaNameList)
		end
	end,function ()	
		self:initListView()
	end)
end

function QUIDialogSilvesArenaHelp:initListView( areaNameList )
	local areaStr = ""
	if areaNameList == nil or next(areaNameList) == nil then
		areaStr = "当前暂无匹配服务器"
	end

	local data = {}
	self._data = data
	table.insert(data, {oType = "describe", info = {helpType = "silves_arena"}})
    table.insert(data, {oType = "empty", height = 10})
    table.insert(data, {oType = "title", info = {name = "排名奖励:"}})
	table.insert(data, {oType = "rank"})
    table.insert(data, {oType = "empty", height = 10})
    table.insert(data, {oType = "title", info = {name = "本次匹配服务器:"}})
	if not q.isEmpty(areaNameList) then
		table.insert(data,{oType = "serverName", info = areaNameList})
	end
	table.insert(data, {oType = "empty", height = 10})
	table.insert(data, {oType = "describe", info = {helpType = "team_arena_peak"}})
	table.insert(data, {oType = "peakRank"})

	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "describe" then
	            		item = QUIWidgetHelpDescribe.new()
	            	elseif itemData.oType == "title" then
                        item = QUIWidgetBaseHelpTitle.new()
            		elseif itemData.oType == "rank" then
            			item = self:getRankNode()
        			elseif itemData.oType == "serverName" then
        				item = self:getServerNode(itemData.info)
        			elseif itemData.oType == "empty" then
                        item = QUIWidgetQlistviewItem.new()
                    elseif itemData.oType == "peakRank" then
                    	item = self:getPeakRankNode()
	            	end
	            	isCacheNode = false
	            end
                if itemData.oType == "describe" or itemData.oType == "title" then
                    item:setInfo(itemData.info)
                end
                if itemData.oType == "empty" then
                    item:setContentSize(CCSizeMake(0, itemData.height))
                end
	           
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogSilvesArenaHelp:getRankNode()
	local rankConfigs = db:getSilvesAeraneConfigs()
	local configs = {}
	for _, config in pairs(rankConfigs) do

		if config.level_min <= remote.user.level and remote.user.level <= config.level_max then
			table.insert(configs, config)
		end
	end

	table.sort(configs, function (a,b)
		return a.rank_min < b.rank_min
	end)
	local height = 30
	local node = CCNode:create()
	for i = 1, #configs do
		local widget = CCNode:create()
		local bgSp = CCSprite:create("ui/GloryTower/G_kuangtiao.png")
		bgSp:setPosition(400, 2)
		widget:addChild(bgSp)

		local tfName = CCLabelTTF:create("", global.font_default, 20)
		tfName:setColor(ccc3(253,237,195))
		tfName:setAnchorPoint(ccp(0, 0.5))
		tfName:setPosition(15, 0)
		widget:addChild(tfName)

		if configs[i].rank_min ~= configs[i].rank_max then
			tfName:setString(string.format("第%s~%s名: ", configs[i].rank_min, configs[i].rank_max))
		else
			tfName:setString(string.format("第%s名: ", configs[i].rank_min))
		end

		local awards = {}
		local awardConfig = string.split(configs[i].awards,";")
		if awardConfig ~= nil then
			for i,v in ipairs(awardConfig) do
				local awardStp = string.split(v,"^")

				local typeName = nil
				local id = tonumber(awardStp[1])
				local count = tonumber(awardStp[2])
				if id == nil then
					typeName = awardStp[1]
				end

				table.insert(awards, {id = id, typeName = typeName, count = count})
			end
		end

		local posX = 260
		for i = 1, 5 do
			if awards[i] ~= nil then
				local itembox = QUIWidgetItemsBox.new()
				itembox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
				itembox:setPositionX(posX)
				itembox:setScale(0.35)
				widget:addChild(itembox)

				local tfCount = CCLabelTTF:create("x"..awards[i].count, global.font_default, 20)
				tfCount:setAnchorPoint(ccp(0, 0.5))
				tfCount:setPosition(posX + 20, -6)
				widget:addChild(tfCount)
				posX = posX + 140
			end
		end
		widget:setPosition(ccp(10, -height))
		node:addChild(widget)
		height = height + 60
	end
	node:setContentSize(CCSize(792, height))

	return node
end


function QUIDialogSilvesArenaHelp:getPeakRankNode()
	local configs = db:getRankAwardsByType("team_arena_peak", remote.user.level)
	
	table.sort(configs, function (a,b)
		return a.rank < b.rank
	end)
	local height = 30
	local node = CCNode:create()
	for i = 1, #configs do
		local widget = CCNode:create()
		local bgSp = CCSprite:create("ui/GloryTower/G_kuangtiao.png")
		bgSp:setPosition(400, 2)
		widget:addChild(bgSp)

		local tfName = CCLabelTTF:create("", global.font_default, 20)
		tfName:setColor(ccc3(253,237,195))
		tfName:setAnchorPoint(ccp(0, 0.5))
		tfName:setPosition(15, 0)
		widget:addChild(tfName)
		if i > 1 and configs[i - 1] and configs[i - 1].rank and  tonumber(configs[i - 1].rank) + 1 ~= configs[i].rank then
			tfName:setString(string.format("第%s~%s名: ", tonumber(configs[i - 1].rank) + 1, configs[i].rank))
		else
			tfName:setString(string.format("第%s名: ", configs[i].rank))
		end

		local awards = {}
		local awardConfig = db:getLuckyDraw(configs[i].lucky_draw)
		if awardConfig ~= nil then
			local index = 1
			while true do
				local typeName = awardConfig["type_"..index]
				local id = awardConfig["id_"..index]
				local count = awardConfig["num_"..index]
				if typeName ~= nil then
					table.insert(awards, {id = id, typeName = typeName, count = count})
				else
					break
				end
				index = index + 1
			end
		end

		local posX = 260
		for i = 1, 5 do
			if awards[i] ~= nil then
				local itembox = QUIWidgetItemsBox.new()
				itembox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
				itembox:setPositionX(posX)
				itembox:setScale(0.35)
				widget:addChild(itembox)

				local tfCount = CCLabelTTF:create("x"..awards[i].count, global.font_default, 20)
				tfCount:setAnchorPoint(ccp(0, 0.5))
				tfCount:setPosition(posX + 20, -6)
				widget:addChild(tfCount)
				posX = posX + 140
			end
		end
		widget:setPosition(ccp(10, -height))
		node:addChild(widget)
		height = height + 60
	end
	node:setContentSize(CCSize(792, height))

	return node
end

function QUIDialogSilvesArenaHelp:getServerNode(info)
	local nameTbl = {}
	local index = 0
	for i, name in ipairs(info) do
		if (i-1) % 3 == 0 then
			index = index + 1
			nameTbl[index] = {}
		end
		table.insert(nameTbl[index], name)
	end
	local node = CCNode:create()
	local height = 0
	for _, names in ipairs(nameTbl) do
		local str = ""
		for _, name in pairs(names) do
			str = str..name.."  "
		end
		local tf = CCLabelTTF:create("", global.font_default, 20, CCSize(725, 0), kCCTextAlignmentLeft)
		tf:setAnchorPoint(ccp(0, 1))
		tf:setColor(GAME_COLOR_LIGHT.normal)
		tf:setPosition(ccp(25, -height))
		tf:setString(str)
		node:addChild(tf)

		height = height + tf:getContentSize().height
	end

	node:setContentSize(CCSize(792, height+20))

	return node
end

function QUIDialogSilvesArenaHelp:showRule()
    app.sound:playSound("common_cancel")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryTutorialDialog", options = {}}, {isPopCurrentDialog = false})
end

return QUIDialogSilvesArenaHelp
