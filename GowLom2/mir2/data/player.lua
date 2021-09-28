local player = {
	drumStrengthenLevel = 0,
	inPileUping = false,
	expPoolValue = 0,
	IsSplliteItem = false,
	initedAbility = false,
	monSoulLevel = 0,
	militaryRank = 0,
	stamina = 0,
	TianDiHeYi = false,
	crossServerState = 0,
	medalEnhantingLevel = 0,
	vitalityMax = 0,
	groupEnable = false,
	medalImpressNum = 0,
	isTeamLeader = false,
	gold = 0,
	drumLevel = 0,
	regtime = 0,
	vitality = 0,
	sex = 0,
	staminaMax = 0,
	roleid = 0,
	vitaliyitemValue = 0,
	attackMode = "",
	lastUnlockTime = 0,
	goldNum = {
		silver = 0,
		gold = 0,
		limtGird = 0,
		coupon = 0,
		silverExp = 0,
		hongZuan = 0,
		diamond = 0,
		point = 0,
		gird = 0
	},
	goldName = {
		coupon = "",
		diamond = "",
		point = "",
		gird = "",
		gold = "",
		limtGird = "",
		silver = "",
		silverExp = ""
	},
	magicList = {},
	hitEnables = {
		long = false
	},
	groupMembers = {},
	nearMemInfo = {},
	nearGroupInfo = {},
	guild = {
		memberShowType = false,
		isAllowAlly = false,
		curIndex = 0,
		focusVer = 0,
		isGetRelationShipInfo = false,
		recruitGuildInfo = "",
		recvAllyVer = 0,
		guildRight = 0,
		heroTeamMember = 0,
		allyVer = 0,
		isLastAllyPage = false,
		rankName = "",
		killVer = 0,
		hasGuild = false,
		guildName = "",
		log = {},
		relationShip = {},
		hasAllyList = {}
	},
	slaves = {},
	guildInfo = {},
	gemstonesInfo = {},
	gemstonesUpgradeInfo = {},
	wingInfo = {
		FWingHaveExp = 0,
		FCurrWingShowId = 0,
		FWingLv = 0,
		FActivateWingList = {},
		FShowWingList = {}
	},
	horseInfo = {
		state = 0
	},
	petInfo = {
		state = 0
	},
	luckyTip = {
		isPopTip1 = false,
		isPopTip10 = false
	},
	godRingList = {},
	equipSuiteActList = {},
	wingEquipInfoList = {},
	fashionInfo = {
		weaponShowId = 0,
		clothShowId = 0,
		FHaveList = {}
	},
	militaryEquip = {},
	flagInfo = {
		state = 0
	},
	medalImpressInfo = {},
	emojiActiveList = {}
}
local common = import("..scenes.main.common.common")
player.setIsSplliting = function (self, inSplliting)
	self.IsSplliteItem = inSplliting

	return 
end
player.setIsinPileUping = function (self, isinPileUping)
	self.inPileUping = isinPileUping

	return 
end
player.setRoleID = function (self, roleid)
	self.roleid = roleid

	return 
end
player.setSex = function (self, sex)
	self.sex = sex

	return 
end
player.setWineExp = function (self, cur, next)
	self.wineCurExp = cur
	self.wineNextExp = next

	return 
end
player.setdrinkDrugStatus = function (self, cur, next)
	self.drinkDrugStatusValue = cur
	self.drinkDrugStatusValueNext = next

	return 
end
player.setdrinkStatus = function (self, cur, next)
	self.drinkStatusValue = cur
	self.drinkStatusMaxValue = next

	return 
end
player.setGold = function (self, num)
	self.gold = num

	return 
end
player.setIngot = function (self, num)
	self.goldNum.gold = num

	return 
end
player.getIngot = function (self)
	return self.goldNum.gold
end
player.getIngotShow = function (self)
	return common.getMoneyShowText(self.goldNum.gold)
end
player.getSilver = function (self)
	return self.goldNum.silver
end
player.getSilverShow = function (self)
	return common.getMoneyShowText(self.goldNum.silver)
end
player.setGird = function (self, num)
	self.goldNum.gird = num

	return 
end
player.getGird = function (self)
	return self.goldNum.gird
end
player.setCoupon = function (self, num)
	self.goldNum.coupon = num

	return 
end
player.getCoupon = function (self)
	return self.goldNum.coupon
end
player.setLimitGird = function (self, num)
	self.goldNum.limtGird = num

	return 
end
player.getLimitGird = function (self)
	return self.goldNum.limtGird
end
player.setDiamond = function (self, num)
	self.goldNum.diamond = num

	return 
end
player.getDiamond = function (self)
	return self.goldNum.diamond
end
player.setSilver = function (self, num)
	self.goldNum.silver = num

	return 
end
player.getSilver = function (self)
	return self.goldNum.silver
end
player.setHongZuan = function (self, num)
	self.goldNum.hongZuan = num

	return 
end
player.getHongZuan = function (self)
	return self.goldNum.hongZuan
end
player.checkChangedAbility = function (self, result)
	local strS = {}
	local newAblity = result.FClientAbility
	local oldAblity = self.ability

	if not oldAblity then
		return strS
	end

	local abli = {
		{
			{
				"FAC",
				"防御下限"
			},
			{
				"FMaxAC",
				"防御上限"
			}
		},
		{
			{
				"FMAC",
				"魔御下限"
			},
			{
				"FMaxMAC",
				"魔御上限"
			}
		},
		{
			{
				"FDC",
				"攻击下限"
			},
			{
				"FMaxDC",
				"攻击上限"
			}
		},
		{
			{
				"FMC",
				"魔法下限"
			},
			{
				"FMaxMC",
				"魔法上限"
			}
		},
		{
			{
				"FSC",
				"道术下限"
			},
			{
				"FMaxSC",
				"道术上限"
			}
		},
		{
			{
				"FHitRate",
				"准确"
			}
		},
		{
			{
				"FQuickRate",
				"敏捷"
			}
		},
		{
			{
				"FBuAttSpeed",
				"攻击速度"
			}
		},
		{
			{
				"FBuAntiMagic",
				"魔法躲避"
			}
		},
		{
			{
				"FBuMagHit",
				"魔法命中"
			}
		},
		{
			{
				"FAttackLuck",
				"幸运值"
			}
		},
		{
			{
				"FAttackLuck",
				"诅咒"
			}
		},
		{
			{
				"FMaxHP",
				"生命值"
			}
		},
		{
			{
				"FMaxMP",
				"魔法值"
			}
		},
		{
			{
				"FRapeChance",
				"强攻概率"
			}
		},
		{
			{
				"FRapeDamage",
				"强攻伤害"
			}
		},
		{
			{
				"FCriticalChance",
				"暴击概率"
			}
		},
		{
			{
				"FCriticalDamage",
				"暴击系数"
			}
		},
		{
			{
				"FOnceRecvNum_HP",
				"回血速度"
			}
		},
		{
			{
				"FOnceRecvNum_MP",
				"回魔速度"
			}
		},
		{
			{
				"FMaxRecv_HP",
				"回血上限"
			}
		},
		{
			{
				"FMaxRecv_MP",
				"回魔上限"
			}
		},
		{
			{
				"FNumb",
				"麻痹"
			}
		},
		{
			{
				"FIce",
				"冰冻"
			}
		},
		{
			{
				"FAntiNumb",
				"麻痹抗性"
			}
		},
		{
			{
				"FAntiIce",
				"冰冻抗性"
			}
		},
		{
			{
				"FShield",
				"守护减免"
			}
		},
		{
			{
				"FShieldChange",
				"守护概率"
			}
		},
		{
			{
				"FHolyShit",
				"神圣伤害"
			}
		},
		{
			{
				"FDeepDamage",
				"伤害加深"
			}
		},
		{
			{
				"FEaseDamage",
				"伤害减免"
			}
		},
		{
			{
				"FAttMonRev",
				"打怪回复"
			}
		},
		{
			{
				"FAntiHoly",
				"神圣防御"
			}
		},
		{
			{
				"FMagicAvoidRatio",
				"魔法闪避"
			}
		},
		{
			{
				"FPhyAvoidRatio",
				"物理闪避"
			}
		},
		{
			{
				"FHitRatio",
				"命中"
			}
		}
	}

	for i, v in ipairs(abli) do
		if v[1][2] == "幸运值" then
			if 0 < (newAblity[v[1][1]] or 0) or 0 < (oldAblity[v[1][1]] or 0) then
				local newV = ((newAblity[v[1][1]] or 0) >= 0 or 0) and (newAblity[v[1][1]] or 0)
				local oldV = ((oldAblity[v[1][1]] or 0) >= 0 or 0) and (oldAblity[v[1][1]] or 0)
				v[1][3] = newV - oldV
			else
				v[1][3] = 0
			end
		elseif v[1][2] == "诅咒" then
			if (newAblity[v[1][1]] or 0) < 0 or (oldAblity[v[1][1]] or 0) < 0 then
				local newV = math.abs((0 >= (newAblity[v[1][1]] or 0) or 0) and (newAblity[v[1][1]] or 0))
				local oldV = math.abs((0 >= (oldAblity[v[1][1]] or 0) or 0) and (oldAblity[v[1][1]] or 0))
				v[1][3] = newV - oldV
			else
				v[1][3] = 0
			end
		else
			v[1][3] = (newAblity[v[1][1]] or 0) - (oldAblity[v[1][1]] or 0)

			if v[2] then
				v[2][3] = (newAblity[v[2][1]] or 0) - (oldAblity[v[2][1]] or 0)
			end
		end
	end

	for k, v in ipairs(abli) do
		local str1 = ""
		local str2 = ""

		if v[1][3] ~= 0 then
			local sign = (0 < v[1][3] and "+") or ""
			str1 = v[1][2] .. ": " .. sign .. v[1][3]

			if v[1][2] == "伤害加深" or v[1][2] == "伤害减免" or v[1][2] == "怒之烈火几率" or v[1][2] == "怒之火雨几率" or v[1][2] == "怒之噬血几率" or v[1][2] == "物理闪避" or v[1][2] == "魔法闪避" or v[1][2] == "命中" then
				str1 = str1 .. "%"
			end
		end

		if v[2] and v[2][3] ~= 0 then
			local sign = (0 < v[2][3] and "+") or ""
			str2 = v[2][2] .. ": " .. sign .. v[2][3]

			if v[2][2] == "伤害加深" or v[2][2] == "伤害减免" or v[2][2] == "怒之烈火几率" or v[2][2] == "怒之火雨几率" or v[2][2] == "怒之噬血几率" or v[2][2] == "物理闪避" or v[2][2] == "魔法闪避" or v[2][2] == "命中" then
				str2 = str2 .. "%"
			end
		end

		if str1 ~= "" or str2 ~= "" then
			if str1 ~= "" and str2 ~= "" and v[1][3] < 0 and 0 < v[2][3] then
				str2 = str1
				str1 = str2
			end

			local abliS = nil

			if str1 == "" then
				abliS = str2
			elseif str2 == "" then
				abliS = str1
			else
				abliS = str1 .. " " .. str2
			end

			strS[#strS + 1] = abliS
		end
	end

	return strS
end
player.setNewAbility = function (self, result)
	self.job = result.FJob
	self.initedAbility = true
	self.ability = result.FClientAbility

	return 
end
player.setStamina = function (self, cur, max)
	self.stamina = cur or 0
	self.staminaMax = max or 0

	return 
end
player.setVitality = function (self, cur, max)
	self.vitality = cur or 0
	self.vitalityMax = max or 0

	return 
end
player.setExpPoolValue = function (self, cur)
	self.expPoolValue = cur or 0

	return 
end
player.setVitaliyitemValue = function (self, cur)
	self.vitaliyitemValue = cur or 0

	return 
end
player.setAuthen = function (self, value)
	if not self.ability then
		print("player:setAuthen faild")

		return false
	end

	self.ability.FAuthenticate = value

	return 
end
player.isAuthen = function (self)
	if not self.ability then
		print("player:isAuthen faild")

		return false
	end

	return self.ability.FAuthenticate or false
end
player.setCreditScore = function (self, value)
	if not self.ability then
		print("player:setCreditScore faild")

		return 
	end

	self.ability.FCreditPoint = value

	return 
end
player.getCreditScore = function (self)
	if not self.ability then
		print("player:getCreditScore faild")

		return 0
	end

	return self.ability.FCreditPoint or 0
end
player.getJobStr = function (self)
	if self.job == 0 then
		return "战士"
	elseif self.job == 1 then
		return "法师"
	elseif self.job == 2 then
		return "道士"
	end

	return "刺客"
end
player.getOtherJobStr = function (self, job)
	if job == 0 then
		return "战士"
	elseif job == 1 then
		return "法师"
	elseif job == 2 then
		return "道士"
	end

	return "刺客"
end
player.setAttackMode = function (self, mode)
	self.attackMode = mode

	return 
end
player.setHitEnable = function (self, key, value)
	self.hitEnables[key] = value

	return 
end
player.setIsUnlimitedMove = function (self, b)
	self.isUnlimitedMove = b

	return 
end
player.setMagicList = function (self, result)
	self.magicList = {}

	for k, v in ipairs(result.FList) do
		self.magicList[#self.magicList + 1] = v
	end

	if WIN32_OPERATE then
		g_data.hotKey:loadMagicHotKey()
	end

	return 
end
player.getMagicDelay = function (self, magicId)
	for k, v in pairs(self.magicList) do
		if v.FMagicId == magicId then
			return v.FDelay
		end
	end

	return 
end
player.addMagic = function (self, result)
	self.magicList[#self.magicList + 1] = result.FClientMagic

	return result.FClientMagic
end
player.setMagicExp = function (self, result)
	local magic = nil

	for i, v in ipairs(self.magicList) do
		if v.FMagicId == result.FMagicIdx then
			magic = v

			break
		end
	end

	if not magic then
		return 
	end

	magic.FLevel = result.FMagicLv
	magic.FCurTrain = result.FCurExp
	magic.FMaxTrain = result.FNextExp
	magic.FNeedMp = result.FNeedMP

	return magic
end
player.setMagicKey = function (self, magicID, key)
	local changes = {}

	for i, v in ipairs(self.magicList) do
		if v.FMagicId == magicID then
			v.FKey = key
			changes[#changes + 1] = v
		elseif v.FKey == key and key ~= 0 then
			v.FKey = 0
			changes[#changes + 1] = v
		end
	end

	return changes
end
player.getMagic = function (self, magicID)
	for i, v in ipairs(self.magicList) do
		if v.FMagicId == magicID then
			return v
		end
	end

	return 
end
player.getMagicLvl = function (self, magicID)
	magicID = tonumber(magicID)

	for i, v in ipairs(self.magicList) do
		if v.FMagicId == magicID then
			return v.FLevel
		end
	end

	return 
end
player.weightChanged = function (self, weight, wearWeight, handWeight)
	self.ability:set("weight", weight)
	self.ability:set("wearWeight", wearWeight)
	self.ability:set("handWeight", handWeight)

	return 
end
player.setAllowGroup = function (self, groupEnable)
	self.groupEnable = groupEnable

	return 
end
player.setGroupMembers = function (self, list)
	self.groupMembers = {}

	if list then
		for i, v in ipairs(list) do
			if v ~= "" then
				self.groupMembers[#self.groupMembers + 1] = string.sub(v, 2)
			end
		end
	end

	return 
end
player.updateGroupMembers = function (self, result)
	local position, exleaderPos = nil

	for k, v in pairs(self.groupMembers) do
		if v.FUserId == result.FBase.FUserId then
			position = k
		end

		if v.FIsCaptain then
			exleaderPos = k
		end
	end

	if result.Flag == 0 and not position then
		local temp = result.FBase
		temp.FIsCaptain = false

		table.insert(self.groupMembers, temp)
		print(self.groupMembers)
	elseif not position then
		return 
	elseif result.Flag == 1 then
		table.remove(self.groupMembers, position)
	elseif result.Flag == 2 then
		local temp = result.FBase
		temp.FIsCaptain = self.groupMembers[position].FIsCaptain
		self.groupMembers[position] = temp
	elseif result.Flag == 3 then
		local temp = result.FBase
		temp.FIsCaptain = self.groupMembers[position].FIsCaptain
		self.groupMembers[position] = temp
	elseif result.Flag == 4 then
		self.groupMembers[exleaderPos].FIsCaptain = false
		self.groupMembers[position].FIsCaptain = true
	else
		return 
	end

	g_data.eventDispatcher:dispatch("TEAM_MEM_CHANGE", result.FBase.FUserId)

	return 
end
player.initGroupMembers = function (self, result)
	self.groupMembers = {}
	local mem = nil
	local roleids = {}

	if 1 <= #result.FMemInfoList then
		for i = 1, #result.FMemInfoList, 1 do
			mem = result.FMemInfoList[i].FBase
			mem.FIsCaptain = result.FMemInfoList[i].FIsCaptain
			self.groupMembers[#self.groupMembers + 1] = mem

			if g_data.player.roleid ~= mem.FUserId then
				table.insert(roleids, mem.FUserId)
			end

			g_data.mark:addGroup(mem.FName)
		end
	end

	g_data.eventDispatcher:dispatch("TEAM_MEM_CHANGE", roleids)

	return 
end
player.GroupCancel = function (self)
	if not self.groupMembers then
		return 
	end

	local roleids = {}

	for i, v in ipairs(self.groupMembers) do
		if g_data.player.roleid ~= v.FUserId then
			table.insert(roleids, v.FUserId)
		end
	end

	self.groupMembers = {}

	g_data.eventDispatcher:dispatch("TEAM_MEM_CHANGE", roleids)

	return 
end
player.getLeaderName = function (self)
	if not self.groupMembers then
		return ""
	end

	for i, v in ipairs(self.groupMembers) do
		if v.FIsCaptain then
			return v.FName
		end
	end

	return ""
end
player.setTeamLeader = function (self, leader)
	self.isTeamLeader = leader

	return 
end
player.getIsTeamLeader = function (self)
	return self.isTeamLeader
end
player.delGroupMember = function (self, name)
	if not self.groupMembers then
		return 
	end

	for i, v in ipairs(self.groupMembers) do
		print("name " .. name)

		if name == v.FName then
			g_data.eventDispatcher:dispatch("TEAM_MEM_CHANGE", v.FUserId)
			table.remove(self.groupMembers, i)

			break
		end
	end

	return 
end
player.isGroupMem = function (self, roleid)
	for i, v in ipairs(self.groupMembers) do
		if roleid == v.FUserId then
			return true
		end
	end

	return false
end
player.initNearGroup = function (self, result)
	self.nearGroupInfo = {}

	for i = 1, #result, 1 do
		self.nearGroupInfo[#self.nearGroupInfo + 1] = result[i]
	end

	return 
end
player.exitGuildSuccess = function (self)
	self.guild.info = nil
	self.guild.guildName = ""
	self.guild.rankName = ""
	self.guild.rankList = nil
	self.guild.memberList = {}
	self.guild.guildRight = 0
	self.guild.hasGuild = false
	self.guild.isAllowAlly = false
	self.guild.log = {}
	self.guild.heroTeamMember = 0
	self.guild.relationShip = {}
	self.guild.isGetRelationShipInfo = false
	self.guild.recvAllyVer = 0
	self.guild.allyVer = 0
	self.guild.focusVer = 0
	self.guild.killVer = 0

	return 
end
player.setGuildInfo = function (self, guildinfo)
	self.guild.info = guildinfo

	if guildinfo then
		self.setGuildRight(self, guildinfo.get(guildinfo, "conferRight"))

		local value = ycFunction:band(def.guild.guildFlag.tfAllowAlly, self.guild.info:get("guildFlag"))

		self.setAllowAlly(self, value == 1)
	end

	return 
end
player.getIsLeader = function (self)
	if self.guild.info then
		local value = ycFunction:band(ycFunction:rshift(self.guild.info:get("conferRight"), def.guild.guildPrivilege.gpOwner - 1), 1)

		return value == 1
	end

	print("info is nil")

	return false
end
player.getIsFirstLeader = function (self)
	if self.guild.info then
		local value = ycFunction:band(ycFunction:rshift(self.guild.info:get("conferRight"), def.guild.guildPrivilege.gpFirstOwner - 1), 1)

		return value == 1
	end

	print("info is nil")

	return false
end
player.getDisTime = function (self, timeNow, timeLocal)
	timeLocal = timeLocal or math.floor(self.guild.info:get("gsTime"):double())
	local disTime = math.floor(timeLocal - timeNow)

	if disTime < 1 then
		return "1天内"
	elseif 14 <= disTime then
		return "14天前"
	else
		return disTime .. "天前"
	end

	return 
end
player.setGuildName = function (self, guildName)
	self.guild.guildName = guildName

	self.setHasGuild(self, 0 < string.length(guildName))

	return 
end
player.getGuildName = function (self)
	if self.guild.info then
		return self.guild.info:get("gName")
	else
		return ""
	end

	return 
end
player.setHasGuild = function (self, hasGuild)
	self.guild.hasGuild = hasGuild

	return 
end
player.getHasGuild = function (self)
	return self.guild.hasGuild
end
player.setAllowAlly = function (self, isAllowAlly)
	self.guild.isAllowAlly = isAllowAlly

	return 
end
player.getAllowAlly = function (self)
	return self.guild.isAllowAlly
end
player.parseLog = function (self, buf, bufLen, type)
	local ibegin = 1
	local strs = {}

	for i = 1, bufLen, 1 do
		if string.byte(buf, i) == 0 and i ~= ibegin then
			local tmpLabel = string.sub(buf, ibegin, i)
			tmpLabel = ycFunction:a2u(tmpLabel, i - ibegin + 1)
			strs[#strs + 1] = tmpLabel
			ibegin = i + 1
		end
	end

	self.guild.log[type] = strs

	return 
end
player.isNeedSendrelationship = function (self)
	return isGetRelationShipInfo
end
player.relationShip = function (self, buf, bufLen, type)
	bufLen = bufLen or 0
	local ibegin = 1
	local strs = {}

	for i = 1, bufLen, 1 do
		if string.byte(buf, i) == 0 and i ~= ibegin then
			local tmpLabel = string.sub(buf, ibegin, i)
			tmpLabel = ycFunction:a2u(tmpLabel, i - ibegin + 1)
			strs[#strs + 1] = tmpLabel
			ibegin = i + 1
		end
	end

	isGetRelationShipInfo = true
	self.guild.relationShip[type] = strs

	return 
end
player.getRelationShip = function (self, type)
	return self.guild.relationShip[type]
end
player.getLog = function (self, type)
	return self.guild.log[type]
end
player.setHeroTeamMember = function (self, shotCode)
	self.guild.heroTeamMember = shotCode

	return 
end
player.getHeroTeamMember = function (self)
	return self.guild.heroTeamMember
end
player.setRankName = function (self, rankName)
	self.guild.rankName = rankName

	return 
end
player.getRankName = function (self)
	return self.guild.rankName
end
player.setGuildName = function (self, guildName)
	self.guild.guildName = guildName

	return 
end
player.getGuildName = function (self)
	return self.guild.guildName
end
player.setRankList = function (self, rankList)
	self.guild.rankList = rankList

	return 
end
player.getRankList = function (self)
	return self.guild.rankList
end
player.getOtherRankName = function (self, rankId)
	if not rankId then
		return ""
	end

	for i, v in ipairs(self.guild.rankList) do
		if v.get(v, "rankID") == rankId then
			return v.get(v, "rankName")
		end
	end

	return ""
end
player.setMemberList = function (self, RankKey, memberList)
	if not self.guild.memberList then
		self.guild.memberList = {}
	end

	self.guild.memberList[RankKey] = memberList

	return 
end
player.getMemberList = function (self, RankKey)
	if not self.guild.memberList then
		return {}
	end

	return self.guild.memberList[RankKey] or {}
end
player.DelMember = function (self, name)
	for i, v in pairs(self.guild.memberList) do
		for j, value in ipairs(v) do
			if value.get(value, "chrName") == name then
				table.remove(v, j)

				return i
			end
		end
	end

	return 
end
player.updateMemberInfo = function (self, member)
	if not self.guild.memberList then
		return 
	end

	for i, v in pairs(self.guild.memberList) do
		for j, value in ipairs(v) do
			if value.get(value, "chrName") == member.get(member, "chrName") then
				table.remove(v, j)
			end
		end
	end

	local rankList = self.guild.memberList[member.get(member, "rankID")]

	if not rankList then
		rankList = {}
		self.guild.memberList[member.get(member, "rankID")] = rankList
	end

	rankList[#rankList + 1] = member

	return 
end
player.setGuildInfoText = function (self, info)
	print("player:setGuildInfoText")

	info = info or ""
	self.guild.recruitGuildInfo = info

	return 
end
player.getGuildInfoText = function (self)
	return self.guild.recruitGuildInfo
end
player.setAllyVer = function (self, value)
	allyVer = value or 0

	return 
end
player.setRecvAllyVer = function (self, value)
	recvAllyVer = value or 0

	return 
end
player.setFocusVer = function (self, value)
	focusVer = value or 0

	return 
end
player.setKillVer = function (self, value)
	killVer = value or 0

	return 
end
player.setMemberShowType = function (self, type)
	self.guild.memberShowType = type

	return 
end
player.getMemberShowType = function (self)
	return self.guild.memberShowType
end
player.chargeRight = function (self, setType, value)
	return ycFunction:band(ycFunction:rshift(value, setType), 1) == 1
end
player.AddLshift = function (self, a, b, c)
	return ycFunction:bor(a, ycFunction:lshift(b, c))
end
player.setGuildRight = function (self, guildPrivilege)
	if not guildPrivilege then
		return 
	end

	print("设置行会权限")

	local tmpGuildPrivilege = def.guild.guildPrivilege
	local tmpGuildRight = 0
	local privilege = {}

	if self.chargeRight(self, tmpGuildPrivilege.gpOwner - 1, guildPrivilege) then
		privilege = {
			def.guild.guildActiveRight.garChgNotice,
			def.guild.guildActiveRight.garAddMember,
			def.guild.guildActiveRight.garDelMember,
			def.guild.guildActiveRight.garStartKill,
			def.guild.guildActiveRight.garAllyGuild,
			def.guild.guildActiveRight.garMoveRankMember,
			def.guild.guildActiveRight.garCreateRank,
			def.guild.guildActiveRight.garEditRank,
			def.guild.guildActiveRight.garSetFactoryRank,
			def.guild.guildActiveRight.garBuildWeapon,
			def.guild.guildActiveRight.garUpgradeWeapon,
			def.guild.guildActiveRight.garUseWeapon
		}
	else
		if self.chargeRight(self, tmpGuildPrivilege.gpLeader - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garMoveRankMember
			privilege[#privilege + 1] = def.guild.guildActiveRight.garBuildWeapon
			privilege[#privilege + 1] = def.guild.guildActiveRight.garUpgradeWeapon
			privilege[#privilege + 1] = def.guild.guildActiveRight.garUseWeapon
		end

		if self.chargeRight(self, tmpGuildPrivilege.gpDomestic - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garAddMember
			privilege[#privilege + 1] = def.guild.guildActiveRight.garDelMember
		end

		if self.chargeRight(self, tmpGuildPrivilege.gpForeign - 1, guildPrivilege) then
			privilege[#privilege + 1] = def.guild.guildActiveRight.garStartKill
			privilege[#privilege + 1] = def.guild.guildActiveRight.garAllyGuild
		end
	end

	for i = 1, #privilege, 1 do
		tmpGuildRight = self.AddLshift(self, tmpGuildRight, 1, privilege[i])
	end

	self.guild.guildRight = tmpGuildRight

	return 
end
player.hasStartKill = function (self)
	return self.chargeRight(self, def.guild.guildActiveRight.garStartKill, self.guild.guildRight)
end
player.hasEditRank = function (self)
	return self.chargeRight(self, def.guild.guildActiveRight.garEditRank, self.guild.guildRight)
end
player.hasMoveRankMember = function (self)
	return self.chargeRight(self, def.guild.guildActiveRight.garMoveRankMember, self.guild.guildRight)
end
player.hasChangeMember = function (self)
	return self.chargeRight(self, def.guild.guildActiveRight.garAddMember, self.guild.guildRight)
end
player.hasAllyGuild = function (self)
	return self.chargeRight(self, def.guild.guildActiveRight.garAllyGuild, self.guild.guildRight)
end
player.setTitlesInfo = function (self, result)
	self.titleInfo = result.FHonourTitleList

	return 
end
player.setWingInfo = function (self, result)
	self.wingInfo.FWingLv = result.FWingLv
	self.wingInfo.FWingHaveExp = result.FWingHaveExp
	self.wingInfo.FActivateWingList = result.FActivateWingList
	self.wingInfo.FShowWingList = result.FShowWingList
	self.wingInfo.FCurrWingShowId = result.FCurrWingShowId

	self.checkWingPointTip(self)

	return 
end
player.updateWingInfo = function (self, info)
	for i, v in pairs(info) do
		if self.wingInfo[i] ~= nil then
			self.wingInfo[i] = v
		end
	end

	self.checkWingPointTip(self)

	return 
end
player.checkWingPointTip = function (self)
	local allActiveWings = def.wing.getAllActivateCfg()
	local isShow = false

	for i, v in ipairs(allActiveWings) do
		if not self.isWingActivate(self, i) and self.isWingCanActivate(self, i) then
			g_data.pointTip:set("wing_activate", true)

			isShow = true

			break
		end
	end

	if not isShow then
		g_data.pointTip:set("wing_activate", false)
	end

	local allShowWings = def.wing.getAllShowCfg()
	local isShow = false

	for i, v in ipairs(allShowWings) do
		if not self.isWingHaveFeature(self, i) and self.isWingCanGetFeature(self, i) and self.isWingActivate(self, i) then
			g_data.pointTip:set("wing_show", true)

			isShow = true

			break
		end
	end

	if not isShow then
		g_data.pointTip:set("wing_show", false)
	end

	return 
end
player.getActivateWing = function (self, kind)
	local lst = {}

	if self.wingInfo and self.wingInfo.FActivateWingList then
		for i, v in ipairs(self.wingInfo.FActivateWingList) do
			local data = def.wing.getActiveCfg(v.FId)

			if data and kind == data.Kind then
				lst[#lst + 1] = data
			end
		end
	end

	return lst
end
player.isWingActivate = function (self, fid)
	if self.wingInfo and self.wingInfo.FActivateWingList then
		for i, v in ipairs(self.wingInfo.FActivateWingList) do
			if v.FId == fid then
				return true
			end
		end
	end

	return false
end
player.isWingCanActivate = function (self, fid)
	local cfg = def.wing.getActiveCfg(fid)

	if self.wingInfo.FWingLv < cfg.NeedWingLv then
		return false
	end

	local total = g_data.bag:getItemCount("白色羽毛")
	local totalBind = g_data.bag:getItemCount("绑定白色羽毛")

	if total + totalBind < cfg.NeedWhiteFeatherNum then
		return false
	end

	return true
end
player.isWingHaveFeature = function (self, fid)
	if self.wingInfo and self.wingInfo.FShowWingList then
		for i, v in ipairs(self.wingInfo.FShowWingList) do
			if v.FId == fid then
				return true
			end
		end
	end

	return false
end
player.isWingCanGetFeature = function (self, fid)
	local cfg = def.wing.getShowCfg(fid)

	if self.wingInfo.FWingLv < cfg.NeedWingLv then
		return false
	end

	local total = g_data.bag:getItemCount("金色羽毛")
	local totalBind = g_data.bag:getItemCount("绑定金色羽毛")

	if total + totalBind < cfg.NeedGoldenFeatherNum then
		return false
	end

	local need = string.split(cfg.NeedShowIdStr, "|")
	local allok = true

	for i, v in ipairs(need) do
		local wingId = tonumber(v)

		if wingId and not self.isWingHaveFeature(self, wingId) then
			allok = false

			break
		end
	end

	if not allok then
		return false
	end

	return true
end
player.getBestActivateWing = function (self, kind)
	local lst = self.getActivateWing(self, kind)
	local best = nil

	for i, v in ipairs(lst) do
		if not best or best.NeedWingLv < v.NeedWingLv then
			best = v
		end
	end

	return best
end
player.setFlagState = function (self, state)
	self.flagInfo.state = state

	g_data.eventDispatcher:dispatch("Flag_STATE_CHG")

	return 
end
player.setRideState = function (self, state)
	self.horseInfo.state = state

	g_data.eventDispatcher:dispatch("HORSE_STATE_CHG")

	return 
end
player.setPetState = function (self, state)
	self.petInfo.state = state

	g_data.eventDispatcher:dispatch("PET_STATE_CHG")

	return 
end
player.addSlave = function (self, monId)
	table.insert(self.slaves, monId)

	return 
end
player.removeSlave = function (self, monId)
	for k, v in ipairs(self.slaves) do
		if v == monId then
			table.remove(self.slaves, k)

			return true
		end
	end

	return false
end
player.hasSlave = function (self, monId)
	if not monId then
		return 0 < #self.slaves
	end

	for k, v in ipairs(self.slaves) do
		if v == monId then
			return true
		end
	end

	return 
end
player.fixStrLen = function (self, text, len)
	local strs = utf8strs(text)

	if len < #strs then
		local ret = ""

		for k = 1, len, 1 do
			ret = ret .. strs[k]
		end

		return ret .. "..."
	end

	return text
end
player.setGemstonesInfo = function (self, result)
	self.gemstonesInfo = {}

	for i, v in ipairs(def.gemstone.tOpenItem) do
		local exist = false
		local item = nil

		for n, m in pairs(result.FDiamondList) do
			if v.ID == tonumber(m.FID) then
				exist = true
				item = m

				break
			end
		end

		local unit = {
			ID = v.ID,
			exist = exist,
			configData = v
		}

		if unit.exist then
			unit.FID = v.ID
			unit.FLevel = item.FLevel
			unit.FHaveStuff = item.FHaveStuff
			unit.canActive = false
		else
			unit.FID = v.ID
			unit.FLevel = 0
			unit.FHaveStuff = 0
			unit.canActive = true
		end

		self.gemstonesInfo[unit.ID] = unit
	end

	self.checkGemstoneCanActive(self)
	g_data.pointTip:checkGemstoneActive()

	return 
end
player.setGemstonesUpgradeInfo = function (self, result)
	self.gemstonesUpgradeInfo = {}

	for i, v in ipairs(result.FDiamondSpotList) do
		table.insert(self.gemstonesUpgradeInfo, tonumber(v.FID))
	end

	g_data.pointTip:checkGemstoneUpgrade()

	return 
end
player.checkGemstoneCanActive = function (self)
	local function isCanActive(id, diamonList)
		local canActive = true
		local config = nil

		for k, v in pairs(def.gemstone.tConfigData) do
			if v.ID == id and v.DiamondLevel == 1 then
				config = v
			end
		end

		if not config then
			canActive = false
		else
			local level = self.ability.FLevel

			if level < tonumber(config.NeedLevel) then
				canActive = false
			elseif g_data.login.serverLevel and g_data.login.serverLevel < tonumber(config.NeedServerStep) then
				canActive = false
			elseif config.NeedStr ~= 0 then
				local ss = string.split(config.NeedStr, "/")

				for _, v in ipairs(ss) do
					local sss = string.split(v, "|")
					local needStone = tonumber(sss[2])
					local needLv = tonumber(sss[3])
					local exist = false

					for _, j in pairs(diamonList) do
						if needStone == tonumber(j.FID) then
							exist = true

							if j.FLevel < needLv then
								canActive = false

								break
							end
						end
					end

					if not canActive or not exist then
						canActive = false

						break
					end
				end
			end
		end

		return canActive
	end

	if not self.gemstonesInfo then
		return 
	end

	for i, v in pairs(self.gemstonesInfo) do
		if v.canActive then
			v.canActive = slot1(v.FID, self.gemstonesInfo)
		end
	end

	return 
end
player.setCrossServerState = function (self, state)
	self.crossServerState = state

	return 
end
player.getIsCrossServer = function (self)
	if not self.crossServerState or self.crossServerState == 0 then
		return false
	end

	return true
end
player.setFashionInfo = function (self, result)
	self.fashionInfo.FHaveList = result.FrevgList
	self.fashionInfo.clothShowId = result.FFEClothID
	self.fashionInfo.weaponShowId = result.FFEWeaponID

	return 
end
player.updateFashionLevelInfo = function (self, updateItemId, level, havestuff)
	for k, v in ipairs(self.fashionInfo.FHaveList) do
		if v.FID == updateItemId then
			v.FLevel = level
			v.FHaveStuff = havestuff

			break
		end
	end

	return 
end
player.updateFashionShowInfo = function (self, updateItemId, isshow)
	local updatetype = def.fashion.getFashionTypeByIdx(updateItemId)

	for k, v in ipairs(self.fashionInfo.FHaveList) do
		if updatetype == v.FFEType then
			if v.FID == updateItemId and isshow then
				if def.fashion.clothType == updatetype then
					self.fashionInfo.clothShowId = updateItemId
				elseif def.fashion.clothType == updatetype then
					self.fashionInfo.weaponType = updateItemId
				end

				v.FIsShow = 1
			else
				v.FIsShow = 0
			end
		end
	end

	if not isshow then
		if def.fashion.clothType == updatetype then
			self.fashionInfo.clothShowId = 0
		elseif def.fashion.clothType == updatetype then
			self.fashionInfo.weaponType = 0
		end
	end

	return 
end
player.setMilitaryEquipList = function (self, list)
	self.militaryEquip = list

	return 
end
player.getMilitaryEquipListById = function (self, typeid)
	for i = 1, #self.militaryEquip, 1 do
		local v = self.militaryEquip[i]

		if v.FID == typeid then
			return v
		end
	end

	return {
		FLevel = 0,
		FID = typeid
	}
end
player.decodePropsMI = function (self, miInfos, job)
	local id, lvl = nil
	local rets = {}
	local miTypes = {
		"青龙纹",
		"白虎纹",
		"朱雀纹"
	}
	local propTypes = {
		"攻击：",
		"魔法：",
		"道术："
	}

	for k, v in pairs(miInfos) do
		print("勋章铭刻数据解析:")

		if v and v.FmiTypeID and v.FmiLevel then
			id = v.FmiTypeID
			lvl = v.FmiLevel

			print("id:" .. id .. "-lvl:" .. lvl)

			local config = nil

			for k2, v2 in pairs(def.medalImpressUP) do
				if v2.miType == id and v2.miLevel == lvl then
					config = v2

					break
				end
			end

			if config then
				rets[id] = {
					lvl = miTypes[id] .. "+" .. lvl
				}

				if config.miGetProperty and config.miGetProperty ~= "" then
					print("解析主属性:" .. id .. lvl)

					local propStrs = string.split(config.miGetProperty, ";")
					local tmps, xx, sx = nil
					tmps = string.split(propStrs[job*2 + 1], "=")
					xx = tonumber(tmps[2])
					tmps = string.split(propStrs[job*2 + 2], "=")
					sx = tonumber(tmps[2])
					rets[id].mp = propTypes[job + 1] .. xx .. "-" .. sx

					if propStrs[job + 7] then
						tmps = string.split(propStrs[job + 7], "=")
						rets[id].hp = "生命值：+" .. tonumber(tmps[2])
					end
				end
			end
		end
	end

	return rets
end
player.setEmojiList = function (self, list)
	self.emojiActiveList = list

	return 
end
player.getEmojiList = function (self)
	local result = {}

	for k, v in pairs(self.emojiActiveList) do
		if v.FFlagState == 1 then
			table.insert(result, v.FIDType, true)
		end
	end

	return result
end

return player
