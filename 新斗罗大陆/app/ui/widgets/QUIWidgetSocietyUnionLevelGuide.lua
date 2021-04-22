local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSocietyUnionLevelGuide = class("QUIWidgetSocietyUnionLevelGuide", QUIWidget)
local QUIWidgetSocietyUnionLevelGuideSheet = import("..widgets.QUIWidgetSocietyUnionLevelGuideSheet")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QListView = import("...views.QListView")

function QUIWidgetSocietyUnionLevelGuide:ctor(options)
	local ccbFile = "Widget_society_union_level_guide.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyUnionLevelGuide.super.ctor(self,ccbFile,callBacks,options)

	local level = remote.union.consortia.level or 0
	self._datas = QStaticDatabase:sharedDatabase():getLevelGuideInfosByType(LEVEL_GOAL.UNION)
	table.sort(self._datas, function (a, b)
		if a.closing_condition > level and b.closing_condition > level then
			return a.closing_condition < b.closing_condition
		end
		return a.closing_condition > b.closing_condition
	end)
end

function QUIWidgetSocietyUnionLevelGuide:onEnter()
	QUIWidgetSocietyUnionLevelGuide.super.onEnter(self)
	self:initListView()
end

function QUIWidgetSocietyUnionLevelGuide:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = true,
	        totalNumber = #self._datas,
	        spaceY = 0,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._datas})
	end
end

function QUIWidgetSocietyUnionLevelGuide:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._datas[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSocietyUnionLevelGuideSheet.new()
        isCacheNode = false
    end

    info.item = item
	item:setInfo(data)
    info.size = item:getContentSize()
	return isCacheNode
end


return QUIWidgetSocietyUnionLevelGuide