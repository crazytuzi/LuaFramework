-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_change_skill_icon = i3k_class("wnd_change_skill_icon", ui.wnd_base)

local LAYER_XGTPT = "ui/widgets/xgtpt"
local LAYER_XGTPT2 = "ui/widgets/xgtpt2"

local RowitemCount = 6

function wnd_change_skill_icon:ctor()
	self._id = nil
	self._select_state = {}
end



function wnd_change_skill_icon:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.item_scroll

end

function wnd_change_skill_icon:onShow()

end

function wnd_change_skill_icon:refresh(id)
	self._id = id
	self:setData()
end

function wnd_change_skill_icon:setData()

	local _data = {}
	if self._id == 1 then
		_data = i3k_db_kungfu_args.icons.id
		local index = #_data
		local children = self.item_scroll:addChildWithCount(LAYER_XGTPT, RowitemCount, #_data)
		for i,v in ipairs(children) do
			v.vars.bt:setTag(_data[i])
			v.vars.bt:onClick(self,self.onSelect)
			v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(_data[i]))
		end
	elseif self._id == 2 then
		self._select_state = {}
		local _data2 = {}
		for k,v in pairs(i3k_db_faction_icons) do
			if not _data2[v.need_level] then
				_data2[v.need_level] = {need_level = v.need_level,icons = {},faction_id = {}}
			end
			table.insert(_data2[v.need_level].icons,v.iconid)
			table.insert(_data2[v.need_level].faction_id,v.faction_id)
		end
		
		local tmp_t = {}
		for k,v in pairs(_data2) do
			table.insert(tmp_t,v)
		end 

		table.sort(tmp_t,function(a,b)
			return a.need_level < b.need_level
		end)
		local faction_lvl = 1
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
				a.vars.bt:onClick(self,self.onSelectFactionIcon,t)
				a.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icons[i]))
				a.vars.select_icon:hide()
				self._select_state[v.icons[i]] = {select_icon = a.vars.select_icon}
				a.vars.grade_icon:enable()
				if faction_lvl < v.need_level then
					a.vars.grade_icon:disable()
				end
			end
		end

	end

end

function wnd_change_skill_icon:hideAllSelectState()
	for k,v in pairs(self._select_state) do
		v.select_icon:hide()
	end
end

function wnd_change_skill_icon:showSelectState(id)
	self:hideAllSelectState()
	self._select_state[id].select_icon:show()
end

function wnd_change_skill_icon:onSelectFactionIcon(sender,t)
	if t.faction_lvl < t.lvl then
		g_i3k_ui_mgr:PopupTipMessage("未开放，不可选择")
		return
	end
	g_i3k_game_context:setFactionSelectIcon(t.faction_id)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateFaction, "updatefactionIcon")
	g_i3k_ui_mgr:CloseUI(eUIID_ChangeSkillIcon)
end

function wnd_change_skill_icon:onSelect(sender)
	g_i3k_game_context:setCreateKungfuSkillIcon(sender:getTag())
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CreateKungfuSuccess,"setData")
	g_i3k_ui_mgr:RefreshUI(eUIID_CreateKungfuSuccess,nil,sender:getTag())
	g_i3k_ui_mgr:CloseUI(eUIID_ChangeSkillIcon)
end

--[[function wnd_change_skill_icon:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ChangeSkillIcon)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_change_skill_icon.new();
		wnd:create(layout, ...);

	return wnd;
end
