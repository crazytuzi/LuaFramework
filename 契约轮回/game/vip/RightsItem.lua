-- @Author: lwj
-- @Date:   2018-12-08 10:50:28
-- @Last Modified time: 2018-12-08 10:50:51

RightsItem = RightsItem or class("RightsItem", BaseItem)
local RightsItem = RightsItem

function RightsItem:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "RightsItem"
    self.layer = layer

    --self.model = VipModel:GetInstance()
    BaseItem.Load(self)
end

function RightsItem:dctor()
end

function RightsItem:LoadCallBack()
    self.nodes = {
        "icon", "Text", "titleText",
    }
    self:GetChildren(self.nodes)
    self.textT = self.Text:GetComponent('Text')
    self.iconI = self.icon:GetComponent('Image')
    self.titleT = self.titleText:GetComponent('Text')
    self:AddEvent()
    self:UpdateView()
end

function RightsItem:AddEvent()
end

function RightsItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function RightsItem:UpdateView()
    self.textT.text = self.data.des
    self.titleT.text = self.data.titleDes
    lua_resMgr:SetImageTexture(self, self.iconI, "iconasset/icon_vip", tostring(self.data.icon), false, nil, false)
end