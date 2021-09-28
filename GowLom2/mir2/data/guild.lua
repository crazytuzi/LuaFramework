local guild = {
	hasGuild = true,
	memberList = {},
	applyList = {},
	socialList = {},
	memberLogList = {},
	socialLogList = {},
	uptMemberTitle = function (self, userId, position)
		for k, v in pairs(self.memberList) do
			if v.FUserID == userId then
				v.FPosition = position

				break
			end
		end

		return 
	end,
	uptSocialColor = function (self, guildId, color)
		for k, v in pairs(self.socialList) do
			if v.FGildID == guildId then
				v.FColor = color
				v.FState = 1

				break
			end
		end

		return 
	end,
	delApplyList = function (self, userIds)
		for k, v in pairs(self.applyList) do
			for k1, v1 in pairs(userIds) do
				if v.FUserID == v1 then
					table.remove(self.applyList, k)
				end
			end
		end

		return 
	end,
	delMember = function (self, userId)
		for k, v in pairs(self.memberList) do
			if v.FUserID == userId then
				table.remove(self.memberList, k)

				break
			end
		end

		return 
	end
}

return guild
