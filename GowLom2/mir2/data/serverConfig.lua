local sconfig = {
	allowMaxLevel = 999,
	deathColor = 0,
	set = function (self, msg, body)
		self.deathColor = math.min(Lobyte(msg.param), 8)

		return 
	end
}

return sconfig
