-- @Author: lwj
-- @Date:   2018-12-26 16:20:05
-- @Last Modified time: 2018-12-26 16:20:08

FashionPanelProItem = FashionPanelProItem or class("FashionPanelProItem", BaseItem)
local FashionPanelProItem = FashionPanelProItem

function FashionPanelProItem:ctor(parent_node, layer)
    self.abName = "fashion"
    self.assetName = "FashionPanelProItem"
    self.layer = layer

    BaseItem.Load(self)
end

function FashionPanelProItem:dctor()

end

function FashionPanelProItem:LoadCallBack()
    self.nodes = {
        "n_value", "n_cur", "n_title", "flag1",
    }
    self:GetChildren(self.nodes)
    --self.sel_img = self.select:GetComponent('Image')
    self.value = self.n_value:GetComponent('Text')
    self.title = self.n_title:GetComponent('Text')
    self.cur = self.n_cur:GetComponent('Text')
    self:AddEvent()
    self:UpdateView()
end

function FashionPanelProItem:AddEvent()
end

function FashionPanelProItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function FashionPanelProItem:UpdateView()
    self.title.text = self.data.titleStr .. "："
    if self.data.isMax then
        SetVisible(self.flag1, false)
        SetColor(self.value, 119, 78, 59, 255)
        SetVisible(self.value, false)
        self.cur.text = self.data.curStr
        SetVisible(self.cur, true)
    else
        if self.data.isHideCur then
            SetVisible(self.cur, true)
            SetVisible(self.value, false)
            self.cur.text = self.data.upValue
            SetVisible(self.flag1, false)
        else
            self.cur.text = self.data.curStr
            SetVisible(self.cur, true)
            SetVisible(self.flag1, true)
            SetVisible(self.value, true)
            SetColor(self.value, 24, 193, 20, 255)
            self.value.text = self.data.upValue
        end
    end
end
