_G.UnionInfoVO = {}

-- UnionInfoVO.guildId
-- UnionInfoVO.rank
-- UnionInfoVO.level
-- UnionInfoVO.memCnt
-- UnionInfoVO.contribution
-- UnionInfoVO.totalContribution
-- UnionInfoVO.maxMemCnt
-- UnionInfoVO.captial
-- UnionInfoVO.power
-- UnionInfoVO.guildName
-- UnionInfoVO.guildMasterName
-- UnionInfoVO.guildNotice
-- UnionInfoVO.pos
-- UnionInfoVO.GuildResList--{itemId, count}
-- UnionInfoVO.GuildSkillList--{skillId, openFlag}
-- UnionInfoVO.loyalty 忠诚度
function UnionInfoVO:New(unionInfo)
	local obj = setmetatable({},{__index = self})
	
	for i,v in pairs(unionInfo) do
		if type(v) ~= "table" then
			obj[i] = v
		end
	end
	
	obj.GuildResList = {}
	if unionInfo.GuildResList then
		for k,guildRes in pairs(unionInfo.GuildResList) do
			local resVO = {}
			resVO.itemId = guildRes.itemId
			resVO.count = guildRes.count
			table.push(obj.GuildResList, resVO)
		end
	end
	
	obj.GuildSkillList = {}
	if unionInfo.GuildSkillList then
		for k,guildSkill in pairs(unionInfo.GuildSkillList) do
			local skillVO = {}
			skillVO.skillId = guildSkill.skillId
			skillVO.openFlag = guildSkill.openFlag
			skillVO.isSelected = false		--是否选中显示时赋值
			if skillVO.openFlag == 1 then
				skillVO.isDisabled = false	--是否可操作显示时赋值
			else
				skillVO.isDisabled = true
			end
			skillVO.isOpenReached = false 	--解锁是否达到显示时赋值
			table.push(obj.GuildSkillList, skillVO)
		end
	end
	
	return obj
end

function UnionInfoVO:UpdateUnionInfo(unionInfo)
	self.rank = unionInfo.rank	
	self.level = unionInfo.level		
	self.memCnt = unionInfo.memCnt		
	self.captial = unionInfo.captial	
	self.liveness = unionInfo.liveness	
	self.extendNum = unionInfo.extendNum	
	self.power = unionInfo.power	
	self.alianceGuildId = unionInfo.alianceGuildId	
	-- self.loyalty = unionInfo.loyalty
	self.GuildResList = {}
	if unionInfo.GuildResList then
		for k,guildRes in pairs(unionInfo.GuildResList) do
			local resVO = {}
			resVO.itemId = guildRes.itemId
			resVO.count = guildRes.count
			table.push(self.GuildResList, resVO)
		end
	end
end

