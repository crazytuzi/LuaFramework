-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarSure = i3k_class("wnd_defenceWarSure", ui.wnd_base)

-- 城战确认
-- [eUIID_DefenceWarSure]	= {name = "defenceWarSure", layout = "chengzhanbmqr", order = eUIO_TOP_MOST,},
-------------------------------------------------------
local INPUT_TEXT = i3k_db_defenceWar_cfg.fightText

function wnd_defenceWarSure:ctor()

end

function wnd_defenceWarSure:configure()
	self:setButtons()
	local widgets = self._layout.vars
	local callback = function ()
		widgets.inputLabel:hide()
	end
	widgets.editBox:addEventListener(callback)
end

function wnd_defenceWarSure:refresh(id, state)
	self._selectIndex = id -- 存一下
	self._state = state
	self:setCityImages(id)
	self:setLabels(id, state)
end

function wnd_defenceWarSure:onUpdate(dTime)

end

function wnd_defenceWarSure:onShow()

end

function wnd_defenceWarSure:onHide()

end

function wnd_defenceWarSure:setButtons()
	local widgets = self._layout.vars
	widgets.Sure:onClick(self, self.onSureBtn)
	widgets.Close:onClick(self, self.onCloseBtn)
	widgets.City:onClick(self, self.onCityBtn)
end

function wnd_defenceWarSure:onSureBtn(sender)
	local widgets = self._layout.vars
	local text = widgets.editBox:getText()

	-- 此函数内进行了权限的检查，以及提示文本
	if not g_i3k_game_context:getDefenceWarPermission() then
		return
	end

	if text ~= INPUT_TEXT then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5168))--"输入内容不正确，请重新输入")
		return
	end
	local id = self._selectIndex
	local cfg = i3k_db_defenceWar_city[id]

	local needCoin = g_i3k_game_context:getDragonCrystal()
	if needCoin < cfg.signCost then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5167))
		return
	end

	local sectLevel = g_i3k_game_context:GetFactionLevel()
	local config = i3k_db_defenceWar_cfg
	if sectLevel < config.factionLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5172, config.factionLvl) )--"帮派等级到达"..config.factionLvl.."可以参与城战")
		return
	end

	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < config.playerLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5320, config.playerLvl))
		return
	end

	if self._state == g_DEFENCE_WAR_SIGN_MINE then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5179))
		return
	end

	i3k_sbean.defenceWarSign(id)
end

function wnd_defenceWarSure:onCloseBtn(sender)
	self:onCloseUI()
end

function wnd_defenceWarSure:onCityBtn(sender)
	-- TODO 查看城池信息？
end

function wnd_defenceWarSure:setCityImages(id)
	local widgets = self._layout.vars
	local cfg = i3k_db_defenceWar_city[id]
	widgets.CityImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconSign))
end

function wnd_defenceWarSure:setLabels(id, state)
	local widgets = self._layout.vars
	local cfg = i3k_db_defenceWar_city[id]
	-- widgets.no_name:setText("确 定")
	widgets.inputHint:setText(i3k_get_string(5182, INPUT_TEXT))
	widgets.inputLabel:setText("请输入："..INPUT_TEXT)
	widgets.CityName:setText(cfg.name)
	widgets.cityName2:setText(cfg.name)
	widgets.Scale:setText(g_i3k_db.i3k_db_get_defence_war_city_sizeStr_by_grade(cfg.grade))
	local dragonCrystal = g_i3k_game_context:getDragonCrystal()
	dragonCrystal = dragonCrystal < 0 and 0 or dragonCrystal
	local curHaveCount = i3k_get_string(5310, dragonCrystal) --  "(当前拥有".. dragonCrystal..")"
	widgets.Price:setText(cfg.signCost.."龙晶"..curHaveCount)
	local text = self:getTextByState(state)
	widgets.State:setText(text)
end

-- 表示每个城是否有帮派报名，0没有，1有，2本帮已报
function wnd_defenceWarSure:getTextByState(state)
	local states =
	{
		[g_DEFENCE_WAR_SIGN_NONE] = i3k_get_string(5180), -- "没有帮派报名",
		[g_DEFENCE_WAR_SIGN_OTHER] = i3k_get_string(5179), -- "有帮派报名",
		[g_DEFENCE_WAR_SIGN_MINE] = i3k_get_string(5321), -- 已经报名
	}
	return states[state] or states[g_DEFENCE_WAR_SIGN_NONE]
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarSure.new()
	wnd:create(layout, ...)
	return wnd;
end
