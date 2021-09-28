local testCommond = {
	data = {},
	get = function (self)
		self.data = cache.getTestCommond() or {}

		return self.data
	end,
	set = function (self, testCom)
		self.data = testCom

		cache.saveTestCommond(self.data)

		return 
	end
}

return testCommond
