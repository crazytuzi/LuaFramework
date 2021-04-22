--
-- Author: Kumo.Wang
-- 通用選擇界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAutoSelection = class("QUIDialogAutoSelection", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetAutoSelection = import("..widgets.QUIWidgetAutoSelection")   

QUIDialogAutoSelection.deployList = {
    {bgX = 0, bgY = 0, bgW = 400, bgH = 430, fgX = 0, fgY = 37, fgW = 340, fgH = 290, closeX = 190, closeY = 204, widgetXs = {0}, widgetYs = {0}}, -- 1個
    {bgX = 0, bgY = 0, bgW = 610, bgH = 430, fgX = 0, fgY = 37, fgW = 550, fgH = 290, closeX = 290, closeY = 204, widgetXs = {-110, 110}, widgetYs = {0, 0}}, -- 2個
    {bgX = 0, bgY = 0, bgW = 860, bgH = 430, fgX = 0, fgY = 37, fgW = 800, fgH = 290, closeX = 410, closeY = 204, widgetXs = {-230, 0, 230}, widgetYs = {0, 0, 0}}, -- 3個
    {bgX = 0, bgY = 0, bgW = 1110, bgH = 430, fgX = 0, fgY = 37, fgW = 1050, fgH = 290, closeX = 540, closeY = 204, widgetXs = {-370, -110, 110, 370}, widgetYs = {0, 0, 0, 0}}, -- 4個
}

function QUIDialogAutoSelection:ctor(options)
    assert(options.planList, "No deployList!")
 	local ccbFile = "ccb/Dialog_AutoSelection.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAutoSelection._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogAutoSelection._onTriggerOK)},
    }
    QUIDialogAutoSelection.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    if options then
        self._planList = options.planList
    end
    self._ccbOwner.frame_tf_title:setString("自动添加")

    self._selectedIndex = 0

    self:_initComposition()
end

-- planList = {
--     {
--         callback = func, -- 回調
--         titleName = str, -- 標題名
--         instruction = str, -- 說明內容
--     },
--     {
--         callback = func, -- 回調
--         titleName = str, -- 標題名
--         instruction = str, -- 說明內容
--     },
--     {
--         callback = func, -- 回調
--         titleName = str, -- 標題名
--         instruction = str, -- 說明內容
--     },
-- }

function QUIDialogAutoSelection:_initComposition()
    self._ccbOwner.node_client:removeAllChildren()
    self._widgetList = {}
    self._widgetCount = #self._planList
    if self._widgetCount == 0 then
        self:_onTriggerClose()
    elseif self._widgetCount == 1 then
        self._selectedIndex = 1
        self:_onTriggerOK()
    elseif self._widgetCount > #QUIDialogAutoSelection.deployList then
        print("plan count > deploy count!")
        self:_onTriggerClose()
    else
        -- 獲取預設界面方案數據
        local curDeploy = QUIDialogAutoSelection.deployList[self._widgetCount]
        -- btn_guard
        self._ccbOwner.btn_guard:setPreferredSize(CCSize(curDeploy.bgW, curDeploy.bgH))
        self._ccbOwner.btn_guard:setPosition(ccp(curDeploy.bgX, curDeploy.bgY))
        -- bg
        -- self._ccbOwner.s9s_bg:setPreferredSize(CCSize(curDeploy.bgW, curDeploy.bgH))
        -- self._ccbOwner.s9s_bg:setPosition(ccp(curDeploy.bgX, curDeploy.bgY))
        -- -- fg
        -- self._ccbOwner.s9s_fg:setPreferredSize(CCSize(curDeploy.fgW, curDeploy.fgH))
        -- self._ccbOwner.s9s_fg:setPosition(ccp(curDeploy.fgX, curDeploy.fgY))
        -- btn_close
        -- self._ccbOwner.btn_close:setPosition(ccp(curDeploy.closeX, curDeploy.closeY))
        for index, plan in ipairs(self._planList) do
            local widget = QUIWidgetAutoSelection.new({plan = plan, index = index})
            widget:setPosition(ccp(curDeploy.widgetXs[index], curDeploy.widgetYs[index]))
            widget:addEventListener(QUIWidgetAutoSelection.CLICK, handler(self, self._onWidgetEvent))
            self._ccbOwner.node_client:addChild(widget)
            self._widgetList[index] = widget
        end
    end
end

function QUIDialogAutoSelection:_onWidgetEvent(e)
    if e.name == QUIWidgetAutoSelection.CLICK then
        if e.isSelected then
            self._selectedIndex = e.index
            for index, widget in ipairs(self._widgetList) do
                if index ~= self._selectedIndex then
                    widget:setSelectState(false)
                end
            end
        else
            self._selectedIndex = 0
            self._widgetList[e.index]:setSelectState(false)
        end
    end
end

function QUIDialogAutoSelection:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    if e ~= nil then
        app.sound:playSound("common_small")
    end
    if self._selectedIndex == 0 then 
        app.tip:floatTip("三哥，你还没有选择呢，选一个吧～")
        return 
    end

    local selectedPlan
    if self._selectedIndex <= #self._planList then
        selectedPlan = self._planList[self._selectedIndex]
    end
    if selectedPlan and selectedPlan.callback then
        print("名字：", selectedPlan.titleName)
        selectedPlan.callback(self._selectedIndex)
    end
    self:_onTriggerClose()
end

function QUIDialogAutoSelection:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogAutoSelection:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if e ~= nil then
        app.sound:playSound("common_small")
    end
    self:playEffectOut()
end

function QUIDialogAutoSelection:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogAutoSelection