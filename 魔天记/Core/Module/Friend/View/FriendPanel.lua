require "Core.Module.Common.Panel"
require "Core.Module.Common.UIComponent";
require "Core.Module.Friend.FriendNotes";
require "Core.Module.Mail.View.MailPanel";
require "Core.Module.Friend.controlls.PartyPanelControll";
require "Core.Module.Friend.controlls.FriendPanelControll";

FriendPanel = class("FriendPanel", Panel);



function FriendPanel:New()
    self = { };
    setmetatable(self, { __index = FriendPanel });
    return self
end

function FriendPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    self._panel_num = 3;
    self._panels = { };


    self._panelIndex = 0;


end

function FriendPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btnFriend = UIUtil.GetChildInComponents(btns, "btnFriend");
    self._btnParty = UIUtil.GetChildInComponents(btns, "btnParty");
    self._btnMail = UIUtil.GetChildInComponents(btns, "btnMail");

    self._btnPartyTip = UIUtil.GetChildByName(self._btnParty, "Transform", "hasApplyListTip");
    self._btnPartyTip.gameObject:SetActive(false);

    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsToggle = UIUtil.GetChildInComponents(trss, "trsToggle");

    self.mainView = UIUtil.GetChildInComponents(trss, "mainView");

    self._icoMailRedPoint = UIUtil.GetChildByName(self._btnMail, "UISprite", "npoint");
    self._icoMailRedPoint.alpha = 0;
     self._btnFriend_npoint = UIUtil.GetChildByName(self._btnFriend, "Transform", "npoint");
     self._btnFriend_npoint.gameObject:SetActive(false);

    FixedUpdateBeat:Add(self.UpTime, self);
    FriendProxy.TryGetTeamFBData();
    self:CheckAndShowAplTip();
    self:UpTimeFroChatDataChange();
end

function FriendPanel:UpTime()
    self._trsContent.gameObject:SetActive(false);
    self._trsContent.gameObject:SetActive(true);
    FixedUpdateBeat:Remove(self.UpTime, self)
end

function FriendPanel:_InitListener()

    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtnFriend = function(go) self:_OnClickBtnFriend(self) end
    UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFriend);
    self._onClickBtnParty = function(go) self:_OnClickBtnParty(self) end
    UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnParty);
    self._onClickBtnMail = function(go) self:_OnClickBtnMail(self) end
    UIUtil.GetComponent(self._btnMail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnMail);

    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_NEW, FriendPanel.OnUpdateMailRedPoint, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_LIST, FriendPanel.OnUpdateMailRedPoint, self);
    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, FriendPanel.CheckAndShowAplTip, self);
end

function FriendPanel:UpTimeFroChatDataChange()
    local d = FriendDataManager.HasNewChatMsg();
    if d then
        self._btnFriend_npoint.gameObject:SetActive(true);
    else
        self._btnFriend_npoint.gameObject:SetActive(false);
    end

end

function FriendPanel:CheckAndShowAplTip()

    local t_num = table.getn(PartData.applyTearmList);
    if t_num > 0 then
        -- 需要显示提示
        self._btnPartyTip.gameObject:SetActive(true);
    else
        self._btnPartyTip.gameObject:SetActive(false);

    end

end


function FriendPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(FriendNotes.CLOSE_FRIENDPANEL);
end

function FriendPanel:_OnClickBtnFriend()
    LogHttp.SendOperaLog("好友")
    self:OpenSubPanel(FriendNotes.PANEL_FRIEND);
end

function FriendPanel:_OnClickBtnParty()
    LogHttp.SendOperaLog("组队")
    self:OpenSubPanel(FriendNotes.PANEL_PARTY);
end

function FriendPanel:_OnClickBtnMail()
    LogHttp.SendOperaLog("邮件")
    self:OpenSubPanel(FriendNotes.PANEL_MAIL);
end

function FriendPanel:SetOpenParam(param)
    self.openParam = param;
end

-- 设置副本数据
function FriendPanel:SetInstanceId(val)
    -- if (self._currInstanceId ~= val) then
    self._currInstanceId = val;
    if self._panels[FriendNotes.PANEL_PARTY] ~= nil then
        self._panels[FriendNotes.PANEL_PARTY]:SetInstanceId(self._currInstanceId);
    end

    -- end
end

function FriendPanel:GetPanel(tab)
    return self._panels and self._panels[tab] or nil
end

function FriendPanel:_Opened(param)
    self:OpenSubPanel(self.openParam or FriendNotes.PANEL_FRIEND);
    self:OnUpdateMailRedPoint();
end

function FriendPanel:OpenSubPanel(tab)

    for i = 1, self._panel_num do
        if i == tab then
            local pl = self:GetCurrentSubPanel(i);
            pl:SetEnable(true)
        else
            if self._panels[i] ~= nil then
                self._panels[i]:SetEnable(false)
            end
        end
    end


    self._panelIndex = tab;

    if (tab == FriendNotes.PANEL_FRIEND) then

        self:SetBtnToggleActive(self._btnFriend, true);
        self:SetBtnToggleActive(self._btnMail, false);
        self:SetBtnToggleActive(self._btnParty, false);

        self._panels[tab]:Show();


    elseif (tab == FriendNotes.PANEL_PARTY) then
        self:SetBtnToggleActive(self._btnFriend, false);
        self:SetBtnToggleActive(self._btnMail, false);
        self:SetBtnToggleActive(self._btnParty, true);
        -- 设置 队伍功能

        self._panels[tab]:Show();

    elseif (tab == FriendNotes.PANEL_MAIL) then
        self:SetBtnToggleActive(self._btnFriend, false);
        self:SetBtnToggleActive(self._btnParty, false);
        self:SetBtnToggleActive(self._btnMail, true);
    end
end

function FriendPanel:SetBtnToggleActive(btn, bool)
    local toggle = UIUtil.GetComponent(btn, "UIToggle");
    toggle.value = bool;
end

function FriendPanel:GetSubPanelIndex()
    return self._panelIndex;
end

function FriendPanel:GetCurrentSubPanel(index)



    if (index == FriendNotes.PANEL_FRIEND) then
        if self._panels[index] == nil then
            self._panels[index] = FriendPanelControll:New(self._btnFriend);

            self._trsFriend = self:AddSubPanel(ResID.UI_trsFriendItem, self.mainView)
            self._panels[index]:Init(self._trsFriend);
        end


    elseif (index == FriendNotes.PANEL_PARTY) then
        if self._panels[index] == nil then
            self._panels[index] = PartyPanelControll:New(self._btnParty);

            self._trsParty = self:AddSubPanel(ResID.UI_trsPartyItem, self.mainView)
            self._panels[index]:Init(self._trsParty);
        end
    elseif (index == FriendNotes.PANEL_MAIL) then
        if self._panels[index] == nil then
            self._panels[index] = MailPanel.New();

            self._trsMail = self:AddSubPanel(ResID.UI_trsMailItem, self.mainView)
            self._panels[index]:Init(self._trsMail);
        end
    end

    return self._panels[index];
end


function FriendPanel:_Dispose()

    self:_DisposeListener();
    self:_DisposeReference();

    HeroDealItem.ins = nil;
end

function FriendPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFriend = nil;
    UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnParty = nil;
    UIUtil.GetComponent(self._btnMail, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnMail = nil;

    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_NEW, FriendPanel.OnUpdateMailRedPoint, self);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_LIST, FriendPanel.OnUpdateMailRedPoint, self);
     MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, FriendPanel.CheckAndShowAplTip, self);
end

function FriendPanel:_DisposeReference()
    self._btn_close = nil;
    self._btnFriend = nil;
    self._btnParty = nil;
    self._btnMail = nil;

    for k, v in pairs(self._panels) do
        if v ~= nil then
            v:Dispose();
        end

    end

    self._panels = nil;

end

-- 如果需要点击遮罩响应,重写此函数
function FriendPanel:_OnClickMask()

    if HeroDealItem.ins ~= nil then
        HeroDealItem.ins:SetActive(false);
        HeroDealItem.ins = nil;
    end
end

function FriendPanel:OnUpdateMailRedPoint()
    self._icoMailRedPoint.alpha = MailManager.GetRedPoint() and 1 or 0;
end