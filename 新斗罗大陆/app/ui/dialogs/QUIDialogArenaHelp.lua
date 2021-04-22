
--[[	
	文件名称：QUIDialogArenaHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogArenaHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogArenaHelp = class("QUIDialogArenaHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
--初始化
function QUIDialogArenaHelp:ctor(options)
	QUIDialogArenaHelp.super.ctor(self,options)
end

function QUIDialogArenaHelp:initData( options )
	-- body
	local options = self:getOptions() 
	self.info = options.info or {} 

	local data = {}
	self._data = data
	table.insert(data,{oType = "describe", info = {
		helpType = "arena_shuoming_1",
		lineSpacing = 0,
		paramArr = {self.info.topRank},
		}})
	table.insert(data,{oType = "empty", height = 10})
	table.insert(data,{oType = "line"})
	table.insert(data,{oType = "empty", height = 10})
	
	local rankItemInfo, larget, low = QStaticDatabase:sharedDatabase():getAreanRewardByRank(self.info.rank, remote.user.level)
	table.insert(data,{oType = "describe", info = {
		helpType = "arena_shuoming_2",
		paramArr={self.info.rank,larget,low}
		}})
	local awardsArr = {}
	local temp = {}
	temp.awardsArr = awardsArr
	for i=1,4 do
		if rankItemInfo["num_"..i] then
			table.insert(awardsArr, {id = rankItemInfo["id_"..i] or rankItemInfo["type_"..i], count = rankItemInfo["num_"..i]})
		end
	end
	table.insert(data, {oType = "award", info = temp})

	table.insert(data,{oType = "describe", info = {
		helpType = "arena_shuoming_3",
		}})

	for i=1,10 do
		local rankItemInfo = QStaticDatabase:sharedDatabase():getAreanRewardByRank(i, remote.user.level)
		temp = {}
		awardsArr = {}
		temp.awardsArr = awardsArr
		temp.rankStr = string.format("第%s名",i)
		for i=1,4 do
			if rankItemInfo["num_"..i] then
				table.insert(awardsArr, {id = rankItemInfo["id_"..i] or rankItemInfo["type_"..i], count = rankItemInfo["num_"..i]})
			end
		end
		table.insert(data, {oType = "award", info = temp})
	end
	table.insert(data,{oType = "describe", info = {
		helpType = "arena_shuoming_4",
		}})
	 
end

function QUIDialogArenaHelp:initListView( ... )
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



return QUIDialogArenaHelp
