------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_house_base = i3k_class("wnd_house_base",ui.wnd_base)

function wnd_house_base:ctor()
	
end

function wnd_house_base:configure()
	self._layout.vars.bag_btn:onClick(self, self.onBagBtn)
	self._layout.vars.place_btn:onClick(self, self.onPlaceBtn)
	self._layout.vars.view_btn:onClick(self, self.onViewBtn)
	self._layout.vars.closeBtn:onClick(self, self.onDescVisible, false)
	self._layout.vars.openBtn:onClick(self, self.onDescVisible, true)
	self._layout.vars.help_btn:onClick(self, self.onHelpBtn)
	self._layout.vars.skin_btn:onClick(self, self.onSkinBtn)
end

function wnd_house_base:refresh(callback)
	if callback then
		callback()
	end
	local houseData = g_i3k_game_context:getHomeLandHouseInfo()
	if houseData then
		self._layout.vars.house_level:setText(houseData.homeland.houseLevel)
		self._layout.vars.cur_build_value:setText(houseData.homeland.buildValue)
		self._layout.vars.max_build_value:setText(houseData.homeland.maxBuildValue)
	end
end

function wnd_house_base:onBagBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Bag)
	g_i3k_ui_mgr:RefreshUI(eUIID_Bag)
end

function wnd_house_base:onPlaceBtn(sender)
	if g_i3k_game_context:GetIsInMyHouse() then
		if not g_i3k_ui_mgr:GetUI(eUIID_HouseFurniture) then
			local callback = function ()
				g_i3k_game_context:setIsInPlaceState(true)
				g_i3k_ui_mgr:OpenUI(eUIID_HouseFurniture)
				g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurniture)
			end
			i3k_sbean.house_bag_furniture_sync(callback)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5335))
	end
end

function wnd_house_base:onViewBtn(sender)
	g_i3k_game_context:setHomelandOverViewStatus(true)
	self:onCloseUI()
end

function wnd_house_base:onDescVisible(sender, state)
	self._layout.vars.desc_root:setVisible(state)
	self._layout.vars.closeBtn:setVisible(state)
	self._layout.vars.openBtn:setVisible(not state)
end

function wnd_house_base:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17416))
end

function wnd_house_base:onSkinBtn(sender)
	if g_i3k_game_context:GetIsInMyHouse() then
		i3k_sbean.house_unlock_skin_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5335))
	end
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_house_base.new()
	wnd:create(layout,...)
	return wnd
end