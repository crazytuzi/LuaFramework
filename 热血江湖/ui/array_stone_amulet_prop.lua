-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_amulet_prop = i3k_class("wnd_array_stone_amulet_prop", ui.wnd_base)


function wnd_array_stone_amulet_prop:ctor()
	
end

function wnd_array_stone_amulet_prop:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_array_stone_amulet_prop:refresh()
	self._layout.vars.title:setText(i3k_get_string(18433))
	local props = {}
	local info = g_i3k_game_context:getArrayStoneData()
	local level = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
	local equipSuit = {}
	local suitAdditionAll = {}
	local suitAdditionSelf = {}
	for i, j in pairs(i3k_db_array_stone_suit_group) do
		for m, n in ipairs(j.includeSuit) do
			for k, v in ipairs(info.equips) do
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
	for i, j in ipairs(info.equips) do
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
				if i3k_db_array_stone_level[level].propertyRate ~= 0 then
					percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
				end
				if not props[n.id] then
					props[n.id] = {value = 0, extra = 0}
				end
				props[n.id].value = props[n.id].value + n.value
				props[n.id].extra = math.floor(props[n.id].extra + n.value * percent)
			end
			for m, n in ipairs(i3k_db_array_stone_cfg[j].extraProperty) do
				if level >= n.needLvl then
					local percent = 0
					for k, v in pairs(equipSuit) do
						if table.indexof(v, j) and suitAdditionSelf[k] and suitAdditionSelf[k][n.id] then
							percent = percent + suitAdditionSelf[k][n.id] / 10000
						end
					end
					if suitAdditionAll[n.id] then
						percent = percent + suitAdditionAll[n.id] / 10000
					end
					if i3k_db_array_stone_level[level].propertyRate ~= 0 then
						percent = percent + i3k_db_array_stone_level[level].propertyRate / 10000
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
	local commonValue = {}
	local extraValue = {}
	for k, v in pairs(props) do
		table.insert(property, {id = k, value = v.value, extra = v.extra})
		commonValue[k] = v.value
		extraValue[k] = v.extra
	end
	table.sort(property, function(a, b)
		return a.id < b.id;
	end)
	self._layout.vars.scroll:removeAllChildren()
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
		self._layout.vars.scroll:addItem(node)
	end
	if g_i3k_db.i3k_db_get_battle_power(extraValue) > 0 then
		self._layout.vars.power:setText(g_i3k_db.i3k_db_get_battle_power(commonValue) .. "+" .. g_i3k_db.i3k_db_get_battle_power(extraValue))
	else
		self._layout.vars.power:setText(g_i3k_db.i3k_db_get_battle_power(commonValue))
	end
end

function wnd_create(layout)
	local wnd = wnd_array_stone_amulet_prop.new();
		wnd:create(layout);
	return wnd;
end