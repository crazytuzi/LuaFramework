-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_cardPacketUnlock = i3k_class("wnd_cardPacketUnlock", ui.wnd_base)

-- 图鉴卡背解锁
-- [eUIID_CardPacketUnlock]	= {name = "cardPacketUnlock", layout = "tujiankbjs", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_cardPacketUnlock:ctor()

end

function wnd_cardPacketUnlock:configure()
	self:setButtons()
end

function wnd_cardPacketUnlock:refresh(type, cardID)
	self._type = type
	self._cardID = cardID
	self:setType(type, cardID)
end

-- InvokeUIFunction
function wnd_cardPacketUnlock:refreshItems()
	self:setType(self._type, self._cardID)
end

function wnd_cardPacketUnlock:setType(type, cardID)
	local widgets = self._layout.vars
	if type == g_CARD_PACKET.UNLOCK_CARD then -- 解锁卡牌
		widgets.name:setText("解锁卡牌")
		local cfg = g_i3k_db.i3k_db_cardPacket_get_card_cfg(cardID)
		local needItems = 
		{
			{id = cfg.args[1], count = cfg.args[2]},
		}
		self:setScrolls(needItems)
	elseif type == g_CARD_PACKET.UNLOCK_CARD_BACK then -- 解锁卡背
		local cardBackID = cardID
		local cardBackCfg = g_i3k_db.i3k_db_cardPacket_get_card_back_cfg(cardBackID)
		self:setScrolls(cardBackCfg.needItems)
		widgets.name:setText("解锁卡背")
	end
end

function wnd_cardPacketUnlock:setScrolls(list)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	self._needItems = list
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/tujiankbjst")()
		local id = v.id
		local count = v.count
		ui.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		ui.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		ui.vars.btn:onClick(self, self.onTips, id)
		ui.vars.count:setText("x"..count)
		local have = g_i3k_game_context:GetCommonItemCanUseCount(id)
		ui.vars.count:setTextColor(g_i3k_get_cond_color(have >= count))
		self._itemEnough = have >= count
		ui.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		ui.vars.name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
		scroll:addItem(ui)
	end
end

function wnd_cardPacketUnlock:setLabels()
	local widgets = self._layout.vars
	--	widgets.btnName:setText("解 锁")
	--	widgets.name:setText("卡背解锁")
end

function wnd_cardPacketUnlock:setRichText()
	local widgets = self._layout.vars
	--	widgets.desc:setText("是否消耗以上道具解锁？")
end

function wnd_cardPacketUnlock:setButtons()
	local widgets = self._layout.vars
	widgets.unlock:onClick(self, self.onunlockBtn)
	widgets.close:onClick(self, self.oncloseBtn)
end


function wnd_cardPacketUnlock:onunlockBtn(sender)
	local cardID = self._cardID
	local type = self._type
	if not self._itemEnough then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	if type == g_CARD_PACKET.UNLOCK_CARD then -- 解锁卡牌
		local itemID = self._needItems[1].id
		i3k_sbean.useCardItem(cardID, self._needItems, itemID)
	elseif type == g_CARD_PACKET.UNLOCK_CARD_BACK then -- 解锁卡背
		local cardBackCfg = g_i3k_db.i3k_db_cardPacket_get_card_back_cfg(cardID)
		i3k_sbean.unlockCardBack(cardBackCfg.id, self._needItems)
	end
end

function wnd_cardPacketUnlock:oncloseBtn(sender)
	self:onCloseUI()
end


function wnd_cardPacketUnlock:onTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_create(layout, ...)
	local wnd = wnd_cardPacketUnlock.new()
	wnd:create(layout, ...)
	return wnd;
end
