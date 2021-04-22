-- @Author: liaoxianbo
-- @Date:   2020-10-27 13:28:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-27 13:29:57
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogCustomShopRule = class("QUIDialogCustomShopRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogCustomShopRule:ctor(options)
	QUIDialogCustomShopRule.super.ctor(self,options)
end

function QUIDialogCustomShopRule:initData( options )
	-- body
	local data = {}
	self._data = data
	

	table.insert(data,{oType = "describe", info = {
		helpType = "help_custom_shop",
		}})

end

function QUIDialogCustomShopRule:initListView( ... )
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
	          
	            item:setInfo(itemData.info or {}, itemData.customStr)
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

return QUIDialogCustomShopRule
