require "Core.Module.Common.Panel"

NumInputPanel = class("NumInputPanel", Panel);
function NumInputPanel:New()
    self = { };
    setmetatable(self, { __index = NumInputPanel });
    return self
end

function NumInputPanel:GetUIOpenSoundName( )
    return ""
end


function NumInputPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function NumInputPanel:_InitReference()
    self._btn_1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_1");
    self._btn_2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_2");
    self._btn_3 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_3");
    self._btn_c = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_c");

    self._btn_0 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_0");
    self._btn_6 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_6");
    self._btn_5 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_5");
    self._btn_4 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_4");

    self._btn_7 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_7");
    self._btn_8 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_8");
    self._btn_9 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_9");
    self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
end

function NumInputPanel:_InitListener()
    self._onClickBtn_1 = function(go) self:_OnClickBtn_1(self) end
    UIUtil.GetComponent(self._btn_1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_1);
    self._onClickBtn_2 = function(go) self:_OnClickBtn_2(self) end
    UIUtil.GetComponent(self._btn_2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_2);
    self._onClickBtn_3 = function(go) self:_OnClickBtn_3(self) end
    UIUtil.GetComponent(self._btn_3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_3);
    self._onClickBtn_c = function(go) self:_OnClickBtn_c(self) end
    UIUtil.GetComponent(self._btn_c, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_c);

    self._onClickBtn_0 = function(go) self:_OnClickBtn_0(self) end
    UIUtil.GetComponent(self._btn_0, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_0);
    self._onClickBtn_6 = function(go) self:_OnClickBtn_6(self) end
    UIUtil.GetComponent(self._btn_6, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_6);
    self._onClickBtn_5 = function(go) self:_OnClickBtn_5(self) end
    UIUtil.GetComponent(self._btn_5, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_5);
    self._onClickBtn_4 = function(go) self:_OnClickBtn_4(self) end
    UIUtil.GetComponent(self._btn_4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_4);

    self._onClickBtn_7 = function(go) self:_OnClickBtn_7(self) end
    UIUtil.GetComponent(self._btn_7, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_7);
    self._onClickBtn_8 = function(go) self:_OnClickBtn_8(self) end
    UIUtil.GetComponent(self._btn_8, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_8);
    self._onClickBtn_9 = function(go) self:_OnClickBtn_9(self) end
    UIUtil.GetComponent(self._btn_9, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_9);
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
end

-- 如果需要点击遮罩响应,重写此函数
function NumInputPanel:_OnClickMask()
    if self.data.confirmHandler ~= nil then
        self.data.confirmHandler(self.data.hd_target, self._txt_str);
    end
    ModuleManager.SendNotification(NumInputNotes.CLOSE_NUMINPUT);
end

--[[
data.hd
data.hd_target
data.x
data.y

]]
function NumInputPanel:SetData(data)

    self.data = data;

    if self.data.x == nil then
        self.data.x = 0;
    end

    if self.data.y == nil then
        self.data.y = 0;
    end
    Util.SetLocalPos(self._trsContent, self.data.x, self.data.y, 0)

--    self._trsContent.localPosition = Vector3.New(self.data.x, self.data.y, 0);
    self._txt_str = "0"

    if self.data.label ~= nil then
    self.data.label.text = self._txt_str;
    end
    
end

function NumInputPanel:Dis_handler(v)
    --    local txt_str = self.data.label.text
    local res = nil
    if v == NumInputNotes.MESSAGE_KEY_c then
        local len = string.len(self._txt_str);
       
        if len > 1 then
            self._txt_str = string.sub(self._txt_str, 1, -2)
        else
            self._txt_str = "0";
        end
    else
        if self._txt_str == "0" then
            self._txt_str = "";
        end

        self._txt_str = self._txt_str .. v;
    end

    if (tonumber(self._txt_str) > 999) then
        self._txt_str = "999"
    end

    if self.data.hd ~= nil then
        self.data.hd(self.data.hd_target, self._txt_str);
    end

end

function NumInputPanel:_OnClickBtn_1()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_1);
end

function NumInputPanel:_OnClickBtn_2()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_2);
end

function NumInputPanel:_OnClickBtn_3()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_3);
end

function NumInputPanel:_OnClickBtn_c()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_c);
end

function NumInputPanel:_OnClickBtn_0()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_0);
end

function NumInputPanel:_OnClickBtn_6()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_6);
end

function NumInputPanel:_OnClickBtn_5()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_5);
end

function NumInputPanel:_OnClickBtn_4()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_4);
end

function NumInputPanel:_OnClickBtn_7()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_7);
end

function NumInputPanel:_OnClickBtn_8()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_8);
end

function NumInputPanel:_OnClickBtn_9()
    self:Dis_handler(NumInputNotes.MESSAGE_KEY_9);
end

function NumInputPanel:_OnClickBtn_ok()
    if self.data.confirmHandler ~= nil then
        self.data.confirmHandler(self.data.hd_target, self._txt_str);
    end
    ModuleManager.SendNotification(NumInputNotes.CLOSE_NUMINPUT);
end

function NumInputPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function NumInputPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_1 = nil;
    UIUtil.GetComponent(self._btn_2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_2 = nil;
    UIUtil.GetComponent(self._btn_3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_3 = nil;
    UIUtil.GetComponent(self._btn_c, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_c = nil;
    UIUtil.GetComponent(self._btn_0, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_0 = nil;
    UIUtil.GetComponent(self._btn_6, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_6 = nil;
    UIUtil.GetComponent(self._btn_5, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_5 = nil;
    UIUtil.GetComponent(self._btn_4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_4 = nil;
    UIUtil.GetComponent(self._btn_7, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_7 = nil;
    UIUtil.GetComponent(self._btn_8, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_8 = nil;
    UIUtil.GetComponent(self._btn_9, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_9 = nil;
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
end

function NumInputPanel:_DisposeReference()
    self._btn_1 = nil;
    self._btn_2 = nil;
    self._btn_3 = nil;
    self._btn_c = nil;
    self._btn_0 = nil;
    self._btn_6 = nil;
    self._btn_5 = nil;
    self._btn_4 = nil;
    self._btn_7 = nil;
    self._btn_8 = nil;
    self._btn_9 = nil;
    self._btn_ok = nil;

    self.data = nil;
end
