--
-- Author: Kumo.Wang
-- 宗门红包帮助
--
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogRedpacketRule = class("QUIDialogRedpacketRule", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogRedpacketRule:ctor(options)
	QUIDialogRedpacketRule.super.ctor(self, ccbFile, callBack, options)
end
function QUIDialogRedpacketRule:initData(  )
	-- body
	local data = {}

	table.insert(data,{oType = "describe", info = {
		helpType = "consortia_redpacket",
		}})

	self._data = data
end

function QUIDialogRedpacketRule:initListView( ... )
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


return QUIDialogRedpacketRule