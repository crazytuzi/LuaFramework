
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_hideWeaponHuanhuaUnlock = i3k_class("wnd_hideWeaponHuanhuaUnlock",ui.wnd_base)

function wnd_hideWeaponHuanhuaUnlock:ctor()
	self._anqiID = nil
	self._skinID = nil
	self._cost = nil
end

function wnd_hideWeaponHuanhuaUnlock:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.unlockBtn:onClick(self, self.onUnLock)
end

function wnd_hideWeaponHuanhuaUnlock:refresh(anqiID, skinID, cost)
	self._anqiID = anqiID
	self._skinID = skinID
	self._cost = cost

	self:setUnlockItemScroll()
end

function wnd_hideWeaponHuanhuaUnlock:setUnlockItemScroll()
	local cost = self._cost
	self._layout.vars.scrollview:removeAllChildren()
	for _, v in ipairs(cost) do
		local ui = require("ui/widgets/anqihhjst")()
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		ui.vars.bt:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
		end)
		ui.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		local text = (math.abs(v.id) == g_BASE_ITEM_COIN or math.abs(v.id) == g_BASE_ITEM_DIAMOND) and v.count or haveCount.."/"..v.count  -- 铜钱,元宝只显示数量
		ui.vars.item_count:setText(text)
		ui.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= v.count))
		self._layout.vars.scrollview:addItem(ui)
	end
end

function wnd_hideWeaponHuanhuaUnlock:onUnLock(sender)
	for _, v in pairs(self._cost) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
		end
	end
	i3k_sbean.hideweapon_skin_unLock(self._anqiID, self._skinID, self._cost)
end

function wnd_create(layout, ...)
	local wnd = wnd_hideWeaponHuanhuaUnlock.new()
	wnd:create(layout, ...)
	return wnd;
end

