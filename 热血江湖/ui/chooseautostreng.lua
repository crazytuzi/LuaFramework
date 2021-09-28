-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chooseAutoStreng = i3k_class("wnd_chooseAutoStreng", ui.wnd_base)


function wnd_chooseAutoStreng:ctor()
	self.allItem = {}
end

function wnd_chooseAutoStreng:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
end

function wnd_chooseAutoStreng:refresh(partId)
	local widgets = self._layout.vars
	widgets.autoStreng:onClick(self, self.onAutoStreng, partId)
	widgets.autoAverage:onClick(self, self.onAutoAverage, partId)
end

function wnd_chooseAutoStreng:onAutoStreng(sender, partId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_StrengEquip, "autoStrengMax", partId)
end

function wnd_chooseAutoStreng:onAutoAverage(sender, nowPartID)
	local wEquips = g_i3k_game_context:GetWearEquips()
	local upData = {}
	for i,e in ipairs(wEquips) do
		if e.equip and g_i3k_game_context:GetEquipStrengLevel(i) then
			if g_i3k_game_context:checkEquipFacility(i, g_FACILITY_EQUIP_UPGRADE) then
			upData[i] ={ qh_lv = g_i3k_game_context:GetEquipStrengLevel(i), breakLvl = g_i3k_game_context:GetEquipBreakLevel(i)}
			end
		end
	end
	local temp1,temp2 = true,true--需要连续失败两次才能说明没有可以升级的了
	while true do
		local minLevel = 999
		local partID = 0
		for k,v in pairs(upData) do
			local isShouldBreak = g_i3k_game_context:GetEquipShouldBreak(k, v.breakLvl, v.qh_lv)
			if minLevel >= v.qh_lv and not isShouldBreak then
				minLevel = v.qh_lv
				partID = k
			end
		end
		if wEquips[partID] and wEquips[partID].equip then
			local isCan = self:isEnough(partID, upData[partID].qh_lv)
			temp1 = temp2
			temp2 = isCan
			if isCan then
				upData[partID].qh_lv = upData[partID].qh_lv + 1
			else
				local isShouldBreak = g_i3k_game_context:GetEquipShouldBreak(partID, upData[partID].breakLvl, upData[partID].qh_lv)
				if isShouldBreak then
					upData[partID].breakLvl = upData[partID].breakLvl + 1
				end
				if (not temp1) and (not temp2) then
					break
				end
			end
		else
			break
		end
	end
	for k,v in pairs(upData) do
		if g_i3k_game_context:GetEquipStrengLevel(k) == v.qh_lv then
			upData[k] = nil
		else
			upData[k] = v.qh_lv
		end
	end
	if next(upData) then
		i3k_sbean.equip_batchlevelup(upData, nowPartID)
	else
		local decide = 0
		local recordAllpart = 0
		for i,e in ipairs(wEquips) do
			if e.equip and g_i3k_game_context:GetEquipStrengLevel(i) then
				recordAllpart = recordAllpart + 1
				local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(i);
				local level = g_i3k_game_context:GetEquipStrengLevel(i)
				local role_lvl = g_i3k_game_context:GetLevel()
				local _data = i3k_db_streng_equip[strengGroup][level + 1]
				if level == role_lvl then
					decide = decide + 1
				end
			end
		end
		if decide == recordAllpart then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(40))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1475))
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_StrengEquip, "updatePartRedPoint")
end

function wnd_chooseAutoStreng:isEnough(partID, Level)
	local role_lvl = g_i3k_game_context:GetLevel()
	local strengGroup = g_i3k_db.i3k_db_get_equip_streng_group(partID);
	local breakLvl = g_i3k_game_context:GetEquipBreakLevel(partID)
	local breakCfg = i3k_db_streng_equip_break[strengGroup][breakLvl + 1]
	if (breakCfg and breakCfg.level) == Level then--若果这个等级该突破了 就return false
		return false
	end
	local _data = i3k_db_streng_equip[strengGroup][Level + 1]
	if not _data or Level == role_lvl then
		return false
	end
	for i=1,3 do
		local item_id = string.format("item%sID",i)
		local item_count = string.format("item%sCount",i)
		if _data[item_id] ~= 0 then
			if not self.allItem[_data[item_id]] then
				self.allItem[_data[item_id]] = _data[item_count]
			else
				self.allItem[_data[item_id]] = self.allItem[_data[item_id]] + _data[item_count]
			end
			if self.allItem[_data[item_id]] > g_i3k_game_context:GetCommonItemCanUseCount(_data[item_id]) then
				return false
			end
		end
	end
	local value = g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_EQUIP_ENERGY)
	if not self.allItem[g_BASE_ITEM_EQUIP_ENERGY] then
		self.allItem[g_BASE_ITEM_EQUIP_ENERGY] = _data.energy
	else
		self.allItem[g_BASE_ITEM_EQUIP_ENERGY] = self.allItem[g_BASE_ITEM_EQUIP_ENERGY] + _data.energy
	end
	if self.allItem[g_BASE_ITEM_EQUIP_ENERGY] > value then
		return false
	end
	return true
end

function wnd_create(layout)
	local wnd = wnd_chooseAutoStreng.new()
	wnd:create(layout)
	return wnd;
end
