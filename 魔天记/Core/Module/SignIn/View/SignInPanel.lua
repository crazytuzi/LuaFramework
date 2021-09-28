require "Core.Module.Common.Panel"
require "Core.Module.SignIn.View.Item.SubSignInDailyPanel"
require "Core.Module.SignIn.View.Item.SignInTypeItem"
require "Core.Module.SignIn.View.Item.SubInLinePanel"
require "Core.Module.SignIn.View.Item.SubSignInRevertAwardPanel"
require "Core.Module.SignIn.View.Item.SubLogin7RewardPanel"
require "Core.Module.SignIn.View.Item.SubSevenDayPanel"
require "Core.Module.SignIn.View.Item.SubSignInVipAwardPanel"

SignInPanel = class("SignInPanel", Panel);
function SignInPanel:New()
    self = { };
    setmetatable(self, { __index = SignInPanel });
    return self
end

function SignInPanel:_Init()
    SignInProxy.SendGetSignData();
    SignInProxy.ReqRevertAwardInfo();
    self:_InitReference();
    self:_InitListener();
    self._panelIndex = 1
    self._panels = { }

    self._panels[1] = SubSignInDailyPanel:New(self._trsDaily);
    self._panels[2] = SubInLinePanel:New(self._trsInLine);
    self._panels[3] = SubSignInRevertAwardPanel.New(self._trsRevertAward);
    self._panels[4] = SubSevenDayPanel:New(self._trsSevenDay);
    self._panels[5] = SubLogin7RewardPanel:New(self.trsLogin7Reward);
    self._panels[6] = SubSignInVipAwardPanel.New(self._trsVipAward);

    self:BuildSignList()
end

function SignInPanel:BuildSignList()
    local data = SignInManager.GetWealTypeData()
    self._panelIndex = data[1].code_id
    self._phalanx:Build(table.getCount(data), 1, data)
    local item = self._phalanx:GetItem(1)
    if (item) then
        item.itemLogic:SetToggleActive(true)
    end
    self:UpdateTipState();
end

function SignInPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsDaily = UIUtil.GetChildByName(self._trsContent, "Transform", "trsDaily");
    self._trsInLine = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInLine");
    self._trsRevertAward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRevertAward");
    self.trsLogin7Reward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsLogin7Reward");

    self._trsSevenDay = UIUtil.GetChildByName(self._trsContent, "Transform", "trsSevenDay");
    self._trsVipAward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsVipAward");
    self._trsOffLineAward = UIUtil.GetChildByName(self._trsContent, "Transform", "trsOffLineAward");

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SignInTypeItem)

end

function SignInPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function SignInPanel:_OnClickBtn_close()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(SignInNotes.CLOSE_SIGNINPANEL)
end 

function SignInPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end

    if (self._panels) then
        for k, v in pairs(self._panels) do
            v:Dispose()
            self._panels[k] = nil
        end
    end
end

function SignInPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

end

function SignInPanel:_DisposeReference()

    self._btn_close = nil;
    self._trsDaily = nil;
    self._trsInLine = nil;
    self._trsSevenDay = nil;
end

function SignInPanel:UpdatePanel()
    self:ChangePanel(self._panelIndex)
end

function SignInPanel:ChangePanel(to)

    for i = 1, table.getCount(self._panels) do
        if i == to then
            self._panels[i]:SetEnable(true);
        else
            self._panels[i]:SetEnable(false);
        end
    end

    self._panelIndex = to
    self:UpdateSignInSubPanel()

    SequenceManager.TriggerEvent(SequenceEventType.Guide.SIGNIN_TAB_CHG, to);
end

function SignInPanel:UpdateSignInSubPanel()
    if (self._panels[self._panelIndex] ~= nil) then
        self._panels[self._panelIndex]:UpdatePanel()
    end
end

function SignInPanel:UpdateTipState()
    local items = self._phalanx:GetItems()
    if (items) then
        for k, v in ipairs(items) do
            v.itemLogic:UpdateTipState()
        end
    end
end

function SignInPanel:GetSelectIndex()
    return self._panelIndex;
end
