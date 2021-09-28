local redPacket = {
	numUnreadRP = 0,
	receiveNewRP = function (self)
		self.numUnreadRP = self.numUnreadRP + 1

		g_data.pointTip:set("redPacket", 0 < self.numUnreadRP)

		return 
	end,
	getNumUnreadRP = function (self)
		return self.numUnreadRP
	end,
	setNumUnreadRP = function (self, num)
		self.numUnreadRP = num

		g_data.pointTip:set("redPacket", 0 < num)

		return 
	end,
	readAllRP = function (self)
		self.numUnreadRP = 0

		return 
	end
}

return redPacket
