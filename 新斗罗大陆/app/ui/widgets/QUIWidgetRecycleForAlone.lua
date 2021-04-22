--
-- Kumo.Wang
-- 回收站，单个回收界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRecycleForAlone = class("QUIWidgetRecycleForAlone", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

local QListView = import("...views.QListView")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QRichText = import("...utils.QRichText")
local QUIWidgetRecycleItemContainer = import("..widgets.QUIWidgetRecycleItemContainer")

function QUIWidgetRecycleForAlone:ctor(options)
	local ccbFile = "ccb/Widget_Recycle_For_Alone.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerRecycle", callback = handler(self, self.onTriggerRecycle)},
        {ccbCallbackName = "onTriggerStore", callback = handler(self, self.onTriggerStore)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self.onTriggerHelp)},
        {ccbCallbackName = "onTriggerSelect", callback = handler(self, self.onTriggerSelect)},

        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerMonthCard", callback = handler(self, self._onTriggerMonthCard)},
	}
	QUIWidgetRecycleForAlone.super.ctor(self, ccbFile, callBacks, options)

    q.setButtonEnableShadow(self._ccbOwner.btn_recycle)

    self:init()
end

function QUIWidgetRecycleForAlone:getWidgetId()
    if self:getOptions() then
        return self:getOptions().widgetId
    end
end
------------- reset function -------------

function QUIWidgetRecycleForAlone:onEnter()
    self:update()
end

function QUIWidgetRecycleForAlone:onExit()
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    local soulBar = page.topBar:getBarForType(ITEM_TYPE.SOULMONEY)
    local barSoulIcon = soulBar:getIcon()
    barSoulIcon:stopAllActions()
end

function QUIWidgetRecycleForAlone:update()
    self:updateData()
end

function QUIWidgetRecycleForAlone:init()
    self._ccbOwner.node_btn_store:setVisible(false)
    self._ccbOwner.node_unselected:setVisible(true)
    self._ccbOwner.node_selected:setVisible(false)
    self._ccbOwner.node_month_card:setVisible(false)
    self._ccbOwner.node_avatar_star:setVisible(false)
    self._ccbOwner.node_level_info:setVisible(false)
    self._ccbOwner.node_name_info:setVisible(false)
    self._ccbOwner.node_selected_info:setVisible(true)

    self.id = nil -- 选择的重生对象id
    self.info = nil -- 选择的重生对象table_info
    self.importantKeysList = {} -- 需要优先排序的key

    self.itemClassName = "QUIWidgetHeroInformation"
    self.isPlaying = false 
    self.avatar = nil
    self.priceKey = "HERO_RECYCLE"
    
    -- 初始化价格
    -- HERO_RECYCLE
    -- GEMSTONE_RECYCLE
    -- ZUOQI_RECYCLE
    -- SOUL_SPIRIT_RETURN
    self.price = db:getConfigurationValue(self.priceKey)
    if not self.price then
        self.price = 0
    end
    self._ccbOwner.tf_price:setString(self.price)
    self._ccbOwner.node_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self.price = 0
    end

    self:initExplain()
    self:initMenu()
end

function QUIWidgetRecycleForAlone:initExplain()
    self._ccbOwner.node_tf_explain:removeAllChildren()
end

function QUIWidgetRecycleForAlone:initMenu()
    -- 由於init方法裡可能會修改按鈕icon的圖片資源，所以按鈕狀態設定放在這裡
    q.setButtonEnableShadow(self._ccbOwner.btn_store)
    q.setButtonEnableShadow(self._ccbOwner.btn_help)

    self._ccbOwner.node_btn_help:setVisible(false)
    self._ccbOwner.node_btn_store:setVisible(false)
end

function QUIWidgetRecycleForAlone:updateData()
end


function QUIWidgetRecycleForAlone:updateRecyclePreviewInfo()
    local info = {}

    return info
end

function QUIWidgetRecycleForAlone:sortRecyclePreviewInfo(info)
    local finalRecycleInfo = {}
    table.sort(info, function(a, b)
            return a.key < b.key
        end)
    QKumo(self.importantKeysList)
    for _, key in ipairs(self.importantKeysList) do
        if info[key] and info[key] > 0 then
            table.insert(finalRecycleInfo, {id = key, value = info[key]})
            info[key] = nil
        end
    end
    for key, value in pairs(info) do
        if info[key] and info[key] > 0 then
            table.insert(finalRecycleInfo, {id = key, value = value})
        end
    end

    return finalRecycleInfo
end


function QUIWidgetRecycleForAlone:onTriggerRecycle()
end
function QUIWidgetRecycleForAlone:onTriggerStore()
end
function QUIWidgetRecycleForAlone:onTriggerHelp()
end
function QUIWidgetRecycleForAlone:onTriggerSelect()
end

------------- ------------- -------------

function QUIWidgetRecycleForAlone:_onTriggerMonthCard()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMonthCardPrivilege"})
end

function QUIWidgetRecycleForAlone:_onTriggerClose()
    if self.isPlaying then return end
    self.id = nil 
    self.info = nil
    self:update()
end

return QUIWidgetRecycleForAlone
