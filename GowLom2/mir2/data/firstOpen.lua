local firstOpen = {
	data = {},
	get = function (self, type)
		self.data = cache.getFirstOpen(common.getPlayerName()) or {}

		return self.data[type]
	end,
	set = function (self, type, opened)
		self.data[type] = opened

		cache.saveFirstOpen(common.getPlayerName())

		return 
	end
}

return firstOpen
