-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_ranking = i3k_class("wnd_array_stone_ranking", ui.wnd_base)

function wnd_array_stone_ranking:ctor()
	self._overview = {}
	self._level = 1
	self._stoneSuit = {}
	self._curGroupIndex = 1
end

function wnd_array_stone_ranking:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.suitBtn:onClick(self, self.onOpenSuitRanking)
end

function wnd_array_stone_ranking:refresh(overview)
	self._overview = overview
	self._level = g_i3k_db.i3k_db_get_array_stone_level(overview.exp)
	self:updateAlumetData()
end

function wnd_array_stone_ranking:updateAlumetData()
	local equipCount = i3k_db_array_stone_level[self._level].equipStoneCount
	for k = 1, g_ARRAY_STONE_MAX_EQUIP do
		self._layout.vars["levelBg"..k]:hide()
		self._layout.vars["amuletLock"..k]:hide()
		if self._overview.equips[k] and self._overview.equips[k] ~= 0 then
			self._layout.vars["levelBg"..k]:show()
			self._layout.vars["level"..k]:setText(i3k_get_string(18403, i3k_db_array_stone_cfg[self._overview.equips[k]].level))
			self._layout.vars["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_array_stone_cfg[self._overview.equips[k]].stoneIcon))
		elseif k <= equipCount then
			self._layout.vars["amuletIcon"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(2396))
		else
			self._layout.vars["amuletLock"..k]:show()
		end
	end
	local props = {}
	local equipSuit = {}
	local suitAdditionAll = {}
	local suitAdditionSelf = {}
	for i, j in pairs(i3k_db_array_stone_suit_group) do
		for m, n in ipairs(j.includeSuit) do
			for k, v in ipairs(self._overview.equips) do
				if v ~= 0 then
					if g_i3k_db.i3k_db_is_in_stone_suit_group(v, i) then
						if not equipSuit[n] then
							equipSuit[n] = {}
						end
						table.insert(equipSuit[n], v)
					end
				end
			end
		end
	end
	for k, v in pairs(equipSuit) do
		local suitCfg = i3k_db_array_stone_suit[k]
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, k) then
			local suitLevel = g_i3k_db.i3k_db_get_stone_suit_level(v, k)
			if suitCfg.additionType == g_STONE_SUIT_ADDITION_SELF then
				if not suitAdditionSelf[k] then
					suitAdditionSelf[k] = {}
				end
				for m, n in ipairs(suitCfg.additionProperty) do
					if n.id ~= 0 then
						if not suitAdditionSelf[k][n.id] then
							suitAdditionSelf[k][n.id] = 0
						end
						suitAdditionSelf[k][n.id] = suitAdditionSelf[k][n.id] + n.value[suitLevel]
					end
				end
			elseif suitCfg.additionType == g_STONE_SUIT_ADDITION_ALL then
				for m, n in ipairs(suitCfg.additionProperty) do
					if n.id ~= 0 then
						if not suitAdditionAll[n.id] then
							suitAdditionAll[n.id] = 0
						end
						suitAdditionAll[n.id] = suitAdditionAll[n.id] + n.value[suitLevel]
					end
				end
			end
			for m, n in ipairs(suitCfg.suitProperty) do
				if n.id ~= 0 then
					if not props[n.id] then
						props[n.id] = {value = 0, extra = 0}
					end
					props[n.id].extra = props[n.id].extra + n.value[suitLevel]
				end
			end
		end
	end
	for i, j in ipairs(self._overview.equips) do
		if j ~= 0 then
			for m, n in ipairs(i3k_db_array_stone_cfg[j].commonProperty) do
				local percent = 0
				for k, v in pairs(equipSuit) do
					if table.indexof(v, j) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
						percent = percent + suitAdditionSelf[k][n.id] / 10000
					end
				end
				if suitAdditionAll[n.id] then
					percent = percent + suitAdditionAll[n.id] / 10000
				end
				if i3k_db_array_stone_level[self._level].propertyRate ~= 0 then
					percent = percent + i3k_db_array_stone_level[self._level].propertyRate / 10000
				end
				if not props[n.id] then
					props[n.id] = {value = 0, extra = 0}
				end
				props[n.id].value = props[n.id].value + n.value
				props[n.id].extra = math.floor(props[n.id].extra + n.value * percent)
			end
			for m, n in ipairs(i3k_db_array_stone_cfg[j].extraProperty) do
				if self._level >= n.needLvl then
					local percent = 0
					for k, v in pairs(equipSuit) do
						if table.indexof(v, j) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
							percent = percent + suitAdditionSelf[k][n.id] / 10000
						end
					end
					if suitAdditionAll[n.id] then
						percent = percent + suitAdditionAll[n.id] / 10000
					end
					if i3k_db_array_stone_level[self._level].propertyRate ~= 0 then
						percent = percent + i3k_db_array_stone_level[self._level].propertyRate / 10000
					end
					if not props[n.id] then
						props[n.id] = {value = 0, extra = 0}
					end
					props[n.id].value = props[n.id].value + n.value
					props[n.id].extra = math.floor(props[n.id].extra + n.value * percent)
				end
			end
		end
	end
	local property = {}
	local powerProps = {}
	for k, v in pairs(props) do
		table.insert(property, {id = k, value = v.value, extra = v.extra})
		powerProps[k] = v.value + v.extra
	end
	table.sort(property, function(a, b)
		return a.id < b.id;
	end)
	self._layout.vars.alumetPropScroll:removeAllChildren()
	for k, v in ipairs(property) do
		local node = require("ui/widgets/zfsfysxt")()
		node.vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
		if v.extra > 0 then
			if v.value > 0 then
				node.vars.value:setText(i3k_get_prop_show(v.id, v.value))
				node.vars.extra:show()
				node.vars.extra:setText("+" .. i3k_get_prop_show(v.id, v.extra))
			else
				node.vars.value:setText(0)
				node.vars.extra:show()
				node.vars.extra:setText("+" .. i3k_get_prop_show(v.id, v.extra))
			end
		else
			node.vars.extra:hide()
			node.vars.value:setText(i3k_get_prop_show(v.id, v.value))
		end
		node.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
		self._layout.vars.alumetPropScroll:addItem(node)
	end
	self._layout.vars.power:setText(g_i3k_db.i3k_db_get_battle_power(powerProps))
end

function wnd_array_stone_ranking:onOpenSuitRanking(sender)
	local stoneSuit = {}
	local stoneGroup = {}
	for k, v in pairs(i3k_db_array_stone_suit_group) do
		for i, j in ipairs(self._overview.equips) do
			if j ~= 0 then
				if g_i3k_db.i3k_db_is_in_stone_suit_group(j, k) then
					if not stoneSuit[k] then
						stoneSuit[k] = {}
					end
					table.insert(stoneSuit[k], j)
				end
			end
		end
	end
	for k, v in pairs(stoneSuit) do
		if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, i3k_db_array_stone_suit_group[k].includeSuit[1]) then
			local finishSuit = {}
			for i, j in ipairs(i3k_db_array_stone_suit_group[k].includeSuit) do
				if g_i3k_db.i3k_db_get_is_finish_stone_suit(v, j) then
					table.insert(finishSuit, j)
				end
			end
			table.insert(stoneGroup, {groupId = k, stones = v, finishSuit = finishSuit})
		end
	end
	if next(stoneGroup) then
		g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneSuitRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneSuitRank, self._overview, stoneGroup)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18491))
	end
end

--后面这些都不要了
function wnd_array_stone_ranking:updateSuitData()
	
end

function wnd_create(layout)
	local wnd = wnd_array_stone_ranking.new()
	wnd:create(layout)
	return wnd
end