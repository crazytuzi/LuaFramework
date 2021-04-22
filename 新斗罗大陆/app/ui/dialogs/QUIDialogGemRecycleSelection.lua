local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemRecycleSelection = class("QUIDialogGemRecycleSelection", QUIDialog)

local QScrollView = import("...views.QScrollView")
local QUIWidgetGemstoneFastBagItem = import("..widgets.QUIWidgetGemstoneFastBagItem")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QListView = import("...views.QListView")

QUIDialogGemRecycleSelection.GEM_CLICK = "QUIDialogGemRecycleSelection_GEM_CLICK"

function QUIDialogGemRecycleSelection:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_kehuishou.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogGemRecycleSelection.super.ctor(self,ccbFile,callBacks,options)

	self.isAnimation = true

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._height = self._ccbOwner.sheet_layout:getContentSize().height

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {bufferMode = 2, sensitiveDistance = 10})
    self._itemSize, self._itemObjects = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetGemstoneFastBagItem")
    self._scrollView:setVerticalBounce(true)

    self._ccbOwner.title:setString(options.type == 1 and "可分解魂骨" or "可重生魂骨")
    self._ccbOwner.title2:setString(options.type == 1 and "可分解魂骨" or "可重生魂骨")

    self._gemstoneSorted = {}
    local gemstone = remote.gemstone:getGemstoneByWear(false)
    if table.nums(gemstone) > 0 then
        local gemstoneSorted = {}
        for k, v in pairs(gemstone) do
            if remote.gemstone:checkGemstoneIsCulture(v) then
                table.insert(gemstoneSorted, {quality = v.gemstoneQuality, value = v})
            end
        end
        table.sort(gemstoneSorted, function (x, y)
            if x.quality == y.quality then
                if x.value.itemId == y.value.itemId then
                    return x.value.sid < x.value.sid
                else
                    return x.value.itemId < y.value.itemId
                end 
            else
                return x.quality < y.quality
            end
        end)

        if table.nums(gemstoneSorted) == 0 then
            self._ccbOwner.node_no:setVisible(true)
            self._ccbOwner.na_text:setString("魂师大人，当前没有可用的魂骨！")
            return
        end

        for k, v in pairs(gemstoneSorted) do
            table.insert(self._gemstoneSorted, {v = v.value, isReturen = ture, buttonText = options.type == 1 and "放入分解" or "放入重生", callback = handler(self, self._onTriggerChose)})
        end

        self:initListView()

        self._ccbOwner.node_no:setVisible(false)
    else
        self._ccbOwner.node_no:setVisible(true)
        self._ccbOwner.na_text:setString("魂师大人，当前没有可用的魂骨！")
    end
end


function QUIDialogGemRecycleSelection:initListView()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self.renderFunHandler),
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._gemstoneSorted,
            spaceY = -12,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:reload({totalNumber = #self._gemstoneSorted})
    end
    self._ccbOwner.node_no:setVisible(#self._gemstoneSorted == 0)
end

function QUIDialogGemRecycleSelection:renderFunHandler( list, index, info )
    local isCacheNode = true
    local gemstone = self._gemstoneSorted[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetGemstoneFastBagItem.new()
        isCacheNode = false
    end
    
    info.item = item
    info.size = item:getContentSize()
    item:setInfo(gemstone)

    list:registerBtnHandler(index, "btn_wear", "_onTriggerWear", nil, true)
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo", nil, true)

    return isCacheNode
end

function QUIDialogGemRecycleSelection:_onTriggerChose(gemstone)
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogGemRecycleSelection.GEM_CLICK, gemstone = gemstone})
	self:_onTriggerClose()
end

function QUIDialogGemRecycleSelection:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogGemRecycleSelection:_backClickHandler()
    self:_onTriggerClose()
end


return QUIDialogGemRecycleSelection