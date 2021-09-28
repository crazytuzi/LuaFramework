-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenWin = i3k_class("wnd_petWakenWin",ui.wnd_base)
local LAYER_SCLBT = "ui/widgets/scjxcgt"
function wnd_petWakenWin:ctor()

end

function wnd_petWakenWin:configure(...)
	local widgets	= self._layout.vars
	self.iconBg		= widgets.iconBg;
	self.iconBg1	= widgets.iconBg1;
	self.icon		= widgets.icon;
	self.icon1		= widgets.icon1;
	self.feedText	= widgets.feedText;
	self.scroll		= widgets.scroll;
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.okBtn:onClick(self, self.onCloseUI)		 
end

function wnd_petWakenWin:refresh(id)
	self:updateDate(id)
end

function wnd_petWakenWin:updateDate(id)
	local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id);
	local awakenCfg = i3k_db_mercenariea_waken_property[id];
	if cfg_data and awakenCfg then
		local upArg = awakenCfg.upArg / 100;
		self.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(cfg_data.icon, true))
		self.icon1:setImage(g_i3k_db.i3k_db_get_head_icon_path(awakenCfg.headIcon, true))
		self.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		self.iconBg1:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		self.feedText:setText("宠物的喂养属性提升"..upArg.."%");
		self:updateScroll(id);
	end	
end

function wnd_petWakenWin:updateScroll(id)
	local level = g_i3k_game_context:getPetLevel(id)
	local Data = self:GetPetAttributeValue(id, level);
	local awakenData = self:GetPetAttributeValue(id, level, true);
	self.scroll:removeAllChildren()
	for i,e in ipairs(Data) do
		local _layer = require(LAYER_SCLBT)()
		local icon
		if i == 8 then
			icon = 1934
		elseif i == 9 then
			icon = 1933
		elseif i == 10 then
			icon = 1018
		elseif i == 11 then
			icon = 1021
		else
			icon = g_i3k_db.i3k_db_get_property_icon(1000 + i)
		end
		_layer.vars.propertyName:setText(e.name)
		_layer.vars.propertyValue:setText(e.value)
		_layer.vars.propertyValue1:setText(awakenData[i].value)
		_layer.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		self.scroll:addItem(_layer)
	end
end

function wnd_petWakenWin:GetPetAttributeValue(id, lvl, isAwaken)
	local temp = {}
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
	if isAwaken then
		cfg = i3k_db_mercenariea_waken_property[id];
	end
	local finc,tdec,xinfa_inc,weapon_inc = g_i3k_game_context:get_star_data(id)
	local nameTab = {"气血", "攻击", "防御", "命中", "躲闪", "暴击", "韧性", "伤害增加", "伤害减免", "气功继承", "神兵继承"}
	local property = {1001, 1002, 1003, 1004, 1005, 1006, 1007, 1043, 1044}
	local propertyID,propertyCount = g_i3k_game_context:getHexiuProperty(id)
	xinfa_inc = xinfa_inc + cfg.atkCOrg*100
	weapon_inc = weapon_inc + cfg.atkWOrg*100
	for i=1,11 do
		local base = 0
		local value1 = 0
		local value2 = 0
		local name
		if i == 1 then
			base = cfg.hpOrg
			value1 = cfg.hpInc1
			value2 = cfg.hpInc2
		elseif i == 2 then
			base = cfg.atkNOrg
			value1 = cfg.atkNInc1
			value2 = cfg.atkNInc2
		elseif i == 3 then
			base = cfg.defNOrg
			value1 = cfg.defNInc1
			value2 = cfg.defNInc2
		elseif i == 4 then
			base = cfg.atrOrg
			value1 = cfg.atrInc1
			value2 = cfg.atrInc2
		elseif i == 5 then
			base = cfg.ctrOrg
			value1 = cfg.ctrInc1
			value2 = cfg.ctrInc2
		elseif i == 6 then
			base = cfg.acrNOrg
			value1 = cfg.acrNInc1
			value2 = cfg.acrNInc2
		elseif i == 7 then
			base = cfg.touOrg
			value1 = cfg.touInc1
			value2 = cfg.touInc2
		elseif i == 8 then
			base = math.modf(finc) .. "%"
		elseif i == 9 then
			base = math.modf(tdec) .. "%"
		elseif i == 10 then
			base = math.modf(xinfa_inc) .. "%"
		elseif i == 11 then
			base = math.modf(weapon_inc) .. "%"
		end
		local value
		local name
		if i <= 11 and i > 7 then
			value = base
			name = nameTab[i]
			if g_i3k_game_context:getIsCompletePetLifeTaskFromID(id) then
				for k=1,#propertyID do
					if name == i3k_db_prop_id[propertyID[k]].desc then
						if g_i3k_game_context:getPetStarLvl(id) == #i3k_db_suicong_upstar[id] and not g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_common.petBackfit.upCount/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(id) ~= #i3k_db_suicong_upstar[id] and g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_mercenariea_waken_property[id].upArg/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(id) == #i3k_db_suicong_upstar[id] and g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_mercenariea_waken_property[id].upArg/10000 + i3k_db_common.petBackfit.upCount/10000 + 1)
						end
						value = value + (propertyCount[k] / 100)
						break
					end
				end
			end
			temp[i] = {value = value, name = name, proID = property[i]}
		else
			name = nameTab[i]
			if g_i3k_game_context:getIsCompletePetLifeTaskFromID(id) then
				for k=1,#propertyID do
					if name == i3k_db_prop_id[propertyID[k]].desc then
						if g_i3k_game_context:getPetStarLvl(id) == #i3k_db_suicong_upstar[id] and not g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_common.petBackfit.upCount/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(id) ~= #i3k_db_suicong_upstar[id] and g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_mercenariea_waken_property[id].upArg/10000 + 1)
						elseif g_i3k_game_context:getPetStarLvl(id) == #i3k_db_suicong_upstar[id] and g_i3k_game_context:getPetIsWaken(id) then
							propertyCount[k] = propertyCount[k] * (i3k_db_mercenariea_waken_property[id].upArg/10000 + i3k_db_common.petBackfit.upCount/10000 + 1)
						end
						base = base + propertyCount[k]
						break
					end
				end
			end
			value = (lvl -1)*(lvl -1)*value1 + (lvl - 1)*value2 + base
			temp[i] = {value = math.modf(value), name = name, proID = property[i]}
		end
	end
	return temp
end


function wnd_create(layout)
	local wnd = wnd_petWakenWin.new()
	wnd:create(layout)
	return wnd
end
