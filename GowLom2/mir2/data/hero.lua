local hero = {
	fealty = 0,
	unionState = 0,
	heroType = 0,
	name = "",
	roleid = 0,
	unionProgress = 0,
	glory = 0,
	bagSize = 0,
	sex = 0,
	heroRank = 0,
	magicList = {},
	setRoleID = function (self, roleid)
		self.roleid = roleid

		return 
	end,
	setName = function (self, name, heroType, heroRank)
		self.name = name
		self.heroType = heroType
		self.heroRank = heroRank

		return 
	end,
	setSex = function (self, sex)
		self.sex = sex

		return 
	end,
	setWineExp = function (self, cur, next)
		self.wineCurExp = cur
		self.wineNextExp = next

		return 
	end,
	setdrinkDrugStatus = function (self, cur, next)
		self.drinkDrugStatusValue = cur
		self.drinkDrugStatusValueNext = next

		return 
	end,
	setdrinkStatus = function (self, cur, next)
		self.drinkStatusValue = cur
		self.drinkStatusMaxValue = next

		return 
	end,
	setBagSize = function (self, bagSize)
		self.bagSize = bagSize

		return 
	end,
	setGloryFealty = function (self, glory, fealty)
		self.glory = glory
		self.fealty = fealty

		return 
	end,
	getJobStr = function (self)
		if self.job == 0 then
			return "战士"
		elseif self.job == 1 then
			return "法师"
		elseif self.job == 2 then
			return "道士"
		end

		return "刺客"
	end,
	getMagic = function (self, magicID)
		for i, v in ipairs(self.magicList) do
			if v.FMagicId == magicID then
				return v
			end
		end

		return 
	end
}

return hero
