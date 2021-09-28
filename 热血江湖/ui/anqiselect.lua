
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_anqiSelect = i3k_class("wnd_anqiSelect",ui.wnd_base)

function wnd_anqiSelect:ctor()

end

function wnd_anqiSelect:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.scroll = widgets.scr_list
end

function wnd_anqiSelect:refresh()
	self.scroll:removeAllChildren()
	self:refreshAnqiData()
end

function wnd_anqiSelect:refreshAnqiData()
	local allAnqi = g_i3k_game_context:getHideWeaponSkills()
	local curSkill = g_i3k_game_context:getEquipedHideWeaponSkill()
	local useId = curSkill and curSkill.skillID or 0
	local ListItems = self.scroll:addItemAndChild("ui/widgets/zdanqiqht", 2, table.nums(allAnqi) - 1)
	local index = 1
	
	
	for i,v in pairs(allAnqi) do
		local weight = ListItems[index]
		local id = v.skillID
		
		if weight and id ~= useId then
			local node = weight.vars
			local anqiID = g_i3k_db.i3k_db_get_anqi_id_by_skillID(id)
			local cfg = i3k_db_anqi_base[anqiID]
			local path = g_i3k_db.i3k_db_get_anqi_skin_skillId_by_skinID(anqiID, id)
			node.skill_icon:setImage(path)
			node.skill_btn:onClick(self, self.onUseAnqiBt, id)
			
			if cfg then
				node.skill_name:setText(cfg.name)
			else
				node.skill_name:setText("")
			end
			
			index = index + 1
		end
	end
end

function wnd_anqiSelect:onUseAnqiBt(sender, id)	
	local aqid = g_i3k_db.i3k_db_get_anqi_id_by_skillID(id)
	i3k_sbean.hideweapon_change(aqid)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_anqiSelect.new()
	wnd:create(layout, ...)
	return wnd;
end

