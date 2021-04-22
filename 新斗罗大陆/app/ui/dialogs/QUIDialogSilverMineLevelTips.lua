--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林tips
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineLevelTips = class("QUIDialogSilverMineLevelTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView") 

function QUIDialogSilverMineLevelTips:ctor(options)
 	local ccbFile = "ccb/Dialog_SilverMine_LevelTips.ccbi"
    local callBacks = {}
    QUIDialogSilverMineLevelTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    -- self:getChildView():setPosition(options.x + 600, options.y - 200)
    self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    self._bgPositionY = self._ccbOwner.s9s_bg:getPositionY()

    self:_init()
end

function QUIDialogSilverMineLevelTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSilverMineLevelTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogSilverMineLevelTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSilverMineLevelTips:_init()
	self:_updateExp()
end

function QUIDialogSilverMineLevelTips:_updateExp()
	local levelConfig = remote.silverMine:getLevelConfigByLevel( remote.silverMine:getMiningLv() + 1 )
	if not levelConfig then
		-- 说明已经满级了，没有下一级的config。
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height - 55))
		self._ccbOwner.s9s_bg:setPositionY(self._bgPositionY - 30)
        self._ccbOwner.sp_title:setPositionX(self._ccbOwner.s9s_bg:getPositionX() + self._bgSize.width/2)
        self._ccbOwner.sp_title:setPositionY(self._bgPositionY - 30)
		self._ccbOwner.node_level:setVisible(false)
		levelConfig = remote.silverMine:getLevelConfigByLevel( remote.silverMine:getMiningLv() )
		self._ccbOwner.tf_cur_money_buff:setString("+"..levelConfig.money_output.."%")
		self._ccbOwner.tf_cur_silvermineMoney_buff:setString("+"..levelConfig.silvermineMoney_output.."%")
		return
	end
    self._ccbOwner.node_level:setVisible(true)
    local exp, expUnit = q.convertLargerNumber(remote.silverMine:getMiningExp())
    local maxExp, maxExpUnit = q.convertLargerNumber(levelConfig.exp)
    self._ccbOwner.tf_exp:setString(exp..(expUnit or "").." / "..maxExp..(maxExpUnit or ""))
    self._ccbOwner.tf_next_money_buff:setString("+"..levelConfig.money_output.."%")
	self._ccbOwner.tf_next_silvermineMoney_buff:setString("+"..levelConfig.silvermineMoney_output.."%")

    levelConfig = remote.silverMine:getLevelConfigByLevel( remote.silverMine:getMiningLv() )
    self._ccbOwner.tf_cur_money_buff:setString("+"..levelConfig.money_output.."%")
	self._ccbOwner.tf_cur_silvermineMoney_buff:setString("+"..levelConfig.silvermineMoney_output.."%")
end

return QUIDialogSilverMineLevelTips