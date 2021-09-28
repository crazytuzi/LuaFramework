require "Core.Module.Common.Panel";

GuildMoBaiPanel = Panel:New();

function GuildMoBaiPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
end

function GuildMoBaiPanel:_InitReference()
    
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
    self._btnActive = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnActive");
    self._btnOpt = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOpt");
    self._txtBtnOpt = UIUtil.GetChildByName(self._btnOpt, "UILabel", "txtBtnOpt");
    self._txtFight = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtFight");
    self._titleCount = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleCount");
    self._txtCount = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleCount/txtCount");

    self._imgRole = UIUtil.GetChildByName(self._trsContent, "Transform", "imgRole");
    self._trsRoleParent = UIUtil.GetChildByName(self._imgRole, "Transform", "heroCamera/trsRoleParent");
end

function GuildMoBaiPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnActive = function(go) self:_OnClickBtnActive(self) end
	UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnActive);

	self._onClickBtnOpt = function(go) self:_OnClickBtnOpt(self) end
	UIUtil.GetComponent(self._btnOpt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOpt);

	MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MOBAI_INFO, GuildMoBaiPanel.UpdateDisplay, self);
	MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MOBAI_OPT, GuildMoBaiPanel.OnRspOpt, self);
	MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MOBAI_ACTIVE, GuildMoBaiPanel.OnRspActive, self);
	
	
end

function GuildMoBaiPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildMoBaiPanel:_DisposeReference()

	if self._uiAnimationModel then 
        self._uiAnimationModel:Dispose();
    end

    NGUITools.DestroyChildren(self._trsRoleParent);
end

function GuildMoBaiPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnActive, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnActive = nil;

    UIUtil.GetComponent(self._btnOpt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOpt = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MOBAI_INFO, GuildMoBaiPanel.UpdateDisplay);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MOBAI_OPT, GuildMoBaiPanel.OnRspOpt);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MOBAI_ACTIVE, GuildMoBaiPanel.OnRspActive);
end

function GuildMoBaiPanel:_Opened()
    GuildProxy.ReqMoBaiInfo();
end

function GuildMoBaiPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_OTHER_PANEL, GuildNotes.OTHER.MOBAI);
end

function GuildMoBaiPanel:UpdateDisplay(data)
	self.data = data;
	self._txtName.text = data.pn;
	self._txtFight.text = data.f;
	
    self:UpdateInfo();

    local roleData = {};
    roleData.kind = data.kind;
    roleData.dress = data.dress;
	if (self._uiAnimationModel == nil) then
        self._uiAnimationModel = UIAnimationModel:New(roleData, self._trsRoleParent, UIRoleModelCreater);
    else
        self._uiAnimationModel:ChangeModel(roleData, self._trsRoleParent);
    end

end

function GuildMoBaiPanel:UpdateInfo()

	if self.data.pi == PlayerManager.playerId then
    	self._btnActive.gameObject:SetActive(self.data.task < 1);
    	self._txtBtnOpt.text = LanguageMgr.Get("guild/mobai/xy");
    	self._titleCount.text = LanguageMgr.Get("guild/mobai/numDesc/xy");
    else
    	self._btnActive.gameObject:SetActive(false);
    	self._txtBtnOpt.text = LanguageMgr.Get("guild/mobai/mb");
    	self._titleCount.text = LanguageMgr.Get("guild/mobai/numDesc/mb");
    end

	local num = 1 - self.data.wh;
    self._txtCount.text = num;
end

function GuildMoBaiPanel:_OnClickBtnActive()
    MsgUtils.UseGoldConfirm(100, self, "guild/mobai/buy", nil, GuildMoBaiPanel.OnConfirmActive, nil, nil, "common/ok");
end

function GuildMoBaiPanel:OnConfirmActive()
    GuildProxy.ReqMoBaiActive();
end

function GuildMoBaiPanel:_OnClickBtnOpt()
	if self.data.wh > 0 then
        MsgUtils.ShowTips("guild/mobai/no/" .. (self.data.pi == PlayerManager.playerId and "1" or "0"));
		return;
	end
	GuildProxy.ReqMoBaiOpt();
end

function GuildMoBaiPanel:OnRspOpt(d)
	self.data.wh = d;
	self:UpdateInfo();
	--self:_OnClickBtnClose();
end

function GuildMoBaiPanel:OnRspActive(d)
	self.data.task = d;
	self:UpdateInfo();
	--self:_OnClickBtnClose();
end
