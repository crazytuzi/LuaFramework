--
-- Kumo.Wang
-- zhangbichen主题曲活动——活动主界面
--

local QUIDialogActivityPanel = import("..dialogs.QUIDialogActivityPanel")
local QUIDialogZhangbichenActivityPanel = class("QUIDialogZhangbichenActivityPanel", QUIDialogActivityPanel)

local QUIWidgetActivityRate = import("..widgets.QUIWidgetActivityRate")

function QUIDialogZhangbichenActivityPanel:ctor(options) 
	QUIDialogZhangbichenActivityPanel.super.ctor(self, options)
end

function QUIDialogZhangbichenActivityPanel:viewDidAppear()
    QUIDialogZhangbichenActivityPanel.super.viewDidAppear(self)

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.ZHANGBICHEN_UPDATE, handler(self, self.onEvent))
end

function QUIDialogZhangbichenActivityPanel:viewWillDisappear()
    QUIDialogZhangbichenActivityPanel.super.viewWillDisappear(self)

    self._activityRoundsEventProxy:removeAllEventListeners()
end

function QUIDialogZhangbichenActivityPanel:onEvent(event)
    QUIDialogZhangbichenActivityPanel.super.onEvent(self, event)

    if event.name == remote.activityRounds.ZHANGBICHEN_UPDATE then
        self._dataDirty = true
        if event.isForce then
            self._isForce = true
        end
    end
end

function QUIDialogZhangbichenActivityPanel:onOtherContent()
    self._ccbOwner.node_time:setVisible(false)
    self._ccbOwner.node_right:setVisible(false)
    self._ccbOwner.node_other:setVisible(true)
    QPrintTable(self._selectInfo)
    -- 用于全屏型活动
    self._ccbOwner.node_other:removeAllChildren()
    -- 用于半屏型活动
    self._ccbOwner.node_right:removeAllChildren()
    self._otherWidget = nil

    if self._selectInfo.type == remote.activity.TYPE_ACTIVITY_FOR_DESC and self._selectInfo.targets and #self._selectInfo.targets == 0 then
        self._otherWidget = QUIWidgetActivityRate.new()
        self._ccbOwner.node_other:addChild(self._otherWidget)
        self._otherWidget:setInfo(self._selectInfo)
        self._otherWidget:setBannerPos(-339, 266)
    end

    local dataProxy = remote.activity:getDataProxyByActivityId(self._selectInfo.activityId)
    if dataProxy ~= nil and dataProxy.getWidget ~= nil then
       self._otherWidget = dataProxy:getWidget(self._selectInfo, self)
        self._ccbOwner.node_other:addChild(self._otherWidget)
        if self._otherWidget.setInfo then
            self._otherWidget:setInfo(self._selectInfo, self)
        end
    end
end

function QUIDialogZhangbichenActivityPanel:reloadActivity()
    QUIDialogZhangbichenActivityPanel.super.reloadActivity(self)
end

function QUIDialogZhangbichenActivityPanel:jumpTo(activityId)
    QUIDialogZhangbichenActivityPanel.super.jumpTo(self, activityId)
end

return QUIDialogZhangbichenActivityPanel