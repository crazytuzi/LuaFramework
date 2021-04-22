local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogUnionDragonWarRule = class("QUIDialogUnionDragonWarRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogUnionDragonWarRule:ctor(options)
	QUIDialogUnionDragonWarRule.super.ctor(self, ccbFile, callBack, options)
	self.index = options.index
end

function QUIDialogUnionDragonWarRule:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "selfInfo"})
	table.insert(data,{oType = "describe", info = { helpType = "sociaty_dragon_fight"}})
	table.insert(data,{oType = "rank"})
	table.insert(data,{oType = "describe", info = { helpType = "sociaty_dragon_fight_month"}})
	table.insert(data,{oType = "monthRank"})

	self._data = data
end

function QUIDialogUnionDragonWarRule:initListView( ... )
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
            		elseif itemData.oType == "rank" then
            			item = self:getRankNode()
            		elseif itemData.oType == "selfInfo" then
            			item = self:getSelfInfoNode()
            		elseif itemData.oType == "monthRank" then
            			item = self:getMonthRankNode()
	            	end
	            	isCacheNode = false
	            end
            	if itemData.oType == "describe" then
	            	item:setInfo(itemData.info)
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

function QUIDialogUnionDragonWarRule:getRankNode()
	local node = CCNode:create()
	local configs = db:getDragonFloorAwardsByLevel(remote.user.level)
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

function QUIDialogUnionDragonWarRule:getSelfInfoNode()
	local widget = QUIWidget.new("ccb/Widget_society_dragontrain_help1.ccbi")
	for i=1,4 do
		widget._ccbOwner["tf_value"..i]:setVisible(false)
	end
	widget:setContentSize(CCSize(100, 150))
	local myFighterInfo = remote.unionDragonWar:getMyDragonFighterInfo()
	local floor = 1
	if myFighterInfo ~= nil then
		floor = myFighterInfo.floor or 1
	end
	local floorData = db:getUnionDragonFloorInfoByFloor(floor)
	widget._ccbOwner.tf_level:setString(floorData.name)
	widget._ccbOwner.tf_score:setString(myFighterInfo.score)
	local awards = {}
	local awardConfig = db:getLuckyDraw(floorData.week_reward)
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

function QUIDialogUnionDragonWarRule:getMonthRankNode()
	local node = CCNode:create()
	local configs = db:getDragonFloorAwardsByLevel(remote.user.level)
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


return QUIDialogUnionDragonWarRule