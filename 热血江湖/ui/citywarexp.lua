-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_cityWarExp = i3k_class("wnd_cityWarExp", ui.wnd_base)

local WIDGHT1 = "ui/widgets/chengzhanczzgt"

function wnd_cityWarExp:ctor()
	self._kings = {}
	self._refreshFlag = false
end

function wnd_cityWarExp:configure()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseUI)
	widgets.Help:onClick(self, function()
		g_i3k_ui_mgr:OpenUI(eUIID_Help)
		g_i3k_ui_mgr:RefreshUI(eUIID_Help, i3k_get_string(5506))
	end)
end

function wnd_cityWarExp:refresh()
	local widgets = self._layout.vars
	widgets.Scroll:removeAllChildren()
	self._kings = g_i3k_game_context:getDefenceWarKings()
	
	for cityID, v in ipairs(i3k_db_defenceWar_city) do
		local ui = require(WIDGHT1)()
		local wid = ui.vars
		wid.CityImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconSign))
		wid.CityName:setText(v.name)
		local sectInfo = self._kings[cityID]
		local sectName = sectInfo and sectInfo.name or i3k_get_string(5318)
		local leader = sectInfo and sectInfo.chiefName or ""
		wid.SectName:setText(sectName)
		wid.leader:setText(leader)
		wid.open:onClick(self, self.onOpenBt, cityID)
		widgets.Scroll:addItem(ui)
	end
	
	widgets.Desc:setText(i3k_get_string(5513))
end

function wnd_cityWarExp:onOpenBt(sender, cityID)
	--没人占
	local sectInfo = self._kings[cityID]
	
	if not sectInfo then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5507))
		return
	end
	
	--钱够不够
	local cfg = i3k_db_defenceWar_city[cityID]
	local totalMoney =  g_i3k_game_context:GetCommonItemCanUseCount(g_BASE_ITEM_COIN)
	local owner = g_i3k_game_context:getDefenceWarCurrentCityState() --获取自己占据的城池
	
	if owner and owner ~= cityID then
		if cfg and cfg.difOpenCost > totalMoney then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5508))
			return
		end
	end
	
	if g_i3k_game_context:isOpenCityLight() then --身上有buff
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5456))
		return
	end	
		--已经领过
	if g_i3k_game_context:getDefenceWarDayCityLight()[cityID] then --身上没buff但是开过
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5512))
		return
	end
	
	i3k_sbean.citywar_req_exp(cityID)
end

function wnd_cityWarExp:havaRefresh()
	self._refreshFlag = true
end
		
function wnd_create(layout, ...)
	local wnd = wnd_cityWarExp.new()
	wnd:create(layout, ...)
	return wnd;
end

