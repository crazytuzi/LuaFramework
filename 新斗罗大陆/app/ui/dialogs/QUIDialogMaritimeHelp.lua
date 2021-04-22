-- @Author: xurui
-- @Date:   2017-01-04 15:13:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-04-01 12:15:56
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogMaritimeHelp = class("QUIDialogMaritimeHelp", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")

function QUIDialogMaritimeHelp:ctor(options)
	QUIDialogMaritimeHelp.super.ctor(self,ccbFile,callBacks,options)
end

function QUIDialogMaritimeHelp:initData(  )
	-- body
	local data = {}
	table.insert(data,{oType = "describe", info = {
		helpType = "maritime_1",
		}})
	table.insert(data,{oType = "empty", height = 10})
	table.insert(data,{oType = "line"})
	table.insert(data,{oType = "empty", height = 10})
	
	table.insert(data,{oType = "describe", info = {
		helpType = "maritime_2",
		}})

	table.insert(data,{oType = "empty", height = 10})
	table.insert(data,{oType = "line"})
	table.insert(data,{oType = "empty", height = 10})

	table.insert(data,{oType = "describe", info = {
		helpType = "maritime_3",
		}})


	table.insert(data,{oType = "empty", height = 10})

	table.insert(data,{oType = "describe", info = {
		helpType = "maritime_4",
		}})

	table.insert(data,{oType = "empty", height = 10})


	local awards = remote.maritime:getMaritimeShipAwardsInfo()
	local awardsData = {}
	for _, tempData in  pairs(awards) do
		if tempData.ship_id >= remote.maritime.startShipId then
			table.insert(awardsData, tempData)
		end
	end
	
	table.sort( awardsData, function(a, b) 
			if a.ship_id ~= b.ship_id then
				return a.ship_id > b.ship_id
			end
		end )
	for _, tempData in ipairs(awardsData) do
		if remote.user.level >= tempData.ship_level_min and remote.user.level <= tempData.ship_level_max then
			local temp = {}
			temp.awardsArr = {}
			for i = 1, 1 do
				local id = tempData["id_"..i]
				if id == nil then
					id = tempData["type_"..i]
				end
				local num = tempData["num_"..i]

				if tempData["plunder_"..i] == 0 then
					num = tempData["num_"..i]
				end
				table.insert(temp.awardsArr, {id = id, count = math.floor(num)})
			end
			local shipColor = {"##A", "##b", "##p", "##o", "##r", "##y"}

			temp.rankStr = shipColor[tempData.ship_id]..tempData.ship_name
			temp.awardOffsetX = -20
			temp.awardOffsetY = -5
			table.insert(data, {oType = "award", info = temp})
		end
	end

	table.insert(data,{oType = "empty", height = 10})

	self._data = data

end

function QUIDialogMaritimeHelp:initListView( ... )
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
	           	info.tag = itemData.oType
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

return QUIDialogMaritimeHelp