-- 2018.05.29
-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_homeLandEquipTips = i3k_class("wnd_homeLandEquipTips", ui.wnd_base)

local WIDGET_ZBTIPST = "ui/widgets/zbtipst"
-- local WIDGET_ZBTIPST2 = "ui/widgets/zbtipst2"
local WIDGET_ZBTIPST3 = "ui/widgets/zbtipst3"

local PROP_NAME = {5046, 5047}

function wnd_homeLandEquipTips:ctor()
	self._isWear = false
	self._info 	 = {}
end

function wnd_homeLandEquipTips:configure()
	local widgets = self._layout.vars
	self.item_icon		= widgets.item_icon
	self.item_name		= widgets.item_name
	self.is_free		= widgets.is_free
	self.lvl_label		= widgets.lvl_label
	self.get_label		= widgets.get_label
	self.times_label	= widgets.times_label

	self.scroll			= widgets.scroll
	self.destroyBtn		= widgets.destroyBtn
	self.destroyLabel	= widgets.destroyLabel
	self.funcLabel		= widgets.funcLabel
	widgets.destroyBtn:onClick(self, self.onDestroyBtn)
	widgets.funcBtn:onClick(self, self.onFuncBtn)
	widgets.globel_btn:onClick(self, self.onCloseUI)
end

function wnd_homeLandEquipTips:refresh(info, isWear)
	self._isWear = isWear
	self._info 	= info
	self:loadFishEquipInfo(info, isWear)
end

function wnd_homeLandEquipTips:loadFishEquipInfo(info, isWear)
	local equipCfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
	local itemID = equipCfg.needItmeID
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemID))
	self.item_name:setTextColor(name_colour)
	self.is_free:setText(itemID > 0 and i3k_get_string(5113) or i3k_get_string(5114))
	self.times_label:setText(i3k_get_string(5115, info.canUseTime))
	self.get_label:setText(g_i3k_db.i3k_db_get_common_item_source(itemID))
	self.destroyBtn:setVisible(not isWear)
	self.funcLabel:setText(isWear and i3k_get_string(5116) or i3k_get_string(5117))
	self:loadScroll(equipCfg)
end

function wnd_homeLandEquipTips:loadScroll(equipCfg)
	local node3 = require(WIDGET_ZBTIPST3)()
	node3.vars.desc:setText(i3k_get_string(5118))
	self.scroll:addItem(node3)

	for _, e in ipairs(equipCfg.propTb) do
		if e.propID ~= 0 then
			local node = require(WIDGET_ZBTIPST)()
			node.vars.desc:setText(i3k_get_string(PROP_NAME[e.propID]))
			node.vars.value:setText(e.propValue)
			self.scroll:addItem(node)
		end
	end
end

function wnd_homeLandEquipTips:onFuncBtn(sender)
	if g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5154))
		return
	end
	if self._isWear then
		local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(self._info.confId)
		i3k_sbean.homeland_equip_unwaer(cfg.equipType)
	else
		i3k_sbean.homeland_equip_wear(self._info.id, self._info)
	end
end

function wnd_homeLandEquipTips:onDestroyBtn(sender)
	i3k_sbean.homeland_equip_remove(self._info.id)
end

function wnd_create(layout)
	local wnd = wnd_homeLandEquipTips.new()
	wnd:create(layout)
	return wnd
end
