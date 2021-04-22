



local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogHighTeaHelp = class("QUIDialogHighTeaHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

--初始化
function QUIDialogHighTeaHelp:ctor(options)
	QUIDialogHighTeaHelp.super.ctor(self,options)
    self:setShowRule(false)
end

function QUIDialogHighTeaHelp:initData()
	-- -- body
	self._data = {}
	table.insert(self._data, {oType = "describe", info = {helpType = "help_xiawucha"}})
   
	-- self.info = remote.sotoTeam:getMyInfo()

	-- local data = {}
	-- self._data = data
	-- table.insert(data, {oType = "describe", info = {
	-- 	helpType = "soto_team_1",
	-- 	lineSpacing = 0,
	-- 	paramArr = {self.info.topRank},
	-- }})
	-- --table.insert(data, {oType = "empty", height = 10})
	-- --table.insert(data, {oType = "line"})
	-- --table.insert(data, {oType = "empty", height = 10})
	
 --    local awardConfigs = db:getRewardConfigByLevel(remote.user.level)
 --    table.sort(awardConfigs, function(a, b)
 --    	return a.ID < b.ID
	-- end)
 --    --去除显示排名所得
 -- --    local curConfig = nil
 -- --    local nextConfig = nil
 -- --    for i, awardConfig in pairs(awardConfigs) do
 -- --    	if awardConfig.rank > self.info.curRank then
 -- --    		nextConfig = awardConfig
 -- --    		break
 -- --    	end
 -- --    	curConfig = awardConfig
 -- --    end
	-- -- table.insert(data,{oType = "describe", info = {
	-- -- 	helpType = "soto_team_2",
	-- -- 	paramArr = {self.info.curRank, curConfig.rank, nextConfig.rank-1}
	-- -- }})

	-- -- local rankItemInfo = db:getSotoTeamRewardById(curConfig.ID)
	-- -- local awardsArr = {}
	-- -- local temp = {}
	-- -- for i=1,4 do
	-- -- 	if rankItemInfo["num_"..i] then
	-- -- 		table.insert(awardsArr, {id = rankItemInfo["id_"..i] or rankItemInfo["type_"..i], count = rankItemInfo["num_"..i]})
	-- -- 	end
	-- -- end
	-- -- temp.awardsArr = awardsArr
	-- -- table.insert(data, {oType = "award", info = temp})

	-- table.insert(data, {oType = "describe", info = {helpType = "soto_team_3"}})

 --    local preRank = 1
	-- for i, awardConfig in pairs(awardConfigs)  do
	-- 	if awardConfig.rank > 15000 then
	-- 		break
	-- 	end
	-- 	local rankItemInfo = db:getSotoTeamRewardById(awardConfig.ID)
	-- 	local temp = {}
	-- 	local awardsArr = {}
	-- 	for i = 1, 4 do
	-- 		if rankItemInfo["num_"..i] then
	-- 			table.insert(awardsArr, {id = rankItemInfo["id_"..i] or rankItemInfo["type_"..i], count = rankItemInfo["num_"..i]})
	-- 		end
	-- 	end
	-- 	temp.awardsArr = awardsArr
	-- 	if preRank == awardConfig.rank then
	-- 		temp.rankStr = string.format("第%s名", awardConfig.rank)
	-- 	else
	-- 		temp.rankStr = string.format("第%s-%s名", preRank, awardConfig.rank)
	-- 	end
	-- 	table.insert(data, {oType = "award", info = temp})
	-- 	preRank = awardConfig.rank + 1
	-- end
	-- table.insert(data, {oType = "describe", info = {helpType = "soto_team_7"}})
	-- table.insert(data, {oType = "describe", info = {helpType = "soto_team_4"}})
	-- table.insert(data, {oType = "describe", info = {helpType = "soto_team_5"}})
	-- table.insert(data, {oType = "describe", info = {helpType = "soto_team_6"}})


	-- preRank = 1
	-- for i, awardConfig in pairs(awardConfigs)  do

	-- 	if awardConfig.rank > 15000 then
	-- 		break
	-- 	end

	-- 	local rankItemInfo = db:getSotoTeamSeasonRewardById(awardConfig.ID)

	-- 	local reward ={}
 --    	local index_ = 1
	--     while rankItemInfo["num_"..index_] do
	--         table.insert(reward, {id = rankItemInfo["id_"..index_] or rankItemInfo["type_"..index_] , typeName = rankItemInfo["type_"..index_] or ITEM_TYPE.ITEM, count = rankItemInfo["num_"..index_]})
	--         index_ = index_ + 1
	--     end
	--     if index_ > 1 then
	-- 		local rankStr = awardConfig.rank
	-- 		if preRank < awardConfig.rank then
	-- 			rankStr = preRank.."-"..awardConfig.rank
	-- 		end
	-- 		preRank = awardConfig.rank + 1
	-- 		table.insert(data,{oType = "rank", info = {reward = reward, rankStr = rankStr}})
	-- 	end
	-- end	
end

function QUIDialogHighTeaHelp:initListView( ... )
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
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetBaseHelpAward.new()
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "empty" then
	            	item:setContentSize(CCSizeMake(0, itemData.height))
	            elseif itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {}, itemData.customStr)
	            else
	            	item:setInfo(itemData.info)
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


function QUIDialogHighTeaHelp:showRule()
    app.sound:playSound("common_cancel")
end

return QUIDialogHighTeaHelp