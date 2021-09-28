require "Core.Module.Common.UIItem";

GuildCreatePanel = UIItem:New();

function GuildCreatePanel:_Init()
    
    self._input = UIUtil.GetChildByName(self.transform , "UIInput", "inputName");

    self._btnCancel = UIUtil.GetChildByName(self.transform , "UIButton", "btnCancel");
    self._btnCreate = UIUtil.GetChildByName(self.transform , "UIButton", "btnCreate");

    self._onClickBtnCancel = function(go) self:_OnClickBtnCancel(self) end
	UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCancel);

    self._onClickBtnCreate = function(go) self:_OnClickBtnCreate(self) end
	UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCreate);
end

function GuildCreatePanel:_Dispose()

    UIUtil.GetComponent(self._btnCancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCancel = nil;

    UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCreate = nil;
end

function GuildCreatePanel:_OnClickBtnCancel()
    MessageManager.Dispatch(GuildNotes, GuildNotes.CLOSE_CREATE_PANEL, GuildReqListPanel.Type.JOIN);
end

function GuildCreatePanel:_OnClickBtnCreate()
    MsgUtils.UseBDGoldConfirm2(200, self, "guild/create", nil, GuildCreatePanel._ConfirmCreate);
end

function GuildCreatePanel:_ConfirmCreate()
    local guildName = self._input.value;
    GuildProxy.ReqCreate(guildName);
end




