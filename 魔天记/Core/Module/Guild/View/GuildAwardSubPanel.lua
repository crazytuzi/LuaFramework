require "Core.Module.Common.UISubPanel";
require "Core.Module.Guild.View.Item.GuildAwardListItem";

GuildAwardSubPanel = class("GuildAwardSubPanel", UISubPanel);
local _sortfunc = table.sort 

function GuildAwardSubPanel:_InitReference()
    
    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildAwardListItem);
    
end

function GuildAwardSubPanel:_DisposeReference()
    self._phalanx:Dispose();
end

function GuildAwardSubPanel:_InitListener()
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, GuildAwardSubPanel.UpdateRedPoint, self);
    --MessageManager.AddListener(GuildNotes, GuildNotes.RSP_AWARD_INFO, GuildAwardSubPanel.OnRspInfo, self);
    MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildAwardSubPanel.UpdateRedPoint, self);
end

function GuildAwardSubPanel:_DisposeListener()
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_UPDATE_AWARD_REDPOINT, GuildAwardSubPanel.UpdateRedPoint);
    --MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_AWARD_INFO, GuildAwardSubPanel.OnRspInfo);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_MONEYCHANGE, GuildAwardSubPanel.UpdateRedPoint);
end

function GuildAwardSubPanel:_OnEnable()
    --GuildProxy.ReqAwardInfo();
    self:UpdateDisplay();
end

function GuildAwardSubPanel:_Refresh()
    --GuildProxy.ReqAwardInfo();
    self:UpdateRedPoint();
end

function GuildAwardSubPanel:UpdateDisplay()
    --local date = os.time({year=2016, month=8, day=16, hour=19, min=20, sec=2});
    local date = os.time();
    local list = GuildDataManager.GetExtends(2);

    _sortfunc(list, function(a,b) 
        return a.sort < b.sort;
    end);

    local count = #list;
    self._phalanx:Build(count, 1, list);
end

--更新红点
function GuildAwardSubPanel:UpdateRedPoint(data)
    local items = self._phalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateRedPoint();
    end
end


function GuildAwardSubPanel:OnRspInfo()
    self:UpdateRedPoint();
end