-- @Author: lwj
-- @Date:   2019-06-04 14:47:29
-- @Last Modified time: 2019-06-04 14:47:31

GMHistroyPanel = GMHistroyPanel or class("GMHistroyPanel", BasePanel)
local GMHistroyPanel = GMHistroyPanel

function GMHistroyPanel:ctor()
    self.abName = "system"
    self.assetName = "GMHistroyPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true
    self.click_bg_close = true

    self.model = GMModel:GetInstance()
end

function GMHistroyPanel:dctor()

end

function GMHistroyPanel:Open()
    GMHistroyPanel.super.Open(self)
end

function GMHistroyPanel:LoadCallBack()
    self.nodes = {
        "scroll/Viewport/con", "scroll/Viewport/con/HistroyItem",
    }
    self:GetChildren(self.nodes)
    self.histroy_obj = self.HistroyItem.gameObject

    SetColor(self.background_img, 0, 0, 0, 0)

    self:AddEvent()
end

function GMHistroyPanel:AddEvent()
    self.close_event_id = GlobalEvent:AddListener(MainEvent.UpdateGMPanelInput, handler(self, self.Close))
end

function GMHistroyPanel:OpenCallBack()
    self:UpdateView()
end

function GMHistroyPanel:UpdateView()
    local list = self.model:GetHistroyList()
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = HistroyItem(self.histroy_obj, self.con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function GMHistroyPanel:CloseCallBack()
    if self.item_list then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end

    if self.close_event_id then
        GlobalEvent:RemoveListener(self.close_event_id)
        self.close_event_id = nil
    end
end