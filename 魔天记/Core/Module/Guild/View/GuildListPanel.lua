require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildListItem";
GuildListPanel = Panel:New();

GuildListPanel.PageShowNum = 7; --界面显示条数

function GuildListPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
    self:SetDisplay();
end

function GuildListPanel:_InitReference()

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsFind = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFind");
    self._btnFind = UIUtil.GetChildByName(self._trsFind, "UIButton", "btnFind");
    self._input = UIUtil.GetChildByName(self._trsFind , "UIInput", "inputName");

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildListItem);

end

function GuildListPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnFind = function(go) self:_OnClickBtnFind(self) end
	UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFind);

    self.callBack = function() self:_onDragScrollView() end;
    self._scrollView.onDragFinished = self.callBack;

    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_LIST, GuildListPanel._UpdateList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_FIND, GuildListPanel._UpdateFind, self);
    
end

function GuildListPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildListPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildListPanel:_DisposeListener()
    
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFind = nil;
    self._scrollView.onDragFinished:Destroy();
    self.callBack = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_LIST, GuildListPanel._UpdateList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_FIND, GuildListPanel._UpdateFind);
end

function GuildListPanel:SetDisplay()
    self.page = 1;
    self:_ReqList(self.page);
end

function GuildListPanel:_onDragScrollView()
    if self.showPage == false then
        return;
    end
    --[[
    if(self._scrollView:RestrictWithinBounds(true)) then
        local tmpPage = self.page + 1;
        self:_ReqList(tmpPage);
    end
    ]]
    local offset = 0;
    local b = self._scrollView.bounds;
    local c = self._scrollPanel:CalculateConstrainOffset(b:GetMin(), b:GetMin());
    offset = c.y;

    if offset <= 1 then
        local tmpPage = self.page + 1;
        self:_ReqList(tmpPage);
    end
    
end

function GuildListPanel:_ReqList(page)
    if page == 1 then
        self.data = nil;
        self._scrollView:ResetPosition();
    end
    GuildProxy.ReqGuildList(page);
end
local insert = table.insert

function GuildListPanel:_UpdateList(data)
    self.showPage = true;
    self.page = data.p;
    
    if self.data == nil then
        self.data = {};
    end

    for i, v in ipairs(data.d) do
        insert(self.data, v);
    end

    local count = #self.data;
    self._phalanx:Build(count, 1, self.data);
end

function GuildListPanel:_UpdateFind(data)
    local count = #data;
    if count == 0 then
        --没找到信息.
        self._input.value = "";
        MsgUtils.ShowTips("error/guild/CannotFindGuild");
    else
        self.showPage = false;
        self._phalanx:Build(count, 1, data);
        self._scrollView:ResetPosition();
    end
end

function GuildListPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDLISTPANEL);
end

function GuildListPanel:_OnClickBtnFind()
    local fStr = self._input.value;
    if fStr == "" then
        self.page = 1;
        self:_ReqList(self.page);
    else
        GuildProxy.ReqFind(fStr);
    end
end






