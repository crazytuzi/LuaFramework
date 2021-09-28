-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base")
require("ui/ui_funcs")

-------------------------------------------------------
wnd_BuyChannelSpiritOther = i3k_class("wnd_BuyChannelSpiritOther", ui.wnd_base)
local COLOR1 = "ffff0000" -- 红色

function wnd_BuyChannelSpiritOther:ctor()
	self._selectIdx = 0
	self._needItemId = 0
	self._needItemCount = 0
	self._replaceItemId = 0
	self._replaceItemCount = 0
end

function wnd_BuyChannelSpiritOther:configure()
	local widgets	= self._layout.vars
	self.okBtn		= widgets.okBtn;
	self.cancelBtn	= widgets.cancelBtn;
	self.topName	= widgets.topName;
	self.desc 		= widgets.desc;

	self.itemBtn	= widgets.itemBtn;
	self.item_icon	= widgets.item_icon;
	self.item_name	= widgets.item_name;
	self.suo		= widgets.suo; 
	self.item_count = widgets.item_count;
	self.icon_bg	= widgets.icon_bg;

	self.itemBtn2	= widgets.itemBtn2;
	self.item_icon2	= widgets.item_icon2;
	self.item_name2	= widgets.item_name2;
	self.suo2		= widgets.suo2; 
	self.item_count2 = widgets.item_count2;
	self.icon_bg2	= widgets.icon_bg2;

	widgets.okBtn:onClick(self, self.onOneBuySpirit)
	widgets.okBtn2:onClick(self, self.onSecondBuySpirit)

	widgets.cancelBtn:onClick(self, self.onCancel)
end

function wnd_BuyChannelSpiritOther:onCancel()
	g_i3k_ui_mgr:CloseUI(eUIID_BuyChannelSpiritOther)
end

--普通购买
function wnd_BuyChannelSpiritOther:onOneBuySpirit()
	local data = i3k_db_arder_pet[self._selectIdx];
	if g_i3k_game_context:GetCommonItemCanUseCount(data.needItemId) >= data.needItemCount then
		i3k_sbean.buyWizardTime(self._selectIdx, data.buyGetTime, g_TYPE_DIMOND);
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

--道具代替购买
function wnd_BuyChannelSpiritOther:onSecondBuySpirit()
	local data = i3k_db_arder_pet[self._selectIdx];
	if g_i3k_game_context:GetCommonItemCanUseCount(data.replaceItemId) >= data.replaceItemCount then
		i3k_sbean.buyWizardTime(self._selectIdx, data.buyGetTime, g_TYPE_REPLACE);
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(453))
	end
end

function wnd_BuyChannelSpiritOther:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_BuyChannelSpiritOther:updateBuySpiritUI(id)
	self._selectIdx = id;
	if id then
		local wizarData = i3k_db_arder_pet[id];
		if wizarData then
			self.desc:setText(wizarData.desc)

			if wizarData.buyGetTime < 0 then
				self.topName:setText(i3k_get_string(1159))
			else
				self.topName:setText(i3k_get_string(962,math.modf(wizarData.buyGetTime / 24 / 60 /60)))
			end
			self.topName:setTextColor(COLOR1)

			self:updateOneBuyWay(wizarData.needItemId, wizarData.needItemCount)
			self:updateSecondBuyWay(wizarData.replaceItemId, wizarData.replaceItemCount)
		end
	end
end

function wnd_BuyChannelSpiritOther:updateOneBuyWay(needItemId, needItemCount)
	self._needItemId = needItemId
	self._needItemCount = needItemCount

	if needItemId == 1 or needItemId == 2 then
		self.suo:show();
	else
		self.suo:hide();
	end
	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(needItemId))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needItemId,i3k_game_context:IsFemaleRole()))
	self.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needItemId))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(needItemId))
	self.item_name:setTextColor(name_colour)
	if needItemId == g_BASE_ITEM_DIAMOND or needItemId == g_BASE_ITEM_COIN then
		self.item_count:setText(needItemCount)
	else
		self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(needItemId) .."/".. needItemCount)
	end
	self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(needItemId) >= needItemCount))
	self.itemBtn:onClick(self, self.onItemTips, needItemId);
end

function wnd_BuyChannelSpiritOther:updateSecondBuyWay(replaceItemId, replaceItemCount)
	self._replaceItemId = replaceItemId
	self._replaceItemCount = replaceItemCount

	self.suo2:setVisible(replaceItemId > 0)

	local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(replaceItemId))
	self.item_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(replaceItemId,i3k_game_context:IsFemaleRole()))
	self.icon_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(replaceItemId))
	self.item_name2:setText(g_i3k_db.i3k_db_get_common_item_name(replaceItemId))
	self.item_name2:setTextColor(name_colour)
	if replaceItemId == g_BASE_ITEM_DIAMOND or replaceItemCount == g_BASE_ITEM_COIN then
		self.item_count2:setText(replaceItemCount)
	else
		self.item_count2:setText(g_i3k_game_context:GetCommonItemCanUseCount(replaceItemId) .."/".. replaceItemCount)
	end
	self.item_count2:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(replaceItemId) >= replaceItemCount))
	self.itemBtn2:onClick(self, self.onItemTips, replaceItemId);
end

function wnd_BuyChannelSpiritOther:refreshItemCount()
	if self._needItemId == g_BASE_ITEM_DIAMOND or self._needItemId == g_BASE_ITEM_COIN then
		self.item_count:setText(self._needItemCount)
	else
		self.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(self._needItemId) .."/".. self._needItemCount)
	end
	self.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(self._needItemId) >= self._needItemCount))

	if self._needItemId == g_BASE_ITEM_DIAMOND or self._needItemId == g_BASE_ITEM_COIN then
		self.item_count2:setText(self._replaceItemCount)
	else
		self.item_count2:setText(g_i3k_game_context:GetCommonItemCanUseCount(self._replaceItemId) .."/".. self._replaceItemCount)
	end
	self.item_count2:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(self._replaceItemId) >= self._replaceItemCount))
end

function wnd_create(layout)
	local wnd = wnd_BuyChannelSpiritOther.new()
	wnd:create(layout)
	return wnd
end
