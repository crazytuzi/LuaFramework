require "Core.Module.Common.Panel"

local SysOpenInfoTipPanel = class("SysOpenInfoTipPanel", Panel);
function SysOpenInfoTipPanel:New()
    self = { };
    setmetatable(self, { __index = SysOpenInfoTipPanel });
    return self
end


function SysOpenInfoTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SysOpenInfoTipPanel:_InitReference()
    self._txt_title1 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title1");
    self._txt_title2 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title2");
    self._txt_title3 = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title3");
    self._txt_dec = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_dec");
    self._txt_need_dec = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_need_dec");


    self.bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "bg");
    self.icon = UIUtil.GetChildByName(self._trsContent, "UISprite", "icon");

end

function SysOpenInfoTipPanel:_InitListener()

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);


end

function SysOpenInfoTipPanel:_OnClickBtn()

    -- 开始前需求
    ModuleManager.SendNotification(MainUINotes.CLOSE_SYSOPENTIPPANEL);

end

function SysOpenInfoTipPanel:_OnBtnsClick(go)
end

function SysOpenInfoTipPanel:SetData(data)

    self.data = data;

    self.icon.spriteName = data.icon;

    self._txt_dec.text = data.more_content;
    self._txt_need_dec.text = data.open_des;

end

function SysOpenInfoTipPanel:_Dispose()
    self:_DisposeReference();
end

function SysOpenInfoTipPanel:_DisposeReference()

    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;


    self._txt_title1 = nil;
    self._txt_title2 = nil;
    self._txt_title3 = nil;
    self._txt_dec = nil;
    self._txt_need_dec = nil;
end
return SysOpenInfoTipPanel