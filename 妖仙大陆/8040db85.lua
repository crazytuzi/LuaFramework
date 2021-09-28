local _M = {}
_M.__index = _M


local ChatModel = require 'Zeus.Model.Chat'
local Util      = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"

local MaxVioceLength = 30
local VoiceMouseOut = false

local function setVisible(self)
    self.m_Root_Voice.Visible = false;
    
end

local function OnClickYuYinBegin(displayNode, pos, self)
    
    XmdsSoundManager.GetXmdsInstance():SetBGMMute(true)
    XmdsSoundManager.GetXmdsInstance():SetGetEffectMute(true)
    self.voicepos = pos
    self.m_ChatTime = nil
    
    print("----------------------语音按下")
    self.m_VoiceTime = System.DateTime.Now;
    self.m_IsTimeUp = true;
    self.m_Root_Voice.Alpha = 1;
    self.m_Root_Voice.Visible = true;
    self.m_Root_Voice:FindChildByEditName("cvs_cancel", true).Visible = true;
    self.m_Root_Voice:FindChildByEditName("cvs_cancelsucces", true).Visible = false;
    self.m_Root_Voice:FindChildByEditName("cvs_message", true).Visible = false;
    
    LocalUSpeakSender.role_id = "" .. DataMgr.Instance.UserData.RoleID
    
    

    local fa = self.m_Root_Voice.UnityObject:GetComponent("uTweenAlpha")
    if fa ~= nil then
        GameObject.Destroy(fa)
    end
    
    
    self.localpath = "/voice_" .. DataMgr.Instance.UserData.RoleID .. tostring((System.DateTime.Now).Ticks) .. ".amr"
    self.voicePath = FileSave.voiceLocalFilePath .. self.localpath
    self.voiceRecordstatus = FileSave.Voiceengine:StartRecording(self.voicePath)
end

local function OnClickYuYinOut(displayNode, pos, self)
    
    print("----------------------语音移出")
    VoiceMouseOut = true
    self.m_Root_Voice.Alpha = 1;
    self.m_Root_Voice:FindChildByEditName("cvs_cancel", true).Visible = false;
    self.m_Root_Voice:FindChildByEditName("cvs_cancelsucces", true).Visible = true

    
















    
    
    

    
    
end

local function OnClickYuYinIn(displayNode, pos, self)
    
    print("----------------------语音移入")
    VoiceMouseOut = false
    self.m_Root_Voice.Alpha = 1;
    self.m_Root_Voice:FindChildByEditName("cvs_cancel", true).Visible = true;
    self.m_Root_Voice:FindChildByEditName("cvs_cancelsucces", true).Visible = false
end

local function SendVoiceToTecent(self)
    
    
    
    

    if self.canSendTencentVoice ~= nil and self.voiceRecordstatus == 0 then
        FileSave.Voiceengine:SpeechToText(self.voicePath, 0)
        self.voiceCallBackstatus = FileSave.Voiceengine:UploadRecordedFile(self.voicePath, 60000)
        self.canSendTencentVoice = nil
        local data = {}
        FileSave.Voiceengine.OnSpeechToTextComplete = function(code, speechText)
            data.AsrResult = speechText
            if data.fileid ~= nil then
                local msg = ChatUtil.AddVoiceByData(data)
                ChatModel.chatMessageRequest(self.m_curChannel, msg, self.m_acceptRoleId, function (param)
                    self.canClearMsg = true
                    self.m_selPersion = nil
                    self.m_functype = nil
                    if self.m_curChannel == ChatModel.ChannelState.Channel_union or self.m_curChannel == ChatModel.ChannelState.Channel_group then
                        _M.SetAcceptRoleData(nil, self)
                    end
                end, self.s2c_isAtAll, self.m_titleMsg, self.m_functype)
            end
        end

        FileSave.Voiceengine.OnUploadReccordFileComplete = function(code, filepath, fileid)
            
            self.voiceCallBackstatus = nil
            if code == gcloud_voice.IGCloudVoice.GCloudVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE then
                data.Time = math.floor((self.m_ChatTime - self.m_VoiceTime).TotalSeconds)
                data.filepath = self.localpath
                data.fileid = fileid
                
                FileSave.reNameFile(self.voicePath, filepath);
                

                if data.AsrResult ~= nil then
                    local msg = ChatUtil.AddVoiceByData(data)
                    ChatModel.chatMessageRequest(self.m_curChannel, msg, self.m_acceptRoleId, function (param)
                        self.canClearMsg = true
                        self.m_selPersion = nil
                        self.m_functype = nil
                        if self.m_curChannel == ChatModel.ChannelState.Channel_union or self.m_curChannel == ChatModel.ChannelState.Channel_group then
                            _M.SetAcceptRoleData(nil, self)
                        end
                    end, self.s2c_isAtAll, self.m_titleMsg, self.m_functype)
                end
            end
        end
    end
end

local function OnClickYuYinEnd(displayNode, pos, self)
    if self.m_IsTimeUp == false then
        return
    end

    
    
    self.voicepos = nil
    print("----------------------语音抬起")
    local fa = self.m_Root_Voice.UnityObject:GetComponent(typeof(uTools.uTweenAlpha))
    if fa ~= nil then
        GameObject.Destroy(fa)
    end
    fa = self.m_Root_Voice.UnityObject:AddComponent(typeof(uTools.uTweenAlpha))
    fa.alpha = 0.1
    fa.duration = 0.2
    local finish = UnityEngine.Events.UnityEvent.New()
    local action = LuaUIBinding.UnityAction(function()
        setVisible(self)
        GameObject.Destroy(self.m_Root_Voice.UnityObject:GetComponent(typeof(uTools.uTweenAlpha)))
    end)
    finish:AddListener(action)
    fa.onFinished = finish

    self.m_Root_Voice:FindChildByEditName("cvs_cancel", true).Visible = true;
    self.m_Root_Voice:FindChildByEditName("cvs_cancelsucces", true).Visible = false;
    local filename = "voice_" .. (System.DateTime.Now).Ticks;

    if self.m_VoiceTime == nil or (self.m_VoiceTime ~= nil and ((System.DateTime.Now - self.m_VoiceTime).TotalMilliseconds / 1000 < 1)) then
        GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.CHAT, 'sound_limit'))
        OnClickYuYinOut(displayNode, nil, self)
        return
    end

    self.m_IsTimeUp = false;
    
    
    
    
    
    self.m_ChatTime = System.DateTime.Now;

    FileSave.Voiceengine:StopRecording()

    FileSave.Voiceengine.OnRecordStopComplete = function( filepath )
        self.canSendTencentVoice = true
    end

    
    
    
    
    
    
    
    
    
    XmdsSoundManager.GetXmdsInstance():SetBGMMute(self.bgstatus)
    XmdsSoundManager.GetXmdsInstance():SetGetEffectMute(self.effectstatus)

    print("----------------------结束语音")
end

local function OnClickYuYinAbort(displayNode, pos, self)
    print("----------------------语音取消")

    if self == nil then
        return
    end
    
    setVisible(self)
    self.voicepos = nil
    self.m_IsTimeUp = false
    XmdsSoundManager.GetXmdsInstance():SetBGMMute(self.bgstatus)
    XmdsSoundManager.GetXmdsInstance():SetGetEffectMute(self.effectstatus)
end

function _M.AbortRecord( self )
    OnClickYuYinAbort(nil, nil, self)
end

function _M.InitChannel(channel, self)
    
    self.m_curChannel = channel
end

function _M.VoiceChatUpate(self)

    if self.m_IsTimeUp and self.voicepos ~= nil then
        if VoiceMouseOut == false then
            local offset = self.voicepos.position.y - self.voicepos.pressPosition.y
            

            if offset > 60 then
                OnClickYuYinOut(nil, nil, self)
            end
        else
            local offset = self.voicepos.position.y - self.voicepos.pressPosition.y
            

            if offset <= 60 then
                OnClickYuYinIn(nil, nil, self)
            end
        end
    end

    local curTime = 1
    if self.m_VoiceTime then
        curTime = math.floor((System.DateTime.Now - self.m_VoiceTime).TotalSeconds)
        self.lb_time.Text = curTime .. "'"
    end

    if self.m_IsTimeUp and curTime >= MaxVioceLength then
        OnClickYuYinEnd(nil, nil, self)
    end

    SendVoiceToTecent(self)
    










































    
end

function _M.SetAcceptRoleID(self, role_id )
    self.m_acceptRoleId = role_id
end

local function InitCompnent(self, btn_talk)
    self.bgstatus = XmdsSoundManager.GetXmdsInstance():GetBGMMute()
    self.effectstatus = XmdsSoundManager.GetXmdsInstance():GetGetEffectMute()
    self.btn_talk = btn_talk
    
    
    local bg = self.m_Root_Voice:FindChildByEditName("bg",true)
    local root = XmdsUISystem.Instance.RootRect
    local scale = root.width > XmdsUISystem.SCREEN_WIDTH and root.width / XmdsUISystem.SCREEN_WIDTH or root.height / XmdsUISystem.SCREEN_HEIGHT
            
    local mMaskW = bg.Width * scale;
    local mMaskH = bg.Height * scale;

    local mMaskOffsetX = (XmdsUISystem.SCREEN_WIDTH - mMaskW) * 0.5
    local mMaskOffsetY = (XmdsUISystem.SCREEN_HEIGHT - mMaskH) * 0.5

    self.lb_time = self.m_Root_Voice:FindChildByEditName("lb_time",true)

    bg.Position2D = Vector2.New(mMaskOffsetX, mMaskOffsetY);
    bg.Size2D = Vector2.New(mMaskW, mMaskH)

    btn_talk.event_PointerDown = function(displayNode, pos)
        if self.m_curChannel == ChatModel.ChannelState.Channel_private and self.m_acceptRoleId == nil then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'chat_object'))
            return
        end
        OnClickYuYinBegin(displayNode, pos, self)
        

    end

    btn_talk.event_PointerUp = function(displayNode, pos)
        if self.m_curChannel == ChatModel.ChannelState.Channel_private and self.m_acceptRoleId == nil then
            return
        end

        if pos ~= nil then
            local offset = pos.position.y - pos.pressPosition.y
            if offset > 60 then
                OnClickYuYinAbort(displayNode, pos, self)
                return 
            end
        end
        OnClickYuYinEnd(displayNode, pos, self)
        
    end
    
    
end

function _M.OnEnter(self)
    self.bgstatus = XmdsSoundManager.GetXmdsInstance():GetBGMMute()
    self.effectstatus = XmdsSoundManager.GetXmdsInstance():GetGetEffectMute()

end

function _M.OnExit(self)
end

function _M.OnDestory(self)
    
    
    
end

function _M.Init(m_Root, self, btn_talk)
     self.m_Root = m_Root
     self.m_Root_Voice = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/chat/chat_hint.gui.xml")
     self.m_Root_Voice.Visible = false
     self.m_Root:AddChild(self.m_Root_Voice)
	 self.m_Root_Voice.Enable = true
     InitCompnent(self, btn_talk)
end

return _M
