require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildVerifyItem";

GuildVerifyPanel = Panel:New();

function GuildVerifyPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateDisplay();
end

function GuildVerifyPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildVerifyItem);

    self._btnAllRefuse = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnAllRefuse");
    self._selectVertify = UIUtil.GetChildByName(self._trsContent, "UISprite", "selectVertify");
    self._icoSelect = UIUtil.GetChildByName(self._selectVertify, "Transform", "icoSelect");
    
end

function GuildVerifyPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    
    self._onClickAllRefuse = function(go) self:_OnClickAllRefuse() end
    UIUtil.GetComponent(self._btnAllRefuse, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAllRefuse);

    self._onSelectClick = function(go) self:_OnSelectClick(self) end
    UIUtil.GetComponent(self._selectVertify, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onSelectClick);

    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_VERTIFY_LIST, GuildVerifyPanel._OnVertifyList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_VERTIFY, GuildVerifyPanel._OnVertify, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_VERTIFY_REFUSEALL, GuildVerifyPanel._RefuseAll, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_VERTIFY_SET, GuildVerifyPanel._OnRspSet, self);
end

function GuildVerifyPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildVerifyPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildVerifyPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnAllRefuse, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickAllRefuse = nil;

    UIUtil.GetComponent(self._selectVertify, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onSelectClick = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_VERTIFY_LIST, GuildVerifyPanel._OnVertifyList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_VERTIFY, GuildVerifyPanel._OnVertify);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_VERTIFY_REFUSEALL, GuildVerifyPanel._RefuseAll);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_VERTIFY_SET, GuildVerifyPanel._OnRspSet);
end

function GuildVerifyPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDVERIFYPANEL);
end

function GuildVerifyPanel:UpdateDisplay()
    GuildProxy.ReqVertifyList();
end

function GuildVerifyPanel:_OnVertifyList(data)
    self:_OnSet(data.autoVertify);
    self:_UpdateList(data.list);
end

function GuildVerifyPanel:_UpdateList(list)
    self.data = list;
    local count = #list;
    self._phalanx:Build(count, 1, list);
end

function GuildVerifyPanel:_OnVertify(id)
    for i,v in ipairs(self.data) do
        if v.id == id then
            table.remove(self.data, i);
            break;
        end
    end
    self:_UpdateList(self.data);
end

function GuildVerifyPanel:_RefuseAll()
    self:_UpdateList({});
end

function GuildVerifyPanel:_OnRspSet(bool)
    GuildProxy.ReqVertifyList();
end

function GuildVerifyPanel:_OnSet(bool)
    self._vertifySelected = bool;
    self._icoSelect.gameObject:SetActive(bool);
end

function GuildVerifyPanel:_OnClickAllRefuse()
    if self.data and #self.data > 0 then
        GuildProxy.ReqVertifyAllRefuse();
    end
end

function GuildVerifyPanel:_OnSelectClick()
    if GuildDataManager.GetGrant(GuildDataManager.opt.approve) then
        local b = not self._vertifySelected;
        GuildProxy.ReqVertifySet(b);
    end
end

