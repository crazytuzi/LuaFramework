-- @Author: liaoxianbo
-- @Date:   2020-08-28 17:09:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-01 15:02:33
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogMusicGameRule = class("QUIDialogMusicGameRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogMusicGameRule:ctor(options)
	QUIDialogMusicGameRule.super.ctor(self,options)
end

function QUIDialogMusicGameRule:initData( options )
	-- body
	local data = {}
	self._data = data
	

	table.insert(data,{oType = "describe", info = {
		helpType = "help_miusc_game",
		}})

end

function QUIDialogMusicGameRule:initListView( ... )
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

return QUIDialogMusicGameRule
