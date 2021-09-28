require "Core.Module.Common.UISubPanel";
require "Core.Module.Rank.View.Item.RankListGuildItem"
RankPanelGuildCtrl = class("RankPanelGuildCtrl", UISubPanel);
RankPanelGuildCtrl.MaxPage = 20;

function RankPanelGuildCtrl:_InitReference()
    
    self._trsTitle = UIUtil.GetChildByName(self._transform, "Transform", "trsTitle");
    self._txtTitle4 = UIUtil.GetChildByName(self._trsTitle, "UILabel", "txtTitle4");

    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, RankListGuildItem);
    
    self._trsMyRank = UIUtil.GetChildByName(self._transform, "Transform", "trsMyRank");
    self._myRank = RankListGuildItem:New();
    self._myRank:Init(self._trsMyRank);

    self.callBack = function() self:_onDragScrollView() end;
    self._scrollView.onDragFinished = self.callBack;

    self._type = nil;
end

function RankPanelGuildCtrl:_DisposeReference()
    self._phalanx:Dispose();
    self._myRank:Dispose();

    self._scrollView.onDragFinished:Destroy();
    self.callBack = nil;
end

function RankPanelGuildCtrl:_InitListener()
    MessageManager.AddListener(RankNotes, RankNotes.RSP_LIST, RankPanelGuildCtrl._OnList, self);
end

function RankPanelGuildCtrl:_DisposeListener()
    MessageManager.RemoveListener(RankNotes, RankNotes.RSP_LIST, RankPanelGuildCtrl._OnList);
end

function RankPanelGuildCtrl:_OnEnable()
    self._selectId = nil;
    self._scrollView:ResetPosition();
    RankProxy.ReqList(self._type, self._page);
end

function RankPanelGuildCtrl:_OnDisable()
    
end

function RankPanelGuildCtrl:_onDragScrollView()
    local offset = 0;
    local b = self._scrollView.bounds;
    local c = self._scrollPanel:CalculateConstrainOffset(b:GetMin(), b:GetMin());
    offset = c.y;

    if math.abs(offset) <= 1 then
        local tmpPage = self._page + 1;
        if tmpPage > RankPanelGuildCtrl.MaxPage then
            return;
        end
        RankProxy.ReqList(self._type, tmpPage);
    end
end

function RankPanelGuildCtrl:Setup(type)
    if self._type ~= type then
        self._type = type;
        self:UpdateType();
    end
    self._page = 1;
    self._list = nil;
    self._myRank:UpdateItem(nil);
end

function RankPanelGuildCtrl:UpdateType()
    self._txtTitle4.text= LanguageMgr.Get("rank/title4/" .. self._type);
end

function RankPanelGuildCtrl:_OnList(data)
    if self._type == data.t then 
        self._page = data.p;

        local list = data.list;
        if self._list == nil then
            self._list = list;
        else
            for i, v in ipairs(list) do
                table.insert(self._list, v)
            end
        end
        
        local count = #self._list;
        self._phalanx:Build(count, 1, self._list);

        self._myRank:UpdateItem(data.my);
        --[[
        if self._selectId == nil and count > 0 then
            self:_OnSelectItem(self._list[1]);
        end
        ]]
    end

end

--[[
--选择列表项
function RankPanelGuildCtrl:_OnSelectItem(data)
    self._selectId = data.id;
    self._selectData = data;
    local items = self._phalanx:GetItems();
    for k, v in pairs(items) do
        v.itemLogic:UpdateSelected(data);
    end
end
]]