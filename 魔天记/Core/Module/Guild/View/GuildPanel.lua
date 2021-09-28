require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.GuildInfoSubPanel";
require "Core.Module.Guild.View.GuildMemberSubPanel";
require "Core.Module.Guild.View.GuildActSubPanel";
require "Core.Module.Guild.View.GuildAwardSubPanel";


GuildPanel = Panel:New();

function GuildPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildPanel:_InitReference()
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btnClose");
	self._btnInfo = UIUtil.GetChildInComponents(btns, "btnInfo");
	self._btnMember = UIUtil.GetChildInComponents(btns, "btnMember");
	self._btnAct = UIUtil.GetChildInComponents(btns, "btnAct");
	self._btnAward = UIUtil.GetChildInComponents(btns, "btnAward");
	
	self._redPoint = {};
	self._redPoint[1] = UIUtil.GetChildByName(self._btnInfo, "UISprite", "redPoint");
	self._redPoint[2] = UIUtil.GetChildByName(self._btnMember, "UISprite", "redPoint");
	self._redPoint[3] = UIUtil.GetChildByName(self._btnAct, "UISprite", "redPoint");
	self._redPoint[4] = UIUtil.GetChildByName(self._btnAward, "UISprite", "redPoint");
	
	self._mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
	self._trsInfoPanel = UIUtil.GetChildByName(self._mainView, "Transform", "InfoPanel");
	self._trsMemberPanel = UIUtil.GetChildByName(self._mainView, "Transform", "MemberPanel");
	self._trsActPanel = UIUtil.GetChildByName(self._mainView, "Transform", "ActPanel");
	self._trsAwardPanel = UIUtil.GetChildByName(self._mainView, "Transform", "AwardPanel");
	
	self._txtId = UIUtil.GetChildByName(self._trsContent, "UILabel", "titleId/txtId");
	self._txtTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTitle");
	
	self._infoSubPanel = GuildInfoSubPanel.New();
	self._memberSubPanel = GuildMemberSubPanel.New();
	self._actSubPanel = GuildActSubPanel.New();
	self._awardSubPanel = GuildAwardSubPanel.New();
	self._infoSubPanel:Init(self._trsInfoPanel);
	self._memberSubPanel:Init(self._trsMemberPanel);
	self._actSubPanel:Init(self._trsActPanel);
	self._awardSubPanel:Init(self._trsAwardPanel);
	
	self._subPanels = {self._infoSubPanel, self._memberSubPanel, self._actSubPanel, self._awardSubPanel};
	self._toggles = {self._btnInfo, self._btnMember, self._btnAct, self._btnAward};
	self._panelIdx = 0;
--self:OpenSubPanel(1);
end

function GuildPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	
	self._onClickToggle = function(go) self:_OnClickToggle(go) end
	UIUtil.GetComponent(self._btnInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	UIUtil.GetComponent(self._btnMember, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	UIUtil.GetComponent(self._btnAct, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle);
	
	MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_REFRESH, GuildPanel.Refresh, self);
	MessageManager.AddListener(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, GuildPanel.UpdateRedPoint, self);
	MessageManager.AddListener(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, GuildPanel.SetRewardRedPoint, self);
    MessageManager.AddListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT,GuildPanel.SetInfoRedPoint, self);
	MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildPanel.SetRewardRedPoint, self);
    MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, GuildPanel.SetRewardRedPoint, self);
end

function GuildPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	
	UIUtil.GetComponent(self._btnInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnMember, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnAct, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btnAward, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle = nil;
	
	MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_REFRESH, GuildPanel.Refresh);
	MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_UPDATE_REDPOINT, GuildPanel.UpdateRedPoint);
	MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, GuildPanel.SetRewardRedPoint);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.HONGBAOREDPOINT,GuildPanel.SetInfoRedPoint);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildPanel.SetRewardRedPoint);
    MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_GUILD_SKILLPOINT_CHANGE, GuildPanel.SetRewardRedPoint);
end

function GuildPanel:_DisposeReference()
	self._btnClose = nil;
	
	self._infoSubPanel:Dispose();
	self._memberSubPanel:Dispose();
	self._actSubPanel:Dispose();
	self._awardSubPanel:Dispose();
end

function GuildPanel:_Opened()
	GuildProxy.ReqGetSalaryStatus();
	self:UpdateDisplay();
end


function GuildPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);
end

function GuildPanel:_OnClickToggle(go)
	if go.name == "btnInfo" then
		self:OpenSubPanel(1);
	elseif go.name == "btnMember" then
		self:OpenSubPanel(2);
	elseif go.name == "btnAct" then
		self:OpenSubPanel(3);
	elseif go.name == "btnAward" then
		self:OpenSubPanel(4);
	end
end

function GuildPanel:UpdateDisplay()
	local data = GuildDataManager.data;
	self._txtId.text = data.id;
	self._txtTitle.text = data.name;
	
	self:UpdateRedPoint();
end

function GuildPanel:Refresh()
	if self._panelIdx > 0 then
		self._curPanel:Refresh();
	end
end

function GuildPanel:SetBtnToggleActive(btn, bool)
	local toggle = UIUtil.GetComponent(btn, "UIToggle");
	toggle.value =(bool);
end

function GuildPanel:OpenSubPanel(idx)
	if self._panelIdx ~= idx then
		local cur = nil;
		for i, v in ipairs(self._subPanels) do
			local toggleBtn = self._toggles[i];
			if i == idx then
				cur = v;
				self:SetBtnToggleActive(toggleBtn, true);
			else
				v:Disable();
				self:SetBtnToggleActive(toggleBtn, false);
			end
		end
		if cur then
			self._curPanel = cur;
			cur:Enable();
		end
		self._panelIdx = idx;
	end
end


function GuildPanel:UpdateRedPoint()
	for i, v in ipairs(self._redPoint) do
		v.gameObject:SetActive(false);
	end
	self:SetInfoRedPoint()
	self:SetMemberRedPoint();
	self:SetRewardRedPoint();
end

function GuildPanel:SetInfoRedPoint()
	self._redPoint[1].gameObject:SetActive(GuildDataManager.GetInfoRedPoint());
end

function GuildPanel:SetMemberRedPoint()
	self._redPoint[2].gameObject:SetActive(GuildDataManager.GetMemberRedPoint());    
end

function GuildPanel:SetRewardRedPoint()
	self._redPoint[4].gameObject:SetActive(GuildDataManager.GetRewardRedPoint());
end

 