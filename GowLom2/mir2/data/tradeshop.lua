local tradeshop = {
	nextUptTime = "",
	tradeCount = 0,
	tradeOrder = true,
	tradeList = {},
	pickList = {},
	sellingList = {},
	setTradeInfo = function (self, result)
		if result.FGoodIndex == 0 then
			self.tradeList[result.FGoodKind] = {}
		end

		local tb = self.tradeList[result.FGoodKind]

		for k, v in ipairs(result.FGoodList) do
			tb[#tb + 1] = v

			setmetatable(tb[#tb].FItemInfo, {
				__index = gItemOp
			})
			tb[#tb].FItemInfo:decodedCallback()
		end

		self.nextUptTime = os.date("%H:%M", result.FUpdateTime)
		self.tradeCount = result.FCount
		self.tradeOrder = result.FBoInc
		self.tradeType = result.FBankType

		return 
	end,
	setPickList = function (self, result)
		self.pickList = result.FGoodList

		for k, v in ipairs(self.pickList) do
			setmetatable(v.FItemInfo, {
				__index = gItemOp
			})
			v.FItemInfo:decodedCallback()
		end

		return 
	end,
	setSellingList = function (self, result)
		self.sellingList = result.FGoodList

		for k, v in ipairs(self.sellingList) do
			setmetatable(v.FItemInfo, {
				__index = gItemOp
			})
			v.FItemInfo:decodedCallback()
		end

		return 
	end,
	delItem = function (self, orderId, kindid)
		for k, v in pairs(self.tradeList[kindid]) do
			if v.FOrderID == orderId then
				table.remove(self.tradeList[kindid], k)

				break
			end
		end

		return 
	end,
	delSellingItem = function (self, orderId)
		for k, v in pairs(self.sellingList) do
			if v.FOrderID == orderId then
				table.remove(self.sellingList, k)

				break
			end
		end

		return 
	end,
	delPickItem = function (self, orderId)
		for k, v in pairs(self.pickList) do
			if v.FOrderID == orderId then
				table.remove(self.pickList, k)

				break
			end
		end

		return 
	end,
	initConfig = function (self, result)
		self.config = result.FConfigList

		return 
	end,
	getMaxPrice = function (self, name)
		for k, v in pairs(self.config) do
			if v.FName == name then
				return {
					v.FMaxYB,
					v.FMaxJB,
					v.FSellPermit
				}
			end
		end

		return 
	end
}

return tradeshop
