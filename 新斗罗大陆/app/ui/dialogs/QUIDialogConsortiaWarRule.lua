-- @Author: zhouxiaoshu
-- @Date:   2019-04-26 14:53:01
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-05-22 10:29:16
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogConsortiaWarRule = class("QUIDialogConsortiaWarRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIViewController = import("..QUIViewController")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogConsortiaWarRule:ctor(options)
	QUIDialogConsortiaWarRule.super.ctor(self, ccbFile, callBack, options)
	
	self.index = options.index
end

function QUIDialogConsortiaWarRule:initData(  )
	-- body
	local data = {}

	table.insert(data, {oType = "selfInfo"})
	table.insert(data, {oType = "describe", info = { helpType = "consortia_war_fight"}})
    table.insert(data, {oType = "empty", height = 10})
	table.insert(data, {oType = "title", info = {name = "宗门战每周奖励详细:"}})
    table.insert(data, {oType = "rank"})
    table.insert(data, {oType = "title", info = {name = "宗门战赛季奖励:"}})
	table.insert(data, {oType = "monthRank"})

	self._data = data
end

function QUIDialogConsortiaWarRule:initListView( ... )
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
            		elseif itemData.oType == "selfInfo" then
            			item = self:getSelfInfoNode()
            		elseif itemData.oType == "monthRank" then
            			item = self:getMonthRankNode()
            		elseif itemData.oType == "empty" then
                        item = QUIWidgetQlistviewItem.new()
	            	end
	            	isCacheNode = false
	            end
                if itemData.oType == "describe" or itemData.oType == "title" then
	            	item:setInfo(itemData.info)
	            end
	            if itemData.oType == "empty" then
                    item:setContentSize(CCSizeMake(0, itemData.height))
                end
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	headIndex = self.index,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogConsortiaWarRule:getRankNode()
	local node = CCNode:create()
	local configs = remote.consortiaWar:getRankConfig()
	table.sort(configs, function (a,b)
		return a.dan < b.dan
	end)
	local height = 30
	for _,config in ipairs(configs) do
		local awards = {}
		local awardConfig = db:getLuckyDraw(config.week_reward)
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
		local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")
		widget._ccbOwner.tf_1:setString(config.name)
		widget._ccbOwner.rank:setVisible(false)
		widget._ccbOwner.tf_2:setVisible(false)
		local posX = 0
		for i=1,5 do
			if awards[i] ~= nil then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
				itemBox:setScale(0.5)
				widget._ccbOwner["item"..i]:addChild(itemBox)
				widget._ccbOwner["reward_nums"..i]:setVisible(true)
				widget._ccbOwner["reward_nums"..i]:setString("x"..awards[i].count)
				widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
				widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
			else
				widget._ccbOwner["reward_nums"..i]:setVisible(false)
			end
		end
		widget:setPosition(ccp(430, -height))
		node:addChild(widget)
		height = height + 40
	end
	node:setContentSize(CCSize(100,height))
	return node
end

function QUIDialogConsortiaWarRule:getSelfInfoNode()
	local widget = QUIWidget.new("ccb/Widget_society_dragontrain_help1.ccbi")
	for i=1,4 do
		widget._ccbOwner["tf_value"..i]:setVisible(false)
	end
	widget:setContentSize(CCSize(100, 150))
	local myFighterInfo = remote.consortiaWar:getConsortiaWarInfo()
	local floor = 1
	local score = 1
	if myFighterInfo ~= nil then
		floor = myFighterInfo.floor or 1
		score = myFighterInfo.score or 1
	end
	local curfloorInfo = remote.consortiaWar:getRankInfo(floor)
	widget._ccbOwner.tf_level:setString(curfloorInfo.name)
	widget._ccbOwner.tf_score:setString(score)
	local awards = {}
	local awardConfig = db:getLuckyDraw(curfloorInfo.week_reward)
	if awardConfig ~= nil then
		local index = 1
		while true do
			local typeName = awardConfig["type_"..index]
			local id = awardConfig["id_"..index]
			local count = awardConfig["num_"..index]
			if typeName ~= nil then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setGoodsInfo(id, typeName, 0)
				itemBox:setScale(0.5)
				widget._ccbOwner["item"..index]:addChild(itemBox)
				widget._ccbOwner["tf_value"..index]:setVisible(true)
				widget._ccbOwner["tf_value"..index]:setString("x"..count)
			else
				break
			end
			index = index + 1
		end
	end

	return widget
end

function QUIDialogConsortiaWarRule:getMonthRankNode()
	local node = CCNode:create()
	local configs = remote.consortiaWar:getRankConfig()
	table.sort(configs, function (a,b)
		return a.dan < b.dan
	end)
	local height = 30
	for _,config in ipairs(configs) do
		local awards = {}
		local awardConfig = db:getLuckyDraw(config.month_reward)
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
		local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")
		widget._ccbOwner.tf_1:setString(config.name)
		widget._ccbOwner.rank:setVisible(false)
		widget._ccbOwner.tf_2:setVisible(false)
		local posX = 0
		for i = 1, 5 do
			if awards[i] ~= nil then
				local itemBox = QUIWidgetItemsBox.new()
				itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
				itemBox:setScale(0.5)
				widget._ccbOwner["item"..i]:addChild(itemBox)
				widget._ccbOwner["reward_nums"..i]:setVisible(true)
				widget._ccbOwner["reward_nums"..i]:setString("x"..awards[i].count)
				widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
				widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
			else
				widget._ccbOwner["reward_nums"..i]:setVisible(false)
			end
		end
		widget:setPosition(ccp(430, -height))
		node:addChild(widget)
		height = height + 40
	end
	node:setContentSize(CCSize(100,height))
	return node
end


return QUIDialogConsortiaWarRule