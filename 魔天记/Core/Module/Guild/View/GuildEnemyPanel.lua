require "Core.Module.Common.Panel";
require "Core.Module.Guild.View.Item.GuildListEnemyItem";

GuildEnemyPanel = Panel:New();

GuildEnemyPanel.PageShowNum = 7; --界面显示条数
GuildEnemyPanel.ScrollHeight = 70;

function GuildEnemyPanel:_Init()
	self:_InitReference();
	self:_InitListener();
    
end

function GuildEnemyPanel:_InitReference()
    
    self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "trsTitle/txtNum");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._trsFind = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFind");
    self._btnFind = UIUtil.GetChildByName(self._trsFind, "UIButton", "btnFind");
    self._input = UIUtil.GetChildByName(self._trsFind , "UIInput", "inputName");
    
    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildListEnemyItem);
end

function GuildEnemyPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    self._onClickBtnFind = function(go) self:_OnClickBtnFind(self) end
	UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFind);

    self.callBack = function() self:_onDragScrollView() end;
    self._scrollView.onDragFinished = self.callBack;

    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_FIND, GuildEnemyPanel._UpdateFind, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_LIST, GuildEnemyPanel._UpdateList, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_ENEMY_CHG, GuildEnemyPanel._UpdateEnemyItem, self);
    
    UpdateBeat:Add(self.OnUpdate, self);
end

function GuildEnemyPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GuildEnemyPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildEnemyPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;

    UIUtil.GetComponent(self._btnFind, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFind = nil;
    self._scrollView.onDragFinished:Destroy();
    self.callBack = nil;

    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_FIND, GuildEnemyPanel._UpdateFind);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_LIST, GuildEnemyPanel._UpdateList);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_ENEMY_CHG, GuildEnemyPanel._UpdateEnemyItem);

    UpdateBeat:Remove(self.OnUpdate, self);
end

function GuildEnemyPanel:_Opened()
    self:UpdateDisplay();
end

function GuildEnemyPanel:UpdateDisplay()
    self.page = 1;
    self:_ReqList(self.page);   
end

function GuildEnemyPanel:_ReqList(page)
    if page == 1 then
        self.data = nil;
        self._scrollView:ResetPosition();
        GuildProxy.ReqEnemyList(page);
    else
        GuildProxy.ReqGuildList(page, true);           
    end
end

function GuildEnemyPanel:OnUpdate()
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateStatus();
    end
end

function GuildEnemyPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDENEMYPANEL);
end

function GuildEnemyPanel:_OnClickBtnFind()
    local fStr = self._input.value;
    if fStr == "" then
        self.page = 1;
        self:_ReqList(self.page);
    else
        GuildProxy.ReqFind(fStr);
    end
end

function GuildEnemyPanel:_onDragScrollView()
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
local insert = table.insert

function GuildEnemyPanel:_UpdateList(data)
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

    self._txtNum.text = LanguageMgr.Get("common/numMax", {num = GuildDataManager.enemyNum, max = GuildDataManager.enemyMax});
end

function GuildEnemyPanel:_UpdateFind(data)
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

function GuildEnemyPanel:_UpdateEnemyItem(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:SetStatus(data.id, data.t);
    end

    self._txtNum.text = LanguageMgr.Get("common/numMax", {num = GuildDataManager.enemyNum, max = GuildDataManager.enemyMax});
end

