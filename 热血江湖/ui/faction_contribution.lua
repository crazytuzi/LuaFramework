-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_contribution = i3k_class("wnd_faction_contribution", ui.wnd_base)

local USE_COUNT = 1

local MAX_COUNT = 0

--帮贡id
local contributionID = 3

function wnd_faction_contribution:ctor()
	self._id = nil
	self._skillID = nil
	self._contri = 0
end



function wnd_faction_contribution:configure(...)
	local cancel = self._layout.vars.cancel 
	cancel:onTouchEvent(self,self.onCancel)
	local ok = self._layout.vars.ok
	ok:onTouchEvent(self,self.onOK)
	self.itemCount = self._layout.vars.itemCount 
	self.item_bg = self._layout.vars.item_bg
	self.item_icon = self._layout.vars.item_icon  
	self.item_name = self._layout.vars.item_name
	self.jian = self._layout.vars.jian 
	self.jia = self._layout.vars.jia
	self.max = self._layout.vars.max 
	self.sale_count = self._layout.vars.sale_count
	self.money_icon = self._layout.vars.money_icon 
	self.money_count = self._layout.vars.money_count 
end

function wnd_faction_contribution:onShow()
	
end

function wnd_faction_contribution:updateData()
	
	local itemid = self._id
	local skills_data = g_i3k_game_context:GetFactionSkillData()
	if not skills_data[self._skillID] or not i3k_db_faction_skill[self._skillID] then
		return 
	end 
	local skill_level = skills_data[self._skillID].level
	local _data = i3k_db_faction_skill[self._skillID][skill_level+1]
	local args = 0
	for i=1,4 do
		local tmp_item = string.format("item%s",i)
		local item = _data[tmp_item]
		local tmp_contri = string.format("contribution%s",i)
		if item == itemid then
			args = _data[tmp_contri]
			break
		end
	end
	local have_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	self.itemCount:setText(have_count)
	MAX_COUNT = have_count
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	self.jian:onTouchEvent(self,self.onJian)
	self.jia:onTouchEvent(self,self.onJia)
	self.max:onTouchEvent(self,self.onMax)
	local tmp_str = string.format("%s/%s",USE_COUNT,MAX_COUNT)
	self.sale_count:setText(tmp_str)
	self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_MONEY,i3k_game_context:IsFemaleRole()))
	self.money_count:setText(args * USE_COUNT)
end

function wnd_faction_contribution:onJian(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local itemid = self._id
		local skills_data = g_i3k_game_context:GetFactionSkillData()
		if not skills_data[self._skillID] or not i3k_db_faction_skill[self._skillID] then
			return 
		end 
		local skill_level = skills_data[self._skillID].level
		local _data = i3k_db_faction_skill[self._skillID][skill_level+1]
		local args = 0
		for i=1,4 do
			local tmp_item = string.format("item%s",i)
			local item = _data[tmp_item]
			local tmp_contri = string.format("contribution%s",i)
			if item == itemid then
				args = _data[tmp_contri]
				break
			end
		end
		USE_COUNT = USE_COUNT - 1
		if USE_COUNT <=0 then
			USE_COUNT = 1
		end 
		
		local tmp_str = string.format("%s/%s",USE_COUNT,MAX_COUNT)
		self.sale_count:setText(tmp_str)
		self.money_count:setText(args * USE_COUNT)
		
	end
end

function wnd_faction_contribution:onJia(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local itemid = self._id
		local skills_data = g_i3k_game_context:GetFactionSkillData()
		if not skills_data[self._skillID] or not i3k_db_faction_skill[self._skillID] then
			return 
		end
		local skill_level = skills_data[self._skillID].level
		local _data = i3k_db_faction_skill[self._skillID][skill_level+1]
		local args = 0
		for i=1,4 do
			local tmp_item = string.format("item%s",i)
			local item = _data[tmp_item]
			local tmp_contri = string.format("contribution%s",i)
			if item == itemid then
				args = _data[tmp_contri]
				break
			end
		end
		USE_COUNT = USE_COUNT + 1
		local temp_count = 0
		if MAX_COUNT >= self._maxContriCount then
			temp_count = self._maxContriCount
		else
			temp_count = MAX_COUNT
		end
		
		if temp_count < USE_COUNT then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10034))
			USE_COUNT = temp_count
			return 
		end
		if USE_COUNT >= temp_count then
			USE_COUNT = temp_count
		end 
		
		local tmp_str = string.format("%s/%s",USE_COUNT,MAX_COUNT)
		self.sale_count:setText(tmp_str)
		self.money_count:setText(args * USE_COUNT)
	end
end

function wnd_faction_contribution:onMax(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local itemid = self._id
		local skills_data = g_i3k_game_context:GetFactionSkillData()
		local skill_level = skills_data[self._skillID].level
		local _data = i3k_db_faction_skill[self._skillID][skill_level+1]
		local args = 0
		for i=1,4 do
			local tmp_item = string.format("item%s",i) 
			local item = _data[tmp_item]
			local tmp_contri = string.format("contribution%s",i)
			if item == itemid then
				args = _data[tmp_contri]
				break
			end
		end
		local temp_count = 0
		if MAX_COUNT >= self._maxContriCount then
			temp_count = self._maxContriCount
		else
			temp_count = MAX_COUNT
		end
		
		if USE_COUNT == temp_count then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10034))
			return 
		end
		USE_COUNT = temp_count
		local tmp_str = string.format("%s/%s",USE_COUNT,MAX_COUNT)
		self.sale_count:setText(tmp_str)
		self.money_count:setText(args * USE_COUNT)
		
	end
end


function wnd_faction_contribution:onCancel(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		USE_COUNT = 1
		g_i3k_ui_mgr:CloseUI(eUIID_FactionContribution)
	end
end

function wnd_faction_contribution:onOK(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local skills_data = g_i3k_game_context:GetFactionSkillData()
		if not skills_data[self._skillID]  then
			return 
		end
		local skill_level = skills_data[self._skillID].level
		local data = i3k_sbean.sect_auraexpadd_req.new()
		data.auraId = self._skillID
		data.itemId = self._id
		data.itemCount = USE_COUNT
		data.level	 = skill_level
		data.contri = self._contri
		i3k_game_send_str_cmd(data,i3k_sbean.sect_auraexpadd_res.getName())
		USE_COUNT = 1
		g_i3k_ui_mgr:CloseUI(eUIID_FactionContribution)
	end
end

function wnd_faction_contribution:refresh(itemid,skillId,maxCount,contri_count)
	self._id = itemid
	self._skillID  = skillId
	self._maxContriCount = maxCount
	self._contri = contri_count
	self:updateData()
end 

function wnd_faction_contribution:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionContribution)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_contribution.new();
		wnd:create(layout, ...);

	return wnd;
end

