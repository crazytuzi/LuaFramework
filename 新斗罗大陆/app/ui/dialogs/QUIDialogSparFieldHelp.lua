local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogSparFieldHelp = class("QUIDialogSparFieldHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidget = import("..widgets.QUIWidget")
--初始化
function QUIDialogSparFieldHelp:ctor(options)
	QUIDialogSparFieldHelp.super.ctor(self,options)
end

function QUIDialogSparFieldHelp:initData( options )
	-- body
	local options = self:getOptions() 

	local data = {}
	self._data = data
	table.insert(data,{oType = "describe", info = {helpType = "spar_help"}})
	-- table.insert(data,{oType = "describe", info = {helpType = "spar_explore"}})
	-- table.insert(data,{oType = "describe", info = {helpType = "spar_explore_lev_reward"}})	 
	-- table.insert(data,{oType = "rank"})
end

function QUIDialogSparFieldHelp:initListView( ... )
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
            		-- elseif itemData.oType == "rank" then
            		-- 	item = self:getRankNode()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {})
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

-- function QUIDialogSparFieldHelp:getRankNode()
-- 	local node = CCNode:create()
-- 	local _configs = QStaticDatabase:sharedDatabase():getSparFieldLevel()
-- 	local configs = {}
-- 	for _,v in pairs(_configs) do
-- 		table.insert(configs, v)
-- 	end
-- 	table.sort(configs, function (a,b)
-- 		return a.lev < b.lev
-- 	end)
-- 	local height = 30
-- 	for _,config in ipairs(configs) do
-- 		local awards = {}
-- 		local awardConfig = QStaticDatabase:sharedDatabase():getLuckyDraw(config.reward)
-- 		if awardConfig ~= nil then
-- 			local index = 1
-- 			while true do
-- 				local typeName = awardConfig["type_"..index]
-- 				local id = awardConfig["id_"..index]
-- 				local count = awardConfig["num_"..index]
-- 				if typeName ~= nil then
-- 					table.insert(awards, {id = id, typeName = typeName, count = count})
-- 				else
-- 					break
-- 				end
-- 				index = index + 1
-- 			end
-- 		end
-- 		local widget = QUIWidget.new("ccb/Widget_RewardRules_client3.ccbi")

-- 		widget._ccbOwner.tf_1:setString(string.format("探索等级%d级奖励: ", config.lev))
-- 		widget._ccbOwner.rank:setString("")
-- 		widget._ccbOwner.tf_2:setString("")
-- 		local posX = widget._ccbOwner.tf_1:getContentSize().width - 70
-- 		if posX < 0 then posX = 0 end
-- 		for i=1,5 do
-- 			if awards[i] ~= nil then
-- 				local itemBox = QUIWidgetItemsBox.new()
-- 				itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, 0)
-- 				itemBox:setScale(0.5)
-- 				widget._ccbOwner["item"..i]:addChild(itemBox)
-- 				widget._ccbOwner["reward_nums"..i]:setString("x "..awards[i].count)
-- 				widget._ccbOwner["item"..i]:setPositionX(widget._ccbOwner["item"..i]:getPositionX() + posX)
-- 				widget._ccbOwner["reward_nums"..i]:setPositionX(widget._ccbOwner["reward_nums"..i]:getPositionX() + posX)
-- 			else
-- 				widget._ccbOwner["reward_nums"..i]:setString("")
-- 			end
-- 		end
-- 		widget:setPosition(ccp(430, -height))
-- 		node:addChild(widget)
-- 		height = height + 40
-- 	end
-- 	node:setContentSize(CCSize(100,height))
-- 	return node
-- end


return QUIDialogSparFieldHelp
