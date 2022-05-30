local FriendManageBox = class("FriendManageBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function FriendManageBox:ctor(id)
	local listData = FriendModel.getList(1)
	local cellData = listData[id]
	self.id = id
	dump(cellData)
	self.acc = cellData.account
	self:setNodeEventEnabled(true)
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("friend/friend_manage_box.ccbi", rootProxy, self._rootnode)
	rootnode:setPosition(display.cx, display.cy)
	self:addChild(rootnode, 1)
	if game.player:getAppOpenData().hy_qiecuo == APPOPEN_STATE.close then
		self._rootnode.pk_btn:setVisible(false)
	else
		self._rootnode.pk_btn:setVisible(true)
	end
	ResMgr.setControlBtnEvent(self._rootnode.chat_btn, function()
		self:createChatBox()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.info_btn, function()
		self:createFriendInfo()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.pk_btn, function()
		self:createPKLayer()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.break_btn, function()
		self:createBreakBox()
	end)
	ResMgr.setControlBtnEvent(self._rootnode.pullBack_btn, function()
		self:pullBackFunc()
	end)
	
	ResMgr.setControlBtnEvent(self._rootnode.close_btn, function()
		self:removeSelf()
	end,
	SFX_NAME.u_guanbi)
	self.playerName = cellData.name
	self.battlepoint = cellData.battlepoint
	local text = common:getLanguageString("@Qiecuo") .. "(" .. (cellData.surplusCnt or 0) .. ")"
	resetctrbtnString(self._rootnode.pk_btn, text)
end

function FriendManageBox:createChatBox()
	local function chatFunc()
		local layer = require("game.Chat.ChatLayer").new({
		data = nil,
		chatType = CHAT_TYPE.friend,
		chatIndex = self.id
		})
		layer:setPosition(0, 0)
		game.runningScene:addChild(layer, 10000)
		self:removeSelf()
	end
	RequestHelper.friend.getRelation({
	facc = self.acc,
	callback = function(data)
		if data.blacked == 0 then
			chatFunc()
		else
			ResMgr.showErr(3200013)
		end
	end
	})
end

function FriendManageBox:createFriendInfo()
	local layer = require("game.form.EnemyFormLayer").new(1, self.acc)
	layer:setPosition(0, 0)
	game.runningScene:addChild(layer, 10000)
	self:removeSelf()
end

function FriendManageBox:createPKLayer()
	ResMgr.oppName = self.playerName
	RequestHelper.friend.pkWithFriend({
	facc = self.acc,
	callback = function(data)
		GameStateManager:ChangeState(GAME_STATE.STATE_FRIEND_PK, {
		data = data,
		id = self.acc,
		name = self.playerName,
		battlepoint = self.battlepoint
		})
	end
	})
end

function FriendManageBox:createBreakBox()
	local rowOneTable = {}
	local descFirst = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@DeleteFriends"),
	color = cc.c3b(255, 255, 255)
	})
	rowOneTable[#rowOneTable + 1] = descFirst
	local name = ResMgr.createShadowMsgTTF({
	text = self.playerName,
	color = cc.c3b(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = name
	local descEnd = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Ma"),
	color = cc.c3b(255, 255, 255)
	})
	rowOneTable[#rowOneTable + 1] = descEnd
	local rowAll = {rowOneTable}
	local curAcc = self.acc
	local friendBreakBox = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function(node)
		FriendModel.removeFriendReq({account = curAcc})
		node:removeSelf()
	end
	})
	game.runningScene:addChild(friendBreakBox, BOX_ZORDER.MIN)
	self:removeSelf()
end

function FriendManageBox:pullBackFunc()
	local rowTable1 = {}
	local rowTable2 = {}
	local descFirst = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@TheHitList"),
	color = cc.c3b(255, 255, 255)
	})
	rowTable1[#rowTable1 + 1] = descFirst
	local lbl1 = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@QDBlacklist"),
	color = cc.c3b(255, 255, 255)
	})
	local lbl2 = ResMgr.createShadowMsgTTF({
	text = self.playerName,
	color = cc.c3b(255, 210, 0)
	})
	local lbl3 = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Ma"),
	color = cc.c3b(255, 255, 255)
	})
	rowTable2[#rowTable2 + 1] = lbl1
	rowTable2[#rowTable2 + 1] = lbl2
	rowTable2[#rowTable2 + 1] = lbl3
	local rowAll = {rowTable1, rowTable2}
	local curAcc = self.acc
	local friendBreakBox = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function(node)
		FriendModel.pullBack({account = curAcc})
		node:removeSelf()
	end
	})
	game.runningScene:addChild(friendBreakBox, BOX_ZORDER.MIN)
	self:removeSelf()
end

return FriendManageBox