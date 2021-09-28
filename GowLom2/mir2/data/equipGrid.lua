local equipGrid = {
	maxEquipGridLvl = 50,
	numEquipGrid = 10,
	FEquipExtralType = 0,
	FEquipBarList = {},
	data = {
		extralCfgData
	},
	equipGridKind = {
		[0] = {
			"dress",
			"衣服"
		},
		{
			"weapon",
			"武器"
		},
		[3] = {
			"necklace",
			"项链"
		},
		[4] = {
			"helmet",
			"头盔"
		},
		[5] = {
			"bracelets",
			"左手镯"
		},
		[6] = {
			"bracelets",
			"右手镯"
		},
		[7] = {
			"ring",
			"左戒指"
		},
		[8] = {
			"ring",
			"右戒指"
		},
		[10] = {
			"belt",
			"腰带"
		},
		[11] = {
			"shoe",
			"鞋子"
		}
	},
	equipBoRange = {
		"",
		"",
		"",
		"沃玛",
		"祖玛",
		"赤月",
		"(强化)魔龙",
		"战神",
		"星王",
		"王者"
	},
	nameToId = {
		武器 = 1,
		头盔 = 4,
		右手手镯 = 6,
		左戒指 = 7,
		衣服 = 0,
		右戒指 = 8,
		左手手镯 = 5,
		腰带 = 10,
		项链 = 3,
		靴子 = 11
	},
	getExtralProp = function (self, idx)
		local extralCfgs = def.equipBarExtralCfg
		local cfg = extralCfgs[self.FEquipExtralType]

		if cfg and cfg.PropertyStr then
			local propertyStr = cfg.PropertyStr
			local strArr = string.split(propertyStr, "=")

			return strArr
		end

		return 
	end,
	getExtralPropByExtralType = function (self, idx, extralType)
		local extralCfgs = def.equipBarExtralCfg
		local cfg = extralCfgs[extralType]

		if cfg and cfg.PropertyStr and cfg.PropertyStr ~= "" then
			local propertyStr = cfg.PropertyStr
			local strArr = string.split(propertyStr, "=")

			if strArr and #strArr == 2 then
				local ret = {
					name = strArr[1],
					val = strArr[2],
					needEquipBarLv = cfg.NeedEquipBarLv,
					barCount = cfg.EquipBarCount
				}

				return ret
			end
		end

		return 
	end,
	getEquipLvlStr = function (self, lvl)
		if lvl <= #self.equipBoRange then
			return self.equipBoRange[lvl]
		end

		return 
	end,
	setEquipBarInfo = function (self, result)
		if result then
			self.FEquipBarList = result.FEquipBarList
			self.FEquipExtralType = result.FEquipExtralType
		end

		return 
	end,
	getCfgName = function (self, idx)
		return self.equipGridKind[idx][2]
	end,
	getCfgImgName = function (self, idx)
		return self.equipGridKind[idx][1]
	end,
	getEquipBarInfoById = function (self, idx)
		local info = nil

		for k, v in pairs(self.FEquipBarList) do
			if v.FIDx == idx then
				info = v

				break
			end
		end

		return info
	end,
	getEquipBarLvlById = function (self, idx)
		local info = self.getEquipBarInfoById(self, idx)

		if info and info.FLevel then
			return info.FLevel
		end

		return 0
	end,
	getBoActLvlById = function (self, selIdx)
		local lvl = self.getEquipBarLvlById(self, selIdx)
		local config = self.findEquipGridCfgByIdAndLvl(self, selIdx, lvl)

		if config and 4 <= config.BoActItemLevel then
			return self.equipBoRange[config.BoActItemLevel]
		end

		return 
	end,
	getEquipLvlToRange = function (self)
		local LvlToRange = self.data.LvlToRange

		if LvlToRange then
			return LvlToRange
		end

		local barBaseCfg = def.equipBarBaseCfg
		LvlToRange = {}
		local limit = 1
		local curLvl = 4
		local i = 1

		for i = 1, #barBaseCfg, 1 do
			if barBaseCfg[i].EquipBarIdx == 0 then
				if curLvl < barBaseCfg[i].BoActItemLevel then
					LvlToRange[#LvlToRange + 1] = {
						self.equipBoRange[curLvl],
						"+1" .. "~+" .. barBaseCfg[i].EquipBarLevel - 1
					}
					limit = barBaseCfg[i].EquipBarLevel
					curLvl = barBaseCfg[i].BoActItemLevel
				end
			else
				LvlToRange[#LvlToRange + 1] = {
					self.equipBoRange[curLvl],
					"+1" .. "~+" .. barBaseCfg[i - 1].EquipBarLevel
				}

				break
			end
		end

		self.data.LvlToRange = self.data.LvlToRange

		return LvlToRange
	end,
	getPropertyStr = function (self, strProp, job)
		local props = {}
		local props2 = {}
		local tabStr = {}
		props = string.split(strProp, ";")

		if #props == 3 then
			props2 = string.split(props[job + 1], "=")
			tabStr[1] = props2[2]
		elseif #props == 6 then
			props2 = string.split(props[job*2 + 1], "=")
			tabStr[1] = props2[2] .. "-"
			props2 = string.split(props[job*2 + 2], "=")
			tabStr[1] = tabStr[1] .. props2[2]
		elseif #props == 9 then
			props2 = string.split(props[job*2 + 1], "=")
			tabStr[1] = props2[2] .. "-"
			props2 = string.split(props[job*2 + 2], "=")
			tabStr[1] = tabStr[1] .. props2[2]
			props2 = string.split(props[job + 7], "=")
			tabStr[2] = props2[2]
		end

		return tabStr, #props
	end,
	getEquipGridToAttr = function (self, idx)
		local barBaseCfg = def.equipBarBaseCfg
		local equipGridToAttr = {}

		for i = 1, #barBaseCfg, 1 do
			if barBaseCfg[i].EquipBarIdx == idx then
				strProp = barBaseCfg[i].PropertyStr

				if strProp ~= "" then
					local tabStr, num = self.getPropertyStr(self, strProp, g_data.player.job)
					local tmp = ""

					if #tabStr == 2 then
						tmp = "攻击: " .. tabStr[1] .. "\n生命: +" .. tabStr[2]
					elseif num == 3 then
						tmp = "生命: +" .. tabStr[1]
					elseif num == 6 then
						tmp = "攻击: " .. tabStr[1]
					end

					equipGridToAttr[#equipGridToAttr + 1] = {
						"+" .. barBaseCfg[i].EquipBarLevel,
						tmp
					}
				end
			end
		end

		return equipGridToAttr
	end,
	getAdditionAttr = function (self)
		local data = self.data.extralCfgData

		if data then
			return data
		end

		local extralCfg = def.equipBarExtralCfg
		data = {}
		local curVal = 0
		local lvl, prop = nil

		for i = 1, #extralCfg, 1 do
			lvl = "+" .. extralCfg[i].NeedEquipBarLv
			prop = string.split(extralCfg[i].PropertyStr, "=")

			if #prop == 2 and curVal < tonumber(prop[2]) then
				curVal = tonumber(prop[2])
				data[#data + 1] = {
					lvl,
					extralCfg[i].EquipBarCount,
					prop[1] .. ": " .. prop[2] .. "%"
				}
			end
		end

		self.data.extralCfgData = data

		return data
	end,
	getPropValue = function (self, idx, lvl, job)
		local propValue = {}
		local barCfg = self.findEquipGridCfgByIdAndLvl(self, idx, lvl)

		if not barCfg then
			return propValue
		end

		if g_data.player.ability.FLevel < barCfg.UpNeedPlayerLevel then
			local playerLevelStr = barCfg.UpNeedPlayerLevel%99 .. "级"

			if 0 < math.floor(barCfg.UpNeedPlayerLevel/99) then
				playerLevelStr = math.floor(barCfg.UpNeedPlayerLevel/99) .. "转" .. playerLevelStr
			end

			propValue[#propValue + 1] = playerLevelStr
		else
			propValue[#propValue + 1] = ""
		end

		if g_data.client.serverState < barCfg.UpNeedServerStep then
			propValue[#propValue + 1] = barCfg.UpNeedServerStep .. "阶段"
		else
			propValue[#propValue + 1] = ""
		end

		local itemLevel = 0

		if g_data.equip.items[idx] then
			itemLevel = g_data.equip.items[idx]:getVar("itemLevel")
		end

		propValue[#propValue + 1] = self.equipBoRange[barCfg.BoActItemLevel]
		local config = g_data.equipGrid:findEquipGridCfgByIdAndLvl(idx, lvl)

		if config and config.UpNeedOpenDays and g_data.client.openDay < config.UpNeedOpenDays then
			propValue[#propValue + 1] = config.UpNeedOpenDays .. "天"
		else
			propValue[#propValue + 1] = ""
		end

		strProp = barCfg.PropertyStr

		if strProp ~= "" then
			local tabStr, kind = self.getPropertyStr(self, strProp, job)

			if kind == 3 then
				propValue[#propValue + 1] = ""
				propValue[#propValue + 1] = "+" .. tabStr[1]
			elseif kind == 6 then
				propValue[#propValue + 1] = tabStr[1]
				propValue[#propValue + 1] = ""
			elseif kind == 9 then
				propValue[#propValue + 1] = tabStr[1]
				propValue[#propValue + 1] = "+" .. tabStr[2]
			end
		end

		return propValue
	end,
	getNeedStuff = function (self, idx, lvl)
		lvl = lvl or 0
		local barBaseCfg = self.findEquipGridCfgByIdAndLvl(self, idx, lvl)

		if not barBaseCfg then
			return ""
		end

		local stuffStr = {}
		local needStuff = barBaseCfg.NeedStuff

		if needStuff ~= "" then
			needStuff = string.split(needStuff, "|")

			if needStuff[2] and needStuff[2] ~= "" then
				stuffStr[#stuffStr + 1] = "炼体符*" .. needStuff[2]
			end
		end

		if 0 < barBaseCfg.UpNeedGoldNum then
			stuffStr[#stuffStr + 1] = "金币*" .. barBaseCfg.UpNeedGoldNum
		end

		local retStr = ""

		if 0 < #stuffStr then
			retStr = stuffStr[1]

			for i = 2, #stuffStr, 1 do
				retStr = retStr .. "、" .. stuffStr[i]
			end
		end

		return retStr
	end,
	findEquipGridCfgByIdAndLvl = function (self, idx, lvl)
		if not idx or not lvl then
			return nil
		end

		local barCfg = nil
		local barBaseCfg = def.equipBarBaseCfg

		for i = 1, #barBaseCfg, 1 do
			if barBaseCfg[i].EquipBarIdx == idx and barBaseCfg[i].EquipBarLevel == lvl then
				barCfg = barBaseCfg[i]

				break
			end
		end

		return barCfg
	end,
	checkSpecialNeed = function (self, idx)
		local lvl = self.getEquipBarLvlById(self, idx)
		local barCfg = self.findEquipGridCfgByIdAndLvl(self, idx, lvl + 1)

		if barCfg and barCfg.SpecialNeed and barCfg.SpecialNeed ~= "" then
			local needArr = string.split(barCfg.SpecialNeed, ";")
			local needLvl = 0
			local barStrs = {}

			for i = 1, #needArr, 1 do
				local nameAndLvl = string.split(needArr[i], "=")

				if #nameAndLvl == 2 then
					local barOtherIdx = self.nameToId[nameAndLvl[1]]
					needLvl = tonumber(nameAndLvl[2])

					if barOtherIdx and needLvl then
						local barOtherLvl = self.getEquipBarLvlById(self, barOtherIdx)

						if barOtherLvl < needLvl then
							barStrs[#barStrs + 1] = nameAndLvl[1]
						end
					end
				end
			end

			return barStrs, needLvl
		end

		return 
	end,
	checkStrengthen = function (self, id, lvl)
		if not id or not lvl or lvl < 0 then
			return false, ""
		end

		local barCfg = self.findEquipGridCfgByIdAndLvl(self, id, lvl)

		if not barCfg then
			return false
		end

		if self.maxEquipGridLvl <= lvl then
			return false, self.equipGridKind[id + 1][2] .. "已强化至最大值"
		end

		if g_data.player.ability.FLevel < barCfg.UpNeedPlayerLevel then
			local playerLevelStr = barCfg.UpNeedPlayerLevel%99 .. "级"

			if 0 < math.floor(barCfg.UpNeedPlayerLevel/99) then
				playerLevelStr = math.floor(barCfg.UpNeedPlayerLevel/99) .. "转" .. playerLevelStr
			end

			return false, "角色等级达到" .. playerLevelStr .. "后开启"
		end

		if g_data.client.openDay < barCfg.UpNeedOpenDays then
			return false, "开服" .. barCfg.UpNeedOpenDays .. "天后开启"
		end

		if lvl == 0 then
			return true
		end

		if barCfg.SpecialNeed ~= "" then
			local ret, msg = self.checkSpecialNeed(self, barCfg.SpecialNeed)

			if not ret then
				return ret, msg
			end
		end

		local msg = "背包内"
		local ret = true

		return ret, msg
	end,
	getTipColorById = function (self, lvl)
		return def.colors.Cf1ed02
	end,
	getBarTipH = function (self, idx)
		if idx == 0 then
			return 60
		elseif idx == 1 then
			return 40
		elseif idx == 4 then
			return 20
		end

		return 
	end,
	getBarLvlWithOtherBar = function (self, FEquipBarList, idx)
		local info = nil

		for k, v in pairs(FEquipBarList) do
			if v.FIDx == idx then
				info = v

				break
			end
		end

		if info then
			return info.FLevel
		end

		return 0
	end,
	getBarBoLvlWithOtherBar = function (self, FEquipBarList, idx)
		local info = nil

		for k, v in pairs(FEquipBarList) do
			if v.FIDx == idx then
				info = v

				break
			end
		end

		if info then
			return info.FBoActiveLevel
		end

		return 0
	end,
	getBarBoActiveLevel = function (self, idx)
		local cfg = self.getEquipBarInfoById(self, idx)

		if cfg then
			return cfg.FBoActiveLevel
		end

		return 0
	end
}

return equipGrid
