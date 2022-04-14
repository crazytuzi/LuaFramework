MarketRecordPanel = MarketRecordPanel or class("MarketRecordPanel", BaseItem)
local MarketRecordPanel = MarketRecordPanel

function MarketRecordPanel:ctor(parent_node, layer)
    self.abName = "market";
    self.assetName = "MarketRecordPanel"
    self.layer = "UI"

    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()
    self.Events = {} --事件

    self.items = {}
    MarketRecordPanel.super.Load(self);
end

function MarketRecordPanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)

    for i, v in pairs(self.items) do
        v:destroy()
    end

end
function MarketRecordPanel:Open()
    WindowPanel.Open(self)
end


function MarketRecordPanel:LoadCallBack()
    self.nodes =
    {
        "MarketRecordItem",
        "itemScrollView/Viewport/itemContent",
        "NoRecord"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self:InitUI()
    self:AddEvent()
    MarketController:GetInstance():RequeseLogInfo()
end

function MarketRecordPanel:InitUI()

end
function MarketRecordPanel:AddEvent()
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.MarketRecordUpdateRecord, handler(self, self.UpdateRecord))
end

function MarketRecordPanel:UpdateRecord(data)
    if data.logs  == nil or data.logs  == {} or #data.logs  == 0 then
        SetVisible(self.NoRecord,true)
    else
        for i = 1, #data.logs do
            self.items[i] = MarketRecordItem(self.MarketRecordItem.gameObject,self.itemContent,"UI")
            self.items[i]:SetData(data.logs[i])
        end
    end


end
