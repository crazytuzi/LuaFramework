require "Core.Module.Common.Panel";
require "Core.Module.GuildWar.View.Item.GuildWarRoleItem";

GuildWarDetailPanel = Panel:New();

function GuildWarDetailPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildWarDetailPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._btnExit = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnExit");

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
	self._txtRank = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtRank");
	self._txtName = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtName");
	self._txtPoint = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtPoint");
	self._txtMyPoint = UIUtil.GetChildByName(self._trsInfo, "UILabel", "txtMyPoint");

	self._btnDesc = UIUtil.GetChildByName(self._trsInfo, "UIButton", "btnDesc");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "ScrollView/phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildWarRoleItem);
end

function GuildWarDetailPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

	self._onClickBtnExit = function(go) self:_OnClickBtnExit(self) end
	UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnExit);

	self._onClickBtnDesc = function () self:_OnClickBtnDesc() end
    UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDesc);

	MessageManager.AddListener(GuildWarNotes, GuildWarNotes.RSP_DETAIL_INFO, GuildWarDetailPanel.UpdateDisplay, self);
end

function GuildWarDetailPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end
 
function GuildWarDetailPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

	UIUtil.GetComponent(self._btnExit, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnExit = nil;

	UIUtil.GetComponent(self._btnDesc, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDesc = nil;

	MessageManager.RemoveListener(GuildWarNotes, GuildWarNotes.RSP_DETAIL_INFO, GuildWarDetailPanel.UpdateDisplay);
end

function GuildWarDetailPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildWarDetailPanel:_Opened()
   	--self:UpdateDisplay();
   	GuildWarProxy.ReqDetail();
end

function GuildWarDetailPanel:UpdateDisplay(data)

	local myInfo = nil; 
	local pid = PlayerManager.hero.id;
	for i, v in ipairs(data.l) do 
		if v.pi == pid then
			myInfo = v;
			break;
		end
	end

	local items = data.l;
	self._phalanx:Build(#items, 1 , items);
	
	self._txtRank.text = myInfo and myInfo.id or "";
	self._txtName.text = GuildDataManager.war.etgn;
	self._txtPoint.text = data.pt;
	self._txtMyPoint.text = myInfo and myInfo.pt or "";
end

function GuildWarDetailPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(GuildWarNotes.CLOSE_DETAIL_PANEL);
end

function GuildWarDetailPanel:_OnClickBtnExit()
	MsgUtils.ShowConfirm(self, "GuildWar/Exit", nil, GuildWarDetailPanel._ConfirmExit);
end

function GuildWarDetailPanel:_ConfirmExit()
	GuildWarProxy.ReqExitWar();
end

function GuildWarDetailPanel:_OnClickBtnDesc()
    ModuleManager.SendNotification(GuildWarNotes.OPEN_DESC_PANEL);
end