module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_seven_tips = i3k_class("wnd_equip_seven_tips", ui.wnd_base)

local LAYER_LYTIPS2 = "ui/widgets/lytips2"

function wnd_equip_seven_tips:ctor()

end



function wnd_equip_seven_tips:configure()
	local widgets = self._layout.vars
	local globel_bt = widgets.globel_bt
	globel_bt:onClick(self, self.onClose)
	self.LongYinName   = widgets.itemName_label
	self.LongYinIron   = widgets.item_icon
	self.LongYinIronBg = widgets.item_bg
	self.needLvl       = widgets.lvl
	self.needPower     = widgets.power
	self.vocation      = widgets.vocation
	self.itemDesc_label= widgets.itemDesc_label
end
function wnd_equip_seven_tips:onShowData(NowLevel, NowPower, NowVocation, argData)
	local name = argData.args.itemName
	local ironID = argData.args.closeItemIronID
	self.LongYinName:setText(name)
	self.LongYinName:setTextColor(g_i3k_get_white_color())
	self.LongYinIron:setImage(g_i3k_db.i3k_db_get_icon_path(ironID))
	local isOpen = g_i3k_game_context:GetIsHeChengLongYin()
	if isOpen ~= 0 then
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		self.LongYinIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(quality))
	else
		local quality = g_i3k_game_context:GetLongYinQuality(isOpen)
		self.LongYinIronBg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
	end
	local needLevel = argData.openNeed.needLvl
	local needPowerNow = argData.openNeed.needPower
	local needTransLvl = argData.openNeed.needTransLvl
	self.itemDesc_label:setText(i3k_get_string(410))
	self.needLvl:setText(i3k_get_string(396,needLevel))
	self.needLvl:setTextColor(g_i3k_get_cond_color(NowLevel >= needLevel))
	self.needPower:setText(i3k_get_string(397,needPowerNow) )
	self.needPower:setTextColor(g_i3k_get_cond_color(NowPower >= needPowerNow))
	self.vocation:setText(i3k_get_string(398,i3k_get_string(409)))
	self.vocation:setTextColor(g_i3k_get_cond_color(NowVocation >= needTransLvl))
end

function wnd_equip_seven_tips:refresh(argData)
	local needData = argData.openNeed
	local NowLevel = g_i3k_game_context:GetLevel()
	local NowPower = g_i3k_game_context:GetRolePower()
	local NowVocation = g_i3k_game_context:GetTransformLvl()
	local isHaveItem = g_i3k_game_context:isLonYinOpen()
	if isHaveItem == true then
		g_i3k_ui_mgr:CloseUI(eUIID_EquipSevenTips)
		g_i3k_ui_mgr:OpenUI(eUIID_EquipSevenTips2)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipSevenTips2, argData)
	else
		self:onShowData( NowLevel, NowPower, NowVocation, argData)
	end
end



function wnd_equip_seven_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_EquipSevenTips)
end

function wnd_create(layout)
	local wnd = wnd_equip_seven_tips.new();
		wnd:create(layout);

	return wnd;
end