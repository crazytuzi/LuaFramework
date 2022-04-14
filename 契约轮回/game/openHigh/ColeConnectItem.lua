-- @Author: lwj
-- @Date:   2019-08-10 11:04:56
-- @Last Modified time: 2019-08-10 11:05:02

ColeConnectItem = ColeConnectItem or class("ColeConnectItem", BaseCloneItem)
local ColeConnectItem = ColeConnectItem

function ColeConnectItem:ctor(parent_node, layer)
    ColeConnectItem.super.Load(self)
end

function ColeConnectItem:dctor()
end

function ColeConnectItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "symbol",
    }
    self:GetChildren(self.nodes)
    self.symbol = GetImage(self.symbol)

    self:AddEvent()
end

function ColeConnectItem:AddEvent()

end

function ColeConnectItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function ColeConnectItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.symbol, "openHigh_image", "cole_symbol_" .. self.data, false, nil, false)
    SetVisible(self.symbol,true)
end