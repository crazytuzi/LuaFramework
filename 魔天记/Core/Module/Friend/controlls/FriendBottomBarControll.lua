

FriendBottomBarControll = class("FriendBottomBarControll");
FriendBottomBarControll._cancel = false
function FriendBottomBarControll:New()
    self = { };
    setmetatable(self, { __index = FriendBottomBarControll });
    return self
end

function FriendBottomBarControll:Init(gameObject)
    self.gameObject = gameObject;

    self.btn_addFriend = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_addFriend");
    self.btn_sendChatMsg = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_sendChatMsg");
    FriendBottomBarControll.btn_chatMc = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_chatMc");
    FriendBottomBarControll.btn_chatMc.gameObject:SetActive(ChatManager.UseVoice)
    self.btn_face = UIUtil.GetChildByName(self.gameObject, "UIButton", "btn_face");

    self.friend_numTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "friend_numTxt");

    self.txtChatInput = UIUtil.GetChildByName(self.gameObject, "Transform", "txtChatInput");
    self.txtChatInputTxt = UIUtil.GetChildByName(self.gameObject, "UIInput", "txtChatInput");
    self.chatTxt = UIUtil.GetChildByName(self.txtChatInput, "UILabel", "chatTxt");

    self._onClickbtn_addFriend = function(go) self:_Onbtn_addFriend(self) end
    UIUtil.GetComponent(self.btn_addFriend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_addFriend);

    self._onClickbtn_sendChatMsg = function(go) self:_OnClickbtn_sendChatMsg(self) end
    UIUtil.GetComponent(self.btn_sendChatMsg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickbtn_sendChatMsg);

    self._onClickBtnFace = function(go) self:_OnClickBtnFace(self) end
    UIUtil.GetComponent(self.btn_face, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFace);
    if ChatManager.UseVoice then
    local ll = UIUtil.GetComponent(FriendBottomBarControll.btn_chatMc, "LuaUIEventListener")
    ll:RegisterDelegate("OnPress", FriendBottomBarControll._OnPress);
    ll:RegisterDelegate("OnDragOver", FriendBottomBarControll._OnDragOver);
    ll:RegisterDelegate("OnDragOut", FriendBottomBarControll._OnDragOut);
    end

    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendBottomBarControll.PlayerChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CLASSIFY_CHANGE, FriendBottomBarControll.ClassifyChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendBottomBarControll.RemoveFriendComplete, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_SEND_CHAT_MSG_COMPLETE, FriendBottomBarControll.SendMsgComplete, self);

    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_UNSELECTED, FriendBottomBarControll.RemoveFriendComplete, self);

    self:PlayerChange(0);

    self:RemoveFriendComplete()
end
function FriendBottomBarControll._OnPress(go, press)
    -- logTrace("FriendBottomBarControll._OnPress:btn=" .. ",press=" .. tostring(press))
    if press then
        FriendDataManager.lastTargetId = FriendDataManager.currSelectTarget.id
        local flg = ChatManager.VoiceRecordStart(ChatChannel.pirvate,
        FriendDataManager.lastTargetId)
        if not flg then return end
        ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_VOICE_PANEL)
        FriendBottomBarControll._currentBtn = FriendBottomBarControll.btn_chatMc.gameObject
        FriendBottomBarControll.clearRecordTime = Timer.New( function()
            FriendBottomBarControll.clearRecordTime = nil
            -- logTrace(Input.touchCount.. tostring(Input.GetMouseButton(0)) .. ":" ..tostring(FriendBottomBarControll._currentBtn))
            if Input.touchCount < 1 and not Input.GetMouseButton(0) then
                FriendBottomBarControll._EndRecord(true)
            end
        end , 1, 1, false)
        FriendBottomBarControll.clearRecordTime:Start();
        FriendBottomBarControll.clearRecordTime2 = Timer.New( function()
            FriendBottomBarControll.clearRecordTime2 = nil
            FriendBottomBarControll._EndRecord(false)
        end , ChatManager.VoiceMaxLen, 1, true)
        FriendBottomBarControll.clearRecordTime2:Start();
    else
        FriendBottomBarControll._EndRecord(UICamera.currentTouch.current ~= FriendBottomBarControll._currentBtn)
    end
end
function FriendBottomBarControll._EndRecord(_cancel)
    -- logTrace("_EndRecord:_cancel=" .. tostring(_cancel))
    if FriendBottomBarControll._currentBtn == nil then return end
    ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_VOICE_PANEL)
    ChatManager.VoiceRecordStop(_cancel)
    FriendBottomBarControll._currentBtn = nil
    if FriendBottomBarControll.clearRecordTime then
        FriendBottomBarControll.clearRecordTime:Stop()
        FriendBottomBarControll.clearRecordTime = nil
    end
    if FriendBottomBarControll.clearRecordTime2 then
        FriendBottomBarControll.clearRecordTime2:Stop()
        FriendBottomBarControll.clearRecordTime2 = nil
    end
end
function FriendBottomBarControll._OnDragOver(go)
    --- logTrace("_OnOnDragOver:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == FriendBottomBarControll._currentBtn))
    if FriendBottomBarControll._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 1)
end
function FriendBottomBarControll._OnDragOut(go)
    -- logTrace("_OnDragOut:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == FriendBottomBarControll._currentBtn))
    if FriendBottomBarControll._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 2)
end
function FriendBottomBarControll:_OnClickBtnFace()
    ModuleManager.SendNotification(FriendNotes.FRIEND_OPEN_CHAT_FACE_PANEL, 2)
end
function FriendBottomBarControll:AddFace(face)
    -- logTrace("SelectFace:face=" .. face)
    self.txtChatInputTxt.value = self.txtChatInputTxt.value .. "#" .. face .. "#"
end

function FriendBottomBarControll:RemoveFriendComplete()
    FriendBottomBarControll.btn_chatMc.gameObject:SetActive(false);
    self.txtChatInput.gameObject:SetActive(false);
    self.btn_sendChatMsg.gameObject:SetActive(false);
    self.btn_face.gameObject:SetActive(false);
end

function FriendBottomBarControll:_Onbtn_addFriend()
    ModuleManager.SendNotification(AddFriendsNotes.OPEN_ADDFRIENDSPANEL);
end

-- 发送消息
function FriendBottomBarControll:_OnClickbtn_sendChatMsg()
    -- print("_OnClickbtn_sendChatMsg",tostring(FriendDataManager.currSelectTarget))
    if FriendDataManager.currSelectTarget ~= nil then

        local msg_Str = self.chatTxt.text;

        if msg_Str ~= "" then
            local r_id = FriendDataManager.currSelectTarget.id;
            -- FriendProxy.TrySendMsg(r_id, msg_Str);
            FriendDataManager.lastTargetId = r_id
            ChatManager.SendMsg(ChatChannel.pirvate, msg_Str, r_id)
        else
            MsgUtils.ShowTips("friend/FriendBottomBarControll/tip1");
        end



    end


end

function FriendBottomBarControll:PlayerChange(type)

    if FriendDataManager.curr_classify == FriendNotes.classify_btnEnemy then
        local t_num = table.getn(FriendDataManager.GetEnemList());
        self.friend_numTxt.text = LanguageMgr.Get("friend/FriendBottomBarControll/enemy_num") .. t_num .. "/" .. FriendDataManager.enemy_max_num;
    else
        local t_num = table.getn(FriendDataManager.GetFriendList());
        self.friend_numTxt.text = LanguageMgr.Get("friend/FriendBottomBarControll/friend_num") .. t_num .. "/" .. FriendDataManager.friend_max_num;
    end

end

function FriendBottomBarControll:ClassifyChange()
    self:PlayerChange(0);
end


function FriendBottomBarControll:ShowInput()
    self.btn_face.gameObject:SetActive(true);
    FriendBottomBarControll.btn_chatMc.gameObject:SetActive(ChatManager.UseVoice)
    self.txtChatInput.gameObject:SetActive(true);
    self.btn_sendChatMsg.gameObject:SetActive(true);
end


function FriendBottomBarControll:SendMsgComplete(data)

    self.chatTxt.text = "";
    self.txtChatInputTxt.value = "";

end

function FriendBottomBarControll:Dispose()
    UIUtil.GetComponent(self.btn_addFriend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtn_addFriend = nil;

    UIUtil.GetComponent(self.btn_sendChatMsg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickbtn_sendChatMsg = nil;

    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendBottomBarControll.PlayerChange)
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CLASSIFY_CHANGE, FriendBottomBarControll.ClassifyChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendBottomBarControll.RemoveFriendComplete);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_SEND_CHAT_MSG_COMPLETE, FriendBottomBarControll.SendMsgComplete);
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_UNSELECTED, FriendBottomBarControll.RemoveFriendComplete);
    if ChatManager.UseVoice then
    local ll = UIUtil.GetComponent(FriendBottomBarControll.btn_chatMc, "LuaUIEventListener")
    ll:RemoveDelegate("OnPress");
    ll:RemoveDelegate("OnDragOver");
    ll:RemoveDelegate("OnDragOut");
    end
    FriendBottomBarControll.btn_chatMc = nil
    UIUtil.GetComponent(self.btn_face, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFace = nil;
    self.btn_face = nil



    self.btn_addFriend = nil;
    self.btn_sendChatMsg = nil;
    self.btn_face = nil;

    self.friend_numTxt = nil;

    self.txtChatInput = nil;
    self.txtChatInputTxt = nil;
    self.chatTxt = nil;




end