--
-- Kumo.Wang
-- 新版魂师图鉴属性展示界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHandbookPropInfo = class("QUIDialogHandbookPropInfo", QUIDialog)

local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")

local QUIWidgetHandbookPropInfo = import("..widgets.QUIWidgetHandbookPropInfo")

function QUIDialogHandbookPropInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Handbook_Prop.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogHandbookPropInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true


	self._ccbOwner.frame_tf_title:setString(options.title or "属 性")

	if options then
		self._showType = options.showType
		self._actorId = options.actorId
	end

	self._data = {}

	if self._showType == remote.handBook.TYPE_ALL_PROP then
		self._data = remote.handBook:getActivatedHandbookPropList()
	elseif self._showType == remote.handBook.TYPE_EPIC_PROP then
		local tData = remote.handBook:getEpicPropConfigList()
		local curConfig = remote.handBook:getCurAndOldEpicPropConfig()
        local curLevel = curConfig.epic_level
		for _, info in ipairs(tData) do
			if curLevel <= info.epic_level then
				table.insert(self._data, info)
			end
		end
	elseif self._showType == remote.handBook.TYPE_BT_PROP then
		self._data = remote.handBook:getHandbookBTConfigListByActorId(self._actorId)
	end
    
    local propFields = QActorProp:getPropFields()
    self._maxWidth = 0
    for _, info in ipairs(self._data) do
	    for key, value in pairs(info) do
	        if propFields[key] and value > 0 then
	            local nameStr = propFields[key].handbookName or propFields[key].uiName or propFields[key].name
	            local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
	            local str = CCLabelTTF:create(nameStr.."+"..valueStr.."  ", global.font_default, 20)
	            local width = str:getContentSize().width
	            if width > self._maxWidth then
	                self._maxWidth = width
	            end
	        end
	    end
   	end
	self:initListView()
end

function QUIDialogHandbookPropInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._data,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end

	if self._showType == remote.handBook.TYPE_EPIC_PROP then
		self:_startScroll()
	end
end

function QUIDialogHandbookPropInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetHandbookPropInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(itemData, self._showType, self._actorId, self._maxWidth)
    info.size = item:getContentSize()

	return isCacheNode
end

function QUIDialogHandbookPropInfo:_startScroll()
	local curEpicPropConfig = remote.handBook:getCurAndOldEpicPropConfig()
    local pos = 0
    for i, config in ipairs(self._data) do
        if tostring(config.epic_level) == tostring(curEpicPropConfig.epic_level) then
            pos = i
            break
        end
    end

    if pos > 3 then
        self._contentListView:startScrollToIndex(pos, false, 100, nil, -40)
    end
end

function QUIDialogHandbookPropInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogHandbookPropInfo:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogHandbookPropInfo