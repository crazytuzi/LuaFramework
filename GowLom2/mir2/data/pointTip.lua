local pointTip = class("pointTip")

table.merge(pointTip, {
	lst = {}
})

pointTip.set = function (self, type, visible, notif)
	notif = notif or true
	self.lst[type] = visible

	if notif then
		g_data.eventDispatcher:dispatch("M_POINTTIP", type, visible)
	end

	return 
end
pointTip.isVisible = function (self, type)
	return self.lst[type] == true
end
pointTip.checkGemstoneActive = function (self)
	for i, info in pairs(g_data.player.gemstonesInfo) do
		if info.canActive then
			self.set(self, "gemstone_active", true)

			return 
		end
	end

	self.set(self, "gemstone_active", false)

	return 
end
pointTip.checkGemstoneUpgrade = function (self)
	if 0 < #g_data.player.gemstonesUpgradeInfo then
		self.set(self, "gemstone_upgrade", true)

		return 
	end

	self.set(self, "gemstone_upgrade", false)

	return 
end
pointTip.cleanup = function (self)
	self.lst = {}

	return 
end

return pointTip
