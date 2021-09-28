-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_new_change_icon = i3k_class("wnd_faction_new_change_icon", ui.wnd_base)

local LAYER_XGTPT = "ui/widgets/xgtpt"
local LAYER_XGTPT2 = "ui/widgets/xgtpt2"

local RowitemCount = 5

function wnd_faction_new_change_icon:ctor()

	self._id = 0
	self._select_state = {}
end



function wnd_faction_new_change_icon:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local sure_btn = self._layout.vars.sure_btn 
	sure_btn:onTouchEvent(self,self.onChange)
	self.faction_icon = self._layout.vars.faction_icon 
	--self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_game_context:GetFactionIcon()))
	self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[g_i3k_game_context:GetFactionIcon()].iconid))
	self.item_scroll = self._layout.vars.item_scroll 
end

function wnd_faction_new_change_icon:onShow()
	
end

function wnd_faction_new_change_icon:refresh()
	self:setData()
end 

function wnd_faction_new_change_icon:setData()
	local _data = {}
	for k,v in pairs(i3k_db_faction_icons) do
		if not _data[v.need_level] then
			_data[v.need_level] = {need_level = v.need_level,icons = {},faction_id = {}}
		end
		table.insert(_data[v.need_level].icons,v.iconid)
		table.insert(_data[v.need_level].faction_id,v.faction_id)
	end
		
	local tmp_t = {}
	for k,v in pairs(_data) do
		table.insert(tmp_t,v)
	end 
	
	table.sort(tmp_t,function(a,b)
		return a.need_level < b.need_level
	end)
	local faction_lvl = g_i3k_game_context:GetFactionLevel()
	for k,v in ipairs(tmp_t) do
		local _layer1 = self.item_scroll:addItemAndChild(LAYER_XGTPT2)
		local desc_label = _layer1[1].vars.desc_label 
		
		if faction_lvl>= v.need_level then
			desc_label:setText(i3k_get_string(253))
		else
			desc_label:setText(i3k_get_string(254,v.need_level))
		end
		
		
		local index = #v.icons
		local children = self.item_scroll:addItemAndChild(LAYER_XGTPT, RowitemCount, index)
		
		for i,a in ipairs(children) do
			local t = {}
			t.id = v.icons[i]
			t.lvl = v.need_level
			t.faction_lvl = faction_lvl
			t.faction_id = v.faction_id[i]
			a.vars.bt:onClick(self,self.onSelect,t)
			a.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icons[i]))
			a.vars.select_icon:hide()
			self._select_state[v.faction_id[i]] = {select_icon = a.vars.select_icon}
			a.vars.grade_icon:enable()
			if faction_lvl < v.need_level then
				a.vars.grade_icon:disable()
			end
		end
		
		
		
	end 
	
end

function wnd_faction_new_change_icon:hideAllSelectState()
	for k,v in pairs(self._select_state) do
		v.select_icon:hide()
	end
end 

function wnd_faction_new_change_icon:showSelectState(id)
	self:hideAllSelectState()
	self._select_state[id].select_icon:show()
end 

function wnd_faction_new_change_icon:onSelect(sender,t)
	
	
	if t.faction_lvl < t.lvl then
		g_i3k_ui_mgr:PopupTipMessage("帮派等级不足，不可选择")
		return 
	end
	
	
	self._id = t.faction_id
	self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[self._id].iconid))
	self:showSelectState(self._id)
	
end

function wnd_faction_new_change_icon:onChange(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._id == 0 then
			return 
		end 
		local data = i3k_sbean.sect_changeicon_req.new()
		data.icon = self._id
		i3k_game_send_str_cmd(data,i3k_sbean.sect_changeicon_res.getName())
		self:hideAllSelectState()
	end 
end 

--[[function wnd_faction_new_change_icon:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionNewChangeIcon)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_new_change_icon.new()
	wnd:create(layout, ...)
	return wnd;
end

