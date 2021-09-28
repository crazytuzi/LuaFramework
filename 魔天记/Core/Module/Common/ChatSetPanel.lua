require "Core.Module.Common.Panel"

ChatSetPanel = class("ChatSetPanel", Panel);
function ChatSetPanel:New()
    self = { };
    setmetatable(self, { __index = ChatSetPanel });
    return self
end


function ChatSetPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ChatSetPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    local togs = UIUtil.GetComponentsInChildren(self._trsContent, "UIToggle");
    self._togworld = UIUtil.GetChildInComponents(togs, "togworld");
    self._togteam = UIUtil.GetChildInComponents(togs, "togteam");
    self._togschool = UIUtil.GetChildInComponents(togs, "togschool");
    self._togactive = UIUtil.GetChildInComponents(togs, "togactive");
    self._togsystem = UIUtil.GetChildInComponents(togs, "togsystem");
    self._togworldSound = UIUtil.GetChildInComponents(togs, "togworldSound");
    self._togteamSound = UIUtil.GetChildInComponents(togs, "togteamSound");
    self._togschoolSound = UIUtil.GetChildInComponents(togs, "togschoolSound");
    self._togactiveSound = UIUtil.GetChildInComponents(togs, "togactiveSound");
    self._togsound = UIUtil.GetChildInComponents(togs, "togsound");

    self._togworld.value = ChatSettingData.world;
    self._togteam.value = ChatSettingData.team;
    self._togschool.value = ChatSettingData.school;
    self._togactive.value = ChatSettingData.active;
    self._togsystem.value = ChatSettingData.system;
    self._togworldSound.value = ChatSettingData.worldSound;
    self._togteamSound.value = ChatSettingData.teamSound;
    self._togschoolSound.value = ChatSettingData.schoolSound;
    self._togactiveSound.value = ChatSettingData.activeSound;
    self._togsound.value = ChatSettingData.wifiSound;

    if not ChatManager.UseVoice then
        self.trsVoice = UIUtil.GetChildByName(self._trsContent, "Transform", "trsVoice")
        self.trsVoice.gameObject:SetActive(false)
        self.trsWifi = UIUtil.GetChildByName(self._trsContent, "Transform", "trsWifi")
        self.trsWifi.gameObject:SetActive(false)
        self.bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg")
        self.bg.height = 220
    end
end

function ChatSetPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function ChatSetPanel:_OnClickBtnClose()
    self:_SetChangeSettingData()
    ModuleManager.SendNotification(ChatNotes.CHAT_SET_COMPLETE)
    ModuleManager.SendNotification(ChatNotes.CLOSE_CHAT_SET_PANEL)
end
function ChatSetPanel:_SetChangeSettingData()
    ChatSettingData.world = self._togworld.value;
    ChatSettingData.team = self._togteam.value;
    ChatSettingData.school = self._togschool.value;
    ChatSettingData.active = self._togactive.value;
    ChatSettingData.system = self._togsystem.value;
    ChatSettingData.worldSound = self._togworldSound.value;
    ChatSettingData.teamSound = self._togteamSound.value;
    ChatSettingData.schoolSound = self._togschoolSound.value;
    ChatSettingData.activeSound = self._togactiveSound.value;
    ChatSettingData.wifiSound = self._togsound.value;
    ChatManager.SaveSettingData()
end

function ChatSetPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ChatSetPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function ChatSetPanel:_DisposeReference()
    self._btnClose = nil;
    self._togworld = nil;
    self._togteam = nil;
    self._togschool = nil;
    self._togactive = nil;
    self._togsystem = nil;
    self._togworldSound = nil;
    self._togteamSound = nil;
    self._togschoolSound = nil;
    self._togsound = nil;
    self._trsMask = nil;
end
