require "Core.Module.Common.Panel";
require "Core.Module.Common.CommonColor";

GuildMemberPanel = Panel:New();
GuildMemberPanel.MODE ={
    MENU = 1,
    IDENTITY = 2
}

function GuildMemberPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildMemberPanel:GetUIOpenSoundName( )
    return ""
end

function GuildMemberPanel:_InitReference()

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._bg = UIUtil.GetChildByName(self._trsInfo, "UISprite", "bg");
    self._btnDetail = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnDetail");
    self._btnChat = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnChat");
    self._btnFriend = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnFriend");
    self._btnParty = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnParty");
    self._btnIdentity = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnIdentity");
    self._btnKick = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnKick");
    self._btnTransfer = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnTransfer");
    self._icoHead = UIUtil.GetChildByName(self._trsInfo, "UISprite", "icoHead");
    self._txtName = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtName");
    self._txtLevel = UIUtil.GetChildByName(self._icoHead, "UILabel", "txtLevel");

    self._trsIdentity = UIUtil.GetChildByName(self._trsContent, "Transform", "trsIdentity");
    self._btn_close = UIUtil.GetChildByName(self._trsIdentity, "UIButton", "btn_close");
    self._txtDesc = UIUtil.GetChildByName(self._trsIdentity, "UILabel", "txtDesc");
    self._btnAssLeader = UIUtil.GetChildByName(self._trsIdentity, "UIButton", "btnAssLeader");
    --self._btnElder = UIUtil.GetChildByName(self._trsIdentity, "UIButton", "btnElder");
    self._btnNormal = UIUtil.GetChildByName(self._trsIdentity, "UIButton", "btnNormal");
    self._txtAssLeader = UIUtil.GetChildByName(self._btnAssLeader, "UILabel", "txtAssLeader");
    --self._txtElder = UIUtil.GetChildByName(self._btnElder, "UILabel", "txtElder");
    self._txtNormal = UIUtil.GetChildByName(self._btnNormal, "UILabel", "txtNormal");

    
end

function GuildMemberPanel:_InitListener()
    self._onClickClose = function(go) self:_OnClickClose() end
	UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose);

    self._onClickBtnDetail = function(go) self:_OnClickBtnDetail(self) end
	UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDetail); 
    self._onClickBtnChat = function(go) self:_OnClickBtnChat(self) end
	UIUtil.GetComponent(self._btnChat, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChat); 
    self._onClickBtnFriend = function(go) self:_OnClickBtnFriend(self) end
	UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFriend); 
    self._onClickBtnParty = function(go) self:_OnClickBtnParty(self) end
	UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnParty); 
    self._onClickBtnIdentity = function(go) self:_OnClickBtnIdentity(self) end
	UIUtil.GetComponent(self._btnIdentity, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIdentity); 
    self._onClickBtnKick = function(go) self:_OnClickBtnKick(self) end
	UIUtil.GetComponent(self._btnKick, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnKick); 
    self._onClickBtnTransfer = function(go) self:_OnClickBtnTransfer(self) end
	UIUtil.GetComponent(self._btnTransfer, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTransfer); 
    
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnAssLeader = function(go) self:_OnClickBtnAssLeader(self) end
	UIUtil.GetComponent(self._btnAssLeader, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAssLeader); 
    --self._onClickBtnElder = function(go) self:_OnClickBtnElder(self) end
	--UIUtil.GetComponent(self._btnElder, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnElder); 
    self._onClickBtnNormal = function(go) self:_OnClickBtnNormal(self) end
	UIUtil.GetComponent(self._btnNormal, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnNormal);

    
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_KICK, self._OnSetAndClose, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_SET_IDENTITY, self._OnSetAndClose, self);
end


function GuildMemberPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildMemberPanel:_DisposeReference()
    
end

function GuildMemberPanel:_DisposeListener()
    UIUtil.GetComponent(self._bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickClose = nil;

    UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDetail = nil;
    UIUtil.GetComponent(self._btnChat, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnChat = nil;
    UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFriend = nil;
    UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnParty = nil;
    UIUtil.GetComponent(self._btnIdentity, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnIdentity = nil;
    UIUtil.GetComponent(self._btnKick, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnKick = nil;
    UIUtil.GetComponent(self._btnTransfer, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTransfer = nil;

    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnAssLeader, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAssLeader = nil;
    --UIUtil.GetComponent(self._btnElder, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --self._onClickBtnElder = nil;
    UIUtil.GetComponent(self._btnNormal, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnNormal = nil;
    
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_KICK, self._OnSetAndClose);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_SET_IDENTITY, self._OnSetAndClose);
end

function GuildMemberPanel:_OnClickClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_MEMBER_PANEL);
end

function GuildMemberPanel:_OnSetAndClose()
    self:_OnClickClose();
    MessageManager.Dispatch(GuildNotes, GuildNotes.ENV_GUILD_REFRESH);
end

function GuildMemberPanel:UpdateDisplay(data)
    self.data = data;
    self:UpdateMode(GuildMemberPanel.MODE.MENU);
    if data then
        self._icoHead.spriteName = data.kind;
        self._txtName.text = data.name;
        self._txtLevel.text = data.level;
        local iStr = LanguageMgr.Get("guild/Identity/" .. data.identity);
        self._txtDesc.text = LanguageMgr.Get("guild/identity/desc", {identity = iStr, name = data.name});
        
        local info = GuildDataManager.info;

        local idt = info.identity < data.identity;
        local grant = GuildDataManager.GetGrant(GuildDataManager.opt.promotion);
        
        CommonColor.TryButtonEnable(self._btnTransfer.gameObject, idt and data.identity == GuildInfo.Identity.AssLeader);
        --CommonColor.TryButtonEnable(self._btnTransfer.gameObject, idt );
        CommonColor.TryButtonEnable(self._btnIdentity.gameObject, grant and idt);
        CommonColor.TryButtonEnable(self._btnAssLeader.gameObject, idt);
        --CommonColor.TryButtonEnable(self._btnElder.gameObject, idt);
        CommonColor.TryButtonEnable(self._btnNormal.gameObject, idt);

        CommonColor.TryButtonEnable(self._btnKick.gameObject, idt and GuildDataManager.GetGrant(GuildDataManager.opt.dismissal));
        
    else
        self._icoHead.spriteName = "";
        self._txtName.text = "";
        self._txtLevel.text = "";

        CommonColor.TryButtonEnable(self._btnTransfer.gameObject, false);
        CommonColor.TryButtonEnable(self._btnIdentity.gameObject, false);
    end
    local num = 0;
    local max = 0;
    
    local cfg = GuildDataManager.GetMyGuildCfg();
    if cfg then
        num = GuildDataManager.iNum[2] or 0;
        max = cfg.vice_chairman;
    end
    self._txtAssLeader.text = LanguageMgr.Get("guild/identityNum/2", {num = num, max = max});
    
    --[[
    if cfg then
        num = GuildDataManager.iNum[3] or 0;
        max = cfg.elders;
    end
    self._txtElder.text = LanguageMgr.Get("guild/identityNum/3", {num = num, max = max});
    ]]
    self._txtNormal.text = LanguageMgr.Get("guild/identityNum/4");

end

function GuildMemberPanel:UpdateMode(mode)
    self.mode = mode;
    self._trsInfo.gameObject:SetActive(mode == GuildMemberPanel.MODE.MENU);
    self._trsIdentity.gameObject:SetActive(mode == GuildMemberPanel.MODE.IDENTITY);
end

function GuildMemberPanel:_OnClickBtnDetail()
    ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, self.data.id);
end

function GuildMemberPanel:_OnClickBtnChat()
    FriendDataManager.TryOpenCharUI(self.data.id)
end

function GuildMemberPanel:_OnClickBtnFriend()
    AddFriendsProxy.TryAddFriend(self.data.id);
end

function GuildMemberPanel:_OnClickBtnParty()
    FriendProxy.TryInviteToTeam(self.data.id,self.data.name);
end

function GuildMemberPanel:_OnClickBtnIdentity()
    self:UpdateMode(GuildMemberPanel.MODE.IDENTITY);
end

function GuildMemberPanel:_OnClickBtnKick()
    MsgUtils.ShowConfirm(self, "guild/msg/kick", {name = self.data.name}, GuildMemberPanel._ConfirmKick);
end

function GuildMemberPanel:_ConfirmKick()
    GuildProxy.ReqKick(self.data.id);
end

function GuildMemberPanel:_OnClickBtnTransfer()
    --[[
    if self.data.identity ~= GuildInfo.Identity.AssLeader then
        MsgUtils.ShowTips("error/guild/TransferIsNotAssLeader");
        return;
    end
    ]]
    MsgUtils.ShowConfirm(self, "guild/msg/transfer", {name = self.data.name}, GuildMemberPanel._ConfirmTransfer);
end

function GuildMemberPanel:_ConfirmTransfer()
    GuildProxy.ReqSetIdentity(self.data.id, GuildInfo.Identity.Leader);
end

function GuildMemberPanel:_OnClickBtnClose()
    self:UpdateMode(GuildMemberPanel.MODE.MENU);
end

function GuildMemberPanel:_OnClickBtnAssLeader()
    GuildProxy.ReqSetIdentity(self.data.id, GuildInfo.Identity.AssLeader);
end

function GuildMemberPanel:_OnClickBtnElder()
    GuildProxy.ReqSetIdentity(self.data.id, GuildInfo.Identity.Elder);
end

function GuildMemberPanel:_OnClickBtnNormal()
    GuildProxy.ReqSetIdentity(self.data.id, GuildInfo.Identity.Normal);
end




