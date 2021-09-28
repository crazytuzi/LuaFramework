local credit = {
	isAuthen = false,
	creditScore = 0,
	setAuthen = function (self, msg)
		self.isAuthen = msg.recog == 0

		return 
	end,
	setScore = function (self, msg)
		self.creditScore = msg.param

		return 
	end
}

return credit
