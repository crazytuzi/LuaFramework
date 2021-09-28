require "Core.Module.Common.UIComponent"
ChatItem = class("ChatItem", UIComponent);
function ChatItem:New()
	self = { };
	setmetatable(self, { __index = ChatItem });
	return self
end
function ChatItem:_Init()
	self:_InitReference();
	self:_InitListener();
end

function ChatItem:_InitReference()
	local trss = UIUtil.GetComponentsInChildren(self._gameObject, "Transform");
	self._trsTxt = UIUtil.GetChildInComponents(trss, "trsTxt");
	self._trsVoice = UIUtil.GetChildInComponents(trss, "trsVoice");
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtMsg1 = UIUtil.GetChildInComponents(txts, "txtMsg1");
	self._txtMsg1Smylog = self._txtMsg1:GetComponent("SymbolLabel")
	self._txtMsg2 = UIUtil.GetChildInComponents(txts, "txtMsg2");
	self._txtTime = UIUtil.GetChildInComponents(txts, "txtTime");
	local imgs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgHead = UIUtil.GetChildInComponents(imgs, "imgHead");
	self._imgType = UIUtil.GetChildInComponents(imgs, "imgType");
	self._imgVoiceBg = UIUtil.GetChildInComponents(imgs, "imgVoiceBg");
	self._imgRead = UIUtil.GetChildInComponents(imgs, "imgRead");
	self._imgBugle = UIUtil.GetChildInComponents(imgs, "bugle");
	self._imgTxtBg = UIUtil.GetChildInComponents(imgs, "msgBg");
	self._imgTxtBg2 = UIUtil.GetChildInComponents(imgs, "msgBg2");
    self._onClickVoiceBg = function(go) self:PlayVoice(self) end
    UIUtil.GetComponent(self._imgTxtBg2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickVoiceBg);
end
--[[
s_id:发送者id
s_name:发送者name
k:职业
t:类型（1：文字2：语音）
c:channel渠道（1：世界2：门派3：队伍）
msg：（1：文字聊天信息 2： 语音翻译语音文字）
url：语音地址
time:语音消息时长（秒为单位）
date:发送时间毫秒数
--]]
function ChatItem:InitData(data, isMy)
    self.data = data
    self._transform.name = data.date
    self.isMy = isMy
    self._imgHead.spriteName = PlayerManager.GetCareerIcon(data.k)
    if self._imgType then self._imgType.spriteName = ChatManager.GetSpriteNameForTag(data.tag) end
    local vc = ColorDataManager.Get_Vip(data.vip)
    self._txtName.text = vc  .. "[00ff00]" .. data.s_name
    self._txtName.color = ColorDataManager.Get_white()
    self._isTxt = data.t == 1
    if self._isTxt then
        self._trsTxt.gameObject:SetActive(true)
        self._trsVoice.gameObject:SetActive(false)
        if self._txtMsg1Width then  self._txtMsg1.width = self._txtMsg1Width
        else self._txtMsg1Width = self._txtMsg1.width end
        self._txtMsg1.text = data.msg
        local tw = self._txtMsg1.printedSize.x
        if isMy then
            self._imgTxtBg.width = tw + 65
            self._txtMsg1.width = tw + 10
        else
            self._txtMsg1.width = tw + 10 
        end
        self._txtMsg1Smylog:UpdateLabel()
    else
        self._trsTxt.gameObject:SetActive(false)
        self._trsVoice.gameObject:SetActive(true)
        data.timeS = data.time / 1000
        local time = math.floor(data.timeS) + 1
        self._txtTime.text = time .. "\""
        self._imgRead.gameObject:SetActive(not data.readed)
        local vw = 70 + (time / ChatManager.VoiceMaxLen) * 200
        self._imgVoiceBg.width = vw
        self:UpdataVoiceMsg(data, isMy)
    end
end
function ChatItem:UpdataVoiceMsg(data, isMy)
    self.data = data
    if self._txtMsg2Width then self._txtMsg2.width = self._txtMsg2Width
    else self._txtMsg2Width = self._txtMsg2.width end
    self._txtMsg2.text = data.msg
    local tw = self._txtMsg2.printedSize.x
    local vw = self._imgVoiceBg.width
    if isMy and string.len(data.msg) > 0 then
        self._txtMsg2.width = tw + 10
    end
    vw = vw + 55
    tw = tw + 55
    self._imgTxtBg2.width = vw > tw and vw or tw
end
function ChatItem:PlayVoiceAuto()
    if self.data == nil then return end
    if self.data.t == 1 or self.data.readed then
        if self.nextItem then self.nextItem:PlayVoiceAuto() end
        return
    end
    self:PlayVoice()
end
function ChatItem:PlayVoice()
    if ChatItem.currentVoice then
        if ChatItem.currentVoice == self then
            ChatManager.VoiceStop()
            ChatItem.currentVoice:_ClearTime()
            return
        end
        ChatItem.currentVoice:_ClearTime()
    end
    ChatItem.currentVoice = self
    ChatManager.VoicePlay(self.data.filePath,self.data.url)
    self.data.readed = true
    self._imgRead.gameObject:SetActive(not self.data.readed)
    self._bugleIndex = 1;
    ChatItem.clearRecordTime = Timer.New(function()
        if self._imgBugle then self._imgBugle.spriteName = "VoiceBugle" .. self._bugleIndex end
        self._bugleIndex = self._bugleIndex + 1
        if self._bugleIndex == 4 then self._bugleIndex = 1 end
    end, 0.2, -1, false)
    ChatItem.clearRecordTime:Start();
    ChatItem.clearRecordTime2 = Timer.New(function()
        ChatItem.clearRecordTime2 = nil
        self:_ClearTime()
        if self.nextItem then self.nextItem:PlayVoiceAuto() end
    end, self.data.timeS, 1, false)
    ChatItem.clearRecordTime2:Start();
end
function ChatItem:_SelectedPlayer()
    if self.data.s_id == PlayerManager.playerId then return end
    self.data.pid = self.data.s_id
    ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, self.data)
end
function ChatItem:SetPos(pos)
    if (not IsNil(self._transform)) then
        Util.SetLocalPos(self._transform, pos.x,pos.y,pos.z)

--        self._transform.localPosition = pos
    end
    return (self._isTxt and self._txtMsg1.height + 20 or self._txtMsg2.height + 43) + 5
end
function ChatItem:OnRecycle()
    self:_ClearTime() 
end
function ChatItem:SetVisible(val)
    self._gameObject:SetActive(val)
end

function ChatItem:_InitListener()
    self._selectedPlayer = function(go) self:_SelectedPlayer(self) end
    UIUtil.GetComponent(self._imgHead.transform.parent, "LuaUIEventListener"):RegisterDelegate("OnClick", self._selectedPlayer);
end

function ChatItem:_DisposeListener()
    UIUtil.GetComponent(self._imgHead.transform.parent, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._selectedPlayer = nil;
    UIUtil.GetComponent(self._imgTxtBg2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickVoiceBg = nil;
end
function ChatItem:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
    if not IsNil(self._gameObject)then
        GameObject.Destroy(self._gameObject)
        self._gameObject = nil
    end
end
function ChatItem:_ClearTime()
    ChatItem.currentVoice = nil
    if self._imgBugle then self._imgBugle.spriteName = "VoiceBugle3" end
    if ChatItem.clearRecordTime then
        ChatItem.clearRecordTime:Stop()
        ChatItem.clearRecordTime = nil
    end
    if ChatItem.clearRecordTime2 then
        ChatItem.clearRecordTime2:Stop()
        ChatItem.clearRecordTime2 = nil
    end
end
function ChatItem:_DisposeReference()
    self:_ClearTime() 
	self._txtName = nil;
	self._txtMsg1 = nil;
	self._txtMsg1Smylog = nil;
	self._txtMsg2 = nil;
	self._txtTime = nil;
	self._imgHead = nil;
	self._imgType = nil;
	self._imgVoiceBg = nil;
	self._imgRead = nil;  
    self.nextItem = nil 
    self.data = nil
end
