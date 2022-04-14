-- @Author: lwj
-- @Date:   2019-12-07 15:19:04 
-- @Last Modified time: 2019-12-07 15:19:09

RechargeDialItem = RechargeDialItem or class("RechargeDialItem", BaseCloneItem)
local RechargeDialItem = RechargeDialItem

function RechargeDialItem:ctor(parent_node, layer)
    RechargeDialItem.super.Load(self)
end

function RechargeDialItem:dctor()
end

function RechargeDialItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "icon", "des", "btn_go", "tag",
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self.des_img = GetImage(self.des)

    self:AddEvent()
end

function RechargeDialItem:AddEvent()
    local function callback()
        if not self.link_tbl then
            return
        end
        OpenLink(unpack(self.link_tbl))
    end
    AddButtonEvent(self.btn_go.gameObject, callback)
end

function RechargeDialItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function RechargeDialItem:UpdateView()
    self.link_tbl = self.data[1][2]
    local icon_str = self.data[4][2]
    self.icon_tbl = string.split(icon_str, ':')
    lua_resMgr:SetImageTexture(self, self.icon, self.icon_tbl[1], self.icon_tbl[2], false, nil, false)

    local des_res = self.data[2][2]
    lua_resMgr:SetImageTexture(self, self.des_img, "iconasset/icon_dial", "recharge_" .. des_res, false, nil, false)

    local is_double = self.data[3][2] == 1
    SetVisible(self.tag, is_double)
end