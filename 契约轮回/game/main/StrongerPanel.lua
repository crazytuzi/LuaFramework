-- @Author: lwj
-- @Date:   2019-04-11 19:51:46
-- @Last Modified time: 2019-04-11 19:51:48

StrongerPanel = StrongerPanel or class("StrongerPanel", BasePanel)
local StrongerPanel = StrongerPanel

function StrongerPanel:ctor()
    self.abName = "main"
    self.assetName = "StrongerPanel"
    self.layer = "Top"

    self.model = MainModel.GetInstance()
    self.item_list = {}
end

function StrongerPanel:dctor()

end

function StrongerPanel:Open()
    StrongerPanel.super.Open(self)
end

function StrongerPanel:LoadCallBack()
    self.nodes = {
        "Btn_Scroll/Viewport/btn_content", "Btn_Scroll/Viewport/btn_content/StrongerItem",
        "mask",
    }
    self:GetChildren(self.nodes)
    self.item_Obj = self.StrongerItem.gameObject


    SetAlignType(self.gameObject.transform,bit.bor(AlignType.Right, AlignType.Null))
    self:AddEvent()

    self:InitPanel()
end

function StrongerPanel:AddEvent()
    self.close_event_id = GlobalEvent:AddListener(MainEvent.CloseStrongerPanel, handler(self, self.Close))
    AddClickEvent(self.mask.gameObject, handler(self, self.Close))
end

function StrongerPanel:OpenCallBack()
end

function StrongerPanel:InitPanel()
    local list = self.model:GetStrongList()
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = StrongerItem(self.item_Obj, self.btn_content)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = {}
        data.id = list[i]
        data.cf_data = Config.db_stronger[list[i]]
        item:SetData(data)
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function StrongerPanel:CloseCallBack()
    if self.close_event_id then
        GlobalEvent:RemoveListener(self.close_event_id)
        self.close_event_id = nil
    end
    for i, v in pairs(self.item_list) do
        if v then
            v:destroy()
        end
    end
    self.item_list = {}
end

