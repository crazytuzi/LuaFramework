-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_constellationTestShare = i3k_class("wnd_constellationTestShare", ui.wnd_base)

local sendItem = {65656, 66167}

function wnd_constellationTestShare:ctor()
	self.groupID = 0
end

function wnd_constellationTestShare:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_constellationTestShare:refresh(groupID)
	self.groupID = groupID
	for i = 1, 2 do
		local rank = g_i3k_db.i3k_db_get_common_item_rank(sendItem[i])
		self._layout.vars["suo"..i]:show()
		self._layout.vars["count"..i]:setText("x1")
		self._layout.vars["item"..i]:onClick(self, self.onItemInfo, sendItem[i])
	end
	self._layout.vars.item1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(65656))
	self._layout.vars.item2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(66167))
	self._layout.vars.normalBtn:onClick(self, self.onSendWorld)
	self._layout.vars.superBtn:onClick(self, self.onSendCross)
	self._layout.vars.descTxt:setText("是否把心语星愿测试结果分享到聊天频道")
end


function wnd_constellationTestShare:onItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_constellationTestShare:onSendWorld(sender)
	if g_i3k_game_context:GetCommonItemCanUseCount(65656) > 0 then
		i3k_sbean.mood_diary_constellation_test_share(global_world, self.groupID)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17189))
	end
end

function wnd_constellationTestShare:onSendCross(sender)
	if g_i3k_game_context:GetCommonItemCanUseCount(66167) > 0 then
		i3k_sbean.mood_diary_constellation_test_share(global_span, self.groupID)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17189))
	end
end

function wnd_create(layout)
	local wnd = wnd_constellationTestShare.new()
	wnd:create(layout)
	return wnd
end
