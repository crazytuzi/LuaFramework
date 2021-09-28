require "Core.Module.Common.Panel"
local ImmortalShopBuy = require "Core.Module.ImmortalShop.View.ImmortalShopBuy"
local ImmortalShopRank = require "Core.Module.ImmortalShop.View.ImmortalShopRank"
local ImmortalShopRevelry = require "Core.Module.ImmortalShop.View.ImmortalShopRevelry"

local ImmortalShopPanel = class("ImmortalShopPanel",Panel);
function ImmortalShopPanel:New()
	self = { };
	setmetatable(self, { __index =ImmortalShopPanel });
	return self
end


function ImmortalShopPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._panels = {}
	self._panels[1] = ImmortalShopBuy:New()
	self._panels[2] = ImmortalShopRank:New()
	self._panels[3] = ImmortalShopRevelry:New()
    self._panels[1]:Init(self._trsBuy)
    self._panels[2]:Init(self._trsRank)
    self._panels[3]:Init(self._trsRevelry)
    self._actConfig = TimeLimitActManager.GetAct(SystemConst.Id.ImmortalShop)
    self._timer = Timer.New(function() self:_UpdateTime() end, 1, -1, true)
    self._timer:Start()
    self:_UpdateTime()
    self:_ChangePanel(1)
    ImmortalShopProxy.SendImmortalRevelry()--红点需要
end

function ImmortalShopPanel:_InitReference()
	self._txtDownTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDownTime")
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._togBuy = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togBuy");
	self._togBuyTip = UIUtil.GetChildByName(self._togBuy, "UISprite", "icoRedPoint");
	self._togRank = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togRank");
	self._togRevelry = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togRevelry");
	self._togRevelryTip = UIUtil.GetChildByName(self._togRevelry, "UISprite", "icoRedPoint");
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsBuy = UIUtil.GetChildInComponents(trss, "trsBuy");
	self._trsRank = UIUtil.GetChildInComponents(trss, "trsRank");
	self._trsRevelry = UIUtil.GetChildInComponents(trss, "trsRevelry");
end

function ImmortalShopPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickTab1 = function(go) self:_ChangePanel(1) end
	UIUtil.GetComponent(self._togBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab1);
	self._onClickTab2 = function(go) self:_ChangePanel(2) end
	UIUtil.GetComponent(self._togRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab2);
	self._onClickTab3 = function(go) self:_ChangePanel(3) end
	UIUtil.GetComponent(self._togRevelry, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab3);
	MessageManager.AddListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE, ImmortalShopPanel.UpdateMsgImmortalShop, self)
end

function ImmortalShopPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(ImmortalShopNotes.CLOSE_IMMORTAL_SHOP_PANEL)
end
function ImmortalShopPanel:_ChangePanel(tab)
	for i, v in ipairs(self._panels)  do
        --Warning(i .. '---' .. tostring(v) .. '-' .. tab)
        self._panels[i]:SetActive(tab == i)
    end
end
function ImmortalShopPanel:_UpdateTime()
    local t = TimeLimitActManager.GetDownTime(self._actConfig)  
	self._txtDownTime.text = TimeUtil.GetTimeShort(t, 10)
end
function ImmortalShopPanel:UpdateMsgImmortalShop()
    self._togBuyTip.enabled = ImmortalShopProxy.GetBuyRedPoint()
    self._togRevelryTip.enabled = ImmortalShopProxy.GetRevelryRedPoint()
    --Warning(tostring(self._togBuyTip.enabled) .. tostring(self._togRevelryTip.enabled))
end

function ImmortalShopPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function ImmortalShopPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._togBuy, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._togRank, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._togRevelry, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickTab1 = nil;
	self._onClickTab2 = nil;
	self._onClickTab3 = nil;
    MessageManager.RemoveListener(ImmortalShopNotes, ImmortalShopNotes.IMMORTAL_TIP_CHANBE, ImmortalShopPanel.UpdateMsgImmortalShop)
end

function ImmortalShopPanel:_DisposeReference()
    if self._panels then
        for i, v in ipairs(self._panels)  do
            self._panels[i]:Dispose()
        end
        self._panels = nil
    end
    if self._timer then self._timer:Stop() self._timer = nil end
	self._btn_close = nil;
	self._togBuy = nil;
	self._togRank = nil;
	self._togRevelry = nil;
	self._txtDownTime = nil;
	self._trsBuy = nil;
	self._trsRank = nil;
	self._trsRevelry = nil;
end
return ImmortalShopPanel