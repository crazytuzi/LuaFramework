-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_selectBq = i3k_class("wnd_selectBq", ui.wnd_base)
local choose_face = 1
local choose_pos 	= 2
local choose_equip = 3
local choose_tools = 4
local choose_dialogue = 5
local choose_invite = 6
local choose_roll = 7
local choose_cardPacket = 8 -- 图鉴

local WIDGETEMOJI = "ui/widgets/ltbqant"
local stateFunTable 
function wnd_selectBq:ctor()
	self.state = choose_face
	self.emojiId = 1
	self.chatUI = nil
	self.chatUIID = 0
	self._challengeTask = {}
end

function wnd_selectBq:configure()
	self._layout.vars.close:onClick(self, self.closeCB)
	self.equipScroll = self._layout.vars.equipScroll
	self.bqscroll = self._layout.vars.bqScroll
	self.cyScroll = self._layout.vars.cyScroll
	self.emoji_scroll = self._layout.vars.emoji_scroll
	self.valid = self._layout.vars.valid
	self.equipList={}
	stateFunTable = {
		[choose_face] 		= {refreshFun = self.refreshFace, getMessageFun = self.getMessageFace, btnNormal = "lt#lt_bq4.png", btnPressed = "lt#lt_bq2.png" }, 				--表情
		[choose_pos]		= {refreshFun = self.refreshPos,   btnNormal = "lt#lt_zb4.png", btnPressed = "lt#lt_zb2.png" },				--坐标
		[choose_equip]		= {refreshFun = self.updateItems, refreshArg = 0, getMessageFun = self.getMessageEquipAndTools, btnNormal = "lt#lt_zhuangbei4.png", btnPressed =  "lt#lt_zhuangbei2.png" },		--装备
		[choose_tools]		= {refreshFun = self.updateItems, refreshArg = 2, getMessageFun = self.getMessageEquipAndTools, btnNormal = "lt#lt_dj4.png", btnPressed = "lt#lt_dj2.png" },		--道具
		[choose_dialogue]	= {refreshFun = self.refreshDialogue, getMessageFun = self.getMessageDialogue, btnNormal = "lt#lt_db4.png", btnPressed = "lt#lt_db2.png"  },			--对白
		[choose_invite]		= {refreshFun = self.refreshInvite, getMessageFun = self.getMessageInvite , btnNormal = "lt#lt_yq4.png", btnPressed = "lt#lt_yq2.png" },				--发申请
		[choose_roll]		= {refreshFun = self.refreshRoll, btnNormal = "lt#roll.png", btnPressed = "lt#roll4.png"  },				--roll点
		[choose_cardPacket] = {refreshFun = self.setCardPacket, btnNormal = "lt#tujian4.png", btnPressed = "lt#tujian2.png", showLevel = i3k_db_cardPacket.startLevel }
	}
end

function wnd_selectBq:updateItems(flag)
	self._layout.vars.root2:show()
		self.equipScroll:show()
		local bagSize,bagitems = g_i3k_game_context:GetBagInfo()
		local index = 0
		local data = {}
		local guids = {}
		for k,v in pairs(bagitems) do
			local Itemtype =  g_i3k_db.i3k_db_get_common_item_type(v.id)
		if Itemtype == flag then
				local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(v.id)
				local cell_count = g_i3k_get_use_bag_cell_size(v.count, stack_count)
				local allCount = v.count
				local id = v.id
				local cc = allCount
				for i=1,cell_count do
					index = index + 1
					local num = allCount-(i-1)*stack_count
					if num>stack_count then
						cc = stack_count
					else
						cc = num
					end
					data[index] = {}
					data[index].id = id
					data[index].count = cc
				end
				for kk, vv in pairs(v.equips) do
					table.insert(guids, kk)
				end
			end
		end
		local children =  self.equipScroll:addChildWithCount("ui/widgets/dj1",6,index)
		for i,e in pairs(data) do
			local widget = children[i].vars
			local id = e.id
			widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			widget.item_count:setVisible(false)
			widget.item_count:setText(e.count)
			widget.suo:setVisible(id>0)
			widget.bt:setTag(id)
			local guid = guids[i]
			widget.bt:onClick(self,self.onSendEquip,guid)
		end
end

--timetable
local stateTimeTable = {
	[1] = {timeCfg = i3k_db_common.chat.timeWorld },		--大喇叭
	[2] = {timeCfg = i3k_db_common.chat.timeTeamSect },		--
	[3] = {timeCfg = i3k_db_common.chat.timeTeamSect },		--
	[4] = {timeCfg = i3k_db_common.chat.timePrivite },		--
}
function wnd_selectBq:checkSend(state)
	local canSend = true
	local timeNow = i3k_game_get_time()
	if stateTimeTable[state] then
		local sendTime = g_i3k_game_context:GetWorldSendTime()
		if sendTime then
			if timeNow-sendTime <= stateTimeTable[state].timeCfg then
				canSend = false
			end
		end
	end
	return canSend
end

function wnd_selectBq:refreshUI()
	self.emojiId = 1
	self.valid:hide()
	self.emoji_scroll:removeAllChildren()
	self.equipScroll:removeAllChildren()
	self.cyScroll:removeAllChildren()
	self._layout.vars.root1:hide()
	self._layout.vars.root2:hide()
	self._layout.vars.root3:hide()
	--[[self.equipScroll:hide()
	self.bqscroll:hide()
	self.emoji_scroll:hide()
	self.cyScroll:hide()--]]
	self.bqscroll:jumpToListPercent(0)
	self.emoji_scroll:jumpToListPercent(0)
	self.equipScroll:jumpToListPercent(0)
	self.cyScroll:jumpToListPercent(0)

	self.chatUI = g_i3k_ui_mgr:GetUI(self.chatUIID)
	if not self.chatUI then
		return
	end
	if stateFunTable[self.state] then
		stateFunTable[self.state].refreshFun(self, stateFunTable[self.state].refreshArg)
	end
end

----表情
function wnd_selectBq:refreshFace()
		--self.emoji_scroll:show()
		self._layout.vars.root1:show()
		local emojiData = g_i3k_game_context:getEmojiData()
		local emoji = {}
		for k, v in ipairs(i3k_db_emoji_cfg) do
			if v.openType == 0 then
				sortId = k
			else
				if emojiData[k] then
					sortId = k
				else
					sortId = k * 100
				end
			end
			table.insert(emoji, {id = k, sortId = sortId, icon = v.icon})
		end
		table.sort(emoji, function(a, b)
			return a.sortId < b.sortId
		end)
		for k, v in ipairs(emoji) do
			local layer = require(WIDGETEMOJI)()
			local widget = layer.vars
			widget.emoji:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
			widget.btn:onClick(self, self.onEmoji, k)
			widget.btn:setTag(v.id)
			self.emoji_scroll:addItem(layer)
		end
	self:refreshEmojiScroll(1)
		self:refreshEmoji()
end

--坐标
function wnd_selectBq:refreshPos()
	if self.chatUI._chatState ~= global_span then
			local roleId = g_i3k_game_context:GetRoleId()
			local logic = i3k_game_get_logic();
			local world = logic:GetWorld()
			local mapId = world._cfg.id
			local player = logic:GetPlayer()
			local pos = player:GetHeroPos()
			local mapLine = g_i3k_game_context:GetCurrentLine()
			if self.chatUI then
				local msg = "#M"..mapId..","..math.floor(pos.x)..","..math.floor(pos.y)..","..math.floor(pos.z)..","..mapLine.."#"
				local cansend = self:checkSend(self.chatUI._chatState)
			if self.chatUI._chatState == global_world then
					local num = self.chatUI:getlbNum()
					if num>0 then
						if cansend then
							self:sendMsgProtocol(self.chatUI._chatState,roleId,msg)
						else
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
						end
					else
						local needItemId = i3k_db_common.chat.worldNeedId
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(needItemId)))
					end
				else
					if cansend then
					if self.chatUI._chatState == global_recent then
							roleId = math.abs(self.chatUI._TargetId)
						end
						self:sendMsgProtocol(self.chatUI._chatState,roleId,msg)
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
					end
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("跨服禁止发送玩家座标")
		end
end

	--对白
function wnd_selectBq:refreshDialogue()
		self._layout.vars.root3:show()
		self.cyScroll:show()
		for i,e in ipairs(i3k_db_chat_dialogue) do
			local node = require("ui/widgets/ltdbt")()
			node.vars.text:setText(e.txt)
			node.vars.btn:setTag(i)
			node.vars.btn:onTouchEvent(self,self.dialogue)
			self.cyScroll:addItem(node)
		end
end

----发申请
function wnd_selectBq:refreshInvite()
	if self.chatUI._chatState ~= global_span then
			local targetTeamId = g_i3k_game_context:GetTeamId()
			if targetTeamId == 0 then
				self:getSendContent(targetTeamId)
			else
				local count = g_i3k_game_context:GetTeamMemberCount()
				if targetTeamId~= 0 and count<3 then
					self:getSendContent(targetTeamId)
				else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(103340))
				end
			end
		else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(103341))
		end
end

	--roll点
function wnd_selectBq:refreshRoll()
		local rollTimePass = i3k_game_get_time() - g_i3k_game_context:getRollSendTime()
		if rollTimePass >= i3k_db_common.chat.rollCd then
			if self.chatUI then
				local randomNum = math.random(1, 100)
				local message = "#ROLL"..randomNum.."#"
				local roleId = g_i3k_game_context:GetRoleId()
				local cfg = g_i3k_game_context:GetUserCfg()
				local isSpanTips = cfg:GetIsSpanTips()
			if self.chatUI._chatState == global_span then
					local vipLvl = g_i3k_game_context:GetVipLevel()
					if vipLvl >= i3k_db_common.chat.isOpenSpanLvl then
						if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.chat.spanNeedId) <= 0 then
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(791))
							return
						end
						if isSpanTips == 1 then
							g_i3k_ui_mgr:OpenUI(eUIID_SpanTips)
							g_i3k_ui_mgr:RefreshUI(eUIID_SpanTips, false, self.chatUI._chatState, message, roleId)
							return
						end
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(790, i3k_db_common.chat.isOpenSpanLvl))
						return
					end
				end
				local send = i3k_sbean.msg_send_req.new()
				send.type = self.chatUI._chatState
				send.id = roleId
				send.msg = message
				send.gsName = i3k_game_get_server_name(i3k_game_get_login_server_id())
				i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17163, i3k_db_common.chat.rollCd - rollTimePass))
		end
end
function wnd_selectBq:setCardPacket()
	local info = g_i3k_game_context:getCardPacketInfo()
	local cards = info.unlockCard
	local cardBack = info.curCardBack
	self._layout.vars.root2:show()
	self.equipScroll:show()
	local list = g_i3k_db.i3k_db_cardPacket_get_cards_list(cards)
	local children =  self.equipScroll:addChildWithCount("ui/widgets/lttjt", 3, #list)
	for i, e in pairs(children) do
		local cfg = list[i]
		local widget = e.vars
		widget.image:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageID))
		widget.back:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.coverImageID))
		local args = {cardBack = cardBack, cfg = cfg}
		widget.btn:onClick(self,self.onSendCardPacket, args)
	end
end

function wnd_selectBq:onSendCardPacket(sender, args)
	local roleId = g_i3k_game_context:GetRoleId()
	local channel = self.chatUI._chatState
	local cardID = args.cfg.id
	local cardBack = args.cardBack
	local msg = "#C"..cardID..","..cardBack.."#"
	local cansend = self:checkSend(self.chatUI._chatState)
	if self.chatUI._chatState == global_world then
		local num = self.chatUI:getlbNum()
		if num>0 then
			if cansend then
				self:sendMsgProtocol(self.chatUI._chatState, roleId, msg)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
			end
		else
			local needItemId = i3k_db_common.chat.worldNeedId
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(137, g_i3k_db.i3k_db_get_common_item_name(needItemId)))
		end
	else
		if cansend then
			if self.chatUI._chatState == global_recent then
				roleId = math.abs(self.chatUI._TargetId)
			end
			self:sendMsgProtocol(self.chatUI._chatState, roleId, msg)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(136))
		end
	end
end
function wnd_selectBq:onEmoji(sender, id)
	local emojiId = sender:getTag()
	if emojiId == 4 then --史诗成就表情，需要同步成就数据
		i3k_sbean.sync_chtask_info(1, emojiId, id)
	else
		self.emojiId = emojiId
	self:refreshEmojiScroll(id)
	self:refreshEmoji()
	end
end

function wnd_selectBq:refreshEmojiScroll(id)
	local emojiData = g_i3k_game_context:getEmojiData()
	local children = self.emoji_scroll:getAllChildren()
	self.valid:show()
	if i3k_db_emoji_cfg[self.emojiId].openType == 0 then
		self.valid:setText("有效期：永久")
	elseif i3k_db_emoji_cfg[self.emojiId].openType == 1 then
		if not emojiData[self.emojiId] then
			self.valid:setText("尚未拥有")
		else
			local timeStamp = i3k_game_get_time()
			local time = emojiData[self.emojiId] - timeStamp
			local day = math.floor(time/86400)
			if day > 0 then
				self.valid:setText(string.format("有效期：%d天", day))
			else
				self.valid:setText(string.format("有效期：%d小时", time%86400/3600))
			end
		end
	elseif i3k_db_emoji_cfg[self.emojiId].openType == 2 then
		self.valid:setText("有效期：永久")
	end
	for k, v in ipairs(children) do
		if k == id then
			v.vars.btn:stateToPressed()
		else
			v.vars.btn:stateToNormal()
		end
	end
end

function wnd_selectBq:refreshEmoji()
	self.bqscroll:removeAllChildren()
	self.bqscroll:show()
	local emoji = {}
	for k, v in ipairs(i3k_db_emoji) do
		if v.groupType == self.emojiId then
			if self.emojiId == 4 then
				if self:isChallengeEmojiValid(k) then
			table.insert(emoji, {id = k, iconId = v.iconId})
				end
			else
				table.insert(emoji, {id = k, iconId = v.iconId})
			end
		end
	end
	local children = self.bqscroll:addChildWithCount("ui/widgets/ltbqt",6,#emoji)
	for i,e in ipairs(children) do
		e.vars.bqImg:setImage(g_i3k_db.i3k_db_get_icon_path(emoji[i].iconId))
		e.vars.btn:setTag(emoji[i].id)--图片的id
		e.vars.btn:onClick(self,self.onSendBq)
	end
end

function wnd_selectBq:reloadScroll()
	local gnScroll = self._layout.vars.scroll
	gnScroll:setBounceEnabled(false)
	local count = 8
	if self.chatUIID == eUIID_PigeonPostSend then
		count = 1
	end
	-- local children = gnScroll:addChildWithCount("ui/widgets/bqat", 7, count)
	-- for i,v in ipairs(children) do
	for i, v in ipairs(stateFunTable) do
		if i > count then break end
		local item = require("ui/widgets/bqat")()
		if stateFunTable[i] then
			item.vars.btn:setImage(stateFunTable[i].btnNormal, stateFunTable[i].btnPressed)
		end
		item.vars.btn:setTag(i + 1000)
		item.vars.btn:onClick(self, self.selectgn)
		if not stateFunTable[i].showLevel or stateFunTable[i].showLevel <= g_i3k_game_context:GetLevel() then
			gnScroll:addItem(item)
		end
	end
end

function wnd_selectBq:refresh(chatUIID)
	self.state = choose_face
	self.emojiId = 1
	self.chatUIID = chatUIID
	self:reloadScroll()
	self:refreshUI()
end

function wnd_selectBq:selectgn(sender)
	local tag = sender:getTag()-1000
	self.state = tag
	if self.state == choose_pos and (i3k_game_get_map_type() ~= g_FIELD or g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId) then
		return g_i3k_ui_mgr:PopupTipMessage("只能在大地图中发送座标")
	end
	self:refreshUI()
end

--消息发送
--表情
function wnd_selectBq:getMessageFace(sendMessage, id, guid)
	local message = "#" .. id
	sendMessage = sendMessage .. message
	return  sendMessage
end
--装备和道具
function wnd_selectBq:getMessageEquipAndTools(sendMessage, id, guid)
	local message = nil
	local prechar = "#I" .. id .. "," .. guid.."#"
	local name = g_i3k_db.i3k_db_get_common_item_name(id)
	message = "[" ..name.. "]"
	local oldName = self.equipList.equipName
	self.equipList.equipName = name
	self.equipList.msg = prechar
	if oldName and sendMessage ~= "" then
		sendMessage = string.gsub(sendMessage,  "%[" .. oldName .. "%]" ,message)
	else
		sendMessage = sendMessage .. message
	end
	return sendMessage
end
--对白
function wnd_selectBq:getMessageDialogue(sendMessage, id, guid)
	local message = i3k_db_chat_dialogue[id].txt
	local isHave = false
	for i,e in ipairs(i3k_db_chat_dialogue) do
		local str1 = e.txt
		local str2 = string.match(sendMessage,str1)
		if str2 then
			sendMessage = string.gsub(sendMessage,str1,message)
			isHave = true
			break;
		end
	end
	if not isHave then
		sendMessage = sendMessage .. message
	end
	return sendMessage
end
--申请
function wnd_selectBq:getMessageInvite(sendMessage, id, guid)
	local message = i3k_get_string(102005)
	self.chatUI:remmberInviteFlag(1)
	if not string.find(sendMessage, i3k_get_string(102007)) then
		sendMessage = sendMessage .. message
	end
	return sendMessage
end
function wnd_selectBq:getSendContent(id,guid)
	if guid == nil then
		guid = ""
	end
	self.chatUI = g_i3k_ui_mgr:GetUI(self.chatUIID)
	if not self.chatUI then
		return
	end

	local sendMessage = ""

	local editbox =  self.chatUI._layout.vars.editBox
	sendMessage = editbox:getText() or ""

	local sendType = self.state
	local prechar = nil
	if stateFunTable[sendType] and stateFunTable[sendType].getMessageFun then

		sendMessage = stateFunTable[sendType].getMessageFun(self, sendMessage, id, guid)
	end

	sendMessage = string.ltrim(sendMessage)
	editbox:setText(sendMessage)
end

function wnd_selectBq:onSendBq(sender)
	--发送表情
	local emojiData = g_i3k_game_context:getEmojiData()
	local itemId = i3k_db_emoji_cfg[self.emojiId].itemId
	local emojiId = self.emojiId
	local id = sender:getTag()
	if not emojiData[self.emojiId] and i3k_db_emoji_cfg[self.emojiId].openType == 1 then
		if g_i3k_game_context:GetCommonItemCanUseCount(itemId) < 1 then
			local callback = function(isOk)
				if isOk then
					local tmp = g_i3k_db.i3k_db_get_isShow_btn(i3k_db_emoji_cfg[emojiId].itemId)
					g_i3k_logic:OpenVipStoreUI(tmp.showType, tmp.isBound, tmp.id)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16364), callback)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, itemId, UseItemGetEmoji)
		end
	elseif i3k_db_emoji_cfg[self.emojiId].openType == 2 then
		if self:isChallengeEmojiValid(id) then
			self:getSendContent(id, 1)
		end
	else
		self:getSendContent(id,1)
	end
end

function wnd_selectBq:onSendEquip(sender,guid)
	--发送装备或者是道具
	local id = sender:getTag()
--	g_i3k_ui_mgr:ShowCommonItemInfo(id)
	self:getSendContent(id,guid)
	--道具、装备替换为原来的id
	self.chatUI = g_i3k_ui_mgr:GetUI(self.chatUIID)
	if self.chatUI then
		self.chatUI:setEquipTableValue(self.equipList)
	end
end

function wnd_selectBq:clearEquipList()
	self.equipList = {}
end

function wnd_selectBq:dialogue(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		self:getSendContent(tag)
	end
end

function wnd_selectBq:sendMsgProtocol(channel,roleId,content)
	local send = i3k_sbean.msg_send_req.new()
	send.type = channel
	send.id = roleId
	send.msg = content
	i3k_game_send_str_cmd(send, i3k_sbean.msg_send_res.getName())
end

function wnd_selectBq:setChallengeTaskData(tasks, emojiId, index)
	self._challengeTask = tasks
	self.emojiId = emojiId
	self:refreshEmojiScroll(index)
	self:refreshEmoji()
end
function wnd_selectBq:isChallengeEmojiValid(id)
	local emojiCfg = i3k_db_emoji[id]
	local challengeCfg = i3k_db_challengeTask[emojiCfg.challengeGroupId]
	return self._challengeTask[emojiCfg.challengeGroupId].reward >= #challengeCfg
end
function wnd_selectBq:closeCB(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SelectBq)
end

function wnd_create(layout, ...)
	local wnd = wnd_selectBq.new();
		wnd:create(layout, ...);

	return wnd;
end
