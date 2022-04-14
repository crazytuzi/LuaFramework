-- @Author: lwj
-- @Date:   2019-03-02 15:20:36
-- @Last Modified time: 2019-03-02 15:20:38

CandyChatOtherItem = CandyChatOtherItem or class("CandyChatOtherItem", BaseChatItemSettor)
local CandyChatOtherItem = CandyChatOtherItem

--CandyChatOtherItem.__cache_count = 3
function CandyChatOtherItem:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyChatOtherItem"
    self.layer = layer

    CandyChatOtherItem.super.Load(self)

    --self.model = CandyChatModel.GetInstance()
end

function CandyChatOtherItem:LoadCallBack()
    self.nodes = {
        "Info/btn_give_gift",
    }
    self:GetChildren(self.nodes)
    CandyChatOtherItem.super.LoadCallBack(self)
end

function CandyChatOtherItem:AddEvent()
    local function callback()
        CandyModel.GetInstance().is_open_give_gift = true
        CandyModel.GetInstance().targetPlayerId = self.chatMsg.sender.id
        CandyModel.GetInstance().targetPlayerName = self.chatMsg.sender.name
        CandyModel.GetInstance():Brocast(CandyEvent.RequestReaminGiveCount)
    end
    AddButtonEvent(self.btn_give_gift.gameObject, callback)
    CandyChatOtherItem.super.AddEvent(self)
end

function CandyChatOtherItem:SetSaiZiItemSize()
    self.height = 200
    GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
end