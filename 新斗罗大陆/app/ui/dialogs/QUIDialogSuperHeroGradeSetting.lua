
-- ss魂师升星自动添加的设置界面

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSuperHeroGradeSetting = class("QUIDialogSuperHeroGradeSetting", QUIDialog)


function QUIDialogSuperHeroGradeSetting:ctor(options)
	local ccbFile = "ccb/Dialog_SuperHeroGrade_setting.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
        {ccbCallbackName = "onTriggertSelectNotAll", callback = handler(self, self._onTriggertSelectNotAll)},
        {ccbCallbackName = "onTriggertSelectAll", callback = handler(self, self._onTriggertSelectAll)},
    }
    QUIDialogSuperHeroGradeSetting.super.ctor(self, ccbFile, callBacks, options)
    self._ccbOwner.frame_tf_title:setString("自动添加")
    self.isAnimation = true

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    q.setButtonEnableShadow(self._ccbOwner.btn_cancel)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

    local status = remote.superHeroGrade:getSelectStatus() or remote.superHeroGrade.SELECT_STATUS_NOT_ALL
    self._isChanged = false
    self:_setSelectStatus(status)
end


----------------------------------------
---交互回调部分

-- 背景被点击
function QUIDialogSuperHeroGradeSetting:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭被点击
function QUIDialogSuperHeroGradeSetting:_onTriggerClose(event)
	if event then
  		app.sound:playSound("common_close")
    end

    -- 不用对话框
    -- if not self._isSaveQuit and self._isChanged then
    --     app:alert({content="设置未保存，确定要关闭吗？", title="系统提示", callback=function(state)
    --         if state == ALERT_TYPE.CONFIRM then
    --             self:playEffectOut()
    --         end
    --     end, isAnimation = false}, false, true)
    -- else
    --     self:playEffectOut()
    -- end

    if not self._isSaveQuit and self._isChanged then
        app.tip:floatTip("魂师大人，您选择了关闭，当前设置变动将不会保存")
    end
    self:playEffectOut()
end

-- 选择全部被选中
function QUIDialogSuperHeroGradeSetting:_onTriggertSelectAll(event)
    app.sound:playSound("common_small")
    self:_setSelectStatus(remote.superHeroGrade.SELECT_STATUS_ALL)
end

-- 选择收集中被选中
function QUIDialogSuperHeroGradeSetting:_onTriggertSelectNotAll(event)
    app.sound:playSound("common_small")
    self:_setSelectStatus(remote.superHeroGrade.SELECT_STATUS_NOT_ALL)
end

-- 取消退出
function QUIDialogSuperHeroGradeSetting:_onTriggerCancel(event)
    self:_onTriggerClose()
end

-- 保存退出
function QUIDialogSuperHeroGradeSetting:_onTriggerOk(event)
    remote.superHeroGrade:setSelectStatus(self._selectStatus)
    self._isSaveQuit = true
    self:_onTriggerClose()
end




----------------------------------------
---私有部分

-- 设置选中状态
function QUIDialogSuperHeroGradeSetting:_setSelectStatus(status)
    if self._selectStatus and self._selectStatus ~= status then
        self._isChanged = true
    end

    if status == remote.superHeroGrade.SELECT_STATUS_ALL then
        self._ccbOwner.sp_select_all:setVisible(true)
        self._ccbOwner.sp_select_not_all:setVisible(false)
    else
        self._ccbOwner.sp_select_all:setVisible(false)
        self._ccbOwner.sp_select_not_all:setVisible(true)
    end
    self._selectStatus = status
end

return QUIDialogSuperHeroGradeSetting
