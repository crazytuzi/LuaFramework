-- @Author: lwj
-- @Date:   2019-09-21 14:19:39
-- @Last Modified time: 2019-09-21 14:19:45

NationAchiItem = NationAchiItem or class("NationAchiItem", BaseCloneItem)
local NationAchiItem = NationAchiItem

function NationAchiItem:ctor(parent_node, layer)
    self.count_x = 19.11
    self.count_y = 0
    self.icon_y = -21
    self.count_scale = 1

    NationAchiItem.super.Load(self)
end

function NationAchiItem:dctor()
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
end

function NationAchiItem:LoadCallBack()

    self.nodes = {
        "icon", "count", "Sundries/title_bg", "rewa_con", "rewa_con/NationSeqRewaItem", "des",
    }
    self:GetChildren(self.nodes)
    self.rewa_obj = self.NationSeqRewaItem.gameObject
    self.count = GetText(self.count)
    self.title_bg = GetImage(self.title_bg)
    self.des = GetText(self.des)
    self.count_rect = GetRectTransform(self.count)
    self.icon_rect = GetRectTransform(self.icon)

    self:AddEvent()
end

function NationAchiItem:AddEvent()

end

function NationAchiItem:SetData(data, stencil_id, stencil_type, model)
    self.stencil_id = stencil_id
    self.data = data
    self.stencil_type = stencil_type
    self.model = model or NationModel.GetInstance()

    self:UpdateView()
end

function NationAchiItem:UpdateView()
    local img_idx = self.data.idx % 3
    lua_resMgr:SetImageTexture(self, self.title_bg, "nation_image", "recharge_item_bg_" .. img_idx, true, nil, false)
    --dump(self.data, "<color=#6ce19b>NationAchiItem   NationAchiItem  NationAchiItem  NationAchiItem</color>")
    self.count.text = self.data[1].grade
    self:LoadRewaItem()
    SetAnchoredPosition(self.count_rect, self.count_x, self.count_y)
    local count_width = self.count.preferredWidth * self.count_scale
    local icon_x = self.count_x + count_width - 4
    SetAnchoredPosition(self.icon_rect, icon_x, self.icon_y)
    local third_item_data = self.model:GetSingleTaskInfo(self.data[3].act_id, self.data[3].id)
    self.des.text = string.format(ConfigLanguage.Nation.RechargeDayShow, third_item_data.count)
end

function NationAchiItem:LoadRewaItem()
    local list = self.data
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = NationSeqRewaItem(self.rewa_obj, self.rewa_con, self.model)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.stencil_id, self.stencil_type)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end