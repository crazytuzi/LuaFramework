-- @Author: liaoxianbo
-- @Date:   2020-08-06 15:32:59
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-19 09:48:31
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogMazeExploreRule = class("QUIDialogMazeExploreRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogMazeExploreRule:ctor(options)
	QUIDialogMazeExploreRule.super.ctor(self,options)
end

function QUIDialogMazeExploreRule:initData( options )
	-- body
	local data = {}
	self._data = data
	

	table.insert(data,{oType = "describe", info = {
		helpType = "help_maze_explore",
		}})

end

function QUIDialogMazeExploreRule:initListView( ... )
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


return QUIDialogMazeExploreRule
