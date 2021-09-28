require "Core.Module.Common.Panel"
require "Core.Module.MainUI.View.Item.AttrItem"
TitleAttrPanel = class("TitleAttrPanel", Panel);
function TitleAttrPanel:New()
    self = { };
    setmetatable(self, { __index = TitleAttrPanel });
    return self
end


function TitleAttrPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdatePanel()
end

function TitleAttrPanel:_InitReference()
    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, AttrItem)
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
end

function TitleAttrPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function TitleAttrPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MainUINotes.CLOSE_TITLEATTRPANEL)
end

function TitleAttrPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    self._phalanx:Dispose()
    self._phalanx = nil
end

function TitleAttrPanel:UpdatePanel()
    local data = TitleManager.GetAllGetTitleAttr()
    if (data) then
        local attr = data:GetAllPropertyAndDes()
        self._phalanx:Build(math.ceil((table.getCount(attr) -1) / 2 + 1), 2, attr)
    end
end


function TitleAttrPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function TitleAttrPanel:_DisposeReference()
    self._btn_close = nil;

end
