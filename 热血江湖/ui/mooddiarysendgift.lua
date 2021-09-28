-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_moodDiary_sendGift = i3k_class("wnd_moodDiary_sendGift", ui.wnd_base)

local LAYER_GIFTITEM = "ui/widgets/zengsongliwut"

function wnd_moodDiary_sendGift:ctor()
	self.friendData = {}
	self.decorationId = 1
end

function wnd_moodDiary_sendGift:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onClose)
end

function wnd_moodDiary_sendGift:refresh(friendData, decorationId)
	self.friendData = friendData
	if decorationId ~= 0 then
		self.decorationId = decorationId
	end
	self:showGift()
end

function wnd_moodDiary_sendGift:onClose()
	--赠送礼物打开类型肯定是2
	i3k_sbean.mood_diary_open_main_page(2, self.friendData.id)
	g_i3k_ui_mgr:CloseUI(eUIID_SendGift)
end

function wnd_moodDiary_sendGift:showGift()
	local widgets = self._layout.vars
	widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendGiftTitle))
	widgets.close_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendUICloseIcon))
	widgets.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendUIBackGround))
	widgets.scrollIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].wndScrollIcon))
	--widgets.scroll
	widgets.scroll:removeAllChildren()
	local children = widgets.scroll:addChildWithCount(LAYER_GIFTITEM, 4, #i3k_db_mood_diary_gift)--第二个参数是每行多少个，第三个是总共显示几个
	for i,v in ipairs(children) do
		v.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendBaseboard))
		local rank = g_i3k_db.i3k_db_get_common_item_rank(i3k_db_mood_diary_gift[i].itemID)
		v.vars.rank:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].giftRankIcon[rank]))
		v.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_mood_diary_gift[i].itemID, g_i3k_game_context:IsFemaleRole()))
		v.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(i3k_db_mood_diary_gift[i].itemID))
		v.vars.item_name:setTextColor(i3k_db_mood_diary_decorate[self.decorationId].sendUIItemNameColor)
		v.vars.name_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendItemsBoard))
		v.vars.des:setText(i3k_db_mood_diary_gift[i].describe)
		v.vars.des:setTextColor(i3k_db_mood_diary_decorate[self.decorationId].sendUIItemDescColor)
		local itemCnt = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_mood_diary_gift[i].itemID)
		v.vars.count:setText("x" .. itemCnt)
		v.vars.icon:onClick(self,self.onItemDesc,i3k_db_mood_diary_gift[i].itemID)
		v.vars.send_btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[self.decorationId].sendUIbtnIcon))
		v.vars.send_btn:onClick(self, self.onSendGift,{id = i3k_db_mood_diary_gift[i].itemID, count = itemCnt, roleId = self.friendData.id, name = self.friendData.name})
		v.vars.send_text:setTextColor(i3k_db_mood_diary_decorate[self.decorationId].normalBtnColor)
		v.vars.send_text:enableOutline(i3k_db_mood_diary_decorate[self.decorationId].normalTextColor)
	end
end

function wnd_moodDiary_sendGift:onItemDesc(sender,itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_moodDiary_sendGift:onSendGift(sender,data)
	
	local fun = (function(ok)
		if ok then
			i3k_sbean.mood_diary_send_popularity_item(data.count, data.id, data.roleId)
		end
	end)
	if data.count > 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_SendItems)
		g_i3k_ui_mgr:RefreshUI(eUIID_SendItems, data, true)
	elseif data.count == 1 then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(data.id)
		local desc = i3k_get_string(17185, cfg.name, data.name)
		g_i3k_ui_mgr:ShowMessageBox2(desc, fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17186))
	end
end

function wnd_create(layout)
	local wnd = wnd_moodDiary_sendGift.new()
	wnd:create(layout)
	return wnd
end
