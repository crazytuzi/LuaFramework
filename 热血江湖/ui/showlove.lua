-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_showLove = i3k_class("wnd_showLove", ui.wnd_base)

function wnd_showLove:ctor()

end

function wnd_showLove:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.input_label:addEventListener(function()
		widgets.label:setText("")
	end)
end

function wnd_showLove:refresh(info)
	self._name = info.name
	self._roleID = info.roleID
	local widgets = self._layout.vars
	widgets.userName:setText(info.name)
	widgets.label:setText("在此处输入您想对他（她）说的话，最多可输入80个字")
	self:setConsumes()
end


function wnd_showLove:setConsumes()
	local cfg1 = i3k_db_activity_world[1].worldItems
	local cfg2 = i3k_db_activity_world[1].kuafuItems
	local widgets = self._layout.vars
	local cfgs = {cfg1, cfg2}
	local channels = {global_world, global_span} --世界(综合)频道, 跨服
	for i = 1 , 2 do
		local itemID = cfgs[i].id
		local itemCount = cfgs[i].count
		widgets["frame"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		widgets["item"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
		widgets["suo"..i]:setVisible(itemID > 0)
		widgets["count"..i]:setText("x"..itemCount)
		local info = { channel = channels[i], itemID = itemID, itemCount = itemCount}
		widgets["btn"..i]:onClick(self, self.onSend, info)
		widgets["itemBtn"..i]:onClick(self, self.onItemTips, itemID)
	end

end

function wnd_showLove:onItemTips(sender, args)
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end


function wnd_showLove:onSend(sender, info)
	local channel = info.channel
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(info.itemID)
	if haveCount < info.itemCount then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	local callback = function()
		g_i3k_game_context:UseCommonItem(info.itemID, info.itemCount, AT_SEND_WORLD_BLESS)
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
		g_i3k_ui_mgr:CloseUI(eUIID_ShowLove)
	end

	local widgets = self._layout.vars
	local message = widgets.input_label:getText()
	local textcount = i3k_get_utf8_len(message)
	if textcount > i3k_db_common.inputlen.chatlen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(747))
		return
	elseif textcount == 0 then
		g_i3k_ui_mgr:PopupTipMessage("输入为空")
		return
	end

	-- 匹配模式：#B(%d+),(%S+),(%S+)#
	local msg = "#B" .. 1 ..","..self._name ..",".. message.."#"
	self:sendProtocol(channel, callback, msg)
end


function wnd_showLove:sendProtocol(channel, callback, msg)

	-- 检查是否在当天的活动时间内
	local checkTime = g_i3k_db.i3k_db_get_is_activity_world_can_get_reward(g_activity_show_world)
	if not checkTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17246)) -- 活动结束
		return
	end

	local send = i3k_sbean.msg_send_req.new()
	send.type = channel
	send.id = self._roleID
	send.msg = msg
	send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
	send.isShowLove = true
	send.callback = callback
	i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
end




function wnd_create(layout, ...)
	local wnd = wnd_showLove.new()
	wnd:create(layout, ...)
	return wnd;
end
