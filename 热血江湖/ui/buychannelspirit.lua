-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base")
require("ui/ui_funcs")

-------------------------------------------------------
wnd_eUIID_BuyChannelSpirit = i3k_class("wnd_eUIID_BuyChannelSpirit", ui.wnd_base)
local COLOR1 = "ffff0000" -- 红色

function wnd_eUIID_BuyChannelSpirit:ctor()
	self._selectIdx = 0
end

function wnd_eUIID_BuyChannelSpirit:configure()
	local widgets	= self._layout.vars
	self.okBtn		= widgets.okBtn;
	self.cancelBtn	= widgets.cancelBtn;
	self.itemBtn	= widgets.itemBtn;
	self.item_icon	= widgets.item_icon;
	self.item_name	= widgets.item_name;
	self.suo		= widgets.suo; 
	self.item_count = widgets.item_count;
	self.topName	= widgets.topName;
	self.icon_bg	= widgets.icon_bg;
	self.desc 		= widgets.desc;
	widgets.okBtn:onClick(self, self.onBuySpirit)
	widgets.cancelBtn:onClick(self, self.onCancel)
end

function wnd_eUIID_BuyChannelSpirit:onCancel()
	g_i3k_ui_mgr:CloseUI(eUIID_BuyChannelSpirit)
end

function wnd_eUIID_BuyChannelSpirit:onBuySpirit()
	local data = i3k_db_arder_pet[self._selectIdx];
	if g_i3k_game_context:GetCommonItemCanUseCount(data.needItemId) >= data.needItemCount then
		i3k_sbean.buyWizardTime(self._selectIdx, data.buyGetTime, g_TYPE_DIMOND);
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

function wnd_eUIID_BuyChannelSpirit:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_eUIID_BuyChannelSpirit:updateBuySpiritUI(id)
	self._selectIdx = id;
	if id then
		local wizarData = i3k_db_arder_pet[id];
		if wizarData then
			self.desc:setText(wizarData.desc)

			if wizarData.needItemId == 1 or wizarData.needItemId == 2 then
				self.suo:show();
			else
				self.suo:hide();
			end
			local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(wizarData.needItemId))
			if wizarData.buyGetTime < 0 then
				self.topName:setText(i3k_get_string(1159))
			else
				self.topName:setText(i3k_get_string(962,math.modf(wizarData.buyGetTime / 24 / 60 /60)))
			end
			self.topName:setTextColor(COLOR1)
			self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(wizarData.needItemId,i3k_game_context:IsFemaleRole()))
			self.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(wizarData.needItemId))
			self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(wizarData.needItemId))
			self.item_name:setTextColor(name_colour)
			if wizarData.needItemId == g_BASE_ITEM_DIAMOND or wizarData.needItemId == g_BASE_ITEM_COIN then
			self.item_count:setText(wizarData.needItemCount)
			else
				self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(wizarData.needItemId) .."/".. wizarData.needItemCount)
			end
			self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(wizarData.needItemId) >= wizarData.needItemCount))
			self.itemBtn:onClick(self, self.onItemTips, wizarData.needItemId);
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_eUIID_BuyChannelSpirit.new()
	wnd:create(layout)
	return wnd
end
