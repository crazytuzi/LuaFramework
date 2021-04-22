--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 公会副本bufftips
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSocietyDungeonBuffTips = class("QUIDialogSocietyDungeonBuffTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogSocietyDungeonBuffTips:ctor(options)
 	local ccbFile = "ccb/Dialog_SocietyDungeon_BuffTips.ccbi"
    local callBacks = {}
    QUIDialogSocietyDungeonBuffTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    -- self:getChildView():setPosition(options.x + 600, options.y - 200)
    -- self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    -- self._bgPositionY = self._ccbOwner.s9s_bg:getPositionY()
    self._buffDes = options.des
    self._isActive = options.isActive

    self:_init()
end

function QUIDialogSocietyDungeonBuffTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSocietyDungeonBuffTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogSocietyDungeonBuffTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSocietyDungeonBuffTips:_init()
    if self._isActive == 1 then
        self._ccbOwner.tf_explain:setString(self._buffDes.."（已激活）")
        -- self._ccbOwner.tf_explain:setColor(ccc3(251,217,167))
    elseif self._isActive == 2 then
        self._ccbOwner.tf_explain:setString(self._buffDes.."（未激活）")
        -- self._ccbOwner.tf_explain:setColor(ccc3(164,164,164))
    else
        self._ccbOwner.tf_explain:setString(self._buffDes)
    end
end

return QUIDialogSocietyDungeonBuffTips