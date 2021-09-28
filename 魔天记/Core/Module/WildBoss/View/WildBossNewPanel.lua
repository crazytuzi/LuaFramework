require "Core.Module.Common.Panel"
local WildBossFieldPanel = require "Core.Module.WildBoss.View.WildBossFieldPanel";
local WildBossVipPanel = require "Core.Module.WildBoss.View.WildBossVipPanel";

local WildBossNewPanel = class("WildBossNewPanel", Panel);

function WildBossNewPanel:New()
	self = {};
	setmetatable(self, {__index = WildBossNewPanel});
	return self
end

function WildBossNewPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function WildBossNewPanel:_InitReference()
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	
	self._trsToggle = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTabs");
	self._toggles = {};
	self._toggles[1] = UIUtil.GetChildByName(self._trsToggle, "UIToggle", "classify_1");
	self._toggles[2] = UIUtil.GetChildByName(self._trsToggle, "UIToggle", "classify_2");
	
	self._views = {};
	self._trsView = UIUtil.GetChildByName(self._trsContent, "Transform", "trsView");
	self._trsField = UIUtil.GetChildByName(self._trsView, "Transform", "trsField");
	self._fieldPanel = WildBossFieldPanel.New(self._trsField);
	
	self._trsVip = UIUtil.GetChildByName(self._trsView, "Transform", "trsVip");
	self._vipPanel = WildBossVipPanel.New(self._trsVip);
	
	self._views = {self._fieldPanel, self._vipPanel};
	
	self._redPoints = {};
	self._redPoints[1] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "classify_1/npoint");
	self._redPoints[2] = UIUtil.GetChildByName(self._trsToggle, "UISprite", "classify_2/npoint");
	
end

function WildBossNewPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	
	self._onClickBtnField = function(go) self:UpdateTab(1) end
	UIUtil.GetComponent(self._toggles[1], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnField);
	self._onClickBtnVip = function(go) self:UpdateTab(2) end
	UIUtil.GetComponent(self._toggles[2], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnVip);
	
end

function WildBossNewPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(WildBossNotes.CLOSE_WILDBOSSPANEL)
end

function WildBossNewPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
end

function WildBossNewPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	
	UIUtil.GetComponent(self._toggles[1], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnField = nil;
	UIUtil.GetComponent(self._toggles[2], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnVip = nil;
	
	self._fieldPanel:Dispose();
	self._vipPanel:Dispose();
end

function WildBossNewPanel:_DisposeReference()
	self._btn_close = nil;
end

function WildBossNewPanel:UpdatePanel()
	self._fieldPanel:UpdatePanel();
end

function WildBossNewPanel:SetOpenParam(p)
	self._tabIdx = p.tab or 1;
end

function WildBossNewPanel:_Opened()
	self:UpdateTab(self._tabIdx or 1);
	self:UpdateRedPoint();
end

function WildBossNewPanel:UpdateTab(idx)
	self._toggles[idx].value = true;
	
	for i, v in ipairs(self._views) do
		if i == idx then
			v:Enable();
		else
			v:Disable();
		end
	end
	SequenceManager.TriggerEvent(SequenceEventType.Guide.WILD_BOSS_TAB_CHG, idx);
end

function WildBossNewPanel:UpdateRedPoint()
	for i, v in ipairs(self._redPoints) do
		v.alpha = 0;
	end
end

function WildBossNewPanel:SetIndex(index)
	if(self._fieldPanel) then
		self._fieldPanel:SetIndex(index)
	end
end

return WildBossNewPanel 