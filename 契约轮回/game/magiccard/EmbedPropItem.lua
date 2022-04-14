EmbedPropItem = EmbedPropItem or class("EmbedPropItem",BaseItem)
local EmbedPropItem = EmbedPropItem

function EmbedPropItem:ctor(parent_node,layer)
    self.abName = "magiccard"
    self.assetName = "EmbedPropItem"
    self.layer = layer

    EmbedPropItem.super.Load(self)
end

function EmbedPropItem:dctor()

end

function EmbedPropItem:LoadCallBack()
    self.nodes = {
        "prop_label_1", "prop_value_1",
    }
    self:GetChildren(self.nodes)
    self.prop_label_1 = GetText(self.prop_label_1);
    self.prop_value_1 = GetText(self.prop_value_1);
    self:AddEvent()
    self:UpdateView()
end

function EmbedPropItem:AddEvent()
end

function EmbedPropItem:SetData(str1, str2)
    self.str1 = str1
    self.str2 = str2
    if self.is_loaded then
        self:UpdateView()
    end
end

function EmbedPropItem:UpdateView()
    self.prop_label_1.text = self.str1;
    self.prop_value_1.text = self.str2;
end