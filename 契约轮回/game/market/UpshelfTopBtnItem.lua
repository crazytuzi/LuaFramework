UpshelfTopBtnItem = UpshelfTopBtnItem or class("UpshelfTopBtnItem",BaseCloneItem)
local UpshelfTopBtnItem = UpshelfTopBtnItem

function UpshelfTopBtnItem:ctor(obj,parent_node,layer)
    UpshelfTopBtnItem.super.Load(self)
end

function UpshelfTopBtnItem:dctor()

end


function UpshelfTopBtnItem:LoadCallBack()
    self.nodes =
    {
        "btnText1",
        "btnSelect1",
    }
    self:GetChildren(self.nodes)
    self.btnText = GetText(self.btnText1)
    self.btn = GetButton(self)
    self:AddEvent()
    --print2(self.btnSelect1)
end

function UpshelfTopBtnItem:AddEvent()
    local call_back = function(target, x, y)
        if self.isMore == false then
            GlobalEvent:Brocast(MarketEvent.UpShelfMarketPageBtn, self.data.type)
        else
            GlobalEvent:Brocast(MarketEvent.UpShelfMarketPageMoreBtn, self.data)
        end

    end
    AddClickEvent(self.btn.gameObject,call_back)
end

function UpshelfTopBtnItem:SetData(data , isMore)
    self.isMore = isMore
    self.data = data
    self.btnText.text = self.data.name
end

function UpshelfTopBtnItem:Select(show)
    if self.isMore then
        SetSizeDeltaX(self.btnSelect1,95)
    end
    SetVisible(self.btnSelect1,show)
end


