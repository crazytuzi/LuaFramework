--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林tips
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalAbyssLevelTips = class("QUIDialogMetalAbyssLevelTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView") 

function QUIDialogMetalAbyssLevelTips:ctor(options)
 	local ccbFile = "ccb/Dialog_MetalAbyss_LevelTips.ccbi"
    local callBacks = {}
    QUIDialogMetalAbyssLevelTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    -- self:getChildView():setPosition(options.x + 600, options.y - 200)
    self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    self._bgPositionY = self._ccbOwner.s9s_bg:getPositionY()
    self._userInfo = options.userInfo
    self:_init()
end

function QUIDialogMetalAbyssLevelTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogMetalAbyssLevelTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogMetalAbyssLevelTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMetalAbyssLevelTips:_init()
	self:_updateExp()
end

function QUIDialogMetalAbyssLevelTips:_updateExp()

    local curStar = self._userInfo.totalStarCount or 0
    local curLevelConfig = remote.metalAbyss:getLevelInfoByExp(curStar)
    local nextLevelConfig = remote.metalAbyss:getNextLevelInfoByExp(curStar)

	if not nextLevelConfig then
		-- 说明已经满级了，没有下一级的config。
		self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height - 55))
		self._ccbOwner.s9s_bg:setPositionY(self._bgPositionY - 30)
        self._ccbOwner.sp_title:setPositionX(self._ccbOwner.s9s_bg:getPositionX() + self._bgSize.width/2)
        self._ccbOwner.sp_title:setPositionY(self._bgPositionY - 30)
		self._ccbOwner.node_level:setVisible(false)
		self._ccbOwner.tf_cur_buff:setString("+"..(curLevelConfig.reward_coefficient * 100).."%")
		return
	end
    self._ccbOwner.node_level:setVisible(true)
    local exp, expUnit = q.convertLargerNumber(curStar)
    local maxExp, maxExpUnit = q.convertLargerNumber(nextLevelConfig.star)
    self._ccbOwner.tf_exp:setString(exp..(expUnit or "").." / "..maxExp..(maxExpUnit or ""))
    self._ccbOwner.tf_next_buff:setString("+"..(nextLevelConfig.reward_coefficient* 100).."%")
    self._ccbOwner.tf_cur_buff:setString("+"..(curLevelConfig.reward_coefficient* 100).."%")
end

return QUIDialogMetalAbyssLevelTips