require "Core.Module.Common.UISubPanel";
require "Core.Module.SignIn.View.Item.SubSignInRevertAwardItem";

SubSignInRevertAwardPanel = class("SubSignInRevertAwardPanel", UISubPanel);

--对接signPanel接口
function SubSignInRevertAwardPanel:UpdatePanel()

end

function SubSignInRevertAwardPanel:SetEnable(bool)
	if bool then
		self:Enable();
	else
		self:Disable();
	end
end

function SubSignInRevertAwardPanel:_InitReference()
    self._btnToggle1 = UIUtil.GetChildByName(self._transform, "UIToggle", "btnToggle1");
    self._btnToggle2 = UIUtil.GetChildByName(self._transform, "UIToggle", "btnToggle2");

    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._trsPhalanx = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._trsPhalanx, SubSignInRevertAwardItem);

    self._onToggleClick = function(go) self:_OnToggleClick(go) end
	UIUtil.GetComponent(self._btnToggle1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggleClick);
	UIUtil.GetComponent(self._btnToggle2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggleClick);
end

function SubSignInRevertAwardPanel:_DisposeReference()
    self._phalanx:Dispose();

    UIUtil.GetComponent(self._btnToggle1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnToggle2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggleClick = nil;
end

function SubSignInRevertAwardPanel:_InitListener()
    MessageManager.AddListener(SignInNotes, SignInNotes.ENV_REVERTAWARD_RSP, SubSignInRevertAwardPanel.UpdateDisplay, self);
end

function SubSignInRevertAwardPanel:_DisposeListener()
    MessageManager.RemoveListener(SignInNotes, SignInNotes.ENV_REVERTAWARD_RSP, SubSignInRevertAwardPanel.UpdateDisplay);
end

function SubSignInRevertAwardPanel:_OnEnable()
	self._btnToggle1.value = (true);
	self.curIdx = 1;
	SignInProxy.ReqRevertAwardInfo();
end

function SubSignInRevertAwardPanel:UpdateDisplay(data)
 
	local count = #data;
	self._phalanx:Build(count, 1, data);
	self:_ChgItemsType(self.curIdx);
end

function SubSignInRevertAwardPanel:_OnToggleClick(go)
	local idx = tonumber(string.sub(go.name, 10));

    if idx ~= self.curIdx then
        self.curIdx = idx;
        self:_ChgItemsType(idx);
    end
end

function SubSignInRevertAwardPanel:_ChgItemsType(type)
	local items = self._phalanx:GetItems()
    if (items) then
        for k, v in ipairs(items) do
            v.itemLogic:UpdateItemType(type);
        end
    end
end