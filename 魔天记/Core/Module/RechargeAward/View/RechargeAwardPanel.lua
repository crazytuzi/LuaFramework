require "Core.Module.Common.Panel"
local RechargeAwardItem = require "Core.Module.RechargeAward.View.RechargeAwardItem"

local RechargeAwardPanel = class("RechargeAwardPanel",Panel);
function RechargeAwardPanel:New()
	self = { };
	setmetatable(self, { __index =RechargeAwardPanel });
	return self
end


function RechargeAwardPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function RechargeAwardPanel:_InitReference()
	self._txtOpenTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtOpenTime");
	self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
	self._trsDesc = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDesc");
	self._trsDesc2 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDesc2");
    self._item1 = RechargeAwardItem:New()
    self._item2 = RechargeAwardItem:New()
    self._item1:Init(self._trsDesc)
    self._item2:Init(self._trsDesc2)
    local t, id = RechargeAwardProxy.GetActiveInfo()
    local cs = RechargeAwardProxy.GetRechargeInfo(id)
    table.sort(cs, function(x, y) return x.cost < y.cost end)
    self._item1:SetConfig(cs[1])
    self._item2:SetConfig(cs[2])
    self.dt = t
    self._timer = Timer.New(function() self:_OnTime() end, 1, -1, false):Start()
    self.lastTime = GetTime()
    self:_OnTime()
end

function RechargeAwardPanel:_OnTime()
    local t = GetTime()
    self.dt = self.dt - (t - self.lastTime)
    self.lastTime = t
    --Warning(self.dt .. '____' .. Time.deltaTime)
    self._txtOpenTime.text = LanguageMgr.Get("RechargeAward/downtime") 
        .. TimeTranslateSecond(self.dt, 10)
    if self.dt <= 0 then
        self._timer:Stop()
        self._item1:TimeClose()
        self._item2:TimeClose()
    end
end
function RechargeAwardPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function RechargeAwardPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(RechargeAwardNotes.CLOSE_RECHARGET_PANEL)
end

function RechargeAwardPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RechargeAwardPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function RechargeAwardPanel:_DisposeReference()
	self._btn_close = nil;
	self._txtOpenTime = nil;
	self._trsDesc = nil;
	self._trsDesc2 = nil
    self._item1:Dispose()
    self._item1 = nil
    self._item2:Dispose()
    self._item2 = nil
    self._timer:Stop()
    self._timer = nil
end
return RechargeAwardPanel