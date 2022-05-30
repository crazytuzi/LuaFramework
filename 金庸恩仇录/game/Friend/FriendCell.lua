local FriendCell = class("FriendCell", function()
	return CCTableViewCell:new()
end)
local MAX_ZORDER = 100000

function FriendCell:getContentSize()
	return cc.size(display.width, self._rootnode.itemBg:getContentSize().height)
end

function FriendCell:ctor(cellType)
	self.cellType = cellType
	local cellPath = "friend/friend_cell.ccbi"
	if cellType == 4 then
		cellPath = "friend/friend_apply_cell.ccbi"
	end
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad(cellPath, proxy, self._rootnode)
	node:setPosition(display.width * 0.5, self._rootnode.itemBg:getContentSize().height)
	self:addChild(node)
	if cellType ~= 4 then
		for i = 1, 5 do
			if i ~= 4 then
				if i == cellType then
					self._rootnode["node_group_" .. i]:setVisible(true)
				else
					self._rootnode["node_group_" .. i]:setVisible(false)
				end
			end
		end
	end
	self.heroNameTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(255, 210, 0)
	})
	self._rootnode.heroName:getParent():addChild(self.heroNameTTF)
	if self._rootnode.bubble_node ~= nil then
		self.bubble = display.newSprite("#friend_chat_buble.png")
		self._rootnode.bubble_node:addChild(self.bubble)
		local expBuble = self._rootnode.chat_bubble
		self.bubble:setPosition(expBuble:getPositionX(), expBuble:getPositionY())
	end
end
function FriendCell:refresh(id)
	self:refreshCellData(id)
	self:refreshCellContent()
end
function FriendCell:initBtnEvent()
	if self.cellType ~= 4 then
		ResMgr.setControlBtnEvent(self._rootnode.send_naili, function()
			self:onSendNaili()
		end)
		ResMgr.setControlBtnEvent(self._rootnode.apply_btn, function()
			self:onApply()
		end)
		ResMgr.setControlBtnEvent(self._rootnode.get_naili, function()
			self:onGetNaili()
		end)
		ResMgr.setControlBtnEvent(self._rootnode.cancelPullBack_btn, function()
			self:onCancelPullBack()
		end)
	else
		ResMgr.setControlBtnEvent(self._rootnode.agree_btn, function()
			self:onAgree()
		end)
		ResMgr.setControlBtnEvent(self._rootnode.reject_btn, function()
			self:onReject()
		end)
	end
end
function FriendCell:refreshCellData(id)
	local listData = FriendModel.getList(self.cellType)
	local cellData = listData[id]
	self.index = id
	self.account = cellData.account
	self.battlepoint = cellData.battlepoint or 0
	self.charm = cellData.charm or 0
	self.cls = cellData.cls or 1
	self.level = cellData.level or 0
	self.name = cellData.name or 0
	self.resId = cellData.resId or 0
	self.isChat = cellData.isChat or 0
	self.isOnline = cellData.isOnline or 0
	self.offlineDays = cellData.offlineDays or 0
	self.isSendNaili = cellData.isSendNaili or 0
	self.isApply = cellData.isApply or 0
	self.isAdd = cellData.isAdd or 0
	self.time = cellData.time or 0
	self.nailiNum = cellData.nailiNum or 1
	self.content = cellData.content or ""
end
function FriendCell:refreshCellContent()
	self._rootnode.zhanli_num:setString(self.battlepoint)
	self._rootnode.charm_num:setString(self.charm)
	self._rootnode.level:setString(self.level)
	self.heroNameTTF:setString(self.name)
	local heroPosX, heroPosY = self._rootnode.heroName:getPosition()
	self.heroNameTTF:setPosition(ccp(heroPosX + self.heroNameTTF:getContentSize().width / 2, heroPosY))
	ResMgr.refreshIcon({
	id = self.resId,
	itemBg = self._rootnode.headIcon,
	resType = ResMgr.HERO,
	cls = self.cls
	})
	local GREEN = cc.c3b(0, 215, 52)
	local GRAY = cc.c3b(100, 100, 100)
	if self.isOnline == 0 then
		self._rootnode.name_status:setColor(GRAY)
		if self.offlineDays == 0 then
			self._rootnode.name_status:setString(common:getLanguageString("@OffTime"))
		else
			self._rootnode.name_status:setString(common:getLanguageString("@OffTime") .. self.offlineDays .. common:getLanguageString("@OfflineForDays"))
		end
	else
		self._rootnode.name_status:setColor(GREEN)
		self._rootnode.name_status:setString(common:getLanguageString("@OnTime"))
	end
	if self._rootnode.bubble_node ~= nil then
		if self.isChat == 0 then
			self._rootnode.bubble_node:setVisible(false)
		else
			self._rootnode.bubble_node:setVisible(true)
			self:startBubbleAnim()
		end
	end
	if self.cellType == 1 then
		self.headIcon:setTouchEnabled(true)
		self._rootnode.name_status:setVisible(true)
		if self.isSendNaili == 0 then
			self._rootnode.send_naili:setVisible(true)
			self._rootnode.send_ttf:setVisible(false)
		else
			self._rootnode.send_naili:setVisible(false)
			self._rootnode.send_ttf:setVisible(true)
		end
	elseif self.cellType == 2 then
		self._rootnode.apply_btn:setVisible(false)
		self._rootnode.apply_ttf:setVisible(false)
		self._rootnode.add_ttf:setVisible(false)
		if self.isApply == 1 then
			self._rootnode.apply_ttf:setVisible(true)
		elseif self.isAdd == 1 then
			self._rootnode.add_ttf:setVisible(true)
		else
			self._rootnode.apply_btn:setVisible(true)
		end
	elseif self.cellType == 3 then
		self._rootnode.name_status:setColor(GREEN)
		self._rootnode.name_status:setVisible(true)
		if 0 < self.time then
			self._rootnode.name_status:setString(common:getLanguageString("@XDay", self.time))
		else
			self._rootnode.name_status:setString(common:getLanguageString("@JinDay"))
		end
	elseif self.cellType == 4 then
		self._rootnode.desc_ttf:setString(self.content)
	end
end
function FriendCell:startBubbleAnim()
	self.bubble:stopAllActions()
	self.bubble:setOpacity(0)
	local toOut = CCFadeOut:create(FriendModel.REQ_INTERVAL / 4)
	local toIn = CCFadeIn:create(FriendModel.REQ_INTERVAL / 4)
	local everAct = CCRepeatForever:create(transition.sequence({toOut, toIn}))
	self.bubble:runAction(everAct)
end

function FriendCell:onSendNaili()
	FriendModel.sendNailiReq({
	account = self.account
	})
end

function FriendCell:onApply()
	if game.player:checkIsSelfByAcc(self.account) then
		ResMgr.showErr(3200009)
	else
		local listData = FriendModel.getList(2)
		local cellData = listData[self.index]
		local applyBox = require("game.Friend.FriendApplyBox").new({
		account = cellData.account
		})
		display.getRunningScene():addChild(applyBox, BOX_ZORDER.BASE)
	end
end
function FriendCell:onGetNaili()
	FriendModel.getNailiReq({
	account = self.account
	})
end
function FriendCell:onAgree()
	FriendModel.acceptReq({
	account = self.account
	})
end
function FriendCell:onReject()
	FriendModel.rejectReq({
	account = self.account
	})
end
function FriendCell:onCancelPullBack()
	local rowTable1 = {}
	local rowTable2 = {}
	local descFirst = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@NotBlacklist"),
	color = cc.c3b(255, 255, 255)
	})
	rowTable1[#rowTable1 + 1] = descFirst
	local lbl1 = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@OKBlacklist"),
	color = cc.c3b(255, 255, 255)
	})
	local lbl2 = ResMgr.createShadowMsgTTF({
	text = self.name,
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
	if common:getLanguageString("@NotBlacklist_1") ~= "@NotBlacklist_1" then
		local rowTable3 = {}
		local descFirst_1 = ResMgr.createShadowMsgTTF({
		text = common:getLanguageString("@NotBlacklist_1"),
		color = cc.c3b(255, 255, 255)
		})
		rowTable3[#rowTable3 + 1] = descFirst_1
		table.insert(rowAll, rowTable3)
	end
	local curAcc = self.account
	local friendBox = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function(node)
		FriendModel.cancelPullBack({
		account = self.account
		})
		node:removeSelf()
	end
	})
	game.runningScene:addChild(friendBox, BOX_ZORDER.BASE)
end

function FriendCell:createFriendBox()
	local friendBox = require("game.Friend.FriendManageBox").new(self.index)
	display.getRunningScene():addChild(friendBox, BOX_ZORDER.BASE)
end

function FriendCell:create(param)
	self.tableViewRect = param.tableViewRect
	self.headIcon = self._rootnode.headIcon
	self:initHeadIcon()
	self:initBtnEvent()
	self:refresh(param.id)
	return self
end

function FriendCell:initHeadIcon()
	self.headIcon:setTouchEnabled(false)
	self.headIcon:setTouchSwallowEnabled(false)
	ResMgr.setNodeEvent({
	node = self.headIcon,
	touchFunc = function()
		self:onHeadTouched()
	end,
	tableViewRect = self.tableViewRect
	})
end

function FriendCell:onHeadTouched()
	if self.isChat == 1 then
		self:createChatLayer()
	else
		self:createFriendBox()
	end
end

function FriendCell:createChatLayer()
	local listData = FriendModel.getList(self.cellType)
	local cellData = listData[self.index]
	cellData.isChat = 0
	self._rootnode.bubble_node:setVisible(false)
	local layer = require("game.Chat.ChatLayer").new({
	data = nil,
	chatType = CHAT_TYPE.friend,
	chatIndex = self.index
	})
	layer:setPosition(0, 0)
	game.runningScene:addChild(layer, 10000)
end

function FriendCell:createDelMsgBox()
	local msg = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function(node)
		if buyFunc ~= nil then
			buyFunc()
		end
		if closeListener ~= nil then
			closeListener()
		end
		node:removeSelf()
	end,
	closeListener = closeListener
	})
	game.runningScene:addChild(msg, MAX_ZORDER)
end

return FriendCell