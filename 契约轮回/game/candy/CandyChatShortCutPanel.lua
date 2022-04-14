-- @Author: lwj
-- @Date:   2019-03-05 11:30:31
-- @Last Modified time: 2019-03-05 11:30:34

CandyChatShortCutPanel = CandyChatShortCutPanel or class("CandyChatShortCutPanel", BasePanel)
local CandyChatShortCutPanel = CandyChatShortCutPanel

function CandyChatShortCutPanel:ctor()
    self.abName = "candy"
    self.assetName = "CandyChatShortCutPanel"
    self.layer = "UI"

    self.model = CandyModel.GetInstance()
end

function CandyChatShortCutPanel:dctor()
end

function CandyChatShortCutPanel:Open()
    BasePanel.Open(self)
end

function CandyChatShortCutPanel:LoadCallBack()
    self.nodes = {
        "mask", "emojiView/EmojiScrollView/Viewport/emojiContent", "emojiView/EmojiScrollView/Viewport/emojiContent/CandyShortCutItem",
    }
    self:GetChildren(self.nodes)
    --self.item_gameObject = self.CandyShortCutItem.gameObject

    self:AddEvent()

    self:UpdateView()
end

function CandyChatShortCutPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    local function callback()
        self:Close()
    end
    AddClickEvent(self.mask.gameObject, callback)
end

function CandyChatShortCutPanel:OpenCallBack()
end

function CandyChatShortCutPanel:UpdateView()
    local text_tbl = string.split(HelpConfig.Candy.ShortCutLanguage, '\n')
    local len = #text_tbl
    self.item_list = self.item_list or {}
    for i = 1, len do
        local data = {}
        data.des = text_tbl[i]
        if data.des ~= "" then
            local item = CandyShortCutItem(self.emojiContent, "UI")
            data.index = i
            item:SetData(data)
            self.item_list[#self.item_list + 1] = item
        end
    end
end

function CandyChatShortCutPanel:CloseCallBack()
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    for i = 1, #self.item_list do
        if self.item_list[i] then
            self.item_list[i]:destroy()
        end
    end
    self.item_list = {}
end

