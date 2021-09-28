local selectRole = {
	sdkChannelUserid,
	sdkUserId,
	sdkAndroidCode,
	sdkUserName,
	sdkUserName,
	sdkChannelName,
	sdkAccessToken,
	sdkChannelId,
	newRoleEnterGame = false,
	hasNewChr = false,
	selectIndex = 1,
	roles = {},
	getRolesNum = function (self)
		return #self.roles
	end,
	getRoleByName = function (self, name)
		if not name then
			return 
		end

		for i, v in ipairs(self.roles) do
			if v.name == name then
				return v
			end
		end

		return nil
	end,
	getCurName = function (self)
		if self.selectIndex <= #self.roles then
			return self.roles[self.selectIndex].name
		end

		return ""
	end,
	getCurJob = function (self)
		if self.selectIndex <= #self.roles then
			return self.roles[self.selectIndex].job
		end

		return ""
	end,
	getCurUserId = function (self)
		if self.selectIndex <= #self.roles then
			return self.roles[self.selectIndex].userId
		end

		return ""
	end,
	getCurRoleCreateTime = function (self)
		if self.selectIndex <= #self.roles then
			return self.roles[self.selectIndex].FRegDate
		end

		return ""
	end,
	setSelectIndex = function (self, idx)
		self.selectIndex = idx

		return 
	end,
	getCurLevel = function (self)
		if self.selectIndex <= #self.roles then
			return self.roles[self.selectIndex].level
		end

		return 0
	end,
	receiveRoles = function (self, result)
		self.roles = {}

		for i = 1, result.FCount, 1 do
			v = result.FChrList[i]
			local lv = v.FLevel
			local hair = v.FHair

			if hair ~= 1 then
				local tmp = ycFunction:lshift(hair - 1, 8)
				lv = ycFunction:bor(lv, tmp)
			end

			self.roles[#self.roles + 1] = {
				name = v.FName,
				job = v.FJob,
				hair = hair,
				level = lv,
				sex = v.FSex,
				userId = v.FUserId,
				createTime = v.FRegDate
			}
		end

		self.selectIndex = result.FSelIdx + 1

		cache.saveLastPlayerName(self.getCurName(self))

		if self.hasNewChr then
			local data = self.getRoleByName(self, self.newChrName)

			self.submitNewChr(self, data)

			self.hasNewChr = false
		end

		return 
	end,
	getUserIdByName = function (self, name)
		for k, v in ipairs(self.roles) do
			if name == v.name then
				return v.userId
			end
		end

		return 0
	end,
	submitNewChr = function (self, data)
		if not data then
			return 
		end

		MirSDKAgent:logEvent("OnRoleCreated", {
			createTimestamp = data.createTime,
			roleId = data.userId,
			roleLevel = data.level,
			roleName = data.name,
			sex = data.sex,
			job = data.job,
			zoneId = g_data.login.localLastSer.id,
			zoneName = g_data.login.localLastSer.name
		})

		return 
	end
}

return selectRole
