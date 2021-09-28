-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_pigeon_post_send = i3k_class("wnd_pigeon_post_send", ui.wnd_base)

local WIDGET = "ui/widgets/feigechuanshut"

function wnd_pigeon_post_send:ctor()
	self.state = g_PIGEON_LOCAL_SEVER --本服1，跨服2
	self.postId = 1
	self.postItems = {{}, {}}
end

function wnd_pigeon_post_send:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self._layout.vars.localPost:onClick(self, self.changeState, g_PIGEON_LOCAL_SEVER)
	self._layout.vars.otherPost:onClick(self, self.changeState, g_PIGEON_OTHER_SEVER)
	self._layout.vars.sendBtn:onClick(self, self.onSendPost)
	self._layout.vars.emojiBtn:onClick(self, self.openEmoji)
	self._layout.vars.editBox:setMaxLength(i3k_db_common.inputlen.pigeonPostLen)
end

function wnd_pigeon_post_send:refresh()
	for k, v in ipairs(i3k_db_pigeon_post.itemInfo) do
		if v.isLocalSever == g_PIGEON_LOCAL_SEVER then
			self.postItems[g_PIGEON_LOCAL_SEVER][k] = v
		else
			self.postItems[g_PIGEON_OTHER_SEVER][k] = v
		end
	end
	self._layout.vars.helpBtn:onClick(self, self.onHelpBtn)
	self:changeState(nil, self.state)
end

function wnd_pigeon_post_send:changeState(sender, state)
	self.state = state
	if self.state == g_PIGEON_LOCAL_SEVER then
		self._layout.vars.localPost:stateToPressed()
		self._layout.vars.otherPost:stateToNormal()
		self._layout.vars.desc:setText("只在本服显示")
	else
		self._layout.vars.localPost:stateToNormal()
		self._layout.vars.otherPost:stateToPressed()
		self._layout.vars.desc:setText("跨服显示")
	end
	self:setPigeonPostScroll()
end

function wnd_pigeon_post_send:setPigeonPostScroll()
	local first = true
	self._layout.vars.postScroll:removeAllChildren()
	for k, v in pairs(self.postItems[self.state]) do
		local node = require(WIDGET)()
		node.vars.postIcon:setImage(g_i3k_db.i3k_db_get_icon_path(v.itemIcon))
		node.vars.name:setText(v.name)
		node.vars.currencyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.currencyType))
		node.vars.count:setText(string.format("x%s", v.currencyCount))
		node.vars.postBtn:onClick(self, self.onChoosePost, {id = k, node = node})
		self._layout.vars.postScroll:addItem(node)
		if first then
			self:choosePost({id = k, node = node})
			first = false
		end
	end
end

function wnd_pigeon_post_send:onChoosePost(sender, data)
	self:choosePost(data)
end

function wnd_pigeon_post_send:choosePost(data)
	self.postId = data.id
	local postCfg = i3k_db_pigeon_post.itemInfo[data.id]
	self._layout.vars.lastTime:setText(string.format("%s秒", postCfg.lastTime))
	self._layout.vars.consumeCount:setText(string.format("x%s", postCfg.currencyCount))
	self._layout.vars.popImage:setImage(g_i3k_db.i3k_db_get_icon_path(postCfg.bgIcon))
	self._layout.vars.currencyIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(postCfg.currencyType))
	self._layout.vars.addBtn:onClick(self, self.toBuyCurrency, postCfg.currencyType)
	self._layout.vars.titleName:setText(postCfg.name)
	self:setCurrency()
	local children = self._layout.vars.postScroll:getAllChildren()
	for _, v in ipairs(children) do
		v.vars.postBtn:stateToNormal()
	end
	data.node.vars.postBtn:stateToPressed()
end

function wnd_pigeon_post_send:setCurrency()
	local postCfg = i3k_db_pigeon_post.itemInfo[self.postId]
	self._layout.vars.currencyImage:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(postCfg.currencyType))
	self._layout.vars.currencyCount:setText(g_i3k_game_context:GetBaseItemCount(postCfg.currencyType))
end

function wnd_pigeon_post_send:onSendPost(sender)
	local postCfg = i3k_db_pigeon_post.itemInfo[self.postId]
	local message = self._layout.vars.editBox:getText()
	if g_i3k_game_context:GetBaseItemCount(postCfg.currencyType) < postCfg.currencyCount then
		g_i3k_ui_mgr:PopupTipMessage("货币不足")
	elseif message == "" then
		g_i3k_ui_mgr:PopupTipMessage("请先输入内容")
	elseif i3k_get_utf8_len(message) > i3k_db_common.inputlen.pigeonPostLen then
		g_i3k_ui_mgr:PopupTipMessage("长度不符合规范")
	else
		i3k_sbean.send_kite(self.postId, message)
	end
end

function wnd_pigeon_post_send:toBuyCurrency(sender, currencyType)
	if currencyType == g_BASE_ITEM_DRAGON_COIN then
		g_i3k_game_context:setPinduoduoDragonCoinOpen(true)
		i3k_sbean.sync_pay_activity(4)
	elseif math.abs(currencyType) == g_BASE_ITEM_COIN then
		g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
	elseif g_i3k_db.i3k_db_get_isShow_btn(currencyType) then
		g_i3k_logic:OpenBuyBaseItemUI(currencyType)
	else
		g_i3k_ui_mgr:PopupTipMessage("无法购买")
	end
end

function wnd_pigeon_post_send:openEmoji(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SelectBq)
	g_i3k_ui_mgr:RefreshUI(eUIID_SelectBq, eUIID_PigeonPostSend)
end

function wnd_pigeon_post_send:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17249))
end

function wnd_create(layout, ...)
	local wnd = wnd_pigeon_post_send.new();
		wnd:create(layout, ...);
	return wnd;
end
