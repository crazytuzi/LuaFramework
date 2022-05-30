local data_pingbi_pingbi = require("data.data_pingbi_pingbi")
local data_config_config = require("data.data_config_config")
local json = require(cc.PACKAGE_NAME .. ".json")
local MAX_TEXT_LEN = 40
local MAX_CHAT_NUM = data_config_config[1].max_chat_num
local kChatTime = data_config_config[1].kchattime
local kUpdateTime = data_config_config[1].kupdatetime

local ChatLayer = class("ChatLayer", function ()
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	return require("utility.ShadeLayer").new()
end)

function ChatLayer:getChatList()
	RequestHelper.chat.getList({
	type = tostring(self._chatType),
	name = game.player:getPlayerName(),
	account = self.friendAccount,
	lasttime = game.player:getChatLastTime(self._chatType, self.name),
	callback = function (data)
		dump(data)
		if string.len(data["0"]) > 0 then
			dump(data["0"])
		else
			game.player:setChatNewNum(0)
			PostNotice(NoticeKey.MainMenuScene_chatNewNum)
			self:init(data)
		end
	end
	})
end

function ChatLayer:reGetChatList()
	GameRequest.chat.getList({
	type = tostring(self._chatType),
	name = game.player:getPlayerName(),
	account = self.friendAccount,
	lasttime = game.player:getChatLastTime(self._chatType, self.name),
	callback = function (data)
		dump(data)
		if string.len(data["0"]) > 0 then
			dump(data["0"])
		else
			self:updateChatData(data)
		end
		self._updateTime = kUpdateTime
	end
	})
end

function ChatLayer:load()
	return GameState.load()
end

function ChatLayer:save(curChatData)
	GameState.save(curChatData)
end

function ChatLayer:writeToChatData(tableMsg)
	--if tableMsg == nil or #tableMsg == 0 then
	--	return {} --九- 零-一-起玩-w-w-w-.9- 0-1 -7-5-.-com
	--end
	local curChatData = self:load()
	if curChatData == nil or type(curChatData) ~= "table" then
		curChatData = {}
	else
		for i, v in ipairs(curChatData) do
			if not v.serverID then
				v.serverID = game.player.m_serverID
			elseif v.serverID ~= game.player.m_serverID then
				curChatData = {}
				break
			end
		end
	end
	if tableMsg ~= nil and type(tableMsg) == "table" then
		for i, v in ipairs(tableMsg) do
			v.serverID = game.player.m_serverID
			table.insert(curChatData, v)
		end
		local needRemoveNum = #curChatData - MAX_CHAT_NUM
		if needRemoveNum > 0 then
			for i = 1, needRemoveNum do
				table.remove(curChatData, 1)
			end
		end
		self:save(curChatData)
	end
	return curChatData
end

function ChatLayer:clearChatData()
	local chatData = {}
	self:save(chatData)
end

function ChatLayer:sendMsg(msg)
	self._time = kChatTime
	local curRename = ""
	if self._chatType == CHAT_TYPE.friend then
		curRename = self.friendAccount
	end
	dump(msg)
	GameRequest.chat.sendMsg({
	type = tostring(self._chatType),
	msg = msg,
	recname = curRename,
	para1 = "",
	para2 = "",
	para3 = "",
	callback = function (data)
		dump(data)
		if data.errCode ~= nil and data.errCode > 0 then
			show_tip_label(data_error_error[data.errCode].prompt)
		else
			self._lastChatMsg = msg
			self:sendMsgSuccess(msg)
		end
	end
	})
end
function ChatLayer:ctor(param)
	local data = param.data
	local chatType = param.chatType
	local chatIndex = param.chatIndex
	self._guildId = param.guildId
	self._dumpList = {}
	self._addChatItem = {}
	self._lastChatMsg = ""
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local path = "chat/chat_bg.ccbi"
	if chatType == CHAT_TYPE.friend then
		path = "friend/friend_chat_bg.ccbi"
		self.friendIndex = chatIndex
	end
	local node = CCBuilderReaderLoad(path, proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	self:checkIsSelf()
	self._rootnode.tag_close:addHandleOfControlEvent(function (eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	self._rootnode.sendBtn:addHandleOfControlEvent(function (eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:checkMsg(self._editBox:getText())
	end,
	CCControlEventTouchUpInside)
	local chatNode = self._rootnode.chatBox_node
	local cntSize = chatNode:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#win_base_inner_bg_black.png",
	size = cc.size(cntSize.width * 0.9, cntSize.height * 0.9),
	x = cntSize.width / 2,
	y = cntSize.height / 2
	})
	self._editBox:setFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setFontColor(FONT_COLOR.WHITE)
	self._editBox:setMaxLength(MAX_TEXT_LEN)
	self._editBox:setPlaceHolder(common:getLanguageString("@Input"))
	self._editBox:setPlaceholderFont(FONTS_NAME.font_fzcy, 22)
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	chatNode:addChild(self._editBox)
	game.player:setChatNewNum(0)
	PostNotice(NoticeKey.MainMenuScene_chatNewNum)
	if chatType ~= CHAT_TYPE.friend then
		self:createTab(chatType, data)
	else
		self:setChatType(chatType, data)
	end
	self:initTimeSchedule()
end

function ChatLayer:selectedTab(tag)
	for i = 1, CHAT_TYPE_TOTAL do
		local tab = self._rootnode["tab" .. tostring(i)]
		if tag == i then
			if tab ~= nil then
				tab:setEnabled(false)
				tab:setZOrder(10)
			end
		elseif tab ~= nil then
			tab:setEnabled(true)
			tab:setZOrder(10 - i)
		end
	end
end

function ChatLayer:createTab(chatType, data)
	local function onTabBtn(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		if tag ~= CHAT_TYPE.guild then
			self:setChatType(tag)
		else
			--[[
			local guild = game.player:getGuildMgr():getGuildInfo()
			if guild and guild.m_id and guild.m_id > 0 then
				self._guildId = guild.m_id
				self:setChatType(tag)
			else
				ResMgr.showErr(1700002)
				self:selectedTab(CHAT_TYPE.world)
			end
			]]
			
			RequestHelper.chat.getGuildId({
			callback = function (data)
				if data.guildId == 0 then
					ResMgr.showErr(1700002)
					self:selectedTab(CHAT_TYPE.world)
				else
					self._guildId = guildId
					self:setChatType(tag)
				end
			end
			})
		end
	end
	local tables = {}
	for i = 1, CHAT_TYPE_TOTAL do
		local tab = self._rootnode["tab" .. tostring(i)]
		if tab ~= nil then
			table.insert(tables, tab)
		end
	end
	CtrlBtnGroupAsMenu(tables, function (idx)
		onTabBtn(idx == 1 and idx or CHAT_TYPE.guild)
	end,
	chatType)
	self:setChatType(chatType, data)
end

function ChatLayer:setChatType(chatType, data)
	if self._chatType ~= chatType then
		for key, values in pairs(self._addChatItem) do
			key:removeFromParentAndCleanup(true)
		end
		self._chatType = chatType
		self._time = 0
		if self._chatType == CHAT_TYPE.friend then
			self._updateTime = 0
		else
			self._updateTime = kUpdateTime
		end
		self:selectedTab(self._chatType)
		self:removeDataFromScrollView()
		self:initFile()
		if self._chatType == CHAT_TYPE.friend or data ~= nil then
			self:init(data)
		else
			self:getChatList()
		end
	else
		self:selectedTab(chatType)
	end
end

function ChatLayer:initFile()
	local fileName = ""
	if self._chatType == CHAT_TYPE.world then
		fileName = "chatData.json"
	elseif self._chatType == CHAT_TYPE.guild then
		fileName = tostring(game.player.m_uid) .. "_chatWith_" .. tostring(self._guildId) .. "_guildData.json"
	elseif self._chatType == CHAT_TYPE.friend then
		self:initFriendChat()
		fileName = tostring(game.player.m_uid) .. "_chatWith_" .. tostring(self.friendAccount) .. "_Data.json"
	end
	dump(fileName)
	local eventListen = function (param)
		local returnValue = {}
		if param.errorCode then
			dump("读取存储文件失败error:" .. param.errorCode)
		elseif param.name == "save" then
			dump("save:")
			returnValue = param.values
		elseif param.name == "load" then
			dump("load:")
			returnValue = param.values
		end
		return returnValue
	end
	GameState.init(eventListen, fileName)
end

function ChatLayer:initFriendChat()
	local mid_height = display.height - self._rootnode.up_node:getContentSize().height - self._rootnode.down_node:getContentSize().height
	self._rootnode.mid_node:setContentSize(CCSize(display.width * 0.9, mid_height))
	self._rootnode.mid_bg:setContentSize(CCSize(display.width * 0.9, mid_height * 0.97))
	self._rootnode.scrollView:setContentSize(CCSize(display.width * 0.9, mid_height * 0.94))
	self._rootnode.scrollView:setViewSize(CCSize(display.width * 0.9, mid_height * 0.94))
	self:initFriendData()
	self:initFriendContent()
end

function ChatLayer:readFromFriendChatFile()
	local friendChatTable = {}
	return friendChatTable
end

function ChatLayer:init(data)
	local curData
	if self._chatType == CHAT_TYPE.friend then
		curData = self:readFromFriendChatFile()
	else
		curData = data
		if game.player.m_isChangedServer == true then
			game.player.m_isChangedServer = false
			self:clearChatData()
		end
	end
	local msgAry = self:writeToChatData(curData["1"])
	for i, v in ipairs(msgAry) do
		local isLeft = true
		if v.name == game.player:getPlayerName() then
			isLeft = false
		end
		self:createItem({
		gender = v.sex,
		isLeft = isLeft,
		name = v.name,
		msg = v.msg,
		guildName = v.sendRoleFaction,
		account = v.account
		})
		if i == #msgAry then
			table.insert(self._dumpList, v)
		end
	end
	self:resetScrollView()
end

function ChatLayer:updateChatData(data)
	local msgAry = self:writeToChatData(data["1"])
	local last
	local count = #self._dumpList
	if count <= 0 then
		self._dumpList = msgAry
	else
		last = self._dumpList[count]
		for i, v in ipairs(msgAry) do
			if last.t < v.t then
				table.insert(self._dumpList, v)
			end
		end
	end
	for i, v in ipairs(self._dumpList) do
		if v.name ~= game.player:getPlayerName() and (last == nil or v.t > last.t) then
			do
				local isLeft = true
				if v.name == game.player:getPlayerName() then
					isLeft = false
				end
				local function showMsgBox()
					local msgBox = require("game.Chat.ChatManageBox").new({
					account = v.account
					})
					game.runningScene:addChild(msgBox, self:getZOrder() + 1)
				end
				local bCanTouch = not self:checkIsSelf(v.account)
				local chatItem = require("game.Chat.ChatItem").new({
				gender = v.sex,
				isLeft = isLeft,
				name = v.name,
				msg = v.msg,
				guildName = v.sendRoleFaction,
				bCanTouch = bCanTouch,
				chatListen = showMsgBox
				})
				chatItem:setVisible(false)
				self:addChild(chatItem)
				self._addChatItem[chatItem] = true
				chatItem:runAction(transition.sequence({
				CCDelayTime:create(i * 0.5),
				CCCallFuncN:create(function (node)
					self._addChatItem[chatItem] = nil
					self:removeChild(node, false)
					node:setVisible(true)
					self:addToScrollView(node, node:getIsLeft())
				end),
				CCCallFunc:create(function ()
					self:resetScrollView()
				end)
				}))
			end
		end
	end
	count = #self._dumpList
	if count > 0 then
		last = self._dumpList[count]
		self._dumpList = {}
		table.insert(self._dumpList, last)
	end
end

function ChatLayer:checkIsSelf(account)
	if not self._selfAcc then
		self._selfAcc = string.lower(game.player:getAccount()) .. "##" .. game.player:getServerID()
	end
	return self._selfAcc == account
end

function ChatLayer:createItem(param)
	local account = param.account
	local function showMsgBox()
		local msgBox = require("game.Chat.ChatManageBox").new({account = account})
		game.runningScene:addChild(msgBox, self:getZOrder() + 1)
	end
	local bCanTouch = not self:checkIsSelf(string.lower(account))
	local chatItem = require("game.Chat.ChatItem").new({
	gender = param.gender,
	isLeft = param.isLeft,
	name = param.name,
	msg = param.msg,
	guildName = param.guildName,
	bCanTouch = bCanTouch,
	chatListen = showMsgBox
	})
	self:addToScrollView(chatItem, param.isLeft)
end

function ChatLayer:addToScrollView(chatItem, isLeft)
	if chatItem == nil then
		return
	end
	local listViewSize = self._rootnode.listView:getContentSize()
	local posX = 15
	if not isLeft then
		posX = listViewSize.width - 15
	end
	local itemH = chatItem:getContentSize().height
	if itemH < 100 then
		self._height = self._height + 10
	end
	local itemH = chatItem:getContentSize().height
	chatItem:setPosition(posX, -self._height)
	self._rootnode.contentView:addChild(chatItem)
	self._height = self._height + itemH
end

function ChatLayer:resetScrollView()
	local listViewSize = self._rootnode.listView:getContentSize()
	local contentViewSize = self._rootnode.contentView:getContentSize()
	local sz = CCSizeMake(contentViewSize.width, contentViewSize.height + self._height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(ccp(sz.width / 2, sz.height))
	local scrollView = self._rootnode.scrollView
	scrollView:updateInset()
	if self._height < listViewSize.height then
		scrollView:setContentOffset(CCPointMake(0, -sz.height + scrollView:getViewSize().height), false)
	else
		self._rootnode.scrollView:getContainer():setPosition(0, 0)
	end
end

function ChatLayer:removeDataFromScrollView()
	self._height = 0
	self._rootnode.contentView:removeAllChildren()
end

function ChatLayer:sendMsgSuccess(msg)
	self:createItem({
	gender = game.player:getGender(),
	isLeft = false,
	name = game.player:getPlayerName(),
	msg = msg,
	account = self._selfAcc
	})
	self:resetScrollView()
	self._editBox:setText("")
end

function ChatLayer:initTimeSchedule()
	self:reGetChatList()
	self:schedule(function ()
		if self._time > 0 then
			self._time = self._time - 1
		end
		if 0 < self._updateTime then
			self._updateTime = self._updateTime - 1
		end
		if 0 >= self._updateTime then
			self:reGetChatList()
		end
	end,
	1)
end

function ChatLayer:checkSensitiveWord(wordStr)
	local endWordStr = wordStr
	for i, v in ipairs(data_pingbi_pingbi) do
		local contian = string.find(endWordStr, v.words)
		if contian ~= nil then
			bHas = true
			local tmpStr = ""
			for j = 1, string.utf8len(v.words) do
				tmpStr = tmpStr .. "*"
			end
			endWordStr = string.gsub(endWordStr, v.words, tmpStr)
		end
	end
	return bHas, endWordStr
end

function ChatLayer:checkMsg(msg)
	local canSend = true
	local length = string.utf8len(msg)
	if length <= 0 then
		show_tip_label(common:getLanguageString("@InputIsNull"))
		return
	end
	if game.player:getLevel() < 15 then
		show_tip_label(common:getLanguageString("@LevelNotEnough15"))
		return
	end
	if 0 < self._time then
		show_tip_label(common:getLanguageString("@SpeakFast"))
		return
	end
	if msg == self._lastChatMsg then
		self:sendMsgSuccess(msg)
		return
	end
	if length > MAX_TEXT_LEN then
		show_tip_label(common:getLanguageString("@ContentIsLong"))
		local text = string.gsub(msg, 1, MAX_TEXT_LEN)
		self._editBox:setText(text)
	end
	local hasSensitiveWord = common:checkSensitiveWord(msg)
	if hasSensitiveWord == true then
		common:muzzleChat(msg)
		self._lastChatMsg = msg
		self:sendMsgSuccess(msg)
		return
	end
	local bContain, endWordStr = self:checkSensitiveWord(msg)
	if canSend then
		self:sendMsg(endWordStr)
	end
end

function ChatLayer:onExit()
	if self._schedule ~= nil then
		self.scheduler.unscheduleGlobal(self._schedule)
	end
	self:unscheduleUpdate()
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

function ChatLayer:initFriendData()
	local listData = FriendModel.getList(1)
	local cellData = listData[self.friendIndex]
	self.friendAccount = cellData.account
	self.battlepoint = cellData.battlepoint or 0
	self.charm = cellData.charm or 0
	self.cls = cellData.cls or 1
	self.level = cellData.level or 0
	self.name = cellData.name or 0
	self.resId = cellData.resId or 0
end

function ChatLayer:initFriendContent()
	self.heroNameTTF = ResMgr.createShadowMsgTTF({
	text = "",
	color = cc.c3b(255, 210, 0)
	})
	self._rootnode.heroName:getParent():addChild(self.heroNameTTF)
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
end

return ChatLayer