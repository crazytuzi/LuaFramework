-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_get_award = i3k_class("wnd_faction_get_award", ui.wnd_base)

local LAYER_BPRWJLT = "ui/widgets/bprwjlt"
--帮贡id
local contributionID = 3

function wnd_faction_get_award:ctor()

end

function wnd_faction_get_award:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local money_icon = self._layout.vars.money_icon
	money_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_MONEY,i3k_game_context:IsFemaleRole()))
	self.money_count = self._layout.vars.money_count
end

function wnd_faction_get_award:onShow()

end

function wnd_faction_get_award:refresh(data)
	self:setData(data)
end

function wnd_faction_get_award:setData(data)
	local all_count = 0
	local percent = i3k_db_kungfu_vip[g_i3k_game_context:GetVipLevel()].factionContribution
	local item_scroll = self._layout.vars.item_scroll
	item_scroll:removeAllChildren()
	if data.tasks then
		for k,v in pairs(data.tasks) do
			local _layer = require(LAYER_BPRWJLT)()
			local taskIcon = _layer.vars.taskIcon
			local taskName = _layer.vars.taskName
			local contri_count = _layer.vars.contri_count
			local task_count = _layer.vars.task_count
			_layer.vars.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_SECT_MONEY,i3k_game_context:IsFemaleRole()))
			local tmp_str = string.format("×%s",v)
			task_count:setText(tmp_str)
			local _task_data = g_i3k_db.i3k_db_get_faction_task_cfg(k)
			taskName:setText(_task_data.name)
			taskIcon:setImage(i3k_db_icons[_task_data.icon].path)
			local tmp_str = string.format("×%s",_task_data.shareContribution * percent)
			all_count = all_count + _task_data.shareContribution * percent * v
			contri_count:setText(tmp_str)
			local task_star = _task_data.starLvl
			for i=1,5 do
				local tmp_star = string.format("star%s",i)
				local star = _layer.vars[tmp_star]
				if i  > task_star then
					star:hide()
				else
					star:show()
				end
			end
			item_scroll:addItem(_layer)
		end
	end
	local tmp_str = string.format("×%s",all_count)
	self.money_count:setText(tmp_str)
end

--[[function wnd_faction_get_award:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionGetAward)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_get_award.new();
		wnd:create(layout, ...);

	return wnd;
end
