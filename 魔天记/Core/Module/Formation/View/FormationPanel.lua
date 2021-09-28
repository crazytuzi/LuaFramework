require "Core.Module.Common.Panel"

local FormationPanel = class("FormationPanel",Panel);
local FormationUpPanel = require "Core.Module.Formation.View.FormationUpPanel"
function FormationPanel:New()
	self = { };
	setmetatable(self, { __index =FormationPanel });
	return self
end


function FormationPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateTip()
end

function FormationPanel:_InitReference()
	local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
	self._imgTip = UIUtil.GetChildInComponents(imgs, "imgTip");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnTab1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTab1");
	self._trsFormation = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFormation")
    self._formation = FormationUpPanel:New()
    self._formation:Init(self._trsFormation)
    MessageManager.AddListener(FormationNotes, FormationNotes.FORMATION_CHANGE,FormationPanel.UpdateTip, self)
end

function FormationPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnTab1 = function(go) self:_OnClickBtnTab1(self) end
	UIUtil.GetComponent(self._btnTab1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTab1);
end

function FormationPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(FormationNotes.CLOSE_FORMATION_PANEL)
end

function FormationPanel:_OnClickBtnTab1()
	
end

function FormationPanel:UpdateTip()
	self._imgTip.enabled = FormationManager.HasTips()
end

function FormationPanel:SetPanel(db)
	if self._formation then self._formation:UseProduct(db and db.id or nil) end
end

function FormationPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function FormationPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnTab1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTab1 = nil;
    MessageManager.RemoveListener(FormationNotes, FormationNotes.FORMATION_CHANGE,FormationPanel.UpdateTip)
end

function FormationPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnTab1 = nil;
	self._imgTip = nil;
    if self._formation then self._formation:Dispose() self._formation = nil end
end
return FormationPanel