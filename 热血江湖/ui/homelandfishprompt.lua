-- 钓鱼提示ui 2018/06/06
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_homeLandFishPrompt = i3k_class("wnd_homeLandFishPrompt", ui.wnd_base)

function wnd_homeLandFishPrompt:ctor()

end

function wnd_homeLandFishPrompt:configure()
	local widgets = self._layout.vars
	self.icon = widgets.icon
	widgets.fishBtn:onClick(self, self.onFish)
end

function wnd_homeLandFishPrompt:refresh()
	local iconID = i3k_db_home_land_base.fishCfg.fishIcon
	self.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
end

function wnd_homeLandFishPrompt:onFish(sender)
	if i3k_game_get_map_type() == g_HOME_LAND then
		if g_i3k_game_context:GetHomeLandCurEquipCanFish() then
			if g_i3k_game_context:IsOnHugMode() then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5148))
			else
				g_i3k_logic:OpenHomeLandFishUI()
			end
		else
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5073), function(flag)
				if flag then 
					g_i3k_logic:OpenHomeLandEquipUI()
				end 
			end)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_homeLandFishPrompt.new()
		wnd:create(layout)
	return wnd
end
