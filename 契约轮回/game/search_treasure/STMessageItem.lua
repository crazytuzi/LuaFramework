STMessageItem = STMessageItem or class("STMessageItem", BaseItem)
local STMessageItem = STMessageItem

function STMessageItem:ctor(parent_node, layer)
    self.abName = "search_treasure"
    self.assetName = "STMessageItem"
    self.layer = layer

    self.typeId = nil -- 寻宝类型

    --self.model = 2222222222222end:GetInstance()
    STMessageItem.super.Load(self)
end

function STMessageItem:dctor()
end

function STMessageItem:LoadCallBack()
    self.nodes = {
        "Text",
    }
    self:GetChildren(self.nodes)
    self.Text = GetText(self.Text)
    self:AddEvent()

    self:UpdateView()
end

function STMessageItem:AddEvent()
end

function STMessageItem:SetData(data, typeId)
    self.data = data
    self.typeId = typeId
    if self.is_loaded then
        self:UpdateView()
    end
end

function STMessageItem:UpdateView()
    local item = Config.db_item[self.data.item_id]

    local str
    local color = "FFFFF"
    if self.typeId == 1 then
        str = "Gear"
    elseif self.typeId == 2 then
        str = "Peak"
    elseif self.typeId == 3 then
		str="Mecha"
    elseif self.typeId == 4 then
        str="Ultimate"
    end

    local itemColor = ColorUtil.GetColor(item.color)

    self.Text.text = string.format(ConfigLanguage.SearchT.STMessage, self.data.name, color, str, itemColor, item.name, self.data.num)
end