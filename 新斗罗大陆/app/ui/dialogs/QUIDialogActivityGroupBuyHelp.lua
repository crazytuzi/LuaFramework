
--[[	
	文件名称：QUIDialogActivityGroupBuyHelp.lua
	创建时间：2016-07-30 19:21:53
	作者：nieming
	描述：QUIDialogActivityGroupBuyHelp
]]

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogActivityGroupBuyHelp = class("QUIDialogActivityGroupBuyHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogActivityGroupBuyHelp:ctor(options)
	QUIDialogActivityGroupBuyHelp.super.ctor(self,ccbFile,callBacks,options)
end


function QUIDialogActivityGroupBuyHelp:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = "group_buying",
		}})

	self._data = data
end

function QUIDialogActivityGroupBuyHelp:initListView( ... )
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
	            	end
	            	isCacheNode = false
	            end
	            item:setInfo(itemData.info)
	            info.tag = itemData.oType
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 20,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end


return QUIDialogActivityGroupBuyHelp
