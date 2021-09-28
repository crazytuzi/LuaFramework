
require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm1Panel = class("Confirm1Panel", BaseConfirmPanel);

local notice = LanguageMgr.Get("common/notice")
local ok = LanguageMgr.Get("common/ok")
local cancle = LanguageMgr.Get("common/cancle")



function Confirm1Panel:_Init()
    self._luaBehaviour.canPool = true
    self:_InitReference();
    self:_InitListener();
end

function Confirm1Panel:_InitReference()
    self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
    self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
    self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
    self._btn_cancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_cancel");
    self._btn_ok_txt = UIUtil.GetChildByName(self._btn_ok, "UILabel", "Label");
    self._btn_cancel_txt = UIUtil.GetChildByName(self._btn_cancel, "UILabel", "Label");
end


function Confirm1Panel:_InitListener()
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
    self._onClickBtn_cancel = function(go) self:_OnClickBtn_cancel(self) end
    UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cancel);
end

function Confirm1Panel:_OnClickBtn_ok()
    if (self.handler) then
        if self.handlerTarget ~= nil then
            self.handler(self.handlerTarget, self.data)
        else
            self.handler(self.data);
        end
    end
    self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM1PANEL);
end

function Confirm1Panel:_OnClickBtn_cancel()

    if self.handlerTarget ~= nil then
        if self.cancelHandler ~= nil then
            self.cancelHandler(self.handlerTarget, self.data);
        end
    else
        if self.cancelHandler ~= nil then
            self.cancelHandler(self.data);
        end
    end

    self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM1PANEL);

end
-- { title="提示",msg="你确定要出售此装备？", ok_Label="确定", cance_lLabel="放弃",  hander = ProductTipProxy.SToSell,cancelHandler= data = info }
--  ok_time="如果有这个字段，那么就在倒计时(秒) 后自动 响应 ok 操作" ,
-- cancel_time="如果有这个字段，那么就在倒计时(秒) 后自动 响应 cance 操作"
-- close_time="如果有这个字段，那么就在倒计时(秒) 后自动 响应 close 操作"
-- closeHandler
-- returnSelfHandler
function Confirm1Panel:SetData(data)

    self._txt_title.text = data.title or notice;
    self._txt_label.text = data.msg;

    self._btn_ok_txt.text = data.ok_Label or ok;
    self._btn_cancel_txt.text = data.cance_lLabel or cancle;

    self.data = data.data;
    self.handler = data.hander;
    self.cancelHandler = data.cancelHandler;
    self.closeHandler = data.closeHandler;
    self.returnSelfHandler = data.returnSelfHandler;
    self.handlerTarget = data.target;

    self.ok_time = data.ok_time;
    self.cancel_time = data.cancel_time;
    self.close_time = data.close_time;

    self:StopTime();

    if self.ok_time ~= nil then


        self._btn_ok_txt.text = data.ok_Label .. "(" .. self.ok_time .. ")";

        self._sec_timer = Timer.New( function()
            self.ok_time = self.ok_time - 1;
            self._btn_ok_txt.text = data.ok_Label .. "(" .. self.ok_time .. ")";
            if self.ok_time <= 0 then
                self:StopTime();
                self._btn_ok_txt.text = data.ok_Label .. "(0)";
                self.ok_time = 0;
                self:_OnClickBtn_ok()
            end
        end , 1, self.ok_time, false);

        self._sec_timer:Start();

    elseif self.cancel_time ~= nil then


        self._btn_cancel_txt.text = data.cance_lLabel .. "(" .. self.cancel_time .. ")";
        self._sec_timer = Timer.New( function()
            self.cancel_time = self.cancel_time - 1;
            self._btn_cancel_txt.text = data.cance_lLabel .. "(" .. self.cancel_time .. ")";
            if self.cancel_time <= 0 then
                self:StopTime();
                self._btn_cancel_txt.text = data.cance_lLabel .. "(0)";
                self.cancel_time = 0;
                self:_OnClickBtn_cancel()
            end
        end , 1, self.cancel_time, false);

        self._sec_timer:Start();


    elseif self.close_time ~= nil then

        self._sec_timer = Timer.New( function()
            self.close_time = self.close_time - 1;

            if self.close_time <= 0 then
                self:StopTime();
                self.close_time = 0;

                if self.handlerTarget ~= nil then
                    if self.closeHandler ~= nil then
                        self.closeHandler(self.handlerTarget, self.data);
                    end
                else
                    if self.closeHandler ~= nil then
                        self.closeHandler(self.data);
                    end
                end

                self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM1PANEL);



            end
        end , 1, self.close_time, false);

        self._sec_timer:Start();

    end


    if self.handlerTarget ~= nil then
        if self.returnSelfHandler ~= nil then
            self.returnSelfHandler(self.handlerTarget, self);
        end
    else
        if self.returnSelfHandler ~= nil then
            self.returnSelfHandler(self);
        end
    end

end

function Confirm1Panel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function Confirm1Panel:_DisposeListener()
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
    UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_cancel = nil;
end

function Confirm1Panel:StopTime()

    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end

end

function Confirm1Panel:_DisposeReference()

    self:StopTime();
    self._txt_title = nil;
    self._txt_label = nil;
    self._btn_ok = nil;
    self._btn_cancel = nil;
    self._btn_ok_txt = nil;
    self._btn_cancel_txt = nil;
    self.data = nil;
end

