--
-- @Author: chk
-- @Date:   2018-09-06 12:01:39
--
ChatItemInMainSettor = ChatItemInMainSettor or class("ChatItemInMainSettor",BaseItem)
local ChatItemInMainSettor = ChatItemInMainSettor


ChatItemInMainSettor.__cache_count = 5
function ChatItemInMainSettor:ctor(parent_node,layer)
	self.abName = "chat"
	self.assetName = "ChatItemInMainUI"
	self.layer = layer

	self.count = 0
	self.chatMsg = nil
	self.model = ChatModel:GetInstance()
	ChatItemInMainSettor.super.Load(self)
end

function ChatItemInMainSettor:__clear()
    ChatItemInMainSettor.super.__clear(self)
end

function ChatItemInMainSettor:__reset(...)
    ChatItemInMainSettor.super.__reset(self, ...)
    SetSizeDelta(self.TextRectTra, self.old_sizedeltaX, self.old_sizedeltaY, 0)
    SetSizeDelta(self.TextRectTra2, self.old_sizedeltaX2, self.old_sizedeltaY2, 0)
    SetLocalScale(self.transform, 1, 1, 1)
end

function ChatItemInMainSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
	end


	if self.lua_link_text then
		self.lua_link_text:destroy()
		self.lua_link_text = nil
	end
end

function ChatItemInMainSettor:LoadCallBack()
	self.nodes = {
		"from",
		"Text",
		"Content",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.itemRectTra = self.transform:GetComponent('RectTransform')
	self.fromImg = GetImage(self.from)
	--self.TextTxt = GetText(self.Text)
	self.ContentText = GetText(self.Content)
	self.TextRectTra = self.Text:GetComponent('RectTransform')
	self.TextRectTra2 = self.Content:GetComponent('RectTransform')
	self.old_sizedeltaX = GetSizeDeltaX(self.TextRectTra)
    self.old_sizedeltaY = GetSizeDeltaY(self.TextRectTra)
    self.old_sizedeltaX2 = GetSizeDeltaX(self.TextRectTra2)
    self.old_sizedeltaY2 = GetSizeDeltaY(self.TextRectTra2)
	if self.need_load_end then
		self:SetInfo(self.chatMsg)
	end
end

function ChatItemInMainSettor:AddEvent()
	local function call_back()
		if self.chatMsg ~= nil then
			local channel_id = self.chatMsg.channel_id
			channel_id = (channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_SYS and enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD or channel_id)
			GlobalEvent:Brocast(ChatEvent.OpenChatPanel, channel_id)
		end
	end
	AddClickEvent(self.transform.gameObject,call_back)
end

function ChatItemInMainSettor:InitChatItemScp()
	self.inlineText  = GetLinkText(self.Text) --self.Text:GetComponent('InlineText')
	self.inlineText:SetObj(self.from.transform)
	--self.inlineText.inlineManager = self.model.inlineMgrMainUIScp
	--self.ChatItemScp = self.gameObject:GetComponent('ChatItem')
	--self.ChatItemScp.inlineText = self.inlineText
	--self.ChatItemScp.itemRect = self.itemRectTra

	--self.inlineText:AddClickListener(handler(self,self.ClickItemEvent))
end

function ChatItemInMainSettor:ClickItemEvent(name,id)
	if string.find(id,"team_id") ~= nil then
		local teamTbl = string.split(id,"=")
		if table.nums(teamTbl) == 2 then
			TeamController:GetInstance():RequestApply(teamTbl[2])
		end
	elseif string.find(id,"mapPos") ~= nil then
		local mapPositionTbl = string.split(name,",")
		if table.nums(mapPositionTbl) == 3 then
			OperationManager.GetInstance():TryMoveToPosition(tonumber(mapPositionTbl[1]),nil,
					Vector2(tonumber(mapPositionTbl[2]), tonumber(mapPositionTbl[3])))
		end
	else
		ChatController.GetInstance():RequestGoodsInfo(tonumber(id))
	end
end

function ChatItemInMainSettor:SetData(data)

end

function ChatItemInMainSettor:SetInfo(chatMsg,scrollRect)
	self.chatMsg = chatMsg
	local role = chatMsg.sender or {}
	if self.is_loaded then
		self:InitChatItemScp()

		if self.fromImg ~= nil then
			if chatMsg.channel_id == ChatModel.AreaChannel and Config.db_area_scene[scene] ~= nil then
				lua_resMgr:SetImageTexture(self, self.fromImg, "chat_image", "chat_cng_" .. chatMsg.scene, true)
			else
				lua_resMgr:SetImageTexture(self, self.fromImg, "chat_image", "chat_cng_" .. chatMsg.channel_id, true)
			end

		end
		local content = ChatColor.FormatMsg(chatMsg.content)
		local has_emoji = false
        for emojiName in string.gmatch(content, "【(e_%d+)】") do
            local images = Config.db_emoji[emojiName].images
            content = string.gsub(content, "【"..emojiName.."】", string.format("<quad name=emoji:%s size=36 width=1 />", images))
        	has_emoji = true
        end
        local saiziNum = string.match(content, "Ako(%d)Ako")
        if saiziNum ~= nil then
       		content = string.gsub(content, "Ako%dAko", string.format("<color=#50ddea>[Dice-%d]</color>", saiziNum))
       	end
		--lua_resMgr:SetImageTexture(self, self.fromImg, "chat_image", "chat_cng_" .. chatMsg.channel_id, false);
		--self.fromTxt.text = channelName
		if not self.lua_link_text then
			self.lua_link_text = LuaLinkImageText(self, self.inlineText, nil, nil)
		end
        self.lua_link_text:clear()
        self.lua_link_text:SetSprites(self.model.emoji_list)
        local name = role.name or ""
        local content2 = "" 
        if chatMsg.type_id == 2 then
        	content = "[Voice]"
        end
	    if name ~= "" then
	       	content2 = "<color=#ff9600>[" .. name .. "]:</color>" .. content
	    else
	       	content2 = content
	    end
	    content2 = ChatColor.ReplaceMainColor(content2)	
	    if has_emoji then
	    	SetVisible(self.Text, true)
			SetVisible(self.Content, false)
			self.inlineText.text = content2
		else
			SetVisible(self.Text, false)
			SetVisible(self.Content, true)
			content2 = string.gsub(content2, "<a.->", "")
			content2 = string.gsub(content2, "</a>", "")
			self.ContentText.text = content2
		end
		self.need_load_end = false
		self:SetItemSize(has_emoji)
	else
		self.need_load_end = true
		self.scrollRect = scrollRect
	end
end

function ChatItemInMainSettor:SetItemSize(has_emoji)
	if has_emoji then
		local textHeight = self.inlineText.preferredHeight
		textHeight = (textHeight<23 and 23 or textHeight)
		self.count = self.count + 1
		self.TextRectTra.sizeDelta = Vector2(self.TextRectTra.sizeDelta.x,textHeight)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,textHeight)
		self.height = textHeight+10
	else
		local textHeight = self.ContentText.preferredHeight
		textHeight = (textHeight<23 and 23 or textHeight)
		self.count = self.count + 1
		self.TextRectTra2.sizeDelta = Vector2(self.TextRectTra2.sizeDelta.x,textHeight)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,textHeight)
		self.height = textHeight+10
	end


	GlobalEvent:Brocast(ChatEvent.CreateItemEndInMain,self.chatMsg, self.height)
end
