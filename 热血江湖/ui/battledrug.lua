module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleDrug = i3k_class("wnd_battleDrug", ui.wnd_base)
function wnd_battleDrug:ctor()

end
function wnd_battleDrug:configure()
    local widget=self._layout.vars
    --药品相关界面
    local drug = {}
    drug.drugicon = self._layout.vars.drugicon
    drug.drugiconroot = self._layout.vars.drugiconroot
    drug.drugicon:onClick(self, self.onShowDrugShop)
    self._widgets = {}
    self._widgets.drug = drug
end

function wnd_battleDrug:refresh()

end



function wnd_battleDrug:onShowDrugShop(sender)
	local maptype = i3k_game_get_map_type()
	if maptype == g_FIELD or mapType == g_Life or mapType == g_BIOGIAPHY_CAREER then
		g_i3k_logic:OpenCommonStoreUI(1)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(387))
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleDrug.new();
		wnd:create(layout);
	return wnd;
end
