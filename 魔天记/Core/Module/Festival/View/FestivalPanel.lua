require "Core.Module.Common.Panel"
local FestivalLoginPanel = require "Core.Module.Festival.View.FestivalLoginPanel"
local FestivalExchangePanel = require "Core.Module.Festival.View.FestivalExchangePanel"
local FestivalChargePanel = require "Core.Module.Festival.View.FestivalChargePanel"

local FestivalPanel = class("FestivalPanel",Panel)
function FestivalPanel:New()
	self = { }
	setmetatable(self, { __index =FestivalPanel })
	return self
end


function FestivalPanel:_Init()
	self:_InitReference()
	self:_InitListener()
    FestivalProxy.SendYYGetActvityInfo()--红点需要
	self._panels = {}
	self._panels[1] = FestivalLoginPanel:New()
	self._panels[2] = FestivalExchangePanel:New()
	self._panels[3] = FestivalChargePanel:New()
    self._panels[1]:Init(self._trsLogin)
    self._panels[2]:Init(self._trsExchange)
    self._panels[3]:Init(self._trsRecharge)
    local actConfig = TimeLimitActManager.GetAct(SystemConst.Id.MidAutumn)
    self._txtDownTime.text = LanguageMgr.Get("FestivalPanel/acttime",
        {t = actConfig.effective_time, t2 = actConfig.end_time })
    --self:UpdateMsgImmortalShop()
    self:_ChangePanel(1, true)
end

function FestivalPanel:_InitReference()
	self._txtDownTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDownTime")
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton")
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close")
	self._togBuy = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togBuy")
	self._togBuyTip = UIUtil.GetChildByName(self._togBuy, "UISprite", "icoRedPoint")
	self._togRank = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togRank")
	self._togRankTip = UIUtil.GetChildByName(self._togRank, "UISprite", "icoRedPoint")
	self._togRevelry = UIUtil.GetChildByName(self._trsContent, "UIToggle", "togRevelry")
	self._togRevelryTip = UIUtil.GetChildByName(self._togRevelry, "UISprite", "icoRedPoint")
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform")
	self._trsLogin = UIUtil.GetChildInComponents(trss, "trsLogin")
	self._trsExchange = UIUtil.GetChildInComponents(trss, "trsExchange")
	self._trsRecharge = UIUtil.GetChildInComponents(trss, "trsRecharge")
end

function FestivalPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close)
	self._onClickTab1 = function(go) self:_ChangePanel(1) end
	UIUtil.GetComponent(self._togBuy, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab1)
	self._onClickTab2 = function(go) self:_ChangePanel(2) end
	UIUtil.GetComponent(self._togRank, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab2)
	self._onClickTab3 = function(go) self:_ChangePanel(3) end
	UIUtil.GetComponent(self._togRevelry, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickTab3)
	MessageManager.AddListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, FestivalPanel.UpdateMsgImmortalShop, self)
end

function FestivalPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(FestivalNotes.CLOSE_FESTIVAL_PANEL)
end
function FestivalPanel:_ChangePanel(tab, f)
    self.tab = tab
	for i, v in ipairs(self._panels)  do
        if tab == i then            
            self._panels[i]:SetEnable(true)
            if not f then self._panels[i]:UpdatePanel(true) end
        else            
            self._panels[i]:SetEnable(false)
        end
    end
end
function FestivalPanel:UpdateMsgImmortalShop()
    self._togBuyTip.enabled = FestivalMgr.HasLoginTips()
    self._togRankTip.enabled = FestivalMgr.HasExchangeTips()
    self._togRevelryTip.enabled = FestivalMgr.HasRechargeTips()
    --Warning(tostring(self._togBuyTip.enabled) ..tostring(self._togRankTip.enabled) .. tostring(self._togRevelryTip.enabled))
    if self.tab then self._panels[self.tab]:UpdatePanel() end
end

function FestivalPanel:_Dispose()
	self:_DisposeListener()
	self:_DisposeReference()
end

function FestivalPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickBtn_close = nil
	UIUtil.GetComponent(self._togBuy, "LuaUIEventListener"):RemoveDelegate("OnClick")
	UIUtil.GetComponent(self._togRank, "LuaUIEventListener"):RemoveDelegate("OnClick")
	UIUtil.GetComponent(self._togRevelry, "LuaUIEventListener"):RemoveDelegate("OnClick")
	self._onClickTab1 = nil
	self._onClickTab2 = nil
	self._onClickTab3 = nil
    MessageManager.RemoveListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, FestivalPanel.UpdateMsgImmortalShop, self)
end

function FestivalPanel:_DisposeReference()
    if self._panels then
        for i, v in ipairs(self._panels)  do
            self._panels[i]:Dispose()
        end
        self._panels = nil
    end
	self._btn_close = nil
	self._togBuy = nil
	self._togRank = nil
	self._togRevelry = nil
	self._txtDownTime = nil
	self._trsLogin = nil
	self._trsExchange = nil
	self._trsRecharge = nil
end
return FestivalPanel