require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildLogItem";

GuildLogPanel = Panel:New();
local insert = table.insert

function GuildLogPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildLogPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsView/trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildLogItem);
end

function GuildLogPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self.callBack = function() self:_onDragScrollView() end;
    self._scrollView.onDragFinished = self.callBack;

    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_LOGLIST, GuildLogPanel._UpdateList, self);
end

function GuildLogPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildLogPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildLogPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    self._scrollView.onDragFinished:Destroy();
    self.callBack = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_LOGLIST, GuildLogPanel._UpdateList);
end

function GuildLogPanel:_Opened()
    self.page = 1;
    self.data = nil;
    self:_ReqList(self.page);
end

function GuildLogPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_LOG_PANEL);
end

function GuildLogPanel:_ReqList(page)
    if page == 1 then
        self.data = nil;
        self._scrollView:ResetPosition();
    end

    GuildProxy.ReqLogList(page);
end

function GuildLogPanel:_onDragScrollView()
    local offset = 0;
    local b = self._scrollView.bounds;
    local c = self._scrollPanel:CalculateConstrainOffset(b:GetMin(), b:GetMin());
    offset = c.y;

    if offset <= 1 then
        local tmpPage = self.page + 1;
        self:_ReqList(tmpPage);
    end
end

function GuildLogPanel:_UpdateList(data)
    
    if self.data == nil then
        self.data = {};
    end
    
    self.page = GuildProxy.tmpLogPage;
    
    for i, v in ipairs(data) do
        insert(self.data, v);
    end
    
    local count = #self.data;
    self._phalanx:Build(count, 1, self.data);

end
