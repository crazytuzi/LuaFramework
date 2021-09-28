require "Core.Module.Common.UIComponent"

MainVoicePanel = class("MainVoicePanel", UIComponent);
MainVoicePanel._currentBtn = nil-- 当前录音频道对象
MainVoicePanel._cancel = false-- 取消录音
MainVoicePanel._selectBtn = nil-- 当前选择频道对象
MainVoicePanel._currentIndex = 999999999

function MainVoicePanel:New()
    self = { };
    setmetatable(self, { __index = MainVoicePanel });
    return self
end
function MainVoicePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function MainVoicePanel:_InitReference()
    MainVoicePanel._uiTable = UIUtil.GetChildByName(self._gameObject, "UITable", "Icons")
    MainVoicePanel._btnVoiceParty = UIUtil.GetChildByName(MainVoicePanel._uiTable, "UIButton", "btnVoiceParty")
    MainVoicePanel._btnVoiceClique = UIUtil.GetChildByName(MainVoicePanel._uiTable, "UIButton", "btnVoiceClique")
    MainVoicePanel._btnVoiceWorld = UIUtil.GetChildByName(MainVoicePanel._uiTable, "UIButton", "btnVoiceWorld")
    MainVoicePanel._btnVoiceActive = UIUtil.GetChildByName(MainVoicePanel._uiTable, "UIButton", "btnVoiceActive")
    -- MainVoicePanel._btnMask = UIUtil.GetChildByName(self._gameObject, "UISprite", "trsMask").gameObject
    self:InitIcon()
end
function MainVoicePanel:InitIcon()
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, MainVoicePanel.PartyChange, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, MainVoicePanel.CliqueChange, self)
    if not ChatManager.CanSpeakWorld() then
        MessageManager.AddListener(PlayerManager, PlayerManager.SelfLevelChange, MainVoicePanel.LevelChange, self)
    end
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_CHANGE, MainVoicePanel.SceneAfterInit, self)
    MainVoicePanel._ResetSelectBtn()
end
function MainVoicePanel:CliqueChange()
    MainVoicePanel._ResetBtn(MainVoicePanel._btnVoiceClique.gameObject, ChatManager.CanSpeakSchool())
end
function MainVoicePanel:PartyChange()
    MainVoicePanel._ResetBtn(MainVoicePanel._btnVoiceParty.gameObject, ChatManager.CanSpeakTeam())
end
function MainVoicePanel:LevelChange()
    MainVoicePanel._ResetBtn(MainVoicePanel._btnVoiceWorld.gameObject, ChatManager.CanSpeakWorld())
end
function MainVoicePanel:SceneAfterInit()
    MainVoicePanel._ResetBtn(MainVoicePanel._btnVoiceActive.gameObject, ChatManager.CanSpeakActive())
end
function MainVoicePanel._ResetBtn(go, show)
    if MainVoicePanel._selectBtn == nil or(not show and go == MainVoicePanel._selectBtn) then
        MainVoicePanel._ResetSelectBtn()
    end
end
function MainVoicePanel._ResetSelectBtn()
    MainVoicePanel._selectBtn = nil
    MainVoicePanel._VisibleIcon(false)
    if ChatManager.CanSpeakWorld() then
        MainVoicePanel._SelectedGo(MainVoicePanel._btnVoiceWorld.gameObject)
    elseif ChatManager.CanSpeakTeam() then
        MainVoicePanel._SelectedGo(MainVoicePanel._btnVoiceParty.gameObject)
    elseif ChatManager.CanSpeakSchool() then
        MainVoicePanel._SelectedGo(MainVoicePanel._btnVoiceClique.gameObject)
    elseif ChatManager.CanSpeakActive() then
        MainVoicePanel._SelectedGo(MainVoicePanel._btnVoiceActive.gameObject)
    end
end

function MainVoicePanel:_InitListener()
    self:_RegisterDelegate(MainVoicePanel._btnVoiceParty)
    self:_RegisterDelegate(MainVoicePanel._btnVoiceClique)
    self:_RegisterDelegate(MainVoicePanel._btnVoiceWorld)
    self:_RegisterDelegate(MainVoicePanel._btnVoiceActive)
    -- UIUtil.GetComponent(MainVoicePanel._btnMask, "LuaUIEventListener"):RegisterDelegate("OnPress", self._OnPressMask)
end
function MainVoicePanel:_RegisterDelegate(obj)
    local ll = UIUtil.GetComponent(obj, "LuaUIEventListener")
    ll:RegisterDelegate("OnPress", self._OnPress);
    ll:RegisterDelegate("OnDragOver", self._OnDragOver);
    ll:RegisterDelegate("OnDragOut", self._OnDragOut);
    ll:RegisterDelegate("OnClick", self._OnClick);
end

function MainVoicePanel._OnPress(go, press)
    -- Warning("_OnPress:btn=" .. tostring(go.name) ..",press=" .. tostring(press))
    if press then
        local channel = ChatChannel.world
        if go == MainVoicePanel._btnVoiceParty.gameObject then
            channel = ChatChannel.team
        elseif go == MainVoicePanel._btnVoiceClique.gameObject then
            channel = ChatChannel.school
        elseif go == MainVoicePanel._btnVoiceActive.gameObject then
            channel = ChatChannel.active
        end
        -- logTrace(tostring(go.name)..channel)
        MainVoicePanel._isPress = true
        local num = 0
        MainVoicePanel._currentBtn = go
        MainVoicePanel.clearRecordTime = Timer.New( function()
            -- logTrace(Input.touchCount.. tostring(Input.GetMouseButton(0)) .. ":" ..tostring(MainVoicePanel._currentBtn))
            local up = Input.touchCount < 1 and not Input.GetMouseButton(0)
            if up then
                if MainVoicePanel._isPress then MainVoicePanel._OnClick(go) end
                MainVoicePanel._EndRecord(true)
            end
            num = num + 1
            if num == 5 and not up then
                local flg = ChatManager.VoiceRecordStart(channel)
                if not flg then return end
                ModuleManager.SendNotification(ChatNotes.OPEN_CHAT_VOICE_PANEL)
                MainVoicePanel.clearRecordTime2 = Timer.New( function()
                    MainVoicePanel.clearRecordTime2 = nil
                    MainVoicePanel._EndRecord(false)
                end , ChatManager.VoiceMaxLen, 1, true)
                MainVoicePanel.clearRecordTime2:Start();
            end
        end , 0.05, 20, false)
        MainVoicePanel.clearRecordTime:Start();
    else
        -- Warning(UICamera.currentTouch.current and UICamera.currentTouch.current.name )
        -- Warning(UICamera.currentTouch.current ~= MainVoicePanel._currentBtn )
        MainVoicePanel._EndRecord(UICamera.currentTouch.current ~= MainVoicePanel._currentBtn)
    end
end
function MainVoicePanel._EndRecord(_cancel)
    -- Warning("_EndRecord:_cancel=" .. tostring(_cancel) .. tostring(MainVoicePanel._currentBtn))
    if MainVoicePanel._currentBtn == nil then return end
    ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_VOICE_PANEL)
    ChatManager.VoiceRecordStop(_cancel)
    MainVoicePanel._currentBtn = nil
    if MainVoicePanel.clearRecordTime then
        MainVoicePanel.clearRecordTime:Stop()
        MainVoicePanel.clearRecordTime = nil
    end
    if MainVoicePanel.clearRecordTime2 then
        MainVoicePanel.clearRecordTime2:Stop()
        MainVoicePanel.clearRecordTime2 = nil
    end
end
function MainVoicePanel._OnDragOver(go)
    -- Warning("_OnDragOver:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == MainVoicePanel._currentBtn))
    if MainVoicePanel._currentBtn == nil or MainVoicePanel._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 1)
end
function MainVoicePanel._OnDragOut(go)
    -- Warning("_OnDragOut:btn=" .. tostring(go.name) ..",inside=" .. tostring(go == MainVoicePanel._currentBtn))
    if MainVoicePanel._currentBtn == nil or MainVoicePanel._currentBtn ~= go then return end
    ModuleManager.SendNotification(ChatNotes.VOICE_STATE_CHANGE, 2)
    MainVoicePanel._isPress = false
end
function MainVoicePanel._OnClick(go)
    -- Warning("_OnClick:btn=" .. tostring(go.name) .. tostring(MainVoicePanel._isPress))
    if not MainVoicePanel._isPress then return end
    MainVoicePanel._SelectedGo(go)
end
function MainVoicePanel._SelectedGo(go)
    MainVoicePanel._isPress = false
    if go == MainVoicePanel._selectBtn then
        local show = not MainVoicePanel._showBtns
        -- MainVoicePanel._btnMask.activeSelf
        if show and MainVoicePanel._GetShowBtnCount() < 2 then return end
        MainVoicePanel._VisibleIcon(show)
    else
        go.name = MainVoicePanel._currentIndex
        MainVoicePanel._currentIndex = MainVoicePanel._currentIndex - 1
        MainVoicePanel._selectBtn = go
        MainVoicePanel._VisibleIcon(false)
    end
end
function MainVoicePanel._GetShowBtnCount()
    local num = 0
    if ChatManager.CanSpeakTeam() then num = num + 1 end
    if ChatManager.CanSpeakSchool() then num = num + 1 end
    if ChatManager.CanSpeakWorld() then num = num + 1 end
    if ChatManager.CanSpeakActive() then num = num + 1 end
    return num
end
function MainVoicePanel._OnPressMask(go, press)
    MainVoicePanel._VisibleIcon(false)
end
function MainVoicePanel:OnCameraClick(go)
    if not MainVoicePanel._showBtns then return end
    if go ~= MainVoicePanel._btnVoiceParty.gameObject and
        go ~= MainVoicePanel._btnVoiceClique.gameObject and
        go ~= MainVoicePanel._btnVoiceWorld.gameObject and
        go ~= MainVoicePanel._btnVoiceActive.gameObject then
        MainVoicePanel._VisibleIcon(false)
    end
end
function MainVoicePanel._VisibleIcon(val)
    -- Warning(tostring(MainVoicePanel._selectBtn) .."___".. tostring(val))
    -- MainVoicePanel._btnMask:SetActive(val)
    MainVoicePanel._showBtns = val
    local pg = MainVoicePanel._btnVoiceParty.gameObject
    local cg = MainVoicePanel._btnVoiceClique.gameObject
    local wg = MainVoicePanel._btnVoiceWorld.gameObject
    local ag = MainVoicePanel._btnVoiceActive.gameObject
    local x, y, g = 37, 42, 82
    if val then
        local b = ChatManager.CanSpeakTeam()
        pg:SetActive(b)
        if b then
            Util.SetLocalPos(pg, x, y, 0)
            --            pg.transform.localPosition = Vector3(x, y, 0)
            y = y + g
        end
        b = ChatManager.CanSpeakSchool()
        cg:SetActive(b)
        if b then
            Util.SetLocalPos(cg, x, y, 0)
            --            cg.transform.localPosition = Vector3(x, y, 0)
            y = y + g
        end
        b = ChatManager.CanSpeakWorld()
        wg:SetActive(b)
        if b then
            Util.SetLocalPos(wg, x, y, 0)
            --            wg.transform.localPosition = Vector3(x, y, 0)
            y = y + g
        end
        b = ChatManager.CanSpeakActive()
        ag:SetActive(b)
        if b then
            Util.SetLocalPos(ag, x, y, 0)
            --            ag.transform.localPosition = Vector3(x, y, 0)
            y = y + g
        end
    else
        pg:SetActive(MainVoicePanel._selectBtn == pg)
        cg:SetActive(MainVoicePanel._selectBtn == cg)
        wg:SetActive(MainVoicePanel._selectBtn == wg)
        ag:SetActive(MainVoicePanel._selectBtn == ag)
        if MainVoicePanel._selectBtn then
            Util.SetLocalPos(MainVoicePanel._selectBtn, x, y, 0)
            --         MainVoicePanel._selectBtn.transform.localPosition = Vector3(x, y, 0)
        end
    end
    -- MainVoicePanel._uiTable:Reposition()
end

function MainVoicePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end
function MainVoicePanel:_DisposeListener()
    self:_RemoveDelegate(MainVoicePanel._btnVoiceParty)
    self:_RemoveDelegate(MainVoicePanel._btnVoiceClique)
    self:_RemoveDelegate(MainVoicePanel._btnVoiceWorld)
    self:_RemoveDelegate(MainVoicePanel._btnVoiceActive)
    -- UIUtil.GetComponent(MainVoicePanel._btnMask, "LuaUIEventListener"):RemoveDelegate("OnPress")
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, MainVoicePanel.PartyChange);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, MainVoicePanel.CliqueChange)
    MessageManager.RemoveListener(PlayerManager, PlayerManager.SelfLevelChange, MainVoicePanel.LevelChange)
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_AFTER_INIT, MainVoicePanel.SceneAfterInit)
end
function MainVoicePanel:_RemoveDelegate(obj)
    local ll = UIUtil.GetComponent(obj, "LuaUIEventListener")
    ll:RemoveDelegate("OnPress")
    ll:RemoveDelegate("OnDragOver")
    ll:RemoveDelegate("OnDragOut")
    ll:RemoveDelegate("OnClick")
end
function MainVoicePanel:_DisposeReference()
    MainVoicePanel._btnVoiceParty = nil;
    MainVoicePanel._btnVoiceClique = nil;
    MainVoicePanel._btnVoiceWorld = nil;
    MainVoicePanel._btnVoiceActive = nil;
    MainVoicePanel._currentBtn = nil
    if MainVoicePanel._currentBtn ~= nil then
        MainVoicePanel._EndRecord(true)
    end
end
