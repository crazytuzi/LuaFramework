require "Core.Module.Common.Panel"
require "Core.Module.Chat.ChatProxy"
require "Core.Module.Common.ChatItemSimple"
ChatPanel = class("ChatPanel", Panel);

-- local ScrollPos = Vector3(0,15,0)
local _Insert = table.insert
local _Rmove = table.remove
function ChatPanel:New()
    self = { };
    setmetatable(self, { __index = ChatPanel });
    self.Items = { }

    self.ItemSyss = { }
    self.ItemMys = { }
    self.ItemOthers = { }

    self.ItemTemps = { }
    return self
end
function ChatFacePanel:IsPopup() return false end

function ChatPanel:SetChannel(channel, compare)
    -- logTrace("SetChannel:" .. tostring(channel) .. type(channel).. tostring(channel == ChatChannel.world))
    if compare and ChatProxy.channel == channel then return end
    ChatProxy.channel = channel
    local msgs = nil
--    if channel == ChatChannel.world then
--        msgs = ChatManager.GetMsgs(ChatProxy.worldShow)
--    else
        msgs = ChatManager.GetMsg(channel)
--    end
    self._last = nil
    self:UpdateMsg(msgs)

    local canSpeak = ChatManager.CanSpeak(channel)
    -- logTrace("SetChannel:" .. tostring(canSpeak))
    if canSpeak then
        self._goInput:SetActive(true)
        self._goWaring:SetActive(false)
    else
        self._goInput:SetActive(false)
        self._goWaring:SetActive(true)
        self._goWorld:SetActive(false)
        self._goActive:SetActive(false)
        self._goTeam:SetActive(false)
        self._goSchool:SetActive(false)
        self._goSystem:SetActive(false)
        if channel == ChatChannel.world then
            UIUtil.GetChildByName(self._goWorld,"UILabel","Label").text = ChatManager.GetNoLevelMsg(ChatChannel.world)
            return self._goWorld:SetActive(true)
        elseif channel == ChatChannel.active then
            return self._goActive:SetActive(true)
        elseif channel == ChatChannel.team then
            return self._goTeam:SetActive(true)
        elseif channel == ChatChannel.school then
            return self._goSchool:SetActive(true)
        elseif channel == ChatChannel.system then
            return self._goSystem:SetActive(true)
        end
    end
end
function ChatPanel:_ClearMsg()
    for i, v in ipairs(self.Items) do
        self:_RecycleItem(v)
        v:SetVisible(false)
    end
    self.Items = { }
end
function ChatPanel:_DisponeMsg()
    for i, v in ipairs(self.Items) do v:Dispose() end
    self.Items = { }
end
function ChatPanel:_RecycleItem(v)
    if v.__cname == "ChatItem" then
        if v.isMy then _Insert(self.ItemMys, v) else _Insert(self.ItemOthers, v) end
    else
        _Insert(self.ItemSyss, v)
    end
    v:OnRecycle()
end
function ChatPanel:UpdateMsg(msgs)
    self:_ClearMsg()
    for i, v in ipairs(msgs) do
        self:AddMsg(v)
    end
    Timer.New( function() self:UpdateReset() end, 0.01, 1):Start()
end
function ChatPanel:AddMsg(msg)
    -- logTrace("____AddMsg___"..msg.msg)
    local c = nil
    if ChatManager.IsPlayerMsg(msg) then
        local myMsg = msg.s_id == PlayerManager.playerId
        local tt = myMsg and self.ItemMys or self.ItemOthers
        local len = #tt
        if len == 0 then
            c = ChatItem:New()
            local cv = Resourcer.Clone(myMsg and self._chatMyItemGo or self._chatItemGo, self._trsScrollView)
            c:Init(cv.transform)
        else
            c = _Rmove(tt, len)
        end
        c:SetVisible(true)
        c:InitData(msg, myMsg)
        if not myMsg then
            if self._last then self._last.nextItem = c end
            self._last = c
        end
    else
        local len = #self.ItemSyss
        if len == 0 then
            local itemv = Resourcer.Clone(self._chatItemSimpleGo, self._trsScrollView)
            c = ChatItemSimple:New()
            c:Init(itemv.transform)
        else
            c = _Rmove(self.ItemSyss, len)
        end
        c:SetVisible(true)
        c:InitData(msg)
    end
    _Insert(self.Items, c)
end
function ChatPanel:ChatReceive(data)
    -- print(data.s_id , PlayerManager.playerId ,  data.msg ,  self._sendText)
    if data.s_id == PlayerManager.playerId and data.msg == self._sendText then self._input.value = "" end
    if self._draging then
        _Insert(self.ItemTemps, data)
        return
    end
    self:AddData(data)
    self:UpdateReset()
end
function ChatPanel:AddData(data)
    if data.c ~= ChatProxy.channel then return end
    if ChatManager.isFirstMsg(data) then
        if #self.Items > ChatManager.MsgMaxUINum then
            self:_RecycleItem(_Rmove(self.Items, 1))
        end
        self:AddMsg(data)
    else
        -- 第二次语音翻译
        for _, value in pairs(self.Items) do
            if ChatManager.CheckSameMsg(value.data, data) then
                value:UpdataVoiceMsg(data, data.s_id == PlayerManager.playerId)
                break
            end
        end
    end
end
function ChatPanel:UpdateReset(data)
    if not self._uiTable then return end
    self._uiTable:Reposition()
    self._scrollView:ResetPosition()
    Util.SetLocalPos(self._trsScrollView, 0, 15, 0)

--    self._trsScrollView.localPosition = ScrollPos
end

function ChatPanel:Hide()
    self._gameObject:SetActive(false)
    self.visible = false
    self._draging = false
    MessageManager.RemoveListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, ChatPanel.ChatReceive);
end
function ChatPanel:Show(channel)
    self._gameObject:SetActive(true)
    self.visible = true
    if channel == nil then channel = ChatChannel.world end
    self:SetChannel(channel)
    if channel == ChatChannel.world then
        self._btnWorld:GetComponent("UIToggle").value = true
    elseif channel == ChatChannel.active then
        self._btnActive:GetComponent("UIToggle").value = true
    elseif channel == ChatChannel.team then
        self._btnTeam:GetComponent("UIToggle").value = true
    elseif channel == ChatChannel.school then
        self._btnSchool:GetComponent("UIToggle").value = true
    elseif channel == ChatChannel.system then
        self._btnSystem:GetComponent("UIToggle").value = true
    end
    --未完成的发送
    if ChatManager.sendText then
        self._input.value = ChatManager.sendText
        ChatManager.sendText = nil
    end
    MessageManager.RemoveListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, ChatPanel.ChatReceive);
    MessageManager.AddListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, ChatPanel.ChatReceive, self);
end

function ChatPanel:AddFace(face)
    -- logTrace("SelectFace:face=" .. face)
    self._input.value = self._input.value .. "#" .. face .. "#"
end
function ChatPanel:ShowUpDow(up)
    -- logTrace("ShowUpDow:up=" .. tostring(face))
    self._imgBg.height = up and self._imgBg.height - ChatFacePanel.Height or self._imgBg.height + ChatFacePanel.Height
end

function ChatPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ChatPanel:_InitReference()
    local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
    self._imgBg = UIUtil.GetChildInComponents(imgs, "imgBg");
    self._imgHistroy = UIUtil.GetChildInComponents(imgs, "imgHistroy");

    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    -- for i = 0 ,btns.Length-1 do logTrace(btns[i].name) end
    self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
    self._btnWorld = UIUtil.GetChildInComponents(btns, "btnWorld");
    self._btnTeam = UIUtil.GetChildInComponents(btns, "btnTeam");
    self._btnSchool = UIUtil.GetChildInComponents(btns, "btnSchool");
    self._btnActive = UIUtil.GetChildInComponents(btns, "btnActive");
    self._btnSystem = UIUtil.GetChildInComponents(btns, "btnSystem");
    ChatPanel._btnVoice = UIUtil.GetChildInComponents(btns, "btnVoice");
    ChatPanel._btnVoice.gameObject:SetActive(ChatManager.UseVoice)
    self._btnHistroy = UIUtil.GetChildInComponents(btns, "btnHistroy");
    self._btnFace = UIUtil.GetChildInComponents(btns, "btnFace");
    self._btnSend = UIUtil.GetChildInComponents(btns, "btnSend");
    self._btnHistroy = UIUtil.GetChildInComponents(btns, "btnHistroy");
    self._btnHistroyItem1 = UIUtil.GetChildInComponents(btns, "btnHistroyItem1");
    self._btnHistroyItem2 = UIUtil.GetChildInComponents(btns, "btnHistroyItem2");
    self._btnHistroyItem3 = UIUtil.GetChildInComponents(btns, "btnHistroyItem3");
    self._btnHistroyItem4 = UIUtil.GetChildInComponents(btns, "btnHistroyItem4");
    self._btnHistroyItem5 = UIUtil.GetChildInComponents(btns, "btnHistroyItem5");
    self._btnJoin = UIUtil.GetChildInComponents(btns, "btnJoin");

    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsScrollView = UIUtil.GetChildInComponents(trss, "trsScrollView");
    self._trsHistroy = UIUtil.GetChildInComponents(trss, "trsHistroy").gameObject;
    self._trsInput = UIUtil.GetChildInComponents(trss, "trsInput");
    self._trsHistroyMask = UIUtil.GetChildInComponents(trss, "trsHistroyMask");
    self._goInput = UIUtil.GetChildInComponents(trss, "trsInputBar").gameObject;
    self._goWaring = UIUtil.GetChildInComponents(trss, "trsWaringBar").gameObject;
    self._goWorld = UIUtil.GetChildInComponents(trss, "trsWorld").gameObject;
    self._goTeam = UIUtil.GetChildInComponents(trss, "trsTeam").gameObject;
    self._goActive = UIUtil.GetChildInComponents(trss, "trsActive").gameObject;
    self._goSchool = UIUtil.GetChildInComponents(trss, "trsSchool").gameObject;
    self._goSystem = UIUtil.GetChildInComponents(trss, "trsSystem").gameObject;

    self._scrollView = UIUtil.GetComponent(self._trsScrollView, "UIScrollView");
    self._uiTable = UIUtil.GetComponent(self._trsScrollView, "UITable");
    self._input = UIUtil.GetComponent(self._trsInput, "UIInput")
    ChatProxy.InputText = self._input.value

    self._chatItemGo = UIUtil.GetChildByName(self._trsScrollView, "UI_ChatItem").gameObject
    self._chatItemGo:SetActive(false)
    self._chatMyItemGo = UIUtil.GetChildByName(self._trsScrollView, "UI_ChatMyItem").gameObject
    self._chatMyItemGo:SetActive(false)
    self._chatItemSimpleGo = UIUtil.GetChildByName(self._trsScrollView, "trsChatItem").gameObject
    self._chatItemSimpleGo:SetActive(false)

    self._scrollView.onDragStarted = function() self:_OnDragStarted() end
    self._scrollView.onDragFinished = function() self:_OnDragFinished() end
end
function ChatPanel:_OnDragFinished()
    -- log("___________OnDragFinished")
    self._dragTimer = Timer.New( function()
        -- log("_OnDragFinished__________")
        self._draging = false
        local hasUpdate = false
        for i, data in ipairs(self.ItemTemps) do
            self:AddData(data)
            hasUpdate = true
        end
        if hasUpdate then
            self.ItemTemps = { }
            self:UpdateReset()
        end
    end , 3, 1, false):Start()
end
function ChatPanel:_OnDragStarted()
    -- log("__________OnDragStarted")
    self._draging = true
    if self._dragTimer then self._dragTimer:Stop() end
end

function ChatPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnWorld = function(go) self:SetChannel(ChatChannel.world, true) end
    UIUtil.GetComponent(self._btnWorld, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnWorld);
    self._onClickBtnTeam = function(go) self:SetChannel(ChatChannel.team, true) end
    UIUtil.GetComponent(self._btnTeam, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTeam);
    self._onClickBtnSchool = function(go) self:SetChannel(ChatChannel.school, true) end
    UIUtil.GetComponent(self._btnSchool, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSchool);
    self._onClickBtnActive = function(go) self:SetChannel(ChatChannel.active, true) end
    UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);
    self._onClickBtnSys = function(go) self:SetChannel(ChatChannel.system, true) end
    UIUtil.GetComponent(self._btnSystem, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSys);
    self._onClickBtnHistroy = function(go) self:_OnClickBtnHistroy(self) end
    UIUtil.GetComponent(self._btnHistroy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroy);
    self._onClickBtnFace = function(go) self:_OnClickBtnFace(self) end
    UIUtil.GetComponent(self._btnFace, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFace);
    self._onClickBtnSend = function(go) self:_OnClickBtnSend(self) end
    UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSend);
    self._onClickHistroyMask = function(go) self:_OnClickHistroyMask(go) end
    UIUtil.GetComponent(self._trsHistroyMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHistroyMask);
    self._onClickBtnHistroyItem = function(go) self:_OnClickBtnHistroyItem(go) end
    UIUtil.GetComponent(self._btnHistroyItem1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroyItem);
    UIUtil.GetComponent(self._btnHistroyItem2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroyItem);
    UIUtil.GetComponent(self._btnHistroyItem3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroyItem);
    UIUtil.GetComponent(self._btnHistroyItem4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroyItem);
    UIUtil.GetComponent(self._btnHistroyItem5, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnHistroyItem);
    UIUtil.GetComponent(self._btnJoin, "LuaUIEventListener"):RegisterDelegate("OnClick", self._OnClickBtnJoin);
    if ChatManager.UseVoice then
    local ll = UIUtil.GetComponent(ChatPanel._btnVoice, "LuaUIEventListener")
    ll:RegisterDelegate("OnPress", ChatPanel._OnPress);
    ll:RegisterDelegate("OnDragOver", ChatPanel._OnDragOver);
    ll:RegisterDelegate("OnDragOut", ChatPanel._OnDragOut);
    end
end
function ChatPanel._OnPress(go, press)
    -- logTrace("ChatPanel._OnPress:btn=" .. ",press=" .. tostring(press))
    if press then
        local flg = ChatManager.VoiceRecordStart(ChatProxy.channel)
        if not flg then return end
        ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_VOICE_PANEL)
        ChatPanel._currentBtn = ChatPanel._btnVoice.gameObject
        ChatPanel.clearRecordTime = Timer.New( function()
            ChatPanel.clearRecordTime = nil
            -- logTrace(Input.touchCount.. tostring(Input.GetMouseButton(0)) .. ":" ..tostring(ChatPanel._currentBtn))
            if Input.touchCount < 1 and not Input.GetMouseButton(0) then
                ChatPanel._EndRecord(true)
            end
        end , 1, 1, false)
        ChatPanel.clearRecordTime:Start();
        ChatPanel.clearRecordTime2 = Timer.New( function()
            ChatPanel.clearRecordTime2 = nil
            ChatPanel._EndRecord(false)
        end , ChatManager.VoiceMaxLen, 1, true)
        ChatPanel.clearRecordTime2:Start();
    else
        ChatPanel._EndRecord(UICamera.currentTouch.current ~= ChatPanel._currentBtn)
    end
end
function ChatPanel._EndRecord(_cancel)
    -- logTrace("_EndRecord:_cancel=" .. tostring(_cancel))
    if ChatPanel._currentBtn == nil then return end
    ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_VOICE_PANEL)
    ChatManager.VoiceRecordStop(_cancel)
    ChatPanel._currentBtn = nil
    if ChatPanel.clearRecordTime then
        ChatPanel.clearRecordTime:Stop()
        ChatPanel.clearRecordTime = nil
    end
    if ChatPanel.clearRecordTime2 then
        ChatPanel.clearRecordTime2:Stop()
        ChatPanel.clearRecordTime2 = nil
    end
end
function ChatPanel._OnDragOver(go)
    --- logTrace("_OnOnDragOver:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == ChatPanel._currentBtn))
    if ChatPanel._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 1)
end
function ChatPanel._OnDragOut(go)
    -- logTrace("_OnDragOut:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == ChatPanel._currentBtn))
    if ChatPanel._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 2)
end

function ChatPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_PANEL)
end
function ChatPanel:_OnClickBtnVoice()
    ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_VOICE_PANEL)
end

function ChatPanel:_OnClickBtnHistroy()
    -- logTrace("_OnClickBtnHistroy:" .. tostring(self._trsHistroy))
    self._trsHistroy:SetActive(true)
    local hmsgs = ChatProxy.GetMyHistroy()
    local len = #hmsgs
    self._imgHistroy.height = len * 50 + 48
    -- logTrace(self._imgHistroy.height .. "___" .. len)
    self:_SetHistroyItem(self._btnHistroyItem1, len > 0 and hmsgs[1] or nil)
    self:_SetHistroyItem(self._btnHistroyItem2, len > 1 and hmsgs[2] or nil)
    self:_SetHistroyItem(self._btnHistroyItem3, len > 2 and hmsgs[3] or nil)
    self:_SetHistroyItem(self._btnHistroyItem4, len > 3 and hmsgs[4] or nil)
    self:_SetHistroyItem(self._btnHistroyItem5, len > 4 and hmsgs[5] or nil)
end
function ChatPanel:_SetHistroyItem(btnHistroyItem, text)
    -- logTrace(tostring(btnHistroyItem) .. tostring(text))
    local go = btnHistroyItem.gameObject
    self._txtHistroyMsg = UIUtil.GetChildByName(go, "UILabel", "txtHistroyMsg");
    if text == nil then
        go:SetActive(false)
    else
        self._txtHistroyMsg.text = text
        go:SetActive(true)
    end
end
function ChatPanel:_OnClickBtnHistroyItem(go)
    self._txtHistroyMsg = UIUtil.GetChildByName(go, "UILabel", "txtHistroyMsg");
    -- logTrace("_OnClickBtnHistroyItem:".. go.name .. tostring(self._txtHistroyMsg))
    self._input.value = self._txtHistroyMsg.text
    self._trsHistroy:SetActive(false)
end
function ChatPanel:_OnClickHistroyMask(go)
    self._trsHistroy:SetActive(false)
end

function ChatPanel:_OnClickMask()
    -- logTrace("_OnClickMask:" .. tostring(self._trsHistroy))
    if self._trsHistroy.activeSelf then
        self._trsHistroy:SetActive(false)
    else
        ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_PANEL)
    end
end
function ChatPanel:_OnClickBtnFace()
    ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_FACE_PANEL)
    if self._input.value == ChatProxy.InputText then self._input.value = "" end
end
function ChatPanel:_OnClickBtnSend()
    self._sendText = string.trim(self._input.value)
    -- logTrace(self._sendText .. string.len(self._sendText))
    if string.len(self._sendText) == 0 then return end
    ChatProxy.SendMsg(self._sendText)
end
function ChatPanel:_OnClickBtnJoin()
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_REQLIST_PANEL)
end

function ChatPanel:_Dispose()
    local sendText = string.trim(self._input.value)
    if string.len(sendText) ~= 0 then ChatManager.sendText = sendText end
    self:_DisposeListener();
    self:_DisposeReference();
end
function ChatPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnWorld, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnWorld = nil;
    UIUtil.GetComponent(self._btnTeam, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTeam = nil;
    UIUtil.GetComponent(self._btnSchool, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSchool = nil;
    UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnActive = nil;
    UIUtil.GetComponent(self._btnSystem, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSys = nil;
    UIUtil.GetComponent(self._btnHistroy, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnHistroy = nil;
    UIUtil.GetComponent(self._btnFace, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFace = nil;
    UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSend = nil;
    UIUtil.GetComponent(self._btnHistroyItem1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnHistroyItem2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnHistroyItem3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnHistroyItem4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnHistroyItem5, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnHistroyItem = nil;
    if ChatManager.UseVoice then
    local ll = UIUtil.GetComponent(ChatPanel._btnVoice, "LuaUIEventListener")
    ll:RemoveDelegate("OnPress");
    ll:RemoveDelegate("OnDragOver");
    ll:RemoveDelegate("OnDragOut");
    end
    UIUtil.GetComponent(self._btnJoin, "LuaUIEventListener"):RemoveDelegate("OnClick")
    MessageManager.RemoveListener(ChatManager, ChatManager.CHAT_RECEIVE_DATA, ChatPanel.ChatReceive);
end
function ChatPanel:_DisposeReference()
    self:_DisponeMsg()
    self._btnClose = nil;
    self._btnWorld = nil;
    self._btnTeam = nil;
    self._btnSchool = nil;
    self._btnActive = nil;
    self._btnSystem = nil;
    ChatPanel._btnVoice = nil;
    self._btnHistroy = nil;
    self._btnFace = nil;
    self._btnSend = nil;
    self._imgBg = nil;
    self._imgHistroy = nil;

    self._trsScrollView = nil;
    
    self._uiTable = nil;
    self._chatItemGo = nil
    self._chatMyItemGo = nil

    self._trsHistroy = nil;
    self._input = nil
    if ChatPanel._currentBtn ~= nil then
        ChatPanel._EndRecord(true)
    end
    if self._dragTimer then self._dragTimer:Stop() self._dragTimer = nil end
    self.visible = false

    self._scrollView.onDragStarted:Destroy();
    self._scrollView.onDragFinished:Destroy();

    self._scrollView = nil
end
