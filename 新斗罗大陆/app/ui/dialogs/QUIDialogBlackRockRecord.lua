local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockRecord = class("QUIDialogBlackRockRecord", QUIDialog)

-- local QNavigationController = import("...controllers.QNavigationController")
-- local QListView = import("...views.QListView")
local QUIWidgetBlackRockRecord = import("..widgets.QUIWidgetBlackRockRecord")
local QUIViewController = import("..QUIViewController")
-- local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")

function QUIDialogBlackRockRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_jiangli.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogBlackRockRecord.super.ctor(self,ccbFile,callBacks,options)

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("对战记录")
    self:_init(options.list or {})
end

function QUIDialogBlackRockRecord:_init(data)
    if #data == 0 then
        self._ccbOwner.node_no:setVisible(true)
        return
    end

    self._ccbOwner.node_no:setVisible(false)

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)

    for index = 1, #data do
        local subData = data[index]

        local node = QUIWidgetBlackRockRecord.new()
        node:setInfo(subData)
        node:setPositionY(-index * 110 + 110)
        self._scrollView:addItemBox(node)
        self._scrollView:setRect(0, -index * 110, 0, self._ccbOwner.sheet_layout:getContentSize().width)

    end
end

function QUIDialogBlackRockRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBlackRockRecord:_close()
    self:playEffectOut()
end

function QUIDialogBlackRockRecord:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:_close()
end

return QUIDialogBlackRockRecord