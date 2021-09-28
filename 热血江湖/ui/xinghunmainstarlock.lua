module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinhun_main_star_lock = i3k_class("wnd_xinhun_main_star_lock", ui.wnd_base)

local LAYER_XINGHUNZHUXINGT = "ui/widgets/xinghunzhuxingt"

function wnd_xinhun_main_star_lock:ctor()
	self._propValue = 0
end

function wnd_xinhun_main_star_lock:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	self.desc1 = widgets.desc1
	self.desc2 = widgets.desc2

	self.scroll = widgets.scroll
end

function wnd_xinhun_main_star_lock:refresh(data)
	local roleType = 0
	local mainStarLvl = 0
	if data then
		self.desc1:hide()
		self.desc2:hide()
		roleType = data.roleType
		mainStarLvl = data.heirloom.mainStarLvl
	else
		self.desc1:show()
		self.desc2:show()
		roleType = g_i3k_game_context:GetRoleType()
		mainStarLvl = 1
	end
	local cfg = g_i3k_db.i3k_db_get_main_star_up_cfg(roleType, mainStarLvl)
	if cfg then
		self._propValue = cfg.propValue
		self.desc1:setText(i3k_get_string(1269, i3k_db_chuanjiabao.cfg.unlockNeedStage))
		self.desc2:setText(i3k_get_string(1270, self._propValue/100))

		self:updateScroll(data and data.heirloom.mainStarProps or {})
	end
end

function wnd_xinhun_main_star_lock:updateScroll(props)
	self.scroll:removeAllChildren()
	self.scroll:stateToNoSlip()
	if props and next(props) then
		for id, _ in pairs(props) do
			local ui = require(LAYER_XINGHUNZHUXINGT)()
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(id)))
			ui.vars.desc:setText(g_i3k_db.i3k_db_get_main_star_prop_desc(id))
			ui.vars.wenhao:hide()
			self.scroll:addItem(ui)
		end
	else
		local randCnt = i3k_db_chuanjiabao.cfg.randCnt
		for i = 1, randCnt do
			local ui = require(LAYER_XINGHUNZHUXINGT)()
			ui.vars.desc:setText(string.format("对某职业伤害提升或减免%s%%", self._propValue/100))
			ui.vars.icon:hide()
			self.scroll:addItem(ui)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_xinhun_main_star_lock.new();
		wnd:create(layout, ...);
	return wnd;
end
