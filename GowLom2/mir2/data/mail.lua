local mail = {
	unreadCnt,
	handler,
	sys = {},
	sell = {},
	offtm = {},
	msg = {},
	infos = {
		sys = {},
		sell = {}
	}
}

local function sort(a, b)
	local mailStateA = (a.mailState and 2) or 1
	local mailStateB = (b.mailState and 2) or 1
	local attachStateA = (a.attachState and 1) or 2
	local attachStateB = (b.attachState and 1) or 2
	local ret = true

	if mailStateA ~= mailStateB then
		ret = mailStateA < mailStateB
	elseif attachStateA ~= attachStateB then
		ret = attachStateA < attachStateB
	elseif a.time ~= b.time then
		ret = b.time < a.time
	else
		ret = false
	end

	return ret
end

mail.cfg = function (self)
	return {
		sell = 4,
		sys = 1,
		offtm = 5,
		msg = 6
	}
end
mail.tag2Var = function (self, key)
	key = key or 1

	for k, v in pairs(self.cfg(self)) do
		if type(key) == "string" and key == k then
			return v
		elseif type(key) == "number" and key == v then
			return key
		end
	end

	if type(key) ~= "string" and type(key) ~= "number" then
		return tags.sys
	end

	return 
end
mail.removeAttached = function (self)
	local temp = {}

	for k, v in pairs(self.sys) do
		local num = 0

		if not v.attachState then
			table.remove(self.sys, k - num)

			num = num + 1
		end
	end

	return 
end
mail.readMail = function (self, mailId)
	if self.infos and self.infos.sys and self.infos.sys[mailId] then
		self.infos.sys[mailId].mailState = true

		for k, v in pairs(self.sys) do
			if v.id == mailId then
				self.sys[k].mailState = true
			end
		end

		return true
	end

	return 
end
mail.setMail = function (self, result)
	if result then
		self.sys = {}

		for k, v in pairs(result.maillist) do
			local mailData = {
				id = v.mailId,
				title = v.MailTitle,
				time = v.CreateTime,
				mailState = v.BoRead,
				attachState = v.CanItemGet
			}
			self.sys[#self.sys + 1] = mailData
		end

		table.sort(self.sys, sort)
	end

	return 
end
mail.setNew = function (self, result)
	self.items = {}
	self.throwing = {}
	self.eat = {}
	self.take = {}

	self.delAllQuickItem(self)

	for k, v in ipairs(result.FList) do
		if not self.isInFusion(self, v) and not self.isInStrengthen(self, v) then
			self.items[#self.items + 1] = v

			setmetatable(v, {
				__index = gItemOp
			})
			v.decodedCallback(v)
		end
	end

	for i, v in pairs(self.quickItems) do
		self.fillQuickItemTest(self, i)
	end

	return 
end
mail.parseMailNew = function (self, result)
	local from = nil

	for _, v in ipairs(self.sys) do
		if result.id == v.mailId then
			from = "sys"

			break
		end
	end

	local data = {
		id = result.mailId,
		title = result.MailTitle,
		context = result.MailText,
		mailState = result.BoRead,
		attachState = result.CanItemGet
	}

	if result.ItemStr and result.ItemStr ~= "" then
		print("mail result.ItemStr: " .. result.ItemStr)

		local temp = {}
		local itemsStr = string.split(result.ItemStr, "/")

		for k, v in pairs(itemsStr) do
			local itemAndCountT = string.split(v, "|")

			if itemAndCountT[1] == "金币" then
				data.金币 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "元宝" then
				data.元宝 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "银锭" then
				data.银锭 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "灵符" then
				data.灵符 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "声望" then
				data.声望 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "活力值" then
				data.活力值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "精力值" then
				data.精力值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "活力" then
				data.活力值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "精力" then
				data.精力值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "阅历值" then
				data.阅历值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "贡献度" then
				data.贡献度 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "阅历" then
				data.阅历值 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "贡献" then
				data.贡献度 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "信用" then
				data.信用分 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "信用分" then
				data.信用分 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "功勋" then
				data.功勋 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "残卷点" then
				data.残卷点 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "奖券" then
				data.奖券 = tonumber(itemAndCountT[2])
			elseif itemAndCountT[1] == "军功" then
				data.军功 = tonumber(itemAndCountT[2])
			else
				local index = #temp + 1
				temp[index] = temp[index] or {}
				temp[index].name = itemAndCountT[1]
				temp[index].Fdura = (itemAndCountT[2] and tonumber(itemAndCountT[2])) or 1
			end
		end

		local itemT = {}

		for k, v in pairs(temp) do
			if v.name == "称号" and _G.def.honortitle[v.Fdura] then
				local honorTitle = clone(_G.def.honortitle[v.Fdura])
				honorTitle.type = "称号"
				honorTitle.honourID = v.Fdura
				itemT[#itemT + 1] = honorTitle
			end

			for index, stditem in ipairs(_G.def.items) do
				if stditem.name == v.name then
					local baseItem = {
						FIndex = index
					}

					if 150 < stditem.stdMode then
						baseItem.FDura = v.Fdura
					else
						baseItem.FDura = stditem.duraMax
					end

					baseItem.FDuraMax = stditem.duraMax
					baseItem.FItemValueList = {}
					baseItem.FItemIdent = 1
					itemT[#itemT + 1] = baseItem

					setmetatable(baseItem, {
						__index = gItemOp
					})
					baseItem.decodedCallback(baseItem)

					break
				end
			end
		end

		data.items = itemT
	end

	if from then
		self.infos[from][data.id] = data
	end

	return result.mailId, from
end
mail.attachNew = function (self)
	if not g_data.client.mailId then
		return 
	end

	local id = g_data.client.mailId
	local from = nil

	for i, v in ipairs(self.sys) do
		if id == v.id then
			v.attachState = false
			from = "sys"

			break
		end
	end

	if self.infos.sys[id] then
		self.infos.sys[id].attachState = false
	end

	return id, from
end
mail.delNew = function (self)
	if not g_data.client.mailId then
		return 
	end

	local id = g_data.client.mailId
	local next, from = nil

	if self.infos.sys and self.infos.sys[id] then
		self.infos.sys[id] = nil
		from = "sys"

		for i, v in ipairs(self.sys) do
			if id == v.id then
				next = (i <= #self.sys and self.sys[i + 1] and self.sys[i + 1].id) or nil

				table.remove(self.sys, i)

				break
			end
		end
	end

	return id, next, from
end
mail.attachOfftm = function (self)
	self.offtm = {}

	return 
end
mail.setUnreadMailCnt = function (self, cnt)
	self.unreadCnt = cnt

	return 
end
mail.cleanup = function (self)
	if self.handler then
		scheduler.unscheduleGlobal(self.handler)

		self.handler = nil
	end

	return 
end
mail.startSchedule = function (self)
	self.handler = scheduler.scheduleGlobal(function ()
		return 
	end, 1800)

	return 
end
mail.attachALL = function (self, mailIds)
	for k, v in pairs(self.sys) do
		local set = nil

		for i = 1, #mailIds, 1 do
			if v.id == mailIds[i] then
				set = true

				break
			end
		end

		if set then
			self.sys[k].mailState = true
			self.sys[k].attachState = false
		end
	end

	for k, v in pairs(mailIds) do
		if self.infos.sys[v] then
			self.infos.sys[v].attachState = false
		end
	end

	return 
end
mail.getUnreadMailNum = function (self)
	local num = 0

	for k, v in pairs(self.sys) do
		if not v.mailState then
			num = num + 1
		end
	end

	return num
end
mail.NewMail = function (self, mailList)
	local mailData = {
		id = mailList.mailId,
		title = mailList.MailTitle,
		time = mailList.CreateTime,
		mailState = mailList.BoRead,
		attachState = mailList.CanItemGet
	}
	self.sys[#self.sys + 1] = mailData

	return 
end
mail.getFirstMailId = function (self)
	if self.sys and self.sys[1] and self.sys[1].id then
		return self.sys[1].id
	end

	return 
end
mail.delByMailId = function (self, mailId)
	local id = nil

	for k = 1, #self.sys, 1 do
		if self.sys[k].id == mailId then
			id = k

			break
		end
	end

	table.remove(self.sys, id)

	return 
end

return mail
