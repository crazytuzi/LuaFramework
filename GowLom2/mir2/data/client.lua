local client = {
	openDay = 0,
	serverState = 0,
	dealGold = 0,
	lastTime = {},
	dealItems = {},
	fusionItems = {},
	lastScale = {
		heroBag = 1,
		storage = 1,
		bag = 1,
		npc = 1
	},
	skillBtns = {},
	rush = {},
	setLastTime = function (self, key, time)
		self.lastTime[key] = (time and socket.gettime()) or nil

		return 
	end,
	checkLastTime = function (self, key, time)
		return not self.lastTime[key] or time < socket.gettime() - self.lastTime[key]
	end,
	getIntervalTime = function (self, key)
		local time = -1

		if self.lastTime[key] then
			time = socket.gettime() - self.lastTime[key]
		end

		return time
	end,
	setLastSellItem = function (self, data)
		self.lastSellItem = data

		return 
	end,
	setStorageItem = function (self, data)
		self.storageItem = data

		return 
	end,
	setStorageGetBackItem = function (self, data)
		self.storageGetBackItem = data

		return 
	end,
	setHeroPutInItem = function (self, data)
		self.heroPutInItem = data

		return 
	end,
	setHeroGetBackItem = function (self, data)
		self.heroGetBackItem = data

		return 
	end,
	setNowDealItem = function (self, data)
		self.dealItem = data

		return 
	end,
	addDealItem = function (self, data)
		self.dealItems[#self.dealItems + 1] = data

		return 
	end,
	clearDealItem = function (self)
		self.dealItems = {}

		return 
	end,
	setNowFusionItem = function (self, data)
		self.fusionItem = data

		return 
	end,
	addfusionItem = function (self, data)
		self.fusionItems[#self.fusionItems + 1] = data

		return 
	end,
	clearfusionItem = function (self)
		self.fusionItems = {}

		return 
	end,
	setDealGold = function (self, gold)
		self.dealGold = gold or 0

		return 
	end,
	setLastScale = function (self, key, scale)
		self.lastScale[key] = scale

		return 
	end,
	setLastQueryChatItem = function (self, makeIndex, name, x, y)
		if makeIndex then
			self.lastQueryChatItem = {
				makeIndex = makeIndex,
				name = name,
				x = x,
				y = y
			}
		else
			self.lastQueryChatItem = nil
		end

		return 
	end,
	setLastNpcMap = function (self, data)
		self.npcMap = data

		return 
	end,
	setLastMail = function (self, id)
		self.mailId = id

		return 
	end
}

return client
