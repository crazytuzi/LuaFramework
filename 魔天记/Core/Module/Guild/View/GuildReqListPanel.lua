require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.GuildCreatePanel";
require "Core.Module.Guild.View.Item.GuildListJoinItem";
GuildReqListPanel = Panel:New();
local insert = table.insert

GuildReqListPanel.Type = {
    LIST = 1;
    CREATE = 20;
}
GuildReqListPanel.PageShowNum = 7; --界面显示条数

function GuildReqListPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function GuildReqListPanel:_InitReference()
    self._goCreate = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCreate").gameObject;
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsJoin = UIUtil.GetChildByName(self._trsContent, "Transform", "trsJoin");
    self._btnCreate = UIUtil.GetChildByName(self._trsJoin, "UIButton", "btnCreate");

    self._trsFind = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFind");
    self._btnFind = UIUtil.GetChildByName(self._trsFind, "UIButton", "btnFind");
    self._input = UIUtil.GetChildByName(self._trsFind , "UIInput", "inputName");

    self._txtReqNum = UIUtil.GetChildByName(self._trsContent , "UILabel", "trsTitle/txtReqNum");

    self._createPanel = GuildCreatePanel:New();
    self._createPanel:Init(self._goCreate, nil);
    self._goCreate:SetActive(false);

    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();

    
end

function GuildReqListPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
    self._onClickBtnFind = function(go) self:_OnClickBtnFind(self) end
	UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFind);
    self._onClickBtnCreate = function(go) self:_OnClickBtnCreate(self) end
	UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCreate);

    self.callBack = function() self:_onDragScrollView() end;
    self._scrollView.onDragFinished = self.callBack;

    MessageManager.AddListener(GuildNotes, GuildNotes.CLOSE_CREATE_PANEL, GuildReqListPanel._UpdateType, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_CREATE, GuildReqListPanel._OnCreateGuild, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_LIST, GuildReqListPanel._UpdateList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_FIND, GuildReqListPanel._UpdateFind, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_JOIN, GuildReqListPanel._UpdateReqJoin, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_REQNUM, GuildReqListPanel._UpdateReqNum, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_BEREFUSE, GuildReqListPanel._UpdateRefuse, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, GuildReqListPanel._OnGuildChg, self);
    
end

function GuildReqListPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildReqListPanel:_DisposeReference()
    self._createPanel:Dispose();
    self._phalanx:Dispose();
end

function GuildReqListPanel:_DisposeListener()
    
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
    UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFind = nil;
    UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCreate = nil;
    self._scrollView.onDragFinished:Destroy();
    self.callBack = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.CLOSE_CREATE_PANEL, GuildReqListPanel._UpdateType);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_CREATE, GuildReqListPanel._OnCreateGuild);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_LIST, GuildReqListPanel._UpdateList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_FIND, GuildReqListPanel._UpdateFind);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_JOIN, GuildReqListPanel._UpdateReqJoin);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_REQNUM, GuildReqListPanel._UpdateReqNum);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_BEREFUSE, GuildReqListPanel._UpdateRefuse);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_CHG, GuildReqListPanel._OnGuildChg);
end

function GuildReqListPanel:_Opened()
    self:SetDisplay(GuildReqListPanel.Type.LIST);
end

function GuildReqListPanel:SetDisplay(v)
    self:_InitType(v);
    self.page = 1;
    self:_ReqList(self.page);
end

function GuildReqListPanel:_InitType(v)
    self._phalanx:Init(self._phalanxInfo, GuildListJoinItem);
    self:_UpdateType(v);
end

function GuildReqListPanel:_UpdateType(v)
    self.type = v;
    --self._trsJoin.gameObject:SetActive(v == GuildReqListPanel.Type.JOIN or v == GuildReqListPanel.Type.CREATE);
    self._goCreate:SetActive(v == GuildReqListPanel.Type.CREATE);
end

function GuildReqListPanel:_onDragScrollView()
    if self.showPage == false then
        return;
    end
    local offset = 0;
    local b = self._scrollView.bounds;
    local c = self._scrollPanel:CalculateConstrainOffset(b:GetMin(), b:GetMin());
    offset = c.y;

    if offset <= 1 then
        local tmpPage = self.page + 1;
        self:_ReqList(tmpPage);
    end
end

function GuildReqListPanel:_ReqList(page)
    if page == 1 then
        self.data = nil;
        self._scrollView:ResetPosition();
    end
    GuildProxy.ReqGuildList(page);
end

function GuildReqListPanel:_UpdateList(data)
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

    SequenceManager.TriggerEvent(SequenceEventType.Guide.GUILD_REQ_LIST);
    
end

function GuildReqListPanel:_UpdateFind(data)
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

function GuildReqListPanel:_UpdateReqJoin(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetStatus(data, GuildInfo.Status.REQ);
    end
end

function GuildReqListPanel:_UpdateRefuse(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetStatus(data, GuildInfo.Status.NONE);
    end
end

function GuildReqListPanel:_UpdateReqNum()
    self._txtReqNum.text = LanguageMgr.Get("common/numMax", {num = GuildDataManager.reqMax - GuildDataManager.reqNum, max = GuildDataManager.reqMax});
end

function GuildReqListPanel:_OnClickBtnClose()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILD_REQLIST_PANEL);
end

function GuildReqListPanel:_OnClickBtnFind()
    local fStr = self._input.value;
    if fStr == "" then
        self.page = 1;
        self:_ReqList(self.page);
    else
        GuildProxy.ReqFind(fStr);
    end
end

function GuildReqListPanel:_OnClickBtnCreate()
    self:_UpdateType(GuildReqListPanel.Type.CREATE);
end

function GuildReqListPanel:_OnCreateGuild()
    self:_OnClickBtnClose();
    ModuleManager.SendNotification(GuildNotes.OPEN_GUILDPANEL);
end

function GuildReqListPanel:_OnGuildChg()
    if GuildDataManager.InGuild() then
        self:_OnCreateGuild();    
    end
end






