require "Core.Module.Common.Panel"
require "Core.Module.Realm.View.RealmUpgradePanel"
require "Core.Module.Realm.View.RealmCompactPanel"
require "Core.Module.Realm.View.RealmTheurgyPanel"


RealmPanel = class("RealmPanel", Panel);
function RealmPanel:New()
	self = {};
	setmetatable(self, {__index = RealmPanel});
	return self
end

function RealmPanel:_Init()
	self._panels = {};
	self:_InitReference();
	self:_InitListener();
	--self:SelectSubPanel(1);
end


function RealmPanel:_InitReference()
	self._panels = {}
	-- self._imgBg = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgBg");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnTab1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTab1");
	self._btnTabTip1 = UIUtil.GetChildByName(self._trsContent, "Transform", "btnTab1/imgTip");
	self._btnTab2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTab2");
	self._btnTabTip2 = UIUtil.GetChildByName(self._trsContent, "Transform", "btnTab2/imgTip");
	self._btnTab3 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnTab3");
	self._btnTabTip3 = UIUtil.GetChildByName(self._trsContent, "Transform", "btnTab3/imgTip");
	self._btnTab2.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.JingJieNinLian));
	
	self._toggles = {self._btnTab1, self._btnTab2, self._btnTab3};
	
	MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_UPGRADETIP_CHANGE, RealmPanel._OnUpgradeTipChange, self);
	MessageManager.AddListener(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, RealmPanel._OnCompactIipChange, self);
	self:_OnCompactIipChange(RealmManager.CanCompact())
	
	local panels = UIUtil.GetChildByName(self._trsContent, "Transform", "panels");
	if(panels) then
		local p1 = UIUtil.GetChildByName(panels, "Transform", "panel1");
		if(p1) then
			self._panels[1] = RealmUpgradePanel:New(p1);
		end
		
		local p2 = UIUtil.GetChildByName(panels, "Transform", "panel2");
		if(p2) then
			self._panels[2] = RealmCompactPanel:New(p2);
		end
		
		local p3 = UIUtil.GetChildByName(panels, "Transform", "panel3");
		if(p3) then
			self._panels[3] = RealmTheurgyPanel:New(p3);
		end
	end
	self._btnTab3.gameObject:SetActive(SystemManager.IsOpen(SystemConst.Id.Theurgy));
	local bg = UIUtil.GetChildByName(self._trsContent, "UITexture", "imgBg");
	self._bgEffect = UIEffect:New()
	self._bgEffect:Init(self._transform, bg, 0, "ui_jingjie_bg")	
end

function RealmPanel:_Opened()
	if(self._bgEffect) then
		self._bgEffect:Play()
	end
end

function RealmPanel:_InitListener()
	self._onClickCloseHandler = function(go) self:_OnClickCloseHandler(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCloseHandler);
	
	self._onClickTab1Handler = function(go) self:_OnClickTab1Handler(self) end
	UIUtil.GetComponent(self._btnTab1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab1Handler);
	
	self._onClickTab2Handler = function(go) self:_OnClickTab2Handler(self) end
	UIUtil.GetComponent(self._btnTab2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab2Handler);
	
	self._onClickTab3Handler = function(go) self:_OnClickTab3Handler(self) end
	UIUtil.GetComponent(self._btnTab3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab3Handler);
	
end

function RealmPanel:_OnUpgradeTipChange(visible)
	self._btnTabTip1.gameObject:SetActive(visible)
end

function RealmPanel:_OnCompactIipChange(visible)
	self._btnTabTip2.gameObject:SetActive(RealmManager.CanCompact())
end


function RealmPanel:_OnClickCloseHandler()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
	ModuleManager.SendNotification(RealmNotes.CLOSE_REALM)
end

function RealmPanel:_OnClickTab1Handler()
	self:SelectSubPanel(1)
end

function RealmPanel:_OnClickTab2Handler()
	self:SelectSubPanel(2)
end

function RealmPanel:_OnClickTab3Handler()
	self:SelectSubPanel(3)
end

function RealmPanel:SelectSubPanel(index)
	if(self._index ~= index and index) then
		for i, v in pairs(self._panels) do
			if(i == index) then
				v:Enable()
				self:SetBtnToggleActive(self._toggles[i], true);
			else
				v:Disable()
				self:SetBtnToggleActive(self._toggles[i], false);
			end
		end
		self._index = index
		SequenceManager.TriggerEvent(SequenceEventType.Guide.REALM_CHANGE_PANEL, index)
	end
end

function RealmPanel:SetBtnToggleActive(btn, bool)
	local toggle = UIUtil.GetComponent(btn, "UIToggle");
	toggle.value = bool;
end


function RealmPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RealmPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickCloseHandler = nil;
	
	UIUtil.GetComponent(self._btnTab1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTab1Handler = nil;
	
	UIUtil.GetComponent(self._btnTab2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTab2Handler = nil;
	
	UIUtil.GetComponent(self._btnTab3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTab3Handler = nil;
	
	MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_UPGRADETIP_CHANGE, RealmPanel._OnUpgradeTipChange);
	MessageManager.RemoveListener(RealmNotes, RealmNotes.EVENT_COMPACTTIP_CHANGE, RealmPanel._OnCompactIipChange);
end

function RealmPanel:_DisposeReference()
	for i, v in pairs(self._panels) do
		v:Dispose()
	end
	self._panels = nil;
	self._btnClose = nil;
	self._btnTab1 = nil;
	self._btnTab2 = nil;
	self._btnTab3 = nil;
	self._btnTabTip1 = nil;
	self._btnTabTip2 = nil;
	self._btnTabTip3 = nil;
	if(self._bgEffect) then
		self._bgEffect:Dispose()
		self._bgEffect = nil
	end
	-- self._imgBg = nil;
end 