-- @Author: xurui
-- @Date:   2017-04-10 19:15:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-12 10:40:42
local QUIDialog = import(".QUIDialog")
local QUIDialogSparRecycleSelection = class("QUIDialogSparRecycleSelection", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetSparFastBagClient = import("..widgets.spar.QUIWidgetSparFastBagClient")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogSparRecycleSelection.SPAR_CLICK = "SPAR_CLICK"

function QUIDialogSparRecycleSelection:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_kehuishou.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSparRecycleSelection.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

    self._ccbOwner.title:setString(options.type == 1 and "可分解外附魂骨" or "可重生外附魂骨")
    self._ccbOwner.title2:setString(options.type == 1 and "可分解外附魂骨" or "可重生外附魂骨")

    self._data = {}
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self:_initListView()
end

function QUIDialogSparRecycleSelection:viewDidAppear()
    QUIDialogSparRecycleSelection.super.viewDidAppear(self)

    self:setSparInfo()
end

function QUIDialogSparRecycleSelection:viewWillDisappear()
    QUIDialogSparRecycleSelection.super.viewWillDisappear(self)
end

function QUIDialogSparRecycleSelection:setSparInfo( ... )
    local options = self:getOptions()        
    local spars = remote.spar:getSparsByType()
    local isNone = false
    if table.nums(spars) > 0 then
        local sparsSorted = {}
        for k, v in pairs(spars) do
            if v.actorId == nil or v.actorId <= 0 then
                local sparInfo, sparPos = remote.spar:getSparsIndexBySparId(v.sparId)
                if options.type == 1 or remote.spar:checkSparIsInitial(v) == false then
                   table.insert(sparsSorted, {grade = v.grade, level = v.level, sparPos = sparPos, value = v})
                end
            end
        end
        if sparsSorted == nil or next(sparsSorted) == nil then
            isNone = true
        end

        table.sort(sparsSorted, function (x, y)
            if x.grade ~= y.grade then
                return x.grade > y.grade
            elseif x.level ~= y.level then
                return x.level > y.level
            elseif x.sparPos ~= y.sparPos then
                return x.sparPos < y.sparPos
            else
                return x.value.itemId < y.value.itemId
            end
            end)

        self._data = sparsSorted
        self._ccbOwner.node_no:setVisible(false)
    else
        isNone = true
    end

    if isNone then
        self._ccbOwner.node_no:setVisible(true)
        self._ccbOwner.na_text:setString("魂师大人，当前没有可用的外附魂骨！")
        return
    end


    self:_initListView()
end

function QUIDialogSparRecycleSelection:_initListView()
    local totalNumber = #self._data

    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self.renderFunHandler),
            ignoreCanDrag = true,
            totalNumber = totalNumber,
            enableShadow = false,
            spaceY = 0,
            contentOffsetX = -3,
            curOffset = 15,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:reload({totalNumber = totalNumber})
    end
end

function QUIDialogSparRecycleSelection:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetSparFastBagClient.new()

        isCacheNode = false
    end
    info.item = item
    local options = self:getOptions()        
    item:setInfo({info = data.value, sparPos = data.sparPos, recycleType = options.type, callback = handler(self, self._onTriggerChose)})
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_wear", "_onTriggerWear", nil, true)
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo", nil, true)
    item:registerItemBoxPrompt(index, list)

    return isCacheNode
end

function QUIDialogSparRecycleSelection:_onTriggerChose(event)
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogSparRecycleSelection.SPAR_CLICK, sparInfo = event.info})
	self:_onTriggerClose()
end

function QUIDialogSparRecycleSelection:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogSparRecycleSelection:_backClickHandler()
    self:_onTriggerClose()
end

return QUIDialogSparRecycleSelection