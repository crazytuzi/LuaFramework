require "Core.Module.Common.Panel"

local BottomNoteCtr = require "Core.Module.XinJiRisks.Ctrs.BottomNoteCtr"
local LeftNoteCtr = require "Core.Module.XinJiRisks.Ctrs.LeftNoteCtr"
local RightNoteCtr = require "Core.Module.XinJiRisks.Ctrs.RightNoteCtr"

local XinJiRisksPanel = class("XinJiRisksPanel", Panel);
function XinJiRisksPanel:New()
    self = { };
    setmetatable(self, { __index = XinJiRisksPanel });
    return self
end


function XinJiRisksPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XinJiRisksPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");


    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");


    self._uieffectParent = UIUtil.GetChildByName(self._trsContent, "effectParent")
    self._bg = UIUtil.GetChildByName(self._trsContent, "UISprite", "effectParent/bg")


    self.leftNote = UIUtil.GetChildByName(self._trsContent, "Transform", "leftNote");
    self.rightNote = UIUtil.GetChildByName(self._trsContent, "Transform", "rightNote");
    self.bottomNote = UIUtil.GetChildByName(self._trsContent, "Transform", "bottomNote");

    self.leftNoteCtr = LeftNoteCtr:New(self.leftNote);
    self.rightNoteCtr = RightNoteCtr:New(self.rightNote);
    self.bottomNoteCtr = BottomNoteCtr:New(self.bottomNote);

    MessageManager.AddListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_XINJIRISKSGETCURRSTATE_CHANGE, self._CurrStateChange, self);
    MessageManager.AddListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_MY_ANSWER_SUCCESS, self._AnswerSuccess, self);
    MessageManager.AddListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_SERVER_GIVE_NOTICE, self._Server_notice, self);



    self.ui_win_BG_Eff = UIEffect:New()
    self.ui_win_Eff = UIEffect:New()
    self.ui_lose_Eff = UIEffect:New()

    self.ui_win_BG_Eff:Init(self._uieffectParent, self._bg, 4, "ui_win_BG", 1, 360)
    self.ui_win_Eff:Init(self._uieffectParent, self._bg, 4, "ui_win", 1, 360)
    self.ui_lose_Eff:Init(self._uieffectParent, self._bg, 4, "ui_lose", 1, 360)

end

function XinJiRisksPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function XinJiRisksPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XinJiRisksNotes.CLOSE_XINJIRISKSPANEL);
end

function XinJiRisksPanel:StopAllEf()
    self.ui_win_BG_Eff:Stop()
    self.ui_win_Eff:Stop()
    self.ui_lose_Eff:Stop()
end

function XinJiRisksPanel:PlayWin()
    self:StopAllEf()

    self.ui_win_BG_Eff:Play()
    self.ui_win_Eff:Play()
end

function XinJiRisksPanel:PlayFail()
    self:StopAllEf()

    self.ui_lose_Eff:Play()
end

function XinJiRisksPanel:SetData(data)

    if data ~= nil then
        local elseTime = data.elseTime;
        self.rightNoteCtr:SetElseTime(elseTime);
    else
        XinJiRisksProxy.Try_XinJiRisksGetCurrState();

    end

end 

--[[
输出：
idx：第几题
qId：题库id
rc：答对数量
st：阶段 1-5
rs：下一阶段倒计时（秒）
ap：[Int,]答案支持率
ar：正确答案1-4

wr：胜率
br：领先率
exp：累计经验
money：累计金钱
]]
function XinJiRisksPanel:_CurrStateChange(data)

    if not self.rightNoteCtr.waitForClose then
        self.leftNoteCtr:SetData(data);
        self.rightNoteCtr:SetData(data);

        local st = data.st;
        local ar = data.ar;
        if st == 5 and XinJiRisksProxy.myAnswer ~= nil then
            if XinJiRisksProxy.myAnswer == ar then
                self:PlayWin()
            else
                self:PlayFail()
            end

        end

    end


end 

--[[
52 回答问题
输入：
a：回答答案1-4
输出：
a：回答答案1-4

]]
function XinJiRisksPanel:_AnswerSuccess(data)
    self.rightNoteCtr:SetMyAnswer(data.a);
end 


function XinJiRisksPanel:_Server_notice(data)
    self.leftNoteCtr:Add_Server_notice(data.pn, data.a);
end 


function XinJiRisksPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XinJiRisksPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function XinJiRisksPanel:_DisposeReference()


    MessageManager.RemoveListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_XINJIRISKSGETCURRSTATE_CHANGE, self._CurrStateChange, self);
    MessageManager.RemoveListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_MY_ANSWER_SUCCESS, self._AnswerSuccess, self);
    MessageManager.RemoveListener(XinJiRisksNotes, XinJiRisksNotes.MESSAGE_SERVER_GIVE_NOTICE, self._Server_notice, self);

    self:StopAllEf()
    if (self.ui_win_BG_Eff) then
        self.ui_win_BG_Eff:Dispose()
        self.ui_win_BG_Eff = nil
    end

    if (self.ui_win_Eff) then
        self.ui_win_Eff:Dispose()
        self.ui_win_Eff = nil
    end

    if (self.ui_lose_Eff) then
        self.ui_lose_Eff:Dispose()
        self.ui_lose_Eff = nil
    end

    self.leftNoteCtr:Dispose()
    self.rightNoteCtr:Dispose()
    self.bottomNoteCtr:Dispose()

    self.leftNoteCtr = nil;
    self.rightNoteCtr = nil;
    self.bottomNoteCtr = nil;

    self._btn_close = nil;



end
return XinJiRisksPanel