require "Core.Module.Common.Panel"

local InspirePanel = class("InspirePanel",Panel);
local goldDes
function InspirePanel:New()
	self = { };
	setmetatable(self, { __index =InspirePanel });
	return self
end


function InspirePanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function InspirePanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtJadeCost = UIUtil.GetChildInComponents(txts, "txtJadeCost");
	self._txtGoldCost = UIUtil.GetChildInComponents(txts, "txtGoldCost");
	self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
	self._btnCancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnCancel");
	self._btnOk = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnOk");
	local togs = UIUtil.GetComponentsInChildren(self._gameObject, "UIToggle");
	self.TogGoldInspire = UIUtil.GetChildInComponents(togs, "TogGold");
	self.TogJadeInspire = UIUtil.GetChildInComponents(togs, "TogJadeInspire");

    self._txtJadeCost.text = LanguageMgr.Get("common/timeDes",{n = EndlessTryProxy.GetJadeCost()})
    goldDes = LanguageMgr.Get("common/timeDes",{n = EndlessTryProxy.GetGoldCost()})
    self:UpdateNum()
end
function InspirePanel:UpdateNum()
    local gt = EndlessTryProxy.GetGoldTime()
    local mt = EndlessTryProxy.GetGoldMaxTime()
    local ss = LanguageMgr.Get("common/timeDes2",{t = gt, tt = mt})
    if gt >= mt then
        self.TogJadeInspire.value = true
        self.TogGoldInspire.gameObject:SetActive(false)
        ss = '[ff0000]' .. ss
    end
    self._txtGoldCost.text = goldDes .. ss
end

function InspirePanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnCancel = function(go) self:_OnClickBtnCancel(self) end
	UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancel);
	self._onClickBtnOk = function(go) self:_OnClickBtnOk(self) end
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOk);
    MessageManager.AddListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO,self.UpdateNum, self)
end

function InspirePanel:_OnClickBtnClose()
	ModuleManager.SendNotification(EndlessTryNotes.CLOSE_ENDLESS_INSPRIE_PANEL)
end

function InspirePanel:_OnClickBtnCancel()
	self:_OnClickBtnClose()
end

function InspirePanel:_OnClickBtnOk()
    --1：金币2：仙玉
	EndlessTryProxy.EndlessTryBuy(self.TogJadeInspire.value and 2 or 1)
end

function InspirePanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function InspirePanel:_DisposeListener()
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCancel = nil;
	UIUtil.GetComponent(self._btnOk, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnOk = nil;
    MessageManager.RemoveListener(EndlessTryNotes, EndlessTryNotes.ENDLESS_CHANGE_INFO,self.UpdateNum, self)
end

function InspirePanel:_DisposeReference()
	self._btnClose = nil;
	self._btnCancel = nil;
	self._btnOk = nil;
	self._txtJadeCost = nil;
	self._txtGoldCost = nil;
end
return InspirePanel