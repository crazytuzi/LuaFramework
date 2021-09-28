require "Core.Module.Common.Panel"

SaleRecordPanel = class("SaleRecordPanel", Panel);
local notice = LanguageMgr.Get("Sale/SaleRecordPanel/saleNotice")
function SaleRecordPanel:New()
    self = { };
    setmetatable(self, { __index = SaleRecordPanel });
    return self
end


function SaleRecordPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdatePanel()
end

function SaleRecordPanel:_InitReference()
    self._txtMyCoin = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtMyCoin");
    self._btnClear = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClear");
    self._btnGetXianyu = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGetXianyu");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._textList = UIUtil.GetChildByName(self._trsContent, "UITextList", "bg")
end

function SaleRecordPanel:_InitListener()
    self._onClickBtnClear = function(go) self:_OnClickBtnClear(self) end
    UIUtil.GetComponent(self._btnClear, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClear);
    self._onClickBtnGetXianyu = function(go) self:_OnClickBtnGetXianyu(self) end
    UIUtil.GetComponent(self._btnGetXianyu, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetXianyu);
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function SaleRecordPanel:_OnClickBtnClear()
    SaleProxy.SendClearRecord()
end
 
function SaleRecordPanel:_OnClickBtnGetXianyu()
    SaleProxy.SendGetXianyu()
end

function SaleRecordPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(SaleNotes.CLOSE_GETXIANYUPANEL)
end

function SaleRecordPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function SaleRecordPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClear, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClear = nil;
    UIUtil.GetComponent(self._btnGetXianyu, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnGetXianyu = nil;
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function SaleRecordPanel:_DisposeReference()
    self._btnClear = nil;
    self._btnGetXianyu = nil;
    self._btn_close = nil;
    self._txtMyCoin = nil;
end


function SaleRecordPanel:UpdatePanel()
    local data = SaleManager.GetSaleRecordData()
    self:SetGoldText(data.gold)
    self:SetSaleRecord(data.record)
end

function SaleRecordPanel:SetGoldText(g)
    if (g) then
        self._txtMyCoin.text = tostring(g)
    else
        self._txtMyCoin.text = "0"
    end
end

function SaleRecordPanel:SetSaleRecord(record)
    self._textList:Clear()
    local temp = ""
    for k, v in ipairs(record) do
        temp = string.format(notice, ColorDataManager.GetColorTextByQuality(v.configData.quality, "【" .. v.configData.name .. "】"), v.num)
        self._textList:Add(temp)
    end
end