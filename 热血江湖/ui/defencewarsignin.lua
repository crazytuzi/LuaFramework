-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarSignIn = i3k_class("wnd_defenceWarSignIn", ui.wnd_base)

-- 城战报名
-- [eUIID_DefenceWarSignIn]	= {name = "defenceWarSignIn", layout = "chengzhanbm", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarSignIn:ctor()
	self._selectIndex = nil
end

function wnd_defenceWarSignIn:configure()
	self:setButtons()
	self:setLabels()
end


function wnd_defenceWarSignIn:refresh(citys)
	self._citys = citys
	self:setScrolls()
end

function wnd_defenceWarSignIn:onUpdate(dTime)

end

function wnd_defenceWarSignIn:onShow()

end

function wnd_defenceWarSignIn:onHide()

end

function wnd_defenceWarSignIn:setScrolls()
	local widgets = self._layout.vars
	local list = i3k_db_defenceWar_city
	self:setScroll_Scroll(list)
end


-- TODO
function wnd_defenceWarSignIn:setScroll_Scroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.Scroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhanbmt")()
		ui.vars.CityImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconSign))
		ui.vars.CityName:setText(v.name)
		ui.vars.Done:setVisible(self._citys[k] == g_DEFENCE_WAR_SIGN_MINE)
		ui.vars.selectImg:setVisible(false)
		ui.vars.City:onClick(self, self.onCityBtn, k)
		scroll:addItem(ui)
	end
end

function wnd_defenceWarSignIn:setLabels()
	local widgets = self._layout.vars
	local config = i3k_db_defenceWar_cfg
	local batchID = g_i3k_db.i3k_db_get_defence_war_batchID()
	local cfg = i3k_db_defenceWar_time[batchID]
	local startTime = g_i3k_get_MonthAndDayTime(cfg.startTime)
	local signEndTime = g_i3k_get_MonthAndDayTime(cfg.signEndTime)
	local captureStartTime = g_i3k_get_MonthAndDayTime(cfg.captureStartTime)
	widgets.Desc:setText(i3k_get_string(5173, config.factionLvl, startTime, signEndTime, captureStartTime))
end

function wnd_defenceWarSignIn:setImages()
	local widgets = self._layout.vars
	widgets.title:setImage()
end

function wnd_defenceWarSignIn:setButtons()
	local widgets = self._layout.vars
	widgets.SignIn:onClick(self, self.onSignInBtn)
	widgets.Help:onClick(self, self.onHelpBtn)
	widgets.Close:onClick(self, self.onCloseBtn)
end

function wnd_defenceWarSignIn:onSignInBtn(sender)

	if not self._selectIndex then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5319)) -- "未选中任何城")
		return
	end

	local state = self._citys[self._selectIndex]

	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarSure)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarSure, self._selectIndex, state)
end

function wnd_defenceWarSignIn:selectScrollItem(id)
	local widgets = self._layout.vars
	local scroll = widgets.Scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selectImg:setVisible(id == k)
	end
end


function wnd_defenceWarSignIn:onCityBtn(sender, index)
	self._selectIndex = index
	self:selectScrollItem(index)
end


function wnd_defenceWarSignIn:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(5327, i3k_db_defenceWar_cfg.joinCnt))
end

function wnd_defenceWarSignIn:onCloseBtn(sender)
	self:onCloseUI()
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarSignIn.new()
	wnd:create(layout, ...)
	return wnd;
end
