local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogHeroPropHelp = class("QUIDialogHeroPropHelp", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")

function QUIDialogHeroPropHelp:ctor(options)
	QUIDialogHeroPropHelp.super.ctor(self, options)
end
function QUIDialogHeroPropHelp:initData(  )
	-- body
	local options = self:getOptions()
	local helpType = "quality_help"
	if options then
		helpType = options.helpType
	end
	local data = {}
	table.insert(data,{oType = "describe", info = { helpType = helpType}})

	self._data = data
end

function QUIDialogHeroPropHelp:initListView( ... )
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

return QUIDialogHeroPropHelp