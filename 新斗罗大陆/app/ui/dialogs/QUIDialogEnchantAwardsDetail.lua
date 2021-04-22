--
-- Author: xurui
-- Date: 2016-03-24 10:33:04
--
local QUIDialogStoreDetail = import("..dialogs.QUIDialogStoreDetail")
local QUIDialogEnchantAwardsDetail = class("QUIDialogEnchantAwardsDetail", QUIDialogStoreDetail)

function QUIDialogEnchantAwardsDetail:ctor(options)
	QUIDialogEnchantAwardsDetail.super.ctor(self, options)
end

function QUIDialogEnchantAwardsDetail:viewAnimationOutHandler()
	if self.isSell == true then
		if self._itemInfo.id == nil then
			self._itemInfo.id = 0
		end
		app:getClient():luckyDrawEnchantRewardRequest(self._position, function(data)
			app.tip:floatTip("购买成功")
		end,
		function(data)
		end)
	end
	self:removeSelfFromParent()
end

return QUIDialogEnchantAwardsDetail
