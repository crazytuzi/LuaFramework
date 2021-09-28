-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_moodDiary_share = i3k_class("wnd_moodDiary_share", ui.wnd_base)

local sendItem = {65656, 66167}

function wnd_moodDiary_share:ctor()
	
end

function wnd_moodDiary_share:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_moodDiary_share:refresh(decorateId)
	for i = 1, 2 do
		local rank = g_i3k_db.i3k_db_get_common_item_rank(sendItem[i])
		self._layout.vars["frame"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].giftRankIcon[rank]))
		self._layout.vars["item"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(sendItem[i]))
		self._layout.vars["suo"..i]:show()
		self._layout.vars["count"..i]:setText("x1")
		self._layout.vars["count"..i]:setTextColor(i3k_db_mood_diary_decorate[decorateId].shareItemNameColor)
		self._layout.vars["item"..i]:onClick(self, self.onItemInfo, sendItem[i])
	end
	self._layout.vars.normalBtn:onClick(self, self.onSend, 1)
	self._layout.vars.superBtn:onClick(self, self.onSend, 2)
	self._layout.vars.descTxt:setText(i3k_get_string(17188))
	self._layout.vars.descTxt:setTextColor(i3k_db_mood_diary_decorate[decorateId].shareDescColor)
	self._layout.vars.background:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareBackGround))
	self._layout.vars.normalBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareUIBtn))
	self._layout.vars.superBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareUIBtn))
	self._layout.vars.descTxtBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareUITextBg))
	self._layout.vars.closeBtn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_mood_diary_decorate[decorateId].shareUICloseBtn))
	self._layout.vars.normalText:setTextColor(i3k_db_mood_diary_decorate[decorateId].normalBtnColor)
	self._layout.vars.superText:setTextColor(i3k_db_mood_diary_decorate[decorateId].normalBtnColor)
	self._layout.vars.normalText:enableOutline(i3k_db_mood_diary_decorate[decorateId].normalTextColor)
	self._layout.vars.superText:enableOutline(i3k_db_mood_diary_decorate[decorateId].normalTextColor)
end

function wnd_moodDiary_share:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_moodDiary_share:onSend(sender, sendType)
	if sendType == 2 and g_i3k_game_context:GetVipLevel() < i3k_db_common.chat.isOpenSpanLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(790, i3k_db_common.chat.isOpenSpanLvl))
	else
		if g_i3k_game_context:GetCommonItemCanUseCount(sendItem[sendType]) > 0 then
			i3k_sbean.mood_diary_share(sendType)
			self:onCloseUI()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17189))
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_moodDiary_share.new()
	wnd:create(layout)
	return wnd
end