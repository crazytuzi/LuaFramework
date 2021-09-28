require "Core.Module.Common.Panel";
require "Core.Module.Rank.View.RankPanelSimpleCtrl";
require "Core.Module.Rank.View.RankPanelGuildCtrl";
require "Core.Module.Rank.View.Item.RankClsItem";

RankPanel = Panel:New()
RankPanel.cls = {
    {id = 1, d = {10,11,14}},
    {id = 2, d = {21,20,22}},
    {id = 3, d = {40,41}},
    {id = 4, d = {30,31}},
    {id = 5, d = {13}}
}

function RankPanel:_Init()
	self:_InitReference();
	self:_InitListener();

    self:InitUI();
end

function RankPanel:_InitReference()
	
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    
    self._trsCls = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCls");
    self._clsTable = UIUtil.GetChildByName(self._trsCls, "UITable", "Table");

    self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
    self._trsSimple = UIUtil.GetChildByName(self._trsInfo, "Transform", "trsSimple");
    self._simpleCtrl = RankPanelSimpleCtrl.New();
    self._simpleCtrl:Init(self._trsSimple);

    self._trsGuild = UIUtil.GetChildByName(self._trsInfo, "Transform", "trsGuild");
    self._guildCtrl = RankPanelGuildCtrl.New();
    self._guildCtrl:Init(self._trsGuild);
    
    self._trsMyRank = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMyRank");
    
    self._type = nil;
    self._flag = 0;
    self._refreshNow = false;
end

function RankPanel:_InitListener()
	self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);

    MessageManager.AddListener(RankNotes, RankNotes.ENV_CLS_REFRESH, RankPanel._OnClsRefresh, self);
    MessageManager.AddListener(RankNotes, RankNotes.ENV_CLS_SELECT, RankPanel._OnClsSelect, self);

    UpdateBeat:Add(self.OnUpdate, self);
end

function RankPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function RankPanel:_DisposeListener()
    
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;

    MessageManager.RemoveListener(RankNotes, RankNotes.ENV_CLS_REFRESH, RankPanel._OnClsRefresh);
    MessageManager.RemoveListener(RankNotes, RankNotes.ENV_CLS_SELECT, RankPanel._OnClsSelect);

    UpdateBeat:Remove(self.OnUpdate, self);
end

function RankPanel:_DisposeReference()
    for k, v in pairs(self._clsList) do
        v:Dispose();
    end

    self._simpleCtrl:Dispose();
    self._guildCtrl:Dispose();
end

function RankPanel:UpdateType(t)
    self._DefaultType = t or RankConst.Type.FIGHT;
end

function RankPanel:_Opened()
    
    self:UpdateDisplay();
end

function RankPanel:InitUI()
    local tableTr = self._clsTable.transform;
    UIUtil.RemoveAllChildren(tableTr);
    self._clsList = {};
    for i,v in ipairs(RankPanel.cls) do
        local item = RankClsItem:New();
        local itemGo = UIUtil.GetUIGameObject(ResID.UI_RANKCLSITEM);
        itemGo.name = i;
        UIUtil.AddChild(tableTr, itemGo.transform);
        item:Init(itemGo, v);
        self._clsList[i] = item;
    end
end

function RankPanel:OnUpdate()
    if self._refreshNow then
        self._flag = self._flag + 1;
        --多刷一帧.防止异步删除gameobject的延迟
        if(self._flag > 1) then
            self._flag = 0;
            self._clsTable:Reposition();
            self._refreshNow = false;    
        end
    end
end

function RankPanel:UpdateDisplay()
    local clsId = math.floor(self._DefaultType / 10);
    local d = RankPanel.cls[clsId];
    self:_OnClsRefresh(d);
    self:_OnClsSelect(self._DefaultType);
end

function RankPanel:_OnClickBtnClose()
	ModuleManager.SendNotification(RankNotes.CLOSE_RANKPANEL);
end

function RankPanel:_OnClsRefresh(data)
    for k, v in pairs(self._clsList) do
        v:UpdateStatus(data);
    end
    self._refreshNow = true;
end
 
function RankPanel:_OnClsSelect(data)
    if self._type ~= data then
        for k, v in pairs(self._clsList) do
            v:UpdateSelected(data);
        end
        self:_OnSetInfo(data);
    end
end

function RankPanel:_OnSetInfo(id)
    if id == RankConst.Type.GUILD_FIGHT or id == RankConst.Type.GUILD_RANK then 
        self._simpleCtrl:Disable();
        self._guildCtrl:Setup(id);
        self._guildCtrl:Enable();
    else
        self._guildCtrl:Disable();
        self._simpleCtrl:Setup(id);
        self._simpleCtrl:Enable();
    end

end






