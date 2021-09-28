require "Core.Module.Common.Panel"
require "Core.Module.Common.ProductItems"

UI_AppSplitPanel = class("UI_AppSplitPanel",Panel);
function UI_AppSplitPanel:New()
	self = { };
	setmetatable(self, { __index =UI_AppSplitPanel });
	return self
end


function UI_AppSplitPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function UI_AppSplitPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtPress = UIUtil.GetChildInComponents(txts, "txtPress");
	self._txtLabel = UIUtil.GetChildInComponents(txts, "txtLabel");
	local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
	self._imgPress = UIUtil.GetChildInComponents(imgs, "imgPress");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnPause = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnPause");
	self._btnGet = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGet");
    self._trsItem = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem");
    if not AppSplitDownProxy.Loaded() then
        self._timer = Timer.New(function() self:Update() end, -1, 0.5, true)
        self._timer:Start()
    end
    self:InitAward()
    self:_SetBtnLabel()
    self:Update()
end

function UI_AppSplitPanel:Show()
    self:SetActive(true)
    self:_SetBtnLabel()
    self:Update()
    self:UpdateDepth()
end
function UI_AppSplitPanel:Hide()
    self:SetActive(false)
end

function UI_AppSplitPanel:InitAward()
	local award = AppSplitDownProxy.GetAwardConfig()
    self._products = ProductItems:New()
    self._products:Init(self._trsItem, award, 120, 120, 6)
end

function UI_AppSplitPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnPause = function(go) self:_OnClickBtnPause(self) end
	UIUtil.GetComponent(self._btnPause, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPause);
	self._onClickBtnGet = function(go) self:_OnClickBtnGet(self) end
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGet);
end

function UI_AppSplitPanel:Update()
    self._imgPress.width = 455 * (AppSplitDownProxy.process / 100)
    self._txtPress.text = AppSplitDownProxy.GetProcessDec()
    self:_SetBtnVisible()
end
function UI_AppSplitPanel:_SetBtnVisible()
    local loaded = AppSplitDownProxy.Loaded()
    self._btnGet.gameObject:SetActive(loaded and not AppSplitDownProxy.GetAwarded())
    self._btnPause.gameObject:SetActive(AppSplitDownProxy.GetStateIsLoading())
end

function UI_AppSplitPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(AppSplitDownNotes.CLOSE_APPSPLITDOWN)
end

function UI_AppSplitPanel:_OnClickBtnPause()
	if AppSplitDownProxy.puased then AppSplitDownProxy.Start()
    else AppSplitDownProxy.Pause() end
    self:_SetBtnLabel()
end
function UI_AppSplitPanel:_SetBtnLabel()
    self._txtLabel.text = AppSplitDownProxy.puased and 
        LanguageMgr.Get("UI_AppSplitPanel/start") or LanguageMgr.Get("UI_AppSplitPanel/puase")
end

function UI_AppSplitPanel:_OnClickBtnGet()
	AppSplitDownProxy.GetAward()
    ModuleManager.SendNotification(AppSplitDownNotes.CLOSE_APPSPLITDOWN)
end

function UI_AppSplitPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function UI_AppSplitPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnPause, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnPause = nil;
	UIUtil.GetComponent(self._btnGet, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnGet = nil;
    if self._timer then 
        self._timer:Stop()
        self._timer = nil
    end
    if self._products then self._products:Dispose() end
end

function UI_AppSplitPanel:_DisposeReference()
	self._btnClose = nil;
	self._btnPause = nil;
	self._btnGet = nil;
	self._txtPress = nil;
	self._txtLabel = nil;
	self._imgPress = nil;
end
