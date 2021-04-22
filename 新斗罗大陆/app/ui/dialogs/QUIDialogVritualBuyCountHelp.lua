-- @Author: xurui
-- @Date:   2017-04-12 20:09:27
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-04-17 10:28:41
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogVritualBuyCountHelp = class("QUIDialogVritualBuyCountHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIDialogVritualBuyCountHelp:ctor(options)
	QUIDialogVritualBuyCountHelp.super.ctor(self, options)
end


function QUIDialogVritualBuyCountHelp:initData(  )
	-- body
	local data = {}
    local options = self:getOptions() or {}
	local helpType = nil
	if options then
		helpType = options.helpType
	end
	
	if helpType then
		table.insert(data,{oType = "describe", info = {
			helpType = helpType
			}})
	end

	self._data = data
end

function QUIDialogVritualBuyCountHelp:initListView( ... )
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


return QUIDialogVritualBuyCountHelp