--
-- Kumo.Wang
-- 圣柱难度模式选择界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogTotemChallengeChoose = class("QUIDialogTotemChallengeChoose", QUIDialog)

function QUIDialogTotemChallengeChoose:ctor(options)
	local ccbFile = "Dialog_totemChallenge_choose.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIDialogTotemChallengeChoose._onTriggerSelect)},
	}
	QUIDialogTotemChallengeChoose.super.ctor(self,ccbFile,callBacks,options)

	CalculateUIBgSize(self._ccbOwner.sp_bg)
	
	self.isAnimation = true --是否动画显示

	if options then
		self._callback = options.callback
	end
end

function QUIDialogTotemChallengeChoose:_onTriggerSelect(e, target)
	local intoLayer = 0
	if target == self._ccbOwner.btn_normal then
		intoLayer = remote.totemChallenge.NORMAL_TYPE
	elseif target == self._ccbOwner.btn_hard then
		intoLayer = remote.totemChallenge.HARD_TYPE
	end

	remote.totemChallenge:requestTotemChallengeIntoLayer(intoLayer, function()
		if self:safeCheck() then
			self:playEffectOut()
		end
	end)
end

function QUIDialogTotemChallengeChoose:viewAnimationOutHandler()
    self:popSelf()

    if self._callback then
    	self._callback()
    end
end

return QUIDialogTotemChallengeChoose
