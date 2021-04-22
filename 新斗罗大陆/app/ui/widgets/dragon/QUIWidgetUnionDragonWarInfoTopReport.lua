--
-- zxs
-- 宗门武魂伤害
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonWarInfoTopReport = class("QUIWidgetUnionDragonWarInfoTopReport", QUIWidget)
local QUIWidgetUnionDragonWarTopRecord = import(".QUIWidgetUnionDragonWarTopRecord")
local QListView = import("....views.QListView")

function QUIWidgetUnionDragonWarInfoTopReport:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_info_client2.ccbi"
	local callBacks = {
	}
	QUIWidgetUnionDragonWarInfoTopReport.super.ctor(self, ccbFile, callBacks, options)

	self._data = {}
end

function QUIWidgetUnionDragonWarInfoTopReport:onEnter()
	QUIWidgetUnionDragonWarInfoTopReport.super.onEnter(self)

   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoTopReport:onExit()
    QUIWidgetUnionDragonWarInfoTopReport.super.onExit(self)
end

function QUIWidgetUnionDragonWarInfoTopReport:setInfo(info)
    self._data = info
   	self:initListView()
end

function QUIWidgetUnionDragonWarInfoTopReport:initListView()
	if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = true,
            spaceY = -4,
	        curOffset = 5,
	        totalNumber = #self._data,
            enableShadow = false,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIWidgetUnionDragonWarInfoTopReport:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then	       	
    	item = QUIWidgetUnionDragonWarTopRecord.new()
        isCacheNode = false
    end
    item:setInfo(data, index)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_head", "_onTriggerHead")
    list:registerBtnHandler(index, "btn_replay", "_onTriggerReplay", nil, true)
    list:registerBtnHandler(index, "btn_share", "_onTriggerShare", nil, true)

    return isCacheNode
end

return QUIWidgetUnionDragonWarInfoTopReport