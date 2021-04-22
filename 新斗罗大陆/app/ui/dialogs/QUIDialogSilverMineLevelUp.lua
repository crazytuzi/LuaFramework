--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林狩猎等级升级
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineLevelUp = class("QUIDialogSilverMineLevelUp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSilverMineLevelUp:ctor(options)
 	local ccbFile = "ccb/Dialog_SilverMine_MineLevel.ccbi"
    local callBacks = {}
    QUIDialogSilverMineLevelUp.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._closeCallBack = options.callBack

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

    local curLevel = remote.silverMine:getMiningLv()
    self._ccbOwner.old_level:setString(curLevel - 1)
    self._ccbOwner.new_level:setString(curLevel)

    local moneyOutputLevelup, silverMineMoneyOutputLevelup = remote.silverMine:getLevelBuff( curLevel - 1 )
    self._ccbOwner.old_money_value:setString((moneyOutputLevelup * 100).."%")
    self._ccbOwner.old_silvermineMoney_value:setString((silverMineMoneyOutputLevelup * 100).."%")

    moneyOutputLevelup, silverMineMoneyOutputLevelup = remote.silverMine:getLevelBuff( curLevel )
    self._ccbOwner.new_money_value:setString((moneyOutputLevelup * 100).."%")
    self._ccbOwner.new_silvermineMoney_value:setString((silverMineMoneyOutputLevelup * 100).."%")
end

function QUIDialogSilverMineLevelUp:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSilverMineLevelUp:_onTriggerClose()
    self:playEffectOut()
end


function QUIDialogSilverMineLevelUp:viewAnimationInHandler()
    app.sound:playSound("battle_level_up")
end

function QUIDialogSilverMineLevelUp:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._closeCallBack ~= nil then
        self._closeCallBack()
    end
end

return QUIDialogSilverMineLevelUp