local shop = {
	goods = {},
	hongZuanGoods = {},
	getCurTypePageGoods = function (self, type, page)
		return (self.goods[type] and self.goods[type]) or {}
	end,
	saveGoods = function (self, type, items)
		for k, v in ipairs(items) do
			v.FYBPrice = v.FYBPrice/100
			v.FYDPrice = v.FYDPrice/100
		end

		self.goods[type] = items or {}

		return 
	end,
	clearGoods = function (self)
		self.goods = {}
		self.hongZuanGoods = {}

		return 
	end,
	getCurHZTypePageGoods = function (self, type, page)
		return (self.hongZuanGoods[type] and self.hongZuanGoods[type]) or {}
	end,
	saveHZGoods = function (self, type, items)
		self.hongZuanGoods[type] = items or {}

		return 
	end,
	gplusCheckPaidOrderEnd = function (self, code, msg)
		return 
	end,
	gplusPayEnd = function (self, code, msg)
		return 
	end
}

return shop
