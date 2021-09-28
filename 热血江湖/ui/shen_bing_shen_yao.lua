-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_shen_bing_shen_yao = i3k_class("wnd_shen_bing_shen_yao",ui.wnd_base)
local star_icon = {3055,3056,3057,3058,3059,3060,3061,3062,3063,3064}


function wnd_shen_bing_shen_yao:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

end

local DESC = {
	17417, 17418, 17419, 17420
}

local FUNCS = {
	g_i3k_game_context.GetAwakeCountOfWeapons,
	g_i3k_game_context.GetMinStarOfWeapopns,
	g_i3k_game_context.GetTotalStarOfWeapons,
	g_i3k_game_context.GetTotalLevelOfWeapons,
}

function wnd_shen_bing_shen_yao:refresh(weaponID)
	local cfg = i3k_db_shen_bing_awake[weaponID]
	local shenYaoType = cfg.shenYaoID
	local shenYaoLvl = g_i3k_game_context:GetShenYaoLevel(shenYaoType)
	local shenYaoCfg = i3k_db_shen_bing_shen_yao[shenYaoType][shenYaoLvl + 1]
	local widget = self._layout.vars
	widget.max:setVisible(not shenYaoCfg)
	widget.notMax:setVisible(shenYaoCfg and true or false)
	if shenYaoCfg then
		local weapons = shenYaoCfg.weapons
		local conditions = shenYaoCfg.conditions
		widget.name:setImage(g_i3k_db.i3k_db_get_icon_path(shenYaoCfg.iconID))
		widget.curLvl:setText(string.format("当前等级：%d级", shenYaoLvl))
		for i,v in ipairs(conditions) do
			local _d = widget['desc'..i]
			local have = FUNCS[v.conditionType](g_i3k_game_context, weapons)
			_d:setText(i3k_get_string(DESC[v.conditionType], have, v.count))
			_d:setTextColor(g_i3k_get_cond_color(have >= v.count))
		end
	end
	self:setModules(i3k_db_shen_bing_shen_yao[shenYaoType][1].weapons)
end

function wnd_shen_bing_shen_yao:setModules(weapons)
	local widget = self._layout.vars
	for i, v in ipairs(weapons) do
		local _module = widget['module'..i]
		local _level = widget['level'..i]
		local _star = widget['starIcon'..i]
		local weaponForm = g_i3k_game_context:GetShenBingForm(v)
		local weaponModuleID = weaponForm == 3 and i3k_db_shen_bing_awake[v].awakeWeaponModle or i3k_db_shen_bing[v].showModuleID
		ui_set_hero_model(_module, weaponModuleID)
		local level = 0
		if pcall(g_i3k_game_context.GetShenBingQlvl, g_i3k_game_context, v) then
			level = g_i3k_game_context:GetShenBingQlvl(v)
		end
		_level:setText(string.format("阶位：%d阶",level))
		local starLvl = 0
		if pcall(g_i3k_game_context.GetShenbingStarLvl, g_i3k_game_context, v) then
			starLvl = g_i3k_game_context:GetShenbingStarLvl(v)
		end
		_star:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[starLvl + 1]))
	end
end
---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_shen_bing_shen_yao.new()
	wnd:create(layout)
	return wnd
end
