--
-- Kumo.Wang
-- 鼠年新春活動幫助
--

local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogRatFestivalHelp = class("QUIDialogRatFestivalHelp", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
--初始化
function QUIDialogRatFestivalHelp:ctor(options)
	QUIDialogRatFestivalHelp.super.ctor(self,ccbFile,callBacks,options)

	if options then
		self._helpType = options.helpType
	end
end


function QUIDialogRatFestivalHelp:initDataAtAnimationIn(  )
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = self._helpType,
		}})

	self._data = data
end

function QUIDialogRatFestivalHelp:initListView( ... )
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


return QUIDialogRatFestivalHelp
