GroupChat = class("GroupChat")
GroupChat.__index = GroupChat

local nMaxChatStrNum = 50

--local szTableName = ""--表名

local tbChatList = {} --聊天记录
local nMaxSave = 100 --缓存聊天记录数

function GroupChat:deleteChatList()
	tbChatList = {}
end

function GroupChat:init(widget)
	g_Hero:setBubbleNotify(macro_pb.NT_GuildChat, 0)
	self.rootWidget = widget
	local Button_Send = tolua.cast(self.rootWidget:getChildByName("Button_Send"), "Button")
	Button_Send:setTouchEnabled(true)
	Button_Send:addTouchEventListener(handler(self, self.onSend))

	self:initTextInput()
	self:initListView()
end

function GroupChat:initTextInput()
	local Image_Input = tolua.cast(self.rootWidget:getChildByName("Image_Input"), "ImageView")
	local TextField_Input = tolua.cast(Image_Input:getChildByName("TextField_Input"), "TextField")
	local Label_ChatNum = tolua.cast(Image_Input:getChildByName("Label_ChatNum"), "Label")
	self.Label_ChatNum = Label_ChatNum
	Label_ChatNum:setText("0/"..nMaxChatStrNum)
	--TextField_Input:setTouchSize(CCSizeMake(nTouchSizeWidth, 0))
	TextField_Input:setMaxLength(300)
	TextField_Input:setTouchEnabled(true)
	local function textFieldEvent(pSender, eventType)
		if eventType == ccs.TextFiledEventType.insert_text or eventType == ccs.TextFiledEventType.delete_backward then
			local mString = TextField_Input:getStringValue()
			local InputNum,maxString = stringNum(mString,nMaxChatStrNum)
			if InputNum >= nMaxChatStrNum then
				Label_ChatNum:setText(nMaxChatStrNum.."/"..nMaxChatStrNum)
				TextField_Input:setText(maxString)
				return
			end 
			Label_ChatNum:setText(InputNum.."/"..nMaxChatStrNum)
		end
	end
	TextField_Input:addEventListenerTextField(textFieldEvent)
	self.TextField_Input = TextField_Input
end

function GroupChat:initListView()
	self.ListView_GroupChat = tolua.cast(self.rootWidget:getChildByName("ListView_GroupChat"), "ListViewEx")
	local Panel_GroupChatItem = self.ListView_GroupChat:getChildByName("Panel_GroupChatItem")
	registerListViewEvent(self.ListView_GroupChat, Panel_GroupChatItem, handler(self, self.updateListViewItem))
	self.ListView_GroupChat:updateItems(#tbChatList, math.max(1, #tbChatList - 7))
end

function GroupChat:updateListViewItem(panel, nIndex)
	local Label_Name = tolua.cast(panel:getChildByName("Label_Name"), "Label")
	Label_Name:setText("["..tbChatList[nIndex].role_name.."]:")
	local text = tbChatList[nIndex].chat_content
	if macro_pb.GuildChatType_Member == tbChatList[nIndex].chat_type then
		Label_Name:setColor(ccc3(255,0,255))
	else
		Label_Name:setColor(ccc3(240,203,29))
        local pos = string.find(text, "%[")
        if pos then
		    text = _T(string.sub(text, 1, pos - 1))..string.sub(text, pos, string.len(text))
		else
			text = _T(text)
		end
	end

	local Label_Dialogure = tolua.cast(Label_Name:getChildByName("Label_Dialogure"), "Label")
	Label_Dialogure:setText(text.."("..os.date("%X",tbChatList[nIndex].time_at)..")")
	Label_Dialogure:setAnchorPoint(ccp(0, 1))
	Label_Dialogure:setPosition(ccp(Label_Name:getSize().width, 15))
end

function GroupChat:destroy()
	self.ListView_GroupChat = nil
end

--保存聊天记录
function GroupChat:saveChatInfo(tbInfo)
	table.insert(tbChatList, tbInfo)
	if #tbChatList > 100 then
		table.remove(tbChatList, 1)
	end
end

-----------------------------收发消息--------------------

function Game_Group:offlineChatRequest(bSend)
	if not self.bFirst then
		self.bFirst = true
		if bSend then
			g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_CHAT_INFO_REQUEST, nil)
		end
	end
end

--发送
function GroupChat:onSend(pSender, eventType)
	if ccs.TouchEventType.ended ==  eventType then
		local content = self.TextField_Input:getStringValue()
		if "" == content then
			return 
		end

		local msg = zone_pb.GuildChatRequest()
		msg.chat_content = self.TextField_Input:getStringValue()
		g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_CHAT_REQUEST, msg)
		self.TextField_Input:setText("")
		self.Label_ChatNum:setText("0/"..nMaxChatStrNum)
	end
end

--聊天消息
function GroupChat:chatResponse(tbMsg)
	local msg = zone_pb.GuildChatResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	local info = msg.chat_info
	if not info then
		cclog("chatlist is null")
		return
	end

	GroupChat:saveChatInfo(info)
	if g_WndMgr:isVisible("Game_Group") and self.ListView_GroupChat then
		self.ListView_GroupChat:updateItems(#tbChatList, math.max(1, #tbChatList - 7))
	else
		g_Hero:addBubbleNotify(macro_pb.NT_GuildChat, 1)
		local HomeWnd = g_WndMgr:getWnd("Game_Home")
		if HomeWnd ~= nil then
			HomeWnd:addNoticeAnimation_Group()
		end
	end
end

--离线聊天消息
function GroupChat:offlineChatResponse(tbMsg)
	local msg = zone_pb.GuildChatInfoResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	if not msg.chat_list then
		cclog("chatlist is null")
		return
	end
	for k,v in ipairs(msg.chat_list) do
		GroupChat:saveChatInfo(v)
	end
	if g_WndMgr:isVisible("Game_Group") and self.ListView_GroupChat then
		self.ListView_GroupChat:updateItems(#tbChatList, math.max(1, #tbChatList - 7))
	else
		g_Hero:addBubbleNotify(macro_pb.NT_GuildChat, 1)
		local HomeWnd = g_WndMgr:getWnd("Game_Home")
		if HomeWnd ~= nil then
			HomeWnd:addNoticeAnimation_Group()
		end
	end
end

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GUILD_CHAT_INFO_RESPONSE,handler(GroupChat,GroupChat.offlineChatResponse))
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GUILD_CHAT_RESPONSE,handler(GroupChat,GroupChat.chatResponse))