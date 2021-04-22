--
-- zxs
-- 宗门武魂伤害
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoLog = class("QUIWidgetUnionDragonWarInfoLog", QUIWidget)
local QUIWidgetUnionDragonWarInfoLogClient = import(".QUIWidgetUnionDragonWarInfoLogClient")
local QListView = import("....views.QListView")

function QUIWidgetUnionDragonWarInfoLog:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_info_client2.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonWarInfoLog.super.ctor(self, ccbFile, callBacks, options)

	self._data = {}
end

function QUIWidgetUnionDragonWarInfoLog:onEnter()
	QUIWidgetUnionDragonWarInfoLog.super.onEnter(self)

   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoLog:onExit()
    QUIWidgetUnionDragonWarInfoLog.super.onExit(self)
end

function QUIWidgetUnionDragonWarInfoLog:setInfo(info)
    self._data = info
   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoLog:initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = true,
	        spaceY = 5,
	        enableShadow = false,
	        curOffset = 5,
	        totalNumber = #self._data
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetUnionDragonWarInfoLog:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetUnionDragonWarInfoLogClient.new()
        isCacheNode = false
    end
    item:setInfo(data, index)
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

return QUIWidgetUnionDragonWarInfoLog